import 'package:flutter/material.dart';

class AvailabilitySettingScreen extends StatefulWidget {
  const AvailabilitySettingScreen({super.key});

  @override
  State<AvailabilitySettingScreen> createState() => _AvailabilitySettingScreenState();
}

class _AvailabilitySettingScreenState extends State<AvailabilitySettingScreen> {
  final Map<String, DayAvailability> _availability = {
    'Monday': DayAvailability(enabled: true, time: '9:00 AM - 5:00 PM'),
    'Tuesday': DayAvailability(enabled: false, time: 'Not available'),
    'Wednesday': DayAvailability(enabled: true, time: '9:00 AM - 5:00 PM'),
    'Thursday': DayAvailability(enabled: true, time: '9:00 AM - 5:00 PM'),
    'Friday': DayAvailability(enabled: true, time: '9:00 AM - 1:00 PM'),
    'Saturday': DayAvailability(enabled: false, time: 'Not available'),
    'Sunday': DayAvailability(enabled: false, time: 'Not available'),
  };

  void _handleSave() {
    // TODO: Save availability to API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Availability saved successfully!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Set Availability'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Select the days and times you\'re available to mentor this week.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._availability.entries.map((entry) {
                    return _buildDayCard(
                      entry.key,
                      entry.value,
                      theme,
                    );
                  }),
                ],
              ),
            ),
          ),

          // Save button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                top: BorderSide(
                  color: theme.brightness == Brightness.light
                      ? const Color(0xFFE5E7EB)
                      : const Color(0xFF374151),
                ),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  child: const Text('Save Availability'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(String day, DayAvailability availability, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  availability.time,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: availability.enabled,
            onChanged: (value) {
              setState(() {
                _availability[day] = DayAvailability(
                  enabled: value,
                  time: value ? '9:00 AM - 5:00 PM' : 'Not available',
                );
              });
            },
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class DayAvailability {
  final bool enabled;
  final String time;

  DayAvailability({required this.enabled, required this.time});
}
