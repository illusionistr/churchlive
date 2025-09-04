import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DenominationSettingsPage extends StatefulWidget {
  const DenominationSettingsPage({super.key});

  @override
  State<DenominationSettingsPage> createState() =>
      _DenominationSettingsPageState();
}

class _DenominationSettingsPageState extends State<DenominationSettingsPage> {
  String? _selectedDenomination;
  bool _isLoading = true;

  final Map<String, String> _denominations = {
    'catholic': 'Catholic',
    'baptist': 'Baptist',
    'methodist': 'Methodist',
    'presbyterian': 'Presbyterian',
    'lutheran': 'Lutheran',
    'pentecostal': 'Pentecostal',
    'anglican': 'Anglican/Episcopal',
    'orthodox': 'Orthodox',
    'non_denominational': 'Non-denominational',
    'evangelical': 'Evangelical',
    'assemblies_of_god': 'Assemblies of God',
    'seventh_day_adventist': 'Seventh-day Adventist',
  };

  @override
  void initState() {
    super.initState();
    _loadSelectedDenomination();
  }

  Future<void> _loadSelectedDenomination() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final denomination = prefs.getString('selected_denomination');
      setState(() {
        _selectedDenomination = denomination;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDenomination(String denominationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_denomination', denominationId);

      setState(() {
        _selectedDenomination = denominationId;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected ${_denominations[denominationId]}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
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

  Future<void> _clearDenomination() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('selected_denomination');

      setState(() {
        _selectedDenomination = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Showing all denominations'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear selection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Denomination'),
        actions: [
          if (_selectedDenomination != null)
            TextButton(
              onPressed: _clearDenomination,
              child: const Text('Clear'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.church,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Choose Your Denomination',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select your faith tradition to see relevant churches and services.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                        if (_selectedDenomination != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Currently showing: ${_denominations[_selectedDenomination]}',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Denominations list
                ..._denominations.entries.map((entry) {
                  final denominationId = entry.key;
                  final denominationName = entry.value;
                  final isSelected = _selectedDenomination == denominationId;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.church,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        denominationName,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : const Icon(Icons.radio_button_unchecked),
                      onTap: () => _selectDenomination(denominationId),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Show all option
                Card(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _selectedDenomination == null
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.public,
                        color: _selectedDenomination == null
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      'Show All Denominations',
                      style: TextStyle(
                        fontWeight: _selectedDenomination == null
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: _selectedDenomination == null
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    subtitle: const Text(
                      'View churches from all faith traditions',
                    ),
                    trailing: _selectedDenomination == null
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : const Icon(Icons.radio_button_unchecked),
                    onTap: _clearDenomination,
                  ),
                ),
              ],
            ),
    );
  }
}
