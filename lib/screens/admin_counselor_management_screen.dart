import 'package:flutter/material.dart';

class AdminCounselorManagementScreen extends StatefulWidget {
  const AdminCounselorManagementScreen({super.key});

  @override
  State<AdminCounselorManagementScreen> createState() => _AdminCounselorManagementScreenState();
}

class _AdminCounselorManagementScreenState extends State<AdminCounselorManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final counselors = [
      {'name': 'Dr. Emily Anderson', 'students': '45', 'status': 'Active'},
      {'name': 'Mr. James Wilson', 'students': '38', 'status': 'Active'},
      {'name': 'Ms. Patricia Brown', 'students': '42', 'status': 'Active'},
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Guidance Counselors'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search counselors',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: counselors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final counselor = counselors[index];
                return _buildCounselorCard(counselor, theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounselorCard(Map<String, String> counselor, ThemeData theme) {
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
              counselor['name']!.substring(0, 1),
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
                  counselor['name']!,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  '${counselor['students']} students',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              // TODO: Navigate to counselor detail
            },
          ),
        ],
      ),
    );
  }
}
