import 'package:flutter/material.dart';
import '../models/mentor.dart';
import '../services/api_service.dart';

class MentorDetailScreen extends StatefulWidget {
  final String mentorId;

  const MentorDetailScreen({super.key, required this.mentorId});

  @override
  State<MentorDetailScreen> createState() => _MentorDetailScreenState();
}

class _MentorDetailScreenState extends State<MentorDetailScreen> {
  final ApiService _apiService = ApiService();

  Mentor? _mentor;
  bool _isLoading = false;
  String? _error;

  DateTime _currentMonth = DateTime.now();
  int? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadMentorDetail();
  }

  Future<void> _loadMentorDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final mentor = await _apiService.getMentorDetail(widget.mentorId);

      setState(() {
        _mentor = mentor;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mentor Profile'),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mentor Profile'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadMentorDetail,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_mentor == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mentor Profile'),
          centerTitle: true,
        ),
        body: const Center(child: Text('Mentor not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Mentor Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 64,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      _mentor!.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    _mentor!.name,
                    style: theme.textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // English level
                  Text(
                    'English Level: ${_mentor!.english_level}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),

                  // Status
                  Text(
                    _mentor!.status == 'active'
                        ? 'Available for tutoring'
                        : 'Currently unavailable',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Contact section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  _buildContactItem(
                    Icons.email,
                    _mentor!.email,
                    theme,
                  ),
                  const SizedBox(height: 12),

                  // Contact info if available
                  if (_mentor!.contact != null)
                    _buildContactItem(
                      Icons.phone,
                      _mentor!.contact!,
                      theme,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Availability section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Availability',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),

                  // Calendar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildCalendar(theme),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Space for bottom buttons
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(theme),
    );
  }

  Widget _buildContactItem(IconData icon, String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(ThemeData theme) {
    final monthName = [
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
    ][_currentMonth.month - 1];

    return Column(
      children: [
        // Month navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _previousMonth,
            ),
            Text(
              '$monthName ${_currentMonth.year}',
              style: theme.textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _nextMonth,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
            return SizedBox(
              width: 40,
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // Calendar grid
        ..._buildCalendarGrid(theme),
      ],
    );
  }

  List<Widget> _buildCalendarGrid(ThemeData theme) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startWeekday = firstDay.weekday % 7; // Sunday = 0

    List<Widget> rows = [];
    List<Widget> currentRow = [];

    // Add empty cells for days before the first day of the month
    for (int i = 0; i < startWeekday; i++) {
      currentRow.add(const SizedBox(width: 40, height: 40));
    }

    // Add cells for each day of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final isSelected = _selectedDay == day;
      final isToday = DateTime.now().day == day &&
          DateTime.now().month == _currentMonth.month &&
          DateTime.now().year == _currentMonth.year;

      currentRow.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = day;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : isToday
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : theme.textTheme.bodyMedium?.color,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );

      if ((startWeekday + day) % 7 == 0 || day == daysInMonth) {
        // Fill remaining cells in the last row
        while (currentRow.length < 7) {
          currentRow.add(const SizedBox(width: 40, height: 40));
        }
        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: currentRow,
            ),
          ),
        );
        currentRow = [];
      }
    }

    return rows;
  }

  Widget _buildBottomButtons(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.light
                ? const Color(0xFFE5E7EB)
                : const Color(0xFF374151),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement book session
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Booking session...')),
                      );
                    },
                    child: const Text('Book Session'),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Implement messaging
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening messages...')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      side: BorderSide.none,
                    ),
                    child: Text(
                      'Message',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
