import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'country_selection_page.dart';
import 'language_selection_page.dart';

class LanguageRegionSettingsPage extends StatefulWidget {
  const LanguageRegionSettingsPage({super.key});

  @override
  State<LanguageRegionSettingsPage> createState() =>
      _LanguageRegionSettingsPageState();
}

class _LanguageRegionSettingsPageState
    extends State<LanguageRegionSettingsPage> {
  String? _selectedCountry;
  String? _selectedLanguage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCountry = prefs.getString('selected_country');
      _selectedLanguage = prefs.getString('selected_language');
      _isLoading = false;
    });
  }

  Future<void> _saveCountryPreference(String? country) async {
    final prefs = await SharedPreferences.getInstance();
    if (country == null) {
      await prefs.remove('selected_country');
    } else {
      await prefs.setString('selected_country', country);
    }
    setState(() {
      _selectedCountry = country;
    });
  }

  Future<void> _saveLanguagePreference(String? language) async {
    final prefs = await SharedPreferences.getInstance();
    if (language == null) {
      await prefs.remove('selected_language');
    } else {
      await prefs.setString('selected_language', language);
    }
    setState(() {
      _selectedLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Language & Region')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Language & Region')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Region Section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.public,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Region',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('Country'),
                  subtitle: Text(
                    _selectedCountry ?? 'All Countries',
                    style: TextStyle(
                      color: _selectedCountry != null
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selectedCountry != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _saveCountryPreference(null),
                          tooltip: 'Clear selection',
                        ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CountrySelectionPage(
                          selectedCountry: _selectedCountry,
                        ),
                      ),
                    );
                    if (result != null) {
                      _saveCountryPreference(result);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Language Section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.language,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Language',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.translate),
                  title: const Text('Primary Language'),
                  subtitle: Text(
                    _selectedLanguage ?? 'All Languages',
                    style: TextStyle(
                      color: _selectedLanguage != null
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selectedLanguage != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _saveLanguagePreference(null),
                          tooltip: 'Clear selection',
                        ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LanguageSelectionPage(
                          selectedLanguage: _selectedLanguage,
                        ),
                      ),
                    );
                    if (result != null) {
                      _saveLanguagePreference(result);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Info Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'How it works',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'These filters will be applied to all church listings throughout the app. You can clear any filter to see churches from all countries or languages.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
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
}
