import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/church.dart';
import '../../domain/entities/livestream.dart';
import 'church_repository.dart';
import 'livestream_repository.dart';

/// Repository for handling local favorites using SharedPreferences
/// Since the app doesn't use authentication, favorites are stored locally
class FavoritesRepository {
  final Logger _logger = GetIt.instance<Logger>();

  static const String _favoriteChurchesKey = 'favorite_churches';
  static const String _favoriteLivestreamsKey = 'favorite_livestreams';

  /// Get favorite church IDs
  Future<List<String>> getFavoriteChurchIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteChurchesJson = prefs.getString(_favoriteChurchesKey);

      if (favoriteChurchesJson == null) return [];

      final List<dynamic> favoritesList = json.decode(favoriteChurchesJson);
      return favoritesList.cast<String>();
    } catch (e) {
      _logger.e('Error getting favorite church IDs: $e');
      return [];
    }
  }

  /// Get favorite livestream IDs
  Future<List<String>> getFavoriteLivestreamIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteLivestreamsJson = prefs.getString(_favoriteLivestreamsKey);

      if (favoriteLivestreamsJson == null) return [];

      final List<dynamic> favoritesList = json.decode(favoriteLivestreamsJson);
      return favoritesList.cast<String>();
    } catch (e) {
      _logger.e('Error getting favorite livestream IDs: $e');
      return [];
    }
  }

  /// Check if a church is favorited
  Future<bool> isChurchFavorited(String churchId) async {
    final favoriteIds = await getFavoriteChurchIds();
    return favoriteIds.contains(churchId);
  }

  /// Check if a livestream is favorited
  Future<bool> isLivestreamFavorited(String livestreamId) async {
    final favoriteIds = await getFavoriteLivestreamIds();
    return favoriteIds.contains(livestreamId);
  }

  /// Add church to favorites
  Future<void> addChurchToFavorites(String churchId) async {
    try {
      final favoriteIds = await getFavoriteChurchIds();

      if (!favoriteIds.contains(churchId)) {
        favoriteIds.add(churchId);
        await _saveFavoriteChurches(favoriteIds);
        _logger.i('Added church $churchId to favorites');
      }
    } catch (e) {
      _logger.e('Error adding church to favorites: $e');
      rethrow;
    }
  }

  /// Remove church from favorites
  Future<void> removeChurchFromFavorites(String churchId) async {
    try {
      final favoriteIds = await getFavoriteChurchIds();

      if (favoriteIds.remove(churchId)) {
        await _saveFavoriteChurches(favoriteIds);
        _logger.i('Removed church $churchId from favorites');
      }
    } catch (e) {
      _logger.e('Error removing church from favorites: $e');
      rethrow;
    }
  }

  /// Add livestream to favorites
  Future<void> addLivestreamToFavorites(String livestreamId) async {
    try {
      final favoriteIds = await getFavoriteLivestreamIds();

      if (!favoriteIds.contains(livestreamId)) {
        favoriteIds.add(livestreamId);
        await _saveFavoriteLivestreams(favoriteIds);
        _logger.i('Added livestream $livestreamId to favorites');
      }
    } catch (e) {
      _logger.e('Error adding livestream to favorites: $e');
      rethrow;
    }
  }

  /// Remove livestream from favorites
  Future<void> removeLivestreamFromFavorites(String livestreamId) async {
    try {
      final favoriteIds = await getFavoriteLivestreamIds();

      if (favoriteIds.remove(livestreamId)) {
        await _saveFavoriteLivestreams(favoriteIds);
        _logger.i('Removed livestream $livestreamId from favorites');
      }
    } catch (e) {
      _logger.e('Error removing livestream from favorites: $e');
      rethrow;
    }
  }

  /// Toggle church favorite status
  Future<bool> toggleChurchFavorite(String churchId) async {
    final isFavorited = await isChurchFavorited(churchId);

    if (isFavorited) {
      await removeChurchFromFavorites(churchId);
      return false;
    } else {
      await addChurchToFavorites(churchId);
      return true;
    }
  }

  /// Toggle livestream favorite status
  Future<bool> toggleLivestreamFavorite(String livestreamId) async {
    final isFavorited = await isLivestreamFavorited(livestreamId);

    if (isFavorited) {
      await removeLivestreamFromFavorites(livestreamId);
      return false;
    } else {
      await addLivestreamToFavorites(livestreamId);
      return true;
    }
  }

  /// Get favorite churches with full data
  Future<List<Church>> getFavoriteChurches() async {
    try {
      final favoriteIds = await getFavoriteChurchIds();

      if (favoriteIds.isEmpty) return [];

      // Get church repository to fetch full church data
      final churchRepository = GetIt.instance<ChurchRepository>();
      final List<Church> favoriteChurches = [];

      // Fetch each favorite church individually
      // Note: This could be optimized with a batch query if the repository supported it
      for (final churchId in favoriteIds) {
        try {
          final churches = await churchRepository.getChurches();
          final church = churches.firstWhere(
            (c) => c.id == churchId,
            orElse: () => throw Exception('Church not found'),
          );
          favoriteChurches.add(church);
        } catch (e) {
          _logger.w('Could not find church $churchId, removing from favorites');
          await removeChurchFromFavorites(churchId);
        }
      }

      return favoriteChurches;
    } catch (e) {
      _logger.e('Error getting favorite churches: $e');
      return [];
    }
  }

  /// Get favorite livestreams with full data
  Future<List<Livestream>> getFavoriteLivestreams() async {
    try {
      final favoriteIds = await getFavoriteLivestreamIds();

      if (favoriteIds.isEmpty) return [];

      // Get livestream repository to fetch full livestream data
      final livestreamRepository = GetIt.instance<LivestreamRepository>();
      final List<Livestream> favoriteLivestreams = [];

      // Fetch each favorite livestream individually
      for (final livestreamId in favoriteIds) {
        try {
          final livestream = await livestreamRepository.getStreamById(
            livestreamId,
          );
          if (livestream != null) {
            favoriteLivestreams.add(livestream);
          } else {
            _logger.w(
              'Could not find livestream $livestreamId, removing from favorites',
            );
            await removeLivestreamFromFavorites(livestreamId);
          }
        } catch (e) {
          _logger.w('Error fetching favorite livestream $livestreamId: $e');
          await removeLivestreamFromFavorites(livestreamId);
        }
      }

      return favoriteLivestreams;
    } catch (e) {
      _logger.e('Error getting favorite livestreams: $e');
      return [];
    }
  }

  /// Clear all favorites
  Future<void> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoriteChurchesKey);
      await prefs.remove(_favoriteLivestreamsKey);
      _logger.i('Cleared all favorites');
    } catch (e) {
      _logger.e('Error clearing favorites: $e');
      rethrow;
    }
  }

  /// Private helper to save favorite churches
  Future<void> _saveFavoriteChurches(List<String> favoriteIds) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = json.encode(favoriteIds);
    await prefs.setString(_favoriteChurchesKey, favoritesJson);
  }

  /// Private helper to save favorite livestreams
  Future<void> _saveFavoriteLivestreams(List<String> favoriteIds) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = json.encode(favoriteIds);
    await prefs.setString(_favoriteLivestreamsKey, favoritesJson);
  }
}
