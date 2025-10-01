import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;

  bool _sessionReminders = true;
  bool _newMessages = true;
  bool _mentorUpdates = true;
  bool _systemAnnouncements = false;

  bool _dailySummary = true;
  bool _weeklySummary = false;
  bool _monthlySummary = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Notification Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Channels
            Text(
              'Notification Channels',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you want to receive notifications',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            _buildSettingCard(
              icon: Icons.email,
              title: 'Email Notifications',
              subtitle: 'Receive notifications via email',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() => _emailNotifications = value);
              },
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.notifications,
              title: 'Push Notifications',
              subtitle: 'Receive push notifications on your device',
              value: _pushNotifications,
              onChanged: (value) {
                setState(() => _pushNotifications = value);
              },
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.sms,
              title: 'SMS Notifications',
              subtitle: 'Receive text messages for important updates',
              value: _smsNotifications,
              onChanged: (value) {
                setState(() => _smsNotifications = value);
              },
              theme: theme,
            ),
            const SizedBox(height: 32),

            // Notification Types
            Text(
              'Notification Types',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Select what you want to be notified about',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            _buildSettingCard(
              icon: Icons.calendar_today,
              title: 'Session Reminders',
              subtitle: 'Get reminded before your sessions',
              value: _sessionReminders,
              onChanged: (value) {
                setState(() => _sessionReminders = value);
              },
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.message,
              title: 'New Messages',
              subtitle: 'Get notified when you receive messages',
              value: _newMessages,
              onChanged: (value) {
                setState(() => _newMessages = value);
              },
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.person,
              title: 'Mentor Updates',
              subtitle: 'Updates from your mentors',
              value: _mentorUpdates,
              onChanged: (value) {
                setState(() => _mentorUpdates = value);
              },
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.campaign,
              title: 'System Announcements',
              subtitle: 'Important platform updates',
              value: _systemAnnouncements,
              onChanged: (value) {
                setState(() => _systemAnnouncements = value);
              },
              theme: theme,
            ),
            const SizedBox(height: 32),

            // Digest Settings
            Text(
              'Digest Settings',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Receive summaries of your activity',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            _buildSettingCard(
              icon: Icons.today,
              title: 'Daily Summary',
              subtitle: 'Daily digest of your sessions and messages',
              value: _dailySummary,
              onChanged: (value) {
                setState(() => _dailySummary = value);
              },
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.date_range,
              title: 'Weekly Summary',
              subtitle: 'Weekly recap of your learning progress',
              value: _weeklySummary,
              onChanged: (value) {
                setState(() => _weeklySummary = value);
              },
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.calendar_month,
              title: 'Monthly Summary',
              subtitle: 'Monthly overview of your achievements',
              value: _monthlySummary,
              onChanged: (value) {
                setState(() => _monthlySummary = value);
              },
              theme: theme,
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Save settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings saved successfully'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
                child: const Text('Save Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
