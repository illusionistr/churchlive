import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';
import 'injection_container.dart';
import 'presentation/pages/splash/splash_page.dart';

final GetIt getIt = GetIt.instance;
final Logger logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Set up dependency injection
    await setupManualDependencies();
    logger.i('Dependency injection configured');

    // Get theme manager from dependency injection and initialize it
    final themeManager = getIt.get<ThemeManager>();
    await themeManager.initialize();
    logger.i('Theme manager initialized');

    runApp(ChurchLiveApp(themeManager: themeManager));
  } catch (e, stackTrace) {
    logger.e('Failed to initialize app', error: e, stackTrace: stackTrace);

    // Print detailed error for debugging
    print('🔥 Initialization Error: $e');
    print('🔥 Stack Trace: $stackTrace');

    runApp(ErrorApp(error: e.toString()));
  }
}

class ChurchLiveApp extends StatelessWidget {
  final ThemeManager themeManager;

  const ChurchLiveApp({super.key, required this.themeManager});

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      themeManager: themeManager,
      child: AnimatedBuilder(
        animation: themeManager,
        builder: (context, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeManager.themeMode,
            home: const SplashPage(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
                  ),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String? error;

  const ErrorApp({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChurchLive - Error',
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize ChurchLive',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This usually means Supabase configuration needs to be set up.',
                  textAlign: TextAlign.center,
                ),
                if (error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Error: $error',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Make sure you have:\n• Set up your Supabase project\n• Updated environment.dart with your credentials\n• Run the SQL scripts',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Restart the app
            main();
          },
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}
