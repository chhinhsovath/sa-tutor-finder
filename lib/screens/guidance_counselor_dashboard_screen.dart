import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/counselor_dashboard.dart';
import 'login_screen.dart';

class GuidanceCounselorDashboardScreen extends StatefulWidget {
  const GuidanceCounselorDashboardScreen({super.key});

  @override
  State<GuidanceCounselorDashboardScreen> createState() => _GuidanceCounselorDashboardScreenState();
}

class _GuidanceCounselorDashboardScreenState extends State<GuidanceCounselorDashboardScreen> {
  final ApiService _apiService = ApiService();
  CounselorDashboard? _dashboard;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final dashboard = await _apiService.getCounselorDashboard();
      setState(() {
        _dashboard = dashboard;
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
        title: const Text('Counselor Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
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
                      Text('Error loading dashboard', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(_error!, style: theme.textTheme.bodySmall),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDashboard,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDashboard,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome
                        Text(
                          'Welcome, ${_dashboard!.counselor.name}',
                          style: theme.textTheme.headlineMedium,
                        ),
                        if (_dashboard!.counselor.specialization != null)
                          Text(
                            _dashboard!.counselor.specialization!,
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        const SizedBox(height: 24),

                        // Statistics Grid
                        Text('Platform Statistics', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.5,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildStatCard(Icons.school, 'Students', '${_dashboard!.statistics.totalStudents}', theme),
                            _buildStatCard(Icons.person, 'Mentors', '${_dashboard!.statistics.totalMentors}', theme),
                            _buildStatCard(Icons.event, 'Sessions', '${_dashboard!.statistics.totalSessions}', theme),
                            _buildStatCard(Icons.star, 'Avg Rating', _dashboard!.statistics.averageRating.toStringAsFixed(1), theme),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Students Needing Attention
                        Text('Students Needing Attention', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 12),
                        if (_dashboard!.studentsNeedingAttention.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text('All students are doing well!', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                            ),
                          )
                        else
                          ..._dashboard!.studentsNeedingAttention.take(5).map((student) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildStudentCard(student, theme),
                              )),
                        const SizedBox(height: 24),

                        // Recent Sessions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Recent Sessions', style: theme.textTheme.titleLarge),
                            TextButton(
                              onPressed: () {},
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._dashboard!.recentSessions.take(5).map((session) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildSessionCard(session, theme),
                            )),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, ThemeData theme) {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 32),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.headlineSmall),
          Text(title, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildStudentCard(StudentNeedingAttention student, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.orange.withOpacity(0.1),
            child: Icon(Icons.person, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: theme.textTheme.titleMedium),
                Text('Level: ${student.englishLevel} • ${student.totalSessions} sessions', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Needs Help', style: TextStyle(fontSize: 12, color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(RecentSession session, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          CircleAvatar(
            radius: 20,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(Icons.event, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${session.studentName} ↔ ${session.mentorName}', style: theme.textTheme.titleSmall),
                Text(session.sessionDate, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(session.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              session.status.toUpperCase(),
              style: TextStyle(fontSize: 11, color: _getStatusColor(session.status), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
