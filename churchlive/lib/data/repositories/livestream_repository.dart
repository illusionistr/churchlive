import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import '../../core/network/supabase_client.dart';
import '../../domain/entities/livestream.dart';
import '../models/livestream_model.dart';

/// Repository for handling livestream data operations
class LivestreamRepository {
  final SupabaseService _supabaseService = GetIt.instance<SupabaseService>();
  final Logger _logger = GetIt.instance<Logger>();

  /// Get currently live streams
  Future<List<Livestream>> getLiveStreams({int limit = 20}) async {
    try {
      _logger.i('Fetching live streams');

      final response = await _supabaseService.database
          .from('livestreams')
          .select('''
            *,
            churches!inner(id, name, denomination_id, logo_url)
          ''')
          .eq('status', 'live')
          .order('viewer_count', ascending: false)
          .limit(limit);

      _logger.i('Found ${response.length} live streams');

      return response.map<Livestream>((json) {
        try {
          return LivestreamModel.fromJson(json).toEntity();
        } catch (e) {
          _logger.w('Error parsing livestream data: $e');
          // Return fallback livestream
          return Livestream(
            id: json['id'] ?? 'unknown',
            churchId: json['church_id'] ?? 'unknown',
            title: json['title'] ?? 'Live Stream',
            platform: StreamPlatform.youtube,
            streamUrl: json['stream_url'] ?? '',
            status: StreamStatus.live,
            isFeatured: false,
            viewerCount: 0,
            maxViewers: 0,
            isRecurring: false,
            recurrencePattern: RecurrenceType.none,
            isChatEnabled: true,
            tags: const [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            languageId: json['language_id'],
          );
        }
      }).toList();
    } catch (e) {
      _logger.e('Error fetching live streams: $e');
      rethrow;
    }
  }

  /// Get upcoming scheduled streams
  Future<List<Livestream>> getUpcomingStreams({int limit = 20}) async {
    try {
      _logger.i('Fetching upcoming streams');

      final response = await _supabaseService.database
          .from('livestreams')
          .select('''
            *,
            churches!inner(id, name, denomination_id, logo_url)
          ''')
          .eq('status', 'scheduled')
          .gte('scheduled_start', DateTime.now().toIso8601String())
          .order('scheduled_start', ascending: true)
          .limit(limit);

      _logger.i('Found ${response.length} upcoming streams');

      return response
          .map<Livestream>((json) => LivestreamModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      _logger.e('Error fetching upcoming streams: $e');
      rethrow;
    }
  }

  /// Get streams by church ID
  Future<List<Livestream>> getStreamsByChurch(String churchId) async {
    try {
      _logger.i('Fetching streams for church: $churchId');

      final response = await _supabaseService.database
          .from('livestreams')
          .select('*')
          .eq('church_id', churchId)
          .order('scheduled_start', ascending: false)
          .limit(10);

      _logger.i('Found ${response.length} streams for church');

      return response
          .map<Livestream>((json) => LivestreamModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      _logger.e('Error fetching streams by church: $e');
      rethrow;
    }
  }

  /// Get streams by denomination
  Future<List<Livestream>> getStreamsByDenomination(
    String denominationId,
  ) async {
    try {
      _logger.i('Fetching streams for denomination: $denominationId');

      final response = await _supabaseService.database
          .from('livestreams')
          .select('''
            *,
            churches!inner(id, name, denomination_id, logo_url)
          ''')
          .eq('churches.denomination_id', denominationId)
          .inFilter('status', ['live', 'scheduled'])
          .order('scheduled_start', ascending: true)
          .limit(20);

      _logger.i('Found ${response.length} streams for denomination');

      return response
          .map<Livestream>((json) => LivestreamModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      _logger.e('Error fetching streams by denomination: $e');
      rethrow;
    }
  }

  /// Get recent/past streams
  Future<List<Livestream>> getRecentStreams({int limit = 10}) async {
    try {
      _logger.i('Fetching recent streams');

      final response = await _supabaseService.database
          .from('livestreams')
          .select('''
            *,
            churches!inner(id, name, denomination_id, logo_url)
          ''')
          .eq('status', 'ended')
          .order('actual_start', ascending: false)
          .limit(limit);

      _logger.i('Found ${response.length} recent streams');

      return response
          .map<Livestream>((json) => LivestreamModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      _logger.e('Error fetching recent streams: $e');
      rethrow;
    }
  }

  /// Get stream details by ID
  Future<Livestream?> getStreamById(String streamId) async {
    try {
      _logger.i('Fetching stream details for ID: $streamId');

      final response = await _supabaseService.database
          .from('livestreams')
          .select('''
            *,
            churches!inner(id, name, denomination_id, logo_url)
          ''')
          .eq('id', streamId)
          .single();

      _logger.i('Successfully fetched stream details');

      return LivestreamModel.fromJson(response).toEntity();
    } catch (e) {
      _logger.e('Error fetching stream by ID: $e');
      return null;
    }
  }

  /// Update viewer count for a stream
  Future<void> updateViewerCount(String streamId, int viewerCount) async {
    try {
      await _supabaseService.database
          .from('livestreams')
          .update({'viewer_count': viewerCount})
          .eq('id', streamId);

      _logger.i('Updated viewer count for stream $streamId: $viewerCount');
    } catch (e) {
      _logger.e('Error updating viewer count: $e');
    }
  }

  /// Search streams by title or description
  Future<List<Livestream>> searchStreams(String query) async {
    try {
      _logger.i('Searching streams with query: $query');

      final response = await _supabaseService.database
          .from('livestreams')
          .select('''
            *,
            churches!inner(id, name, denomination_id, logo_url)
          ''')
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .inFilter('status', ['live', 'scheduled'])
          .order('scheduled_start', ascending: true)
          .limit(20);

      _logger.i('Found ${response.length} streams matching query');

      return response
          .map<Livestream>((json) => LivestreamModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      _logger.e('Error searching streams: $e');
      rethrow;
    }
  }
}
