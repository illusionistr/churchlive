import 'package:logger/logger.dart';
import '../../core/network/supabase_client.dart';

class UserReportsRepository {
  final SupabaseService _supabaseService;
  final Logger _logger = Logger();

  UserReportsRepository() : _supabaseService = SupabaseService.instance;

  /// Submit a user report/issue
  Future<bool> submitReport({
    required String category,
    required String description,
    String? userId,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      _logger.i('Submitting user report: category=$category');

      await _supabaseService.database.from('user_reports').insert({
        'category': category,
        'description': description,
        'user_id': userId,
        'device_info': deviceInfo,
        'status': 'open',
      });

      _logger.i('Report submitted successfully');
      return true;
    } catch (e) {
      _logger.e('Error submitting report: $e');
      return false;
    }
  }

  /// Submit user feedback
  Future<bool> submitFeedback({
    required int rating,
    String? feedbackText,
    String? userId,
  }) async {
    try {
      _logger.i('Submitting user feedback: rating=$rating');

      await _supabaseService.database.from('user_feedback').insert({
        'rating': rating,
        'feedback_text': feedbackText,
        'user_id': userId,
      });

      _logger.i('Feedback submitted successfully');
      return true;
    } catch (e) {
      _logger.e('Error submitting feedback: $e');
      return false;
    }
  }

  /// Get all reports (for admin purposes)
  Future<List<Map<String, dynamic>>> getAllReports() async {
    try {
      _logger.i('Fetching all reports');

      final response = await _supabaseService.database
          .from('user_reports')
          .select('*')
          .order('created_at', ascending: false);

      _logger.i('Fetched ${response.length} reports');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.e('Error fetching reports: $e');
      return [];
    }
  }

  /// Get all feedback (for admin purposes)
  Future<List<Map<String, dynamic>>> getAllFeedback() async {
    try {
      _logger.i('Fetching all feedback');

      final response = await _supabaseService.database
          .from('user_feedback')
          .select('*')
          .order('created_at', ascending: false);

      _logger.i('Fetched ${response.length} feedback entries');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.e('Error fetching feedback: $e');
      return [];
    }
  }

  /// Get device information for reports
  Map<String, dynamic> getDeviceInfo() {
    return {
      'platform': 'flutter',
      'timestamp': DateTime.now().toIso8601String(),
      // You can add more device info here if needed
      // 'device_model': deviceInfo.model,
      // 'os_version': deviceInfo.osVersion,
      // 'app_version': packageInfo.version,
    };
  }

  /// Get user ID (if you have user authentication)
  String? getCurrentUserId() {
    // If you implement user authentication later, you can get the user ID here
    // For now, return null to indicate anonymous user
    return null;
  }
}
