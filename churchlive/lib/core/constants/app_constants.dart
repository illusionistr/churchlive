class AppConstants {
  // App Information
  static const String appName = 'ChurchLive';
  static const String appVersion = '1.0.0';

  // Supabase Configuration
  // TODO: Replace with your actual Supabase URL and key
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // API Endpoints
  static const String baseUrl = supabaseUrl;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Duration
  static const Duration cacheExpiry = Duration(minutes: 5);
  static const Duration longCacheExpiry = Duration(hours: 1);

  // Image Sizes
  static const double churchLogoSize = 60.0;
  static const double churchCoverHeight = 200.0;
  static const double streamThumbnailHeight = 120.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);

  // Stream Platforms
  static const List<String> supportedPlatforms = [
    'youtube',
    'facebook',
    'vimeo',
    'custom',
  ];

  // Notification Types
  static const String notificationTypeLiveStream = 'live_stream';
  static const String notificationTypeNewChurch = 'new_church';
  static const String notificationTypeWeeklyDigest = 'weekly_digest';

  // Shared Preferences Keys
  static const String keyUserPreferences = 'user_preferences';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyLastSyncTime = 'last_sync_time';

  // Error Messages
  static const String errorNoInternet = 'No internet connection';
  static const String errorUnknown = 'An unknown error occurred';
  static const String errorTimeout = 'Request timeout';
  static const String errorUnauthorized = 'Unauthorized access';
  static const String errorNotFound = 'Resource not found';
  static const String errorServerError = 'Server error occurred';

  // Success Messages
  static const String successLogin = 'Successfully logged in';
  static const String successLogout = 'Successfully logged out';
  static const String successSaved = 'Successfully saved';
  static const String successDeleted = 'Successfully deleted';

  // Validation
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int minPasswordLength = 6;
  static const int maxBioLength = 500;
  static const int maxReviewLength = 1000;
}
