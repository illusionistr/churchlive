import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import '../constants/environment.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  final Logger _logger = Logger();
  late final SupabaseClient _client;

  SupabaseClient get client => _client;
  GoTrueClient get auth => _client.auth;
  SupabaseClient get database => _client;
  RealtimeClient get realtime => _client.realtime;
  SupabaseStorageClient get storage => _client.storage;

  /// Initialize Supabase client
  Future<void> initialize() async {
    try {
      _logger.i('Initializing Supabase with URL: ${Environment.supabaseUrl}');

      await Supabase.initialize(
        url: Environment.supabaseUrl,
        anonKey: Environment.supabaseAnonKey,
        debug: true, // Set to true for development to see more details
      );

      _client = Supabase.instance.client;
      _logger.i('Supabase initialized successfully');

      // Set up auth state listener
      _setupAuthListener();
    } catch (e, stackTrace) {
      // Check if it's already initialized
      if (e.toString().contains('already been initialized') ||
          e.toString().contains('Supabase has already been initialized')) {
        _logger.i('Supabase already initialized, using existing instance');
        _client = Supabase.instance.client;
        _setupAuthListener();
        return;
      }

      _logger.e(
        'Failed to initialize Supabase',
        error: e,
        stackTrace: stackTrace,
      );
      _logger.e('Supabase URL: ${Environment.supabaseUrl}');
      _logger.e('Anon Key length: ${Environment.supabaseAnonKey.length}');
      rethrow;
    }
  }

  /// Set up authentication state listener
  void _setupAuthListener() {
    auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      _logger.d('Auth state changed: $event');

      switch (event) {
        case AuthChangeEvent.signedIn:
          _logger.i('User signed in: ${session?.user.email}');
          break;
        case AuthChangeEvent.signedOut:
          _logger.i('User signed out');
          break;
        case AuthChangeEvent.tokenRefreshed:
          _logger.d('Token refreshed');
          break;
        case AuthChangeEvent.userUpdated:
          _logger.d('User updated');
          break;
        case AuthChangeEvent.passwordRecovery:
          _logger.d('Password recovery initiated');
          break;
        default:
          break;
      }
    });
  }

  /// Get current user
  User? get currentUser => auth.currentUser;

  /// Get current session
  Session? get currentSession => auth.currentSession;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _logger.i('User signed in successfully: ${response.user!.email}');
      }

      return response;
    } catch (e) {
      _logger.e('Sign in failed', error: e);
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await auth.signUp(
        email: email,
        password: password,
        data: data,
      );

      if (response.user != null) {
        _logger.i('User signed up successfully: ${response.user!.email}');
      }

      return response;
    } catch (e) {
      _logger.e('Sign up failed', error: e);
      rethrow;
    }
  }

  /// Sign in with OAuth provider
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      final response = await auth.signInWithOAuth(
        provider,
        redirectTo: 'com.churchlive.app://login-callback/',
      );

      _logger.i('OAuth sign in initiated for provider: $provider');
      return response;
    } catch (e) {
      _logger.e('OAuth sign in failed', error: e);
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await auth.signOut();
      _logger.i('User signed out successfully');
    } catch (e) {
      _logger.e('Sign out failed', error: e);
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await auth.resetPasswordForEmail(email);
      _logger.i('Password reset email sent to: $email');
    } catch (e) {
      _logger.e('Password reset failed', error: e);
      rethrow;
    }
  }

  /// Update user profile
  Future<UserResponse> updateProfile({
    Map<String, dynamic>? data,
    String? email,
    String? password,
  }) async {
    try {
      final response = await auth.updateUser(
        UserAttributes(data: data, email: email, password: password),
      );

      _logger.i('User profile updated successfully');
      return response;
    } catch (e) {
      _logger.e('Profile update failed', error: e);
      rethrow;
    }
  }

  /// Upload file to storage
  Future<String> uploadFile({
    required String bucketName,
    required String fileName,
    required List<int> fileBytes,
    String? contentType,
  }) async {
    try {
      final path = '${currentUser?.id}/$fileName';

      await storage
          .from(bucketName)
          .uploadBinary(
            path,
            Uint8List.fromList(fileBytes),
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );

      final url = storage.from(bucketName).getPublicUrl(path);
      _logger.i('File uploaded successfully: $url');

      return url;
    } catch (e) {
      _logger.e('File upload failed', error: e);
      rethrow;
    }
  }

  /// Delete file from storage
  Future<void> deleteFile({
    required String bucketName,
    required String fileName,
  }) async {
    try {
      final path = '${currentUser?.id}/$fileName';

      await storage.from(bucketName).remove([path]);
      _logger.i('File deleted successfully: $path');
    } catch (e) {
      _logger.e('File deletion failed', error: e);
      rethrow;
    }
  }

  /// Execute a database query with error handling
  Future<T> executeQuery<T>(
    Future<T> Function() query, {
    String? operation,
  }) async {
    try {
      final result = await query();
      if (operation != null) {
        _logger.d('Database operation successful: $operation');
      }
      return result;
    } catch (e) {
      _logger.e(
        'Database operation failed: ${operation ?? 'Unknown'}',
        error: e,
      );
      rethrow;
    }
  }

  /// Create a real-time subscription
  RealtimeChannel createRealtimeChannel(String channelName) {
    return realtime.channel(channelName);
  }

  /// Dispose resources
  void dispose() {
    _client.dispose();
    _logger.i('Supabase client disposed');
  }
}
