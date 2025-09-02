import 'package:flutter/material.dart';
import '../../core/theme/theme_manager.dart';

/// A simple theme toggle button that works reliably
class SimpleThemeToggle extends StatelessWidget {
  final bool showLabel;
  final bool compact;

  const SimpleThemeToggle({
    super.key,
    this.showLabel = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeProvider.of(context);

    return AnimatedBuilder(
      animation: themeManager,
      builder: (context, child) {
        if (compact) {
          return IconButton(
            onPressed: () => themeManager.toggleTheme(),
            icon: Icon(_getThemeIcon(themeManager.themeMode)),
            tooltip:
                'Toggle theme (${_getThemeDisplayName(themeManager.themeMode)})',
          );
        }

        if (showLabel) {
          return TextButton.icon(
            onPressed: () => _showThemeSelector(context, themeManager),
            icon: Icon(_getThemeIcon(themeManager.themeMode)),
            label: Text(_getThemeDisplayName(themeManager.themeMode)),
          );
        }

        return IconButton(
          onPressed: () => _showThemeSelector(context, themeManager),
          icon: Icon(_getThemeIcon(themeManager.themeMode)),
          tooltip: 'Change theme',
        );
      },
    );
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  String _getThemeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemeSelector(BuildContext context, ThemeManager themeManager) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.palette,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Theme',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _ThemeModeItem(
                mode: ThemeMode.system,
                name: 'System',
                description: 'Follow system setting',
                icon: Icons.brightness_auto,
                isSelected: themeManager.themeMode == ThemeMode.system,
                onTap: () {
                  themeManager.setThemeMode(ThemeMode.system);
                  Navigator.of(context).pop();
                },
              ),

              _ThemeModeItem(
                mode: ThemeMode.light,
                name: 'Light',
                description: 'Light appearance',
                icon: Icons.light_mode,
                isSelected: themeManager.themeMode == ThemeMode.light,
                onTap: () {
                  themeManager.setThemeMode(ThemeMode.light);
                  Navigator.of(context).pop();
                },
              ),

              _ThemeModeItem(
                mode: ThemeMode.dark,
                name: 'Dark',
                description: 'Dark appearance',
                icon: Icons.dark_mode,
                isSelected: themeManager.themeMode == ThemeMode.dark,
                onTap: () {
                  themeManager.setThemeMode(ThemeMode.dark);
                  Navigator.of(context).pop();
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeModeItem extends StatelessWidget {
  final ThemeMode mode;
  final String name;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeModeItem({
    required this.mode,
    required this.name,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      subtitle: Text(description),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}
