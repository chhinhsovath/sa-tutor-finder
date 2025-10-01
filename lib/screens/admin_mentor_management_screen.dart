import 'package:flutter/material.dart';

class AdminMentorManagementScreen extends StatefulWidget {
  const AdminMentorManagementScreen({super.key});

  @override
  State<AdminMentorManagementScreen> createState() => _AdminMentorManagementScreenState();
}

class _AdminMentorManagementScreenState extends State<AdminMentorManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final mentors = [
      {'name': 'Ethan Carter', 'level': 'Advanced', 'status': 'Active'},
      {'name': 'Sarah Johnson', 'level': 'Intermediate', 'status': 'Active'},
      {'name': 'Michael Chen', 'level': 'Advanced', 'status': 'Inactive'},
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Mentors'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search mentors',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Filters
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Show English level filter
                        },
                        icon: const Icon(Icons.arrow_drop_down),
                        label: const Text('English Level'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Show status filter
                        },
                        icon: const Icon(Icons.arrow_drop_down),
                        label: const Text('Status'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Mentors list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: mentors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final mentor = mentors[index];
                return _buildMentorCard(mentor, theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorCard(Map<String, String> mentor, ThemeData theme) {
    final isActive = mentor['status'] == 'Active';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Text(
              mentor['name']!.substring(0, 1),
              style: TextStyle(
                fontSize: 20,
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
                  mentor['name']!,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  'English Level: ${mentor['level']}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    mentor['status']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? const Color(0xFF10B981) : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              // TODO: Navigate to mentor detail
            },
          ),
        ],
      ),
    );
  }
}
