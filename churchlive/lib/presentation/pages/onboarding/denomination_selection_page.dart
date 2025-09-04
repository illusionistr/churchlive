import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/denomination_repository.dart';
import '../../../domain/entities/common.dart';
import '../home/home_page.dart';

class DenominationSelectionPage extends StatefulWidget {
  const DenominationSelectionPage({super.key});

  @override
  State<DenominationSelectionPage> createState() =>
      _DenominationSelectionPageState();
}

class _DenominationSelectionPageState extends State<DenominationSelectionPage> {
  final DenominationRepository _denominationRepository =
      GetIt.instance<DenominationRepository>();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedDenomination;
  bool _isLoading = false;
  bool _isLoadingDenominations = true;
  bool _showAllDenominations = false;
  String _searchQuery = '';

  List<Denomination> _topDenominations = [];
  List<Denomination> _allDenominations = [];
  List<Denomination> _filteredDenominations = [];

  @override
  void initState() {
    super.initState();
    _loadDenominations();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _filterDenominations();
  }

  Future<void> _loadDenominations() async {
    try {
      final topDenominations = await _denominationRepository
          .getTopDenominations(limit: 4);
      final allDenominations = await _denominationRepository
          .getAllDenominations();

      setState(() {
        _topDenominations = topDenominations;
        _allDenominations = allDenominations;
        _filteredDenominations = allDenominations;
        _isLoadingDenominations = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDenominations = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load denominations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterDenominations() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredDenominations = _allDenominations;
      });
    } else {
      setState(() {
        _filteredDenominations = _allDenominations
            .where(
              (denomination) => denomination.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
            )
            .toList();
      });
    }
  }

  Future<void> _saveDenomination() async {
    if (_selectedDenomination == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Find the selected denomination entity
      final selectedDenominationEntity = _allDenominations.firstWhere(
        (d) => d.name == _selectedDenomination,
      );

      // Increment click count in background (don't block UI)
      _denominationRepository.incrementClickCount(
        selectedDenominationEntity.id,
      );

      // Save to SharedPreferences using the denomination name as ID for backwards compatibility
      final prefs = await SharedPreferences.getInstance();
      final denominationId = _getDenominationIdFromName(_selectedDenomination!);

      await prefs.setString('selected_denomination', denominationId);
      await prefs.setBool('onboarding_completed', true);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePage(denominationFilter: denominationId),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save selection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Convert denomination name back to ID for backwards compatibility
  String _getDenominationIdFromName(String name) {
    final nameToIdMap = {
      'Catholic': 'catholic',
      'Baptist': 'baptist',
      'Methodist': 'methodist',
      'Presbyterian': 'presbyterian',
      'Lutheran': 'lutheran',
      'Pentecostal': 'pentecostal',
      'Anglican/Episcopal': 'anglican',
      'Orthodox': 'orthodox',
      'Non-denominational': 'non_denominational',
      'Evangelical': 'evangelical',
      'Assemblies of God': 'assemblies_of_god',
      'Seventh-day Adventist': 'seventh_day_adventist',
    };
    return nameToIdMap[name] ?? name.toLowerCase().replaceAll(' ', '_');
  }

  void _skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.church,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to ${AppConstants.appName}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Choose your denomination to discover churches that match your faith tradition',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search denominations...',
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

              const SizedBox(height: 24),

              // Denominations Grid
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 300,
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: _isLoadingDenominations
                    ? const Center(child: CircularProgressIndicator())
                    : _buildDenominationsGrid(),
              ),

              const SizedBox(height: 24),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedDenomination != null && !_isLoading
                      ? _saveDenomination
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Skip Button
              TextButton(
                onPressed: !_isLoading ? _skipOnboarding : null,
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDenominationsGrid() {
    final denominationsToShow = _searchQuery.isNotEmpty || _showAllDenominations
        ? _filteredDenominations
        : _topDenominations;

    return Column(
      children: [
        // Show All Button (only when not searching and showing top 4)
        if (_searchQuery.isEmpty &&
            !_showAllDenominations &&
            _allDenominations.length > 4)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _showAllDenominations = true;
                });
              },
              child: Text('Show All ${_allDenominations.length} Denominations'),
            ),
          ),

        // Grid
        SizedBox(
          height: 300, // Fixed height for the grid
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: denominationsToShow.length,
            itemBuilder: (context, index) {
              final denomination = denominationsToShow[index];
              final isSelected = _selectedDenomination == denomination.name;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDenomination = denomination.name;
                  });
                },
                child: Card(
                  elevation: isSelected ? 6 : 2,
                  shadowColor: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isSelected
                        ? BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          )
                        : BorderSide.none,
                  ),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Denomination name
                        Text(
                          denomination.name,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Selected indicator
                        if (isSelected) ...[
                          const SizedBox(height: 8),
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
