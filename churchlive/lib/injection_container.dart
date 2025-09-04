import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import 'core/constants/environment.dart';
import 'core/network/supabase_client.dart';
import 'data/repositories/church_repository.dart';
import 'data/repositories/livestream_repository.dart';
import 'data/repositories/denomination_repository.dart';
import 'data/repositories/favorites_repository.dart';
import 'data/repositories/church_submission_repository.dart';
import 'data/repositories/youtube_repository.dart';
import 'data/repositories/user_reports_repository.dart';
import 'core/theme/theme_manager.dart';

final GetIt getIt = GetIt.instance;

// Manual dependency registration
Future<void> setupManualDependencies() async {
  // Register SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register Logger
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
  );
  getIt.registerSingleton<Logger>(logger);

  // Initialize and register Supabase Service (this will handle Supabase.initialize)
  await SupabaseService.instance.initialize();
  getIt.registerSingleton<SupabaseService>(SupabaseService.instance);

  // Register Repositories
  getIt.registerLazySingleton<ChurchRepository>(() => ChurchRepository());
  getIt.registerLazySingleton<LivestreamRepository>(
    () => LivestreamRepository(),
  );
  getIt.registerLazySingleton<DenominationRepository>(
    () => DenominationRepository(),
  );
  getIt.registerLazySingleton<FavoritesRepository>(() => FavoritesRepository());
  getIt.registerLazySingleton<ChurchSubmissionRepository>(
    () => ChurchSubmissionRepository(),
  );
  getIt.registerLazySingleton<YouTubeRepository>(() => YouTubeRepository());
  getIt.registerLazySingleton<UserReportsRepository>(
    () => UserReportsRepository(),
  );

  // Register ThemeManager
  getIt.registerLazySingleton<ThemeManager>(() => ThemeManager());

  logger.i('Dependencies configured successfully');
  logger.i('Supabase connected to: ${Environment.supabaseUrl}');
}
