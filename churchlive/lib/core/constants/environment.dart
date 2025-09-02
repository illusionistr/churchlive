// Environment Configuration for ChurchLive App
//
// IMPORTANT: Before running the app, you need to:
// 1. Create a Supabase project at https://supabase.com
// 2. Run the SQL scripts from supabase_schema.sql and supabase_rls_policies.sql
// 3. Replace the values below with your actual Supabase credentials
// 4. Update the values in app_constants.dart

class Environment {
  // Development Environment
  static const String devSupabaseUrl = 'https://eezsbgmxqwrjzcywfjmi.supabase.co';
  static const String devSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVlenNiZ214cXdyanpjeXdmam1pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxMTk3NjYsImV4cCI6MjA3MDY5NTc2Nn0.IrlcxjK6uvNnHnm1m2bE--TXFLcf_fiUGzkY002c_vE';

  // Production Environment
  static const String prodSupabaseUrl = 'YOUR_PRODUCTION_SUPABASE_URL_HERE';
  static const String prodSupabaseAnonKey =
      'YOUR_PRODUCTION_SUPABASE_ANON_KEY_HERE';

  // Current Environment
  static const bool isProduction = false; // Set to true for production builds

  static String get supabaseUrl =>
      isProduction ? prodSupabaseUrl : devSupabaseUrl;
  static String get supabaseAnonKey =>
      isProduction ? prodSupabaseAnonKey : devSupabaseAnonKey;

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableDebugLogging = !isProduction;

  // API Configuration
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // Cache Configuration
  static const Duration cacheExpiry = Duration(minutes: 5);
  static const int maxCacheSize = 100; // MB
}

// TODO: Instructions for setting up Supabase
// 
// 1. Go to https://supabase.com and create a new project
// 2. In your Supabase dashboard, go to Settings > API
// 3. Copy your Project URL and Anon (public) key
// 4. Replace YOUR_SUPABASE_URL_HERE and YOUR_SUPABASE_ANON_KEY_HERE above
// 5. Go to the SQL Editor in Supabase and run:
//    - First: supabase_schema.sql (creates tables and functions)
//    - Then: supabase_rls_policies.sql (sets up security)
// 6. Update the constants in app_constants.dart with your values
// 7. Test the connection by running the app
// 
// Your Supabase URL should look like: https://abcdefghijklmnop.supabase.co
// Your Anon key is safe to use in client-side code