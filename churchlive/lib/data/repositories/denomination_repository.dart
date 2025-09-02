import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../core/network/supabase_client.dart';
import '../../domain/entities/common.dart';
import '../models/common_models.dart';

/// Repository for handling denomination data operations
class DenominationRepository {
  final SupabaseService _supabaseService = GetIt.instance<SupabaseService>();
  final Logger _logger = GetIt.instance<Logger>();

  /// Fetch top denominations by click count
  Future<List<Denomination>> getTopDenominations({int limit = 4}) async {
    try {
      _logger.i('Fetching top $limit denominations by click count');

      final response = await _supabaseService.database
          .from('denominations')
          .select('*')
          .order('click_count', ascending: false)
          .limit(limit);

      final List<Denomination> denominations = (response as List)
          .map((json) => DenominationModel.fromJson(json).toEntity())
          .toList();

      _logger.i(
        'Successfully fetched ${denominations.length} top denominations',
      );
      return denominations;
    } catch (e, stackTrace) {
      _logger.e(
        'Error fetching top denominations',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Search denominations by name
  Future<List<Denomination>> searchDenominations(String query) async {
    try {
      _logger.i('Searching denominations with query: $query');

      final response = await _supabaseService.database
          .from('denominations')
          .select('*')
          .ilike('name', '%$query%')
          .order('click_count', ascending: false);

      final List<Denomination> denominations = (response as List)
          .map((json) => DenominationModel.fromJson(json).toEntity())
          .toList();

      _logger.i('Found ${denominations.length} denominations matching query');
      return denominations;
    } catch (e, stackTrace) {
      _logger.e(
        'Error searching denominations',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Fetch all denominations
  Future<List<Denomination>> getAllDenominations() async {
    try {
      _logger.i('Fetching all denominations');

      final response = await _supabaseService.database
          .from('denominations')
          .select('*')
          .order('click_count', ascending: false);

      final List<Denomination> denominations = (response as List)
          .map((json) => DenominationModel.fromJson(json).toEntity())
          .toList();

      _logger.i('Successfully fetched ${denominations.length} denominations');
      return denominations;
    } catch (e, stackTrace) {
      _logger.e(
        'Error fetching all denominations',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Increment click count for a denomination
  Future<void> incrementClickCount(String denominationId) async {
    try {
      _logger.i('Incrementing click count for denomination: $denominationId');

      await _supabaseService.database
          .from('denominations')
          .update({'click_count': 'click_count + 1'})
          .eq('id', denominationId);

      _logger.i('Successfully incremented click count');
    } catch (e, stackTrace) {
      _logger.e(
        'Error incrementing click count',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't rethrow - click tracking failure shouldn't break user flow
    }
  }

  /// Get denomination by name (for mapping from string ID)
  Future<Denomination?> getDenominationByName(String name) async {
    try {
      _logger.i('Fetching denomination by name: $name');

      final response = await _supabaseService.database
          .from('denominations')
          .select('*')
          .eq('name', name)
          .single();

      final denomination = DenominationModel.fromJson(response).toEntity();
      _logger.i('Successfully fetched denomination: ${denomination.name}');
      return denomination;
    } catch (e, stackTrace) {
      _logger.e(
        'Error fetching denomination by name',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
