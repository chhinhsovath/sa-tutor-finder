import 'package:flutter/material.dart';
import '../models/mentor.dart';
import '../services/api_service.dart';
import 'mentor_detail_screen.dart';

class MentorSearchScreen extends StatefulWidget {
  const MentorSearchScreen({super.key});

  @override
  State<MentorSearchScreen> createState() => _MentorSearchScreenState();
}

class _MentorSearchScreenState extends State<MentorSearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Mentor> _mentors = [];
  bool _isLoading = false;
  String? _error;

  int? _selectedDay;
  String? _selectedTimeFrom;
  String? _selectedTimeTo;
  String? _selectedLevel;

  @override
  void initState() {
    super.initState();
    _loadMentors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMentors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final mentors = await _apiService.getMentors(
        day: _selectedDay,
        from: _selectedTimeFrom,
        to: _selectedTimeTo,
        level: _selectedLevel,
      );

      setState(() {
        _mentors = mentors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showDayPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('All Days'),
              onTap: () {
                setState(() => _selectedDay = null);
                Navigator.pop(context);
                _loadMentors();
              },
            ),
            ...List.generate(7, (index) {
              final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
              return ListTile(
                title: Text(days[index]),
                onTap: () {
                  setState(() => _selectedDay = index + 1);
                  Navigator.pop(context);
                  _loadMentors();
                },
              );
            }),
          ],
        );
      },
    );
  }

  void _showTimePicker() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempFrom = _selectedTimeFrom ?? '09:00';
        String? tempTo = _selectedTimeTo ?? '17:00';

        return AlertDialog(
          title: const Text('Select Time Range'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'From (HH:MM)'),
                controller: TextEditingController(text: tempFrom),
                onChanged: (value) => tempFrom = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'To (HH:MM)'),
                controller: TextEditingController(text: tempTo),
                onChanged: (value) => tempTo = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedTimeFrom = tempFrom;
                  _selectedTimeTo = tempTo;
                });
                Navigator.pop(context);
                _loadMentors();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showLevelPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('All Levels'),
              onTap: () {
                setState(() => _selectedLevel = null);
                Navigator.pop(context);
                _loadMentors();
              },
            ),
            ...['A1', 'A2', 'B1', 'B2', 'C1', 'C2'].map((level) {
              return ListTile(
                title: Text(level),
                onTap: () {
                  setState(() => _selectedLevel = level);
                  Navigator.pop(context);
                  _loadMentors();
                },
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Mentor'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search bar and filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a mentor',
                    prefixIcon: Icon(Icons.search, color: theme.textTheme.bodySmall?.color),
                  ),
                  onChanged: (value) {
                    // TODO: Implement search
                  },
                ),
                const SizedBox(height: 12),

                // Filter chips
                Row(
                  children: [
                    _buildFilterChip(
                      'Day',
                      _selectedDay != null,
                      _showDayPicker,
                      theme,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Time',
                      _selectedTimeFrom != null && _selectedTimeTo != null,
                      _showTimePicker,
                      theme,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'English level',
                      _selectedLevel != null,
                      _showLevelPicker,
                      theme,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Mentor list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: $_error'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadMentors,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _mentors.isEmpty
                        ? const Center(child: Text('No mentors found'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _mentors.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final mentor = _mentors[index];
                              return _buildMentorCard(mentor, theme);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive, VoidCallback onTap, ThemeData theme) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border.all(
            color: theme.brightness == Brightness.light
                ? const Color(0xFFE5E7EB)
                : const Color(0xFF374151),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isActive ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              size: 16,
              color: isActive ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMentorCard(Mentor mentor, ThemeData theme) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MentorDetailScreen(mentorId: mentor.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(
                mentor.name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mentor.name,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mentor.english_level,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right,
              color: theme.textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }
}
