import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/admin_analytics.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final ApiService _apiService = ApiService();
  AdminAnalytics? _analytics;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final analytics = await _apiService.getAdminAnalytics();
      setState(() {
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Analytics'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => Navigator.pushNamed(context, '/admin_mentor_management'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error loading analytics', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(_error!, style: theme.textTheme.bodySmall),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAnalytics,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAnalytics,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overview stats
                        Text(
                          'Platform Overview',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.3,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildStatCard(
                              'Total Users',
                              '${_analytics!.totalUsers}',
                              Icons.people,
                              theme,
                            ),
                            _buildStatCard(
                              'Active Mentors',
                              '${_analytics!.mentors.active}',
                              Icons.school,
                              theme,
                            ),
                            _buildStatCard(
                              'Total Sessions',
                              '${_analytics!.sessions.total}',
                              Icons.videocam,
                              theme,
                            ),
                            _buildStatCard(
                              'Avg. Rating',
                              _analytics!.reviews.averageRating.toStringAsFixed(1),
                              Icons.star,
                              theme,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Detailed Stats
                        Text(
                          'Detailed Statistics',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailCard('Students', '${_analytics!.students.total} total', '${_analytics!.students.active} active', theme),
                        const SizedBox(height: 8),
                        _buildDetailCard('Mentors', '${_analytics!.mentors.total} total', '${_analytics!.mentors.active} active', theme),
                        const SizedBox(height: 8),
                        _buildDetailCard(
                          'Sessions',
                          '${_analytics!.sessions.completed} completed',
                          '${_analytics!.sessions.pending} pending',
                          theme,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailCard(
                          'Completion Rate',
                          '${_analytics!.sessions.completionRate.toStringAsFixed(1)}%',
                          '${_analytics!.reviews.total} reviews',
                          theme,
                        ),
                        const SizedBox(height: 32),

                        // Quick Actions
                        Text(
                          'Management',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        _buildManagementButton(
                          'Manage Mentors',
                          Icons.school,
                          () => Navigator.pushNamed(context, '/admin_mentor_management'),
                          theme,
                        ),
                        const SizedBox(height: 8),
                        _buildManagementButton(
                          'Manage Students',
                          Icons.people,
                          () => Navigator.pushNamed(context, '/admin_student_management'),
                          theme,
                        ),
                        const SizedBox(height: 8),
                        _buildManagementButton(
                          'Financial Reports',
                          Icons.attach_money,
                          () => Navigator.pushNamed(context, '/admin_financial_reporting'),
                          theme,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String value1, String value2, ThemeData theme) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(value1, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Text(value2, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildManagementButton(String title, IconData icon, VoidCallback onTap, ThemeData theme) {
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: theme.textTheme.titleMedium),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
