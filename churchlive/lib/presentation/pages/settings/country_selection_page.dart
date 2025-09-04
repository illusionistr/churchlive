import 'package:flutter/material.dart';

class CountrySelectionPage extends StatefulWidget {
  final String? selectedCountry;

  const CountrySelectionPage({super.key, this.selectedCountry});

  @override
  State<CountrySelectionPage> createState() => _CountrySelectionPageState();
}

class _CountrySelectionPageState extends State<CountrySelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // List of countries with their codes and flags
  final List<Map<String, String>> _countries = [
    {'code': 'US', 'name': 'United States', 'flag': '🇺🇸'},
    {'code': 'CA', 'name': 'Canada', 'flag': '🇨🇦'},
    {'code': 'GB', 'name': 'United Kingdom', 'flag': '🇬🇧'},
    {'code': 'AU', 'name': 'Australia', 'flag': '🇦🇺'},
    {'code': 'NZ', 'name': 'New Zealand', 'flag': '🇳🇿'},
    {'code': 'DE', 'name': 'Germany', 'flag': '🇩🇪'},
    {'code': 'FR', 'name': 'France', 'flag': '🇫🇷'},
    {'code': 'ES', 'name': 'Spain', 'flag': '🇪🇸'},
    {'code': 'IT', 'name': 'Italy', 'flag': '🇮🇹'},
    {'code': 'NL', 'name': 'Netherlands', 'flag': '🇳🇱'},
    {'code': 'BE', 'name': 'Belgium', 'flag': '🇧🇪'},
    {'code': 'CH', 'name': 'Switzerland', 'flag': '🇨🇭'},
    {'code': 'AT', 'name': 'Austria', 'flag': '🇦🇹'},
    {'code': 'SE', 'name': 'Sweden', 'flag': '🇸🇪'},
    {'code': 'NO', 'name': 'Norway', 'flag': '🇳🇴'},
    {'code': 'DK', 'name': 'Denmark', 'flag': '🇩🇰'},
    {'code': 'FI', 'name': 'Finland', 'flag': '🇫🇮'},
    {'code': 'IE', 'name': 'Ireland', 'flag': '🇮🇪'},
    {'code': 'PT', 'name': 'Portugal', 'flag': '🇵🇹'},
    {'code': 'GR', 'name': 'Greece', 'flag': '🇬🇷'},
    {'code': 'PL', 'name': 'Poland', 'flag': '🇵🇱'},
    {'code': 'CZ', 'name': 'Czech Republic', 'flag': '🇨🇿'},
    {'code': 'HU', 'name': 'Hungary', 'flag': '🇭🇺'},
    {'code': 'RO', 'name': 'Romania', 'flag': '🇷🇴'},
    {'code': 'BG', 'name': 'Bulgaria', 'flag': '🇧🇬'},
    {'code': 'HR', 'name': 'Croatia', 'flag': '🇭🇷'},
    {'code': 'SI', 'name': 'Slovenia', 'flag': '🇸🇮'},
    {'code': 'SK', 'name': 'Slovakia', 'flag': '🇸🇰'},
    {'code': 'LT', 'name': 'Lithuania', 'flag': '🇱🇹'},
    {'code': 'LV', 'name': 'Latvia', 'flag': '🇱🇻'},
    {'code': 'EE', 'name': 'Estonia', 'flag': '🇪🇪'},
    {'code': 'MX', 'name': 'Mexico', 'flag': '🇲🇽'},
    {'code': 'BR', 'name': 'Brazil', 'flag': '🇧🇷'},
    {'code': 'AR', 'name': 'Argentina', 'flag': '🇦🇷'},
    {'code': 'CL', 'name': 'Chile', 'flag': '🇨🇱'},
    {'code': 'CO', 'name': 'Colombia', 'flag': '🇨🇴'},
    {'code': 'PE', 'name': 'Peru', 'flag': '🇵🇪'},
    {'code': 'VE', 'name': 'Venezuela', 'flag': '🇻🇪'},
    {'code': 'EC', 'name': 'Ecuador', 'flag': '🇪🇨'},
    {'code': 'UY', 'name': 'Uruguay', 'flag': '🇺🇾'},
    {'code': 'PY', 'name': 'Paraguay', 'flag': '🇵🇾'},
    {'code': 'BO', 'name': 'Bolivia', 'flag': '🇧🇴'},
    {'code': 'ZA', 'name': 'South Africa', 'flag': '🇿🇦'},
    {'code': 'NG', 'name': 'Nigeria', 'flag': '🇳🇬'},
    {'code': 'KE', 'name': 'Kenya', 'flag': '🇰🇪'},
    {'code': 'GH', 'name': 'Ghana', 'flag': '🇬🇭'},
    {'code': 'EG', 'name': 'Egypt', 'flag': '🇪🇬'},
    {'code': 'MA', 'name': 'Morocco', 'flag': '🇲🇦'},
    {'code': 'TN', 'name': 'Tunisia', 'flag': '🇹🇳'},
    {'code': 'DZ', 'name': 'Algeria', 'flag': '🇩🇿'},
    {'code': 'IN', 'name': 'India', 'flag': '🇮🇳'},
    {'code': 'CN', 'name': 'China', 'flag': '🇨🇳'},
    {'code': 'JP', 'name': 'Japan', 'flag': '🇯🇵'},
    {'code': 'KR', 'name': 'South Korea', 'flag': '🇰🇷'},
    {'code': 'TH', 'name': 'Thailand', 'flag': '🇹🇭'},
    {'code': 'VN', 'name': 'Vietnam', 'flag': '🇻🇳'},
    {'code': 'PH', 'name': 'Philippines', 'flag': '🇵🇭'},
    {'code': 'ID', 'name': 'Indonesia', 'flag': '🇮🇩'},
    {'code': 'MY', 'name': 'Malaysia', 'flag': '🇲🇾'},
    {'code': 'SG', 'name': 'Singapore', 'flag': '🇸🇬'},
    {'code': 'HK', 'name': 'Hong Kong', 'flag': '🇭🇰'},
    {'code': 'TW', 'name': 'Taiwan', 'flag': '🇹🇼'},
    {'code': 'IL', 'name': 'Israel', 'flag': '🇮🇱'},
    {'code': 'AE', 'name': 'United Arab Emirates', 'flag': '🇦🇪'},
    {'code': 'SA', 'name': 'Saudi Arabia', 'flag': '🇸🇦'},
    {'code': 'TR', 'name': 'Turkey', 'flag': '🇹🇷'},
    {'code': 'RU', 'name': 'Russia', 'flag': '🇷🇺'},
    {'code': 'UA', 'name': 'Ukraine', 'flag': '🇺🇦'},
    {'code': 'BY', 'name': 'Belarus', 'flag': '🇧🇾'},
  ];

  List<Map<String, String>> get _filteredCountries {
    if (_searchQuery.isEmpty) return _countries;

    return _countries.where((country) {
      return country['name']!.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          country['code']!.toLowerCase().contains(_searchQuery.toLowerCase());
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
        title: const Text('Select Country'),
        actions: [
          if (widget.selectedCountry != null)
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
                hintText: 'Search countries...',
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

          // Countries list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                final isSelected = widget.selectedCountry == country['code'];

                return ListTile(
                  leading: Text(
                    country['flag']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    country['name']!,
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
                    country['code']!,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    Navigator.of(context).pop(country['code']);
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
