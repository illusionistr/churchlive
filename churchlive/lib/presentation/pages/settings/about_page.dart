import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_it/get_it.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/user_reports_repository.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(
                      Icons.church,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Discover churches streaming live around the world. Filter by denomination, language, and location to find the perfect worship experience for you.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Features section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    context,
                    icon: Icons.live_tv,
                    title: 'Live Church Streams',
                    description:
                        'Watch churches streaming live from around the world',
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    context,
                    icon: Icons.search,
                    title: 'Smart Search',
                    description:
                        'Find churches by denomination, language, and location',
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    context,
                    icon: Icons.favorite,
                    title: 'Favorites',
                    description: 'Save your favorite churches and streams',
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    context,
                    icon: Icons.notifications,
                    title: 'Notifications',
                    description:
                        'Get notified when your favorite churches go live',
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    context,
                    icon: Icons.palette,
                    title: 'Themes',
                    description: 'Choose between light, dark, or system theme',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Contact & Support section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Contact & Support',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text('Report an Issue'),
                  subtitle: const Text('Help us improve by reporting bugs'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showReportIssueDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.feedback),
                  title: const Text('Send Feedback'),
                  subtitle: const Text('Share your thoughts and suggestions'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showFeedbackDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Contact Us'),
                  subtitle: const Text('Get in touch with our team'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _launchEmail(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Legal section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Legal',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  subtitle: const Text('How we protect your data'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPrivacyPolicy(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Terms of Service'),
                  subtitle: const Text('Terms and conditions'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTermsOfService(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Credits section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Credits',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Built with Flutter and powered by Supabase. Icons by Material Design.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2024 ChurchLive. All rights reserved.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showReportIssueDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => _ReportIssueDialog());
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => _FeedbackDialog());
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'ChurchLive is committed to protecting your privacy. We collect minimal data necessary to provide our services:\n\n'
            '• Church and stream information (publicly available)\n'
            '• Your preferences (denomination, language, theme)\n'
            '• Favorite churches and streams\n'
            '• Notification preferences\n\n'
            'We do not collect personal information or track your viewing habits. All data is stored securely and is not shared with third parties.\n\n'
            'For questions about our privacy practices, please contact us.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using ChurchLive, you agree to these terms:\n\n'
            '• Use the app responsibly and respectfully\n'
            '• Do not misuse or abuse the service\n'
            '• Respect the content and streams provided by churches\n'
            '• Report any inappropriate content\n\n'
            'We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of any changes.\n\n'
            'For questions about these terms, please contact us.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@churchlive.app',
      query: 'subject=ChurchLive Support',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open email client')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _ReportIssueDialog extends StatefulWidget {
  @override
  State<_ReportIssueDialog> createState() => _ReportIssueDialogState();
}

class _ReportIssueDialogState extends State<_ReportIssueDialog> {
  final TextEditingController _issueController = TextEditingController();
  final UserReportsRepository _reportsRepository =
      GetIt.instance<UserReportsRepository>();
  String _selectedCategory = 'Bug Report';
  bool _isSubmitting = false;
  final List<String> _categories = [
    'Bug Report',
    'Feature Request',
    'Performance Issue',
    'UI/UX Problem',
    'Other',
  ];

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report an Issue'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What went wrong?'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Category',
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _issueController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Describe the issue',
                hintText: 'Please provide as much detail as possible...',
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _issueController.text.trim().isEmpty || _isSubmitting
              ? null
              : () {
                  _submitIssue(context);
                },
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }

  Future<void> _submitIssue(BuildContext context) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await _reportsRepository.submitReport(
        category: _selectedCategory,
        description: _issueController.text.trim(),
        userId: _reportsRepository.getCurrentUserId(),
        deviceInfo: _reportsRepository.getDeviceInfo(),
      );

      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Issue submitted successfully!\nThank you for helping us improve!'
                  : 'Failed to submit issue. Please try again.',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting issue: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _FeedbackDialog extends StatefulWidget {
  @override
  State<_FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog> {
  final TextEditingController _feedbackController = TextEditingController();
  final UserReportsRepository _reportsRepository =
      GetIt.instance<UserReportsRepository>();
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send Feedback'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How would you rate ChurchLive?'),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text('Tell us what you think:'),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Your feedback',
                hintText: 'What do you like? What could be better?',
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _feedbackController.text.trim().isEmpty || _isSubmitting
              ? null
              : () {
                  _submitFeedback(context);
                },
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }

  Future<void> _submitFeedback(BuildContext context) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await _reportsRepository.submitFeedback(
        rating: _rating,
        feedbackText: _feedbackController.text.trim().isNotEmpty
            ? _feedbackController.text.trim()
            : null,
        userId: _reportsRepository.getCurrentUserId(),
      );

      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Feedback submitted successfully! (Rating: $_rating/5)\nThank you for your input!'
                  : 'Failed to submit feedback. Please try again.',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting feedback: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
