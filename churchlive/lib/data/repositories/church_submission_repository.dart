import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../core/network/supabase_client.dart';

class ChurchSubmissionRepository {
  final SupabaseService _supabaseService = GetIt.instance<SupabaseService>();
  final Logger _logger = GetIt.instance<Logger>();

  /// Submit a new church for review
  Future<void> submitChurch({
    required String name,
    String? denominationId,
    required String city,
    String? youtubeChannelUrl,
    String? contactEmail,
    required String submitterName,
    required String submitterEmail,
    required String submitterRelationship,
  }) async {
    try {
      _logger.i('Submitting church: $name by $submitterEmail');

      // Extract YouTube channel ID from URL if provided
      String? youtubeChannelId;
      if (youtubeChannelUrl != null && youtubeChannelUrl.isNotEmpty) {
        youtubeChannelId = _extractYouTubeChannelId(youtubeChannelUrl);
      }

      final submission = {
        'name': name,
        'denomination_id': denominationId,
        'city': city,
        'country_id': await _getDefaultCountryId(), // Default to US for now
        'youtube_channel_id': youtubeChannelId,
        'youtube_channel_url': youtubeChannelUrl,
        'contact_email': contactEmail,
        'submitter_name': submitterName,
        'submitter_email': submitterEmail,
        'submitter_relationship': submitterRelationship,
        'status': 'pending',
      };

      final response = await _supabaseService.database
          .from('church_submissions')
          .insert(submission)
          .select()
          .single();

      _logger.i('Church submission successful: ${response['id']}');
    } catch (e) {
      _logger.e('Error submitting church: $e');
      rethrow;
    }
  }

  /// Get all pending submissions (admin only)
  Future<List<Map<String, dynamic>>> getPendingSubmissions() async {
    try {
      final response = await _supabaseService.database
          .from('pending_church_submissions')
          .select()
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.e('Error fetching pending submissions: $e');
      rethrow;
    }
  }

  /// Get submissions by email (for user to track their submissions)
  Future<List<Map<String, dynamic>>> getSubmissionsByEmail(String email) async {
    try {
      final response = await _supabaseService.database
          .from('church_submissions')
          .select('''
            id,
            name,
            city,
            status,
            admin_notes,
            created_at,
            reviewed_at
          ''')
          .eq('submitter_email', email)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.e('Error fetching submissions by email: $e');
      rethrow;
    }
  }

  /// Approve a submission and create church (admin only)
  Future<String> approveSubmission(
    String submissionId,
    String reviewerEmail,
  ) async {
    try {
      final response = await _supabaseService.database.rpc(
        'approve_church_submission',
        params: {
          'submission_id': submissionId,
          'reviewer_email': reviewerEmail,
        },
      );

      _logger.i('Approved submission $submissionId, created church: $response');
      return response as String;
    } catch (e) {
      _logger.e('Error approving submission: $e');
      rethrow;
    }
  }

  /// Reject a submission (admin only)
  Future<void> rejectSubmission(
    String submissionId,
    String reviewerEmail,
    String reason,
  ) async {
    try {
      await _supabaseService.database
          .from('church_submissions')
          .update({
            'status': 'rejected',
            'admin_notes': reason,
            'reviewed_by': reviewerEmail,
            'reviewed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', submissionId);

      _logger.i('Rejected submission $submissionId');
    } catch (e) {
      _logger.e('Error rejecting submission: $e');
      rethrow;
    }
  }

  /// Request more information for a submission (admin only)
  Future<void> requestMoreInfo(
    String submissionId,
    String reviewerEmail,
    String message,
  ) async {
    try {
      await _supabaseService.database
          .from('church_submissions')
          .update({
            'status': 'needs_info',
            'admin_notes': message,
            'reviewed_by': reviewerEmail,
            'reviewed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', submissionId);

      _logger.i('Requested more info for submission $submissionId');
    } catch (e) {
      _logger.e('Error requesting more info: $e');
      rethrow;
    }
  }

  /// Extract YouTube channel ID from various URL formats
  String? _extractYouTubeChannelId(String url) {
    if (url.isEmpty) return null;

    // Handle different YouTube URL formats
    final patterns = [
      RegExp(r'youtube\.com\/channel\/([a-zA-Z0-9_-]+)'),
      RegExp(r'youtube\.com\/c\/([a-zA-Z0-9_-]+)'),
      RegExp(r'youtube\.com\/user\/([a-zA-Z0-9_-]+)'),
      RegExp(r'youtube\.com\/@([a-zA-Z0-9_-]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        return match.group(1);
      }
    }

    return null;
  }

  /// Get default country ID (US for now)
  Future<String?> _getDefaultCountryId() async {
    try {
      final response = await _supabaseService.database
          .from('countries')
          .select('id')
          .eq('code', 'US')
          .single();

      return response['id'] as String;
    } catch (e) {
      _logger.w('Could not get default country ID: $e');
      return null;
    }
  }
}
