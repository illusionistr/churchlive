import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages theme preferences and state
class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  /// Get the current brightness based on theme mode and system settings
  Brightness getCurrentBrightness(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness;
    }
  }

  /// Check if dark mode is currently active
  bool isDarkMode(BuildContext context) {
    return getCurrentBrightness(context) == Brightness.dark;
  }

  /// Initialize theme manager and load saved preferences
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeIndex = prefs.getInt(_themeKey);

      if (savedThemeIndex != null) {
        _themeMode = ThemeMode.values[savedThemeIndex];
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing ThemeManager: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Set theme mode and save to preferences
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  /// Toggle between light and dark mode (skips system)
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Cycle through all theme modes: system -> light -> dark -> system
  Future<void> cycleThemeMode() async {
    final modes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
    final currentIndex = modes.indexOf(_themeMode);
    final nextIndex = (currentIndex + 1) % modes.length;
    await setThemeMode(modes[nextIndex]);
  }

  /// Get display name for current theme mode
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  /// Get icon for current theme mode
  IconData get themeModeIcon {
    switch (_themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  /// Get all available theme modes with display info
  List<ThemeModeOption> get availableThemeModes {
    return [
      ThemeModeOption(
        mode: ThemeMode.system,
        name: 'System',
        description: 'Follow system setting',
        icon: Icons.brightness_auto,
      ),
      ThemeModeOption(
        mode: ThemeMode.light,
        name: 'Light',
        description: 'Light appearance',
        icon: Icons.light_mode,
      ),
      ThemeModeOption(
        mode: ThemeMode.dark,
        name: 'Dark',
        description: 'Dark appearance',
        icon: Icons.dark_mode,
      ),
    ];
  }
}

/// Represents a theme mode option with display information
class ThemeModeOption {
  final ThemeMode mode;
  final String name;
  final String description;
  final IconData icon;

  const ThemeModeOption({
    required this.mode,
    required this.name,
    required this.description,
    required this.icon,
  });
}

/// Provider widget to access ThemeManager throughout the app
class ThemeProvider extends InheritedNotifier<ThemeManager> {
  const ThemeProvider({
    super.key,
    required ThemeManager themeManager,
    required super.child,
  }) : super(notifier: themeManager);

  static ThemeManager of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ThemeProvider>()!
        .notifier!;
  }

  static ThemeManager? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ThemeProvider>()
        ?.notifier;
  }
}
