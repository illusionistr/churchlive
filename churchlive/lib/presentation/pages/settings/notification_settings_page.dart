import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'church_subscription_page.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _pushNotificationsEnabled = true;
  bool _churchLiveNotifications = true;
  bool _churchReminderNotifications = false;
  bool _quietHoursEnabled = false;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 8, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotificationsEnabled =
          prefs.getBool('push_notifications_enabled') ?? true;
      _churchLiveNotifications =
          prefs.getBool('church_live_notifications') ?? true;
      _churchReminderNotifications =
          prefs.getBool('church_reminder_notifications') ?? false;
      _quietHoursEnabled = prefs.getBool('quiet_hours_enabled') ?? false;

      // Load quiet hours
      final startHour = prefs.getInt('quiet_hours_start_hour') ?? 22;
      final startMinute = prefs.getInt('quiet_hours_start_minute') ?? 0;
      final endHour = prefs.getInt('quiet_hours_end_hour') ?? 8;
      final endMinute = prefs.getInt('quiet_hours_end_minute') ?? 0;

      _quietHoursStart = TimeOfDay(hour: startHour, minute: startMinute);
      _quietHoursEnd = TimeOfDay(hour: endHour, minute: endMinute);
      _isLoading = false;
    });
  }

  Future<void> _saveNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      'push_notifications_enabled',
      _pushNotificationsEnabled,
    );
    await prefs.setBool('church_live_notifications', _churchLiveNotifications);
    await prefs.setBool(
      'church_reminder_notifications',
      _churchReminderNotifications,
    );
    await prefs.setBool('quiet_hours_enabled', _quietHoursEnabled);
    await prefs.setInt('quiet_hours_start_hour', _quietHoursStart.hour);
    await prefs.setInt('quiet_hours_start_minute', _quietHoursStart.minute);
    await prefs.setInt('quiet_hours_end_hour', _quietHoursEnd.hour);
    await prefs.setInt('quiet_hours_end_minute', _quietHoursEnd.minute);
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _quietHoursStart : _quietHoursEnd,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _quietHoursStart = picked;
        } else {
          _quietHoursEnd = picked;
        }
      });
      await _saveNotificationPreferences();
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Push Notifications Toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Push Notifications',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Receive notifications on your device',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _pushNotificationsEnabled,
                    onChanged: (value) async {
                      setState(() {
                        _pushNotificationsEnabled = value;
                        if (!value) {
                          _churchLiveNotifications = false;
                          _churchReminderNotifications = false;
                        }
                      });
                      await _saveNotificationPreferences();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Church Subscriptions Section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.church,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Church Subscriptions',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.subscriptions),
                  title: const Text('Manage Church Notifications'),
                  subtitle: const Text(
                    'Choose which churches to get notified about',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ChurchSubscriptionPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Notification Types (only show if push notifications are enabled)
          if (_pushNotificationsEnabled) ...[
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Notification Types',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.live_tv),
                    title: const Text('Church Goes Live'),
                    subtitle: const Text(
                      'Get notified when a subscribed church starts streaming',
                    ),
                    value: _churchLiveNotifications,
                    onChanged: _pushNotificationsEnabled
                        ? (value) async {
                            setState(() {
                              _churchLiveNotifications = value;
                            });
                            await _saveNotificationPreferences();
                          }
                        : null,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.schedule),
                    title: const Text('Service Reminders'),
                    subtitle: const Text(
                      'Get reminded before scheduled services',
                    ),
                    value: _churchReminderNotifications,
                    onChanged: _pushNotificationsEnabled
                        ? (value) async {
                            setState(() {
                              _churchReminderNotifications = value;
                            });
                            await _saveNotificationPreferences();
                          }
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quiet Hours
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bedtime,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Quiet Hours',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.schedule),
                    title: const Text('Enable Quiet Hours'),
                    subtitle: const Text(
                      'Pause notifications during specified hours',
                    ),
                    value: _quietHoursEnabled,
                    onChanged: _pushNotificationsEnabled
                        ? (value) async {
                            setState(() {
                              _quietHoursEnabled = value;
                            });
                            await _saveNotificationPreferences();
                          }
                        : null,
                  ),
                  if (_quietHoursEnabled) ...[
                    ListTile(
                      leading: const Icon(Icons.bedtime),
                      title: const Text('Start Time'),
                      subtitle: Text(_formatTime(_quietHoursStart)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _selectTime(context, true),
                    ),
                    ListTile(
                      leading: const Icon(Icons.wb_sunny),
                      title: const Text('End Time'),
                      subtitle: Text(_formatTime(_quietHoursEnd)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _selectTime(context, false),
                    ),
                  ],
                ],
              ),
            ),
          ],

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
                        'About Notifications',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You can subscribe to specific churches to receive notifications when they go live. Notifications will only be sent for churches you have subscribed to.',
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
