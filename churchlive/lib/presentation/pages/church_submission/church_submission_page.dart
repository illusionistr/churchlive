import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../../data/repositories/denomination_repository.dart';
import '../../../data/repositories/church_submission_repository.dart';
import '../../../domain/entities/common.dart';
import '../../../core/utils/validators.dart';

class ChurchSubmissionPage extends StatefulWidget {
  const ChurchSubmissionPage({super.key});

  @override
  State<ChurchSubmissionPage> createState() => _ChurchSubmissionPageState();
}

class _ChurchSubmissionPageState extends State<ChurchSubmissionPage> {
  final _formKey = GlobalKey<FormState>();
  final _denominationRepository = GetIt.instance<DenominationRepository>();
  final _submissionRepository = GetIt.instance<ChurchSubmissionRepository>();
  final _logger = GetIt.instance<Logger>();

  // Form controllers
  final _churchNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _youtubeChannelController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _submitterNameController = TextEditingController();
  final _submitterEmailController = TextEditingController();

  // Form state
  List<Denomination> _denominations = [];
  Denomination? _selectedDenomination;
  String _selectedRelationship = 'member';
  bool _isLoading = false;
  bool _isSubmitting = false;

  final List<String> _relationshipOptions = [
    'member',
    'staff',
    'visitor',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _loadDenominations();
  }

  @override
  void dispose() {
    _churchNameController.dispose();
    _cityController.dispose();
    _youtubeChannelController.dispose();
    _contactEmailController.dispose();
    _submitterNameController.dispose();
    _submitterEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadDenominations() async {
    try {
      setState(() => _isLoading = true);
      final denominations = await _denominationRepository.getAllDenominations();
      setState(() {
        _denominations = denominations;
        _isLoading = false;
      });
    } catch (e) {
      _logger.e('Error loading denominations: $e');
      setState(() => _isLoading = false);
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

  Future<void> _submitChurch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _submissionRepository.submitChurch(
        name: _churchNameController.text.trim(),
        denominationId: _selectedDenomination?.id,
        city: _cityController.text.trim(),
        youtubeChannelUrl: _youtubeChannelController.text.trim().isEmpty
            ? null
            : _youtubeChannelController.text.trim(),
        contactEmail: _contactEmailController.text.trim().isEmpty
            ? null
            : _contactEmailController.text.trim(),
        submitterName: _submitterNameController.text.trim(),
        submitterEmail: _submitterEmailController.text.trim(),
        submitterRelationship: _selectedRelationship,
      );

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: Icon(Icons.check_circle, color: Colors.green, size: 64),
            title: const Text('Thank You!'),
            content: const Text(
              'Your church submission has been received. We\'ll review it and add approved churches within 2-3 business days.\n\nYou\'ll receive an email update once we\'ve reviewed your submission.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close submission page
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _logger.e('Error submitting church: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit church: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  String _getRelationshipDisplayName(String relationship) {
    switch (relationship) {
      case 'member':
        return 'Member';
      case 'staff':
        return 'Staff/Pastor';
      case 'visitor':
        return 'Visitor';
      case 'other':
        return 'Other';
      default:
        return relationship;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suggest a Church'), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.church,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Help us grow our community!',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Suggest a church that should be added to our platform. We\'ll review your submission and add approved churches within 2-3 business days.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Church Information Section
                    _buildSectionHeader('Church Information'),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _churchNameController,
                      label: 'Church Name',
                      required: true,
                      validator: Validators.required,
                    ),
                    const SizedBox(height: 16),

                    _buildDenominationDropdown(),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _cityController,
                      label: 'City/Location',
                      required: true,
                      validator: Validators.required,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _youtubeChannelController,
                      label: 'YouTube Channel URL',
                      keyboardType: TextInputType.url,
                      validator: Validators.optionalUrl,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _contactEmailController,
                      label: 'Church Contact Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.optionalEmail,
                    ),
                    const SizedBox(height: 32),

                    // Your Information Section
                    _buildSectionHeader('Your Information'),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _submitterNameController,
                      label: 'Your Name',
                      required: true,
                      validator: Validators.required,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _submitterEmailController,
                      label: 'Your Email',
                      keyboardType: TextInputType.emailAddress,
                      required: true,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),

                    _buildRelationshipDropdown(),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitChurch,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Submit Church Suggestion',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Disclaimer
                    Text(
                      'By submitting this form, you confirm that the information provided is accurate to the best of your knowledge. We reserve the right to review and approve submissions.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }

  Widget _buildDenominationDropdown() {
    return DropdownButtonFormField<Denomination>(
      value: _selectedDenomination,
      decoration: const InputDecoration(
        labelText: 'Denomination',
        border: OutlineInputBorder(),
      ),
      items: _denominations.map((denomination) {
        return DropdownMenuItem(
          value: denomination,
          child: Text(denomination.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedDenomination = value);
      },
    );
  }

  Widget _buildRelationshipDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRelationship,
      decoration: const InputDecoration(
        labelText: 'Your relationship to this church *',
        border: OutlineInputBorder(),
      ),
      items: _relationshipOptions.map((relationship) {
        return DropdownMenuItem(
          value: relationship,
          child: Text(_getRelationshipDisplayName(relationship)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedRelationship = value!);
      },
    );
  }
}
