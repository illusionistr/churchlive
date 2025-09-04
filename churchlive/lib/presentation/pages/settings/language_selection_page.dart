import 'package:flutter/material.dart';

class LanguageSelectionPage extends StatefulWidget {
  final String? selectedLanguage;

  const LanguageSelectionPage({super.key, this.selectedLanguage});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // List of languages with their codes and native names
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'es', 'name': 'Spanish', 'native': 'Español'},
    {'code': 'fr', 'name': 'French', 'native': 'Français'},
    {'code': 'de', 'name': 'German', 'native': 'Deutsch'},
    {'code': 'it', 'name': 'Italian', 'native': 'Italiano'},
    {'code': 'pt', 'name': 'Portuguese', 'native': 'Português'},
    {'code': 'ru', 'name': 'Russian', 'native': 'Русский'},
    {'code': 'zh', 'name': 'Chinese', 'native': '中文'},
    {'code': 'ja', 'name': 'Japanese', 'native': '日本語'},
    {'code': 'ko', 'name': 'Korean', 'native': '한국어'},
    {'code': 'ar', 'name': 'Arabic', 'native': 'العربية'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
    {'code': 'th', 'name': 'Thai', 'native': 'ไทย'},
    {'code': 'vi', 'name': 'Vietnamese', 'native': 'Tiếng Việt'},
    {'code': 'id', 'name': 'Indonesian', 'native': 'Bahasa Indonesia'},
    {'code': 'ms', 'name': 'Malay', 'native': 'Bahasa Melayu'},
    {'code': 'tl', 'name': 'Filipino', 'native': 'Filipino'},
    {'code': 'nl', 'name': 'Dutch', 'native': 'Nederlands'},
    {'code': 'sv', 'name': 'Swedish', 'native': 'Svenska'},
    {'code': 'da', 'name': 'Danish', 'native': 'Dansk'},
    {'code': 'no', 'name': 'Norwegian', 'native': 'Norsk'},
    {'code': 'fi', 'name': 'Finnish', 'native': 'Suomi'},
    {'code': 'pl', 'name': 'Polish', 'native': 'Polski'},
    {'code': 'cs', 'name': 'Czech', 'native': 'Čeština'},
    {'code': 'hu', 'name': 'Hungarian', 'native': 'Magyar'},
    {'code': 'ro', 'name': 'Romanian', 'native': 'Română'},
    {'code': 'bg', 'name': 'Bulgarian', 'native': 'Български'},
    {'code': 'hr', 'name': 'Croatian', 'native': 'Hrvatski'},
    {'code': 'sk', 'name': 'Slovak', 'native': 'Slovenčina'},
    {'code': 'sl', 'name': 'Slovenian', 'native': 'Slovenščina'},
    {'code': 'et', 'name': 'Estonian', 'native': 'Eesti'},
    {'code': 'lv', 'name': 'Latvian', 'native': 'Latviešu'},
    {'code': 'lt', 'name': 'Lithuanian', 'native': 'Lietuvių'},
    {'code': 'el', 'name': 'Greek', 'native': 'Ελληνικά'},
    {'code': 'tr', 'name': 'Turkish', 'native': 'Türkçe'},
    {'code': 'he', 'name': 'Hebrew', 'native': 'עברית'},
    {'code': 'fa', 'name': 'Persian', 'native': 'فارسی'},
    {'code': 'ur', 'name': 'Urdu', 'native': 'اردو'},
    {'code': 'bn', 'name': 'Bengali', 'native': 'বাংলা'},
    {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
    {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
    {'code': 'ml', 'name': 'Malayalam', 'native': 'മലയാളം'},
    {'code': 'kn', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
    {'code': 'gu', 'name': 'Gujarati', 'native': 'ગુજરાતી'},
    {'code': 'pa', 'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ'},
    {'code': 'mr', 'name': 'Marathi', 'native': 'मराठी'},
    {'code': 'ne', 'name': 'Nepali', 'native': 'नेपाली'},
    {'code': 'si', 'name': 'Sinhala', 'native': 'සිංහල'},
    {'code': 'my', 'name': 'Burmese', 'native': 'မြန်မာ'},
    {'code': 'km', 'name': 'Khmer', 'native': 'ខ្មែរ'},
    {'code': 'lo', 'name': 'Lao', 'native': 'ລາວ'},
    {'code': 'ka', 'name': 'Georgian', 'native': 'ქართული'},
    {'code': 'hy', 'name': 'Armenian', 'native': 'Հայերեն'},
    {'code': 'az', 'name': 'Azerbaijani', 'native': 'Azərbaycan'},
    {'code': 'kk', 'name': 'Kazakh', 'native': 'Қазақ'},
    {'code': 'ky', 'name': 'Kyrgyz', 'native': 'Кыргыз'},
    {'code': 'uz', 'name': 'Uzbek', 'native': 'Oʻzbek'},
    {'code': 'tg', 'name': 'Tajik', 'native': 'Тоҷикӣ'},
    {'code': 'mn', 'name': 'Mongolian', 'native': 'Монгол'},
    {'code': 'sw', 'name': 'Swahili', 'native': 'Kiswahili'},
    {'code': 'am', 'name': 'Amharic', 'native': 'አማርኛ'},
    {'code': 'ha', 'name': 'Hausa', 'native': 'Hausa'},
    {'code': 'yo', 'name': 'Yoruba', 'native': 'Yorùbá'},
    {'code': 'ig', 'name': 'Igbo', 'native': 'Igbo'},
    {'code': 'zu', 'name': 'Zulu', 'native': 'IsiZulu'},
    {'code': 'af', 'name': 'Afrikaans', 'native': 'Afrikaans'},
    {'code': 'eu', 'name': 'Basque', 'native': 'Euskera'},
    {'code': 'ca', 'name': 'Catalan', 'native': 'Català'},
    {'code': 'gl', 'name': 'Galician', 'native': 'Galego'},
    {'code': 'cy', 'name': 'Welsh', 'native': 'Cymraeg'},
    {'code': 'ga', 'name': 'Irish', 'native': 'Gaeilge'},
    {'code': 'mt', 'name': 'Maltese', 'native': 'Malti'},
    {'code': 'is', 'name': 'Icelandic', 'native': 'Íslenska'},
    {'code': 'mk', 'name': 'Macedonian', 'native': 'Македонски'},
    {'code': 'sq', 'name': 'Albanian', 'native': 'Shqip'},
    {'code': 'sr', 'name': 'Serbian', 'native': 'Српски'},
    {'code': 'bs', 'name': 'Bosnian', 'native': 'Bosanski'},
    {'code': 'me', 'name': 'Montenegrin', 'native': 'Crnogorski'},
  ];

  List<Map<String, String>> get _filteredLanguages {
    if (_searchQuery.isEmpty) return _languages;

    return _languages.where((language) {
      return language['name']!.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          language['native']!.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          language['code']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        actions: [
          if (widget.selectedLanguage != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null); // Clear selection
              },
              child: const Text('Clear'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search languages...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),

          // Languages list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredLanguages.length,
              itemBuilder: (context, index) {
                final language = _filteredLanguages[index];
                final isSelected = widget.selectedLanguage == language['code'];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      language['code']!.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(
                    language['name']!,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    language['native']!,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    Navigator.of(context).pop(language['code']);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
