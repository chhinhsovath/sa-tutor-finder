import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class SessionBookingScreen extends StatefulWidget {
  final String mentorId;
  final String mentorName;
  final String mentorAvatar;

  const SessionBookingScreen({
    super.key,
    required this.mentorId,
    required this.mentorName,
    required this.mentorAvatar,
  });

  @override
  State<SessionBookingScreen> createState() => _SessionBookingScreenState();
}

class _SessionBookingScreenState extends State<SessionBookingScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _selectedTime;

  final List<String> _availableTimes = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Book a Session'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mentor info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        child: Text(
                          widget.mentorName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.mentorName,
                              style: theme.textTheme.titleLarge,
                            ),
                            Text(
                              'Mentor',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Available Slots
                  Text(
                    'Available Slots',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.brightness == Brightness.light
                            ? const Color(0xFFE5E7EB)
                            : const Color(0xFF374151),
                      ),
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 90)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        weekendTextStyle: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        titleTextStyle: theme.textTheme.titleMedium!,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Select Time
                  Text(
                    'Select Time',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableTimes.map((time) {
                      final isSelected = _selectedTime == time;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTime = time;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary.withOpacity(0.1)
                                : theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : (theme.brightness == Brightness.light
                                      ? const Color(0xFFE5E7EB)
                                      : const Color(0xFF374151)),
                            ),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.textTheme.bodyLarge?.color,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Session Details
                  Text(
                    'Session Details',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.brightness == Brightness.light
                            ? const Color(0xFFE5E7EB)
                            : const Color(0xFF374151),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Date & Time',
                          '${_formatDate(_selectedDay)}, ${_selectedTime ?? "Not selected"}',
                          theme,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('Location', 'Online', theme),
                        const SizedBox(height: 16),
                        _buildDetailRow('Duration', '30 minutes', theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom section with button and nav
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _selectedTime == null
                          ? null
                          : () {
                              // TODO: Book session
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Session booked successfully!'),
                                  backgroundColor: Color(0xFF10B981),
                                ),
                              );
                            },
                      child: const Text('Book Session'),
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

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium,
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
