import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

import '../models/previous_stream_model.dart';
import '../../domain/entities/previous_stream.dart';

class YouTubeRepository {
  final _logger = GetIt.instance.get<Logger>();

  // YouTube Data API v3 key - This should be stored in environment variables
  static const String _apiKey = 'AIzaSyBsWwLDXNxmIworentyLitsjIKnHR8kuAI';
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  /// Gets previous live streams from a church's YouTube channel
  Future<List<PreviousStream>> getChannelPreviousStreams(
    String churchId,
    String channelId, {
    int maxResults = 20,
    DateTime? publishedAfter,
  }) async {
    try {
      _logger.i(
        'Fetching previous live streams for church: $churchId, channel: $channelId',
      );

      // Step 1: Search specifically for completed live streams
      final searchUrl = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {
          'part': 'snippet',
          'channelId': channelId,
          'type': 'video',
          'eventType': 'completed', // Only get completed live streams
          'order': 'date',
          'maxResults': maxResults.toString(),
          'key': _apiKey,
          if (publishedAfter != null)
            'publishedAfter': publishedAfter.toIso8601String(),
        },
      );

      final searchResponse = await http.get(searchUrl);

      if (searchResponse.statusCode != 200) {
        _logger.e(
          'YouTube Search API error: ${searchResponse.statusCode} - ${searchResponse.body}',
        );
        throw Exception('Failed to fetch videos from YouTube');
      }

      final searchData = json.decode(searchResponse.body);
      final videos = searchData['items'] as List<dynamic>;

      if (videos.isEmpty) {
        _logger.i('No videos found for channel: $channelId');
        return [];
      }

      // Step 2: Get detailed video information
      final videoIds = videos
          .map((video) => video['id']['videoId'] as String)
          .toList();
      final videoDetails = await _getVideoDetails(videoIds);

      // Step 3: Convert to PreviousStream objects (no need to filter since eventType=completed)
      final previousStreams = <PreviousStream>[];

      for (int i = 0; i < videos.length; i++) {
        final video = videos[i];
        final videoId = video['id']['videoId'];
        final details = videoDetails[videoId];

        if (details != null) {
          try {
            final stream = PreviousStreamModel.fromYouTubeApi(
              churchId: churchId,
              videoData: video,
              videoDetails: details,
            );
            previousStreams.add(stream);
          } catch (e) {
            _logger.w('Failed to parse video $videoId: $e');
          }
        }
      }

      _logger.i(
        'Found ${previousStreams.length} previous streams for church: $churchId',
      );
      return previousStreams;
    } catch (e) {
      _logger.e('Error fetching previous streams: $e');
      throw Exception('Failed to load previous streams');
    }
  }

  /// Gets detailed information for multiple videos
  Future<Map<String, Map<String, dynamic>>> _getVideoDetails(
    List<String> videoIds,
  ) async {
    if (videoIds.isEmpty) return {};

    final url = Uri.parse('$_baseUrl/videos').replace(
      queryParameters: {
        'part': 'snippet,contentDetails,statistics,liveStreamingDetails',
        'id': videoIds.join(','),
        'key': _apiKey,
      },
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      _logger.e(
        'YouTube Videos API error: ${response.statusCode} - ${response.body}',
      );
      throw Exception('Failed to fetch video details from YouTube');
    }

    final data = json.decode(response.body);
    final videos = data['items'] as List<dynamic>;

    final result = <String, Map<String, dynamic>>{};
    for (final video in videos) {
      result[video['id']] = video;
    }

    return result;
  }

  /// Extracts YouTube channel ID from various URL formats
  String? extractChannelIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);

      // Direct channel ID format: youtube.com/channel/UCxxxxx
      if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'channel') {
        return uri.pathSegments[1];
      }

      // Custom channel URL format: youtube.com/c/customname or youtube.com/@username
      if (uri.pathSegments.isNotEmpty &&
          (uri.pathSegments[0] == 'c' || uri.pathSegments[0].startsWith('@'))) {
        // For custom URLs, we'd need to make an API call to resolve to channel ID
        // This is a simplified version - in production, you'd want to implement this
        _logger.w(
          'Custom YouTube URL detected, manual channel ID required: $url',
        );
        return null;
      }

      return null;
    } catch (e) {
      _logger.e('Error parsing YouTube URL: $url - $e');
      return null;
    }
  }

  /// Resolves custom YouTube URL to channel ID using the YouTube API
  Future<String?> resolveChannelId(String customUrl) async {
    try {
      // This would use the YouTube API to resolve custom URLs to channel IDs
      // For now, returning null - this can be implemented later if needed
      _logger.i('Resolving custom YouTube URL: $customUrl');
      return null;
    } catch (e) {
      _logger.e('Error resolving YouTube channel ID: $e');
      return null;
    }
  }

  /// Gets currently live streams from a church's YouTube channel
  Future<List<PreviousStream>> getChannelLiveStreams(
    String churchId,
    String channelId, {
    int maxResults = 5,
  }) async {
    try {
      _logger.i(
        'Fetching current live streams for church: $churchId, channel: $channelId',
      );

      // Search specifically for live streams
      final searchUrl = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {
          'part': 'snippet',
          'channelId': channelId,
          'type': 'video',
          'eventType': 'live', // Only get currently live streams
          'order': 'date',
          'maxResults': maxResults.toString(),
          'key': _apiKey,
        },
      );

      final searchResponse = await http.get(searchUrl);

      if (searchResponse.statusCode != 200) {
        _logger.e(
          'YouTube Live Search API error: ${searchResponse.statusCode} - ${searchResponse.body}',
        );
        throw Exception('Failed to fetch live streams from YouTube');
      }

      final searchData = json.decode(searchResponse.body);
      final videos = searchData['items'] as List<dynamic>;

      if (videos.isEmpty) {
        _logger.i('No live streams found for channel: $channelId');
        return [];
      }

      // Get detailed video information
      final videoIds = videos
          .map((video) => video['id']['videoId'] as String)
          .toList();
      final videoDetails = await _getVideoDetails(videoIds);

      // Convert to PreviousStream objects
      final liveStreams = <PreviousStream>[];

      for (int i = 0; i < videos.length; i++) {
        final video = videos[i];
        final videoId = video['id']['videoId'];
        final details = videoDetails[videoId];

        if (details != null) {
          try {
            final stream = PreviousStreamModel.fromYouTubeApi(
              churchId: churchId,
              videoData: video,
              videoDetails: details,
            );
            liveStreams.add(stream);
          } catch (e) {
            _logger.w('Failed to parse live video $videoId: $e');
          }
        }
      }

      _logger.i(
        'Found ${liveStreams.length} live streams for church: $churchId',
      );
      return liveStreams;
    } catch (e) {
      _logger.e('Error fetching live streams: $e');
      throw Exception('Failed to load live streams');
    }
  }

  /// Searches for previous streams with a query
  Future<List<PreviousStream>> searchPreviousStreams(
    String churchId,
    String channelId,
    String query, {
    int maxResults = 10,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {
          'part': 'snippet',
          'channelId': channelId,
          'type': 'video',
          'eventType': 'completed', // Search only completed live streams
          'q': query,
          'order': 'relevance',
          'maxResults': maxResults.toString(),
          'key': _apiKey,
        },
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to search previous streams');
      }

      final data = json.decode(response.body);
      final videos = data['items'] as List<dynamic>;

      final videoIds = videos
          .map((video) => video['id']['videoId'] as String)
          .toList();
      final videoDetails = await _getVideoDetails(videoIds);

      final previousStreams = <PreviousStream>[];

      for (int i = 0; i < videos.length; i++) {
        final video = videos[i];
        final videoId = video['id']['videoId'];
        final details = videoDetails[videoId];

        if (details != null) {
          try {
            final stream = PreviousStreamModel.fromYouTubeApi(
              churchId: churchId,
              videoData: video,
              videoDetails: details,
            );
            previousStreams.add(stream);
          } catch (e) {
            _logger.w('Failed to parse video $videoId: $e');
          }
        }
      }

      return previousStreams;
    } catch (e) {
      _logger.e('Error searching previous streams: $e');
      throw Exception('Failed to search previous streams');
    }
  }
}
