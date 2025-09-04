import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/theme/theme_manager.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = GetIt.instance.get<ThemeManager>();

    return Scaffold(
      appBar: AppBar(title: const Text('Theme')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme options
          Card(
            child: Column(
              children: [
                _buildThemeOption(
                  context: context,
                  themeManager: themeManager,
                  themeMode: ThemeMode.light,
                  title: 'Light',
                  subtitle: 'Always use light theme',
                  icon: Icons.light_mode,
                ),
                const Divider(height: 1),
                _buildThemeOption(
                  context: context,
                  themeManager: themeManager,
                  themeMode: ThemeMode.dark,
                  title: 'Dark',
                  subtitle: 'Always use dark theme',
                  icon: Icons.dark_mode,
                ),
                const Divider(height: 1),
                _buildThemeOption(
                  context: context,
                  themeManager: themeManager,
                  themeMode: ThemeMode.system,
                  title: 'System',
                  subtitle: 'Follow system theme',
                  icon: Icons.settings_suggest,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Preview section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.church,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ChurchLive',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This is how your app will look with the selected theme',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeManager themeManager,
    required ThemeMode themeMode,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return AnimatedBuilder(
      animation: themeManager,
      builder: (context, child) {
        final isSelected = themeManager.themeMode == themeMode;

        return ListTile(
          leading: Icon(
            icon,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: isSelected
              ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
          onTap: () {
            themeManager.setThemeMode(themeMode);
          },
        );
      },
    );
  }
}
