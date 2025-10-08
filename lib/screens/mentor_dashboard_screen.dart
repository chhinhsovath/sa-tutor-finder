import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/session.dart';
import 'login_screen.dart';

class MentorDashboardScreen extends StatefulWidget {
  const MentorDashboardScreen({super.key});

  @override
  State<MentorDashboardScreen> createState() => _MentorDashboardScreenState();
}

class _MentorDashboardScreenState extends State<MentorDashboardScreen> {
  final ApiService _apiService = ApiService();
  List<Session> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      setState(() => _isLoading = true);
      final sessions = await _apiService.getSessions();
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmSession(String sessionId) async {
    try {
      await _apiService.updateSession(id: sessionId, status: 'confirmed');
      await _loadSessions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session confirmed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _cancelSession(String sessionId) async {
    try {
      await _apiService.updateSession(
        id: sessionId,
        status: 'cancelled',
        cancellationReason: 'Cancelled by mentor',
      );
      await _loadSessions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session cancelled')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final mentor = authProvider.currentMentor;

    final pendingSessions = _sessions.where((s) => s.isPending).toList();
    final upcomingSessions = _sessions.where((s) => s.isConfirmed).toList();
    final completedCount = _sessions.where((s) => s.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
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
          : RefreshIndicator(
              onRefresh: _loadSessions,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Text(
                            mentor?.name.substring(0, 1).toUpperCase() ?? 'M',
                            style: TextStyle(
                              fontSize: 36,
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
                                mentor?.name ?? 'Mentor',
                                style: theme.textTheme.headlineMedium,
                              ),
                              Text(
                                'English Level: ${mentor?.english_level ?? 'N/A'}',
                                style: theme.textTheme.bodySmall,
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    mentor?.status.toUpperCase() ?? 'ACTIVE',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Pending Sessions (need confirmation)
                    if (pendingSessions.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pending Requests',
                            style: theme.textTheme.titleLarge,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${pendingSessions.length}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...pendingSessions.map((session) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildPendingSessionCard(session, theme),
                          )),
                      const SizedBox(height: 24),
                    ],

                    // Upcoming Confirmed Sessions
                    Text(
                      'Upcoming Sessions',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (upcomingSessions.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No upcoming sessions',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ...upcomingSessions.take(5).map((session) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildUpcomingSessionCard(session, theme),
                          )),
                    const SizedBox(height: 32),

                    // Stats grid
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard(
                          Icons.calendar_today,
                          'Total Sessions',
                          '${_sessions.length}',
                          theme,
                          () => Navigator.pushNamed(context, '/availability_management'),
                        ),
                        _buildStatCard(
                          Icons.schedule,
                          'Pending',
                          '${pendingSessions.length}',
                          theme,
                          null,
                        ),
                        _buildStatCard(
                          Icons.history,
                          'Completed',
                          '$completedCount',
                          theme,
                          null,
                        ),
                        _buildStatCard(
                          Icons.star,
                          'Reviews',
                          'View',
                          theme,
                          () => Navigator.pushNamed(context, '/mentor_reviews'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPendingSessionCard(Session session, ThemeData theme) {
    final formattedDate = '${session.sessionDate.day}/${session.sessionDate.month}/${session.sessionDate.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.orange.withOpacity(0.1),
                child: const Icon(Icons.schedule, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session with ${session.studentName ?? 'Student'}',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      '$formattedDate • ${session.startTime} - ${session.endTime}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (session.notes != null) ...[
            const SizedBox(height: 8),
            Text(
              session.notes!,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _cancelSession(session.id),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Decline'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _confirmSession(session.id),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSessionCard(Session session, ThemeData theme) {
    final formattedDate = '${session.sessionDate.day}/${session.sessionDate.month}/${session.sessionDate.year}';

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
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(Icons.person, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.studentName ?? 'Student',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  '$formattedDate • ${session.startTime}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Confirmed',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, ThemeData theme, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
