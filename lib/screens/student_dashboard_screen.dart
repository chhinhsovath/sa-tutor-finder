import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/session.dart';
import '../models/progress.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final ApiService _apiService = ApiService();
  List<Session> _upcomingSessions = [];
  StudentProgress? _progress;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final sessions = await _apiService.getSessions(status: 'confirmed');
      final progress = await _apiService.getStudentProgress();

      // Filter upcoming sessions only
      final now = DateTime.now();
      final upcoming = sessions.where((s) {
        return s.sessionDate.isAfter(now.subtract(const Duration(days: 1)));
      }).toList();

      setState(() {
        _upcomingSessions = upcoming;
        _progress = progress;
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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentMentor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
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
                      Text('Error loading dashboard',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(_error!, style: theme.textTheme.bodySmall),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDashboardData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                child: Text(
                                  user?.name.substring(0, 1).toUpperCase() ?? 'S',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back,',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      user?.name ?? 'Student',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Quick actions
                        Text(
                          'Quick Actions',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.4,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildQuickActionCard(
                              Icons.search,
                              'Find Mentor',
                              theme.colorScheme.primary,
                              theme,
                              () => Navigator.pushNamed(context, '/mentor_search'),
                            ),
                            _buildQuickActionCard(
                              Icons.calendar_today,
                              'My Sessions',
                              const Color(0xFF10B981),
                              theme,
                              () {},
                            ),
                            _buildQuickActionCard(
                              Icons.message,
                              'Messages',
                              const Color(0xFFF59E0B),
                              theme,
                              () => Navigator.pushNamed(context, '/messaging'),
                            ),
                            _buildQuickActionCard(
                              Icons.assessment,
                              'Progress',
                              const Color(0xFF8B5CF6),
                              theme,
                              () => Navigator.pushNamed(context, '/student_progress'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Upcoming Sessions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Upcoming Sessions',
                              style: theme.textTheme.titleLarge,
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_upcomingSessions.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                'No upcoming sessions',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        else
                          ..._upcomingSessions.take(3).map((session) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildSessionCard(session, theme),
                            );
                          }).toList(),
                        const SizedBox(height: 32),

                        // Learning Progress
                        Text(
                          'Learning Progress',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        if (_progress != null) ...[
                          _buildProgressCard(
                            'English Level',
                            _progress!.currentLevel,
                            0.65,
                            '${_progress!.completedSessions} of ${_progress!.totalSessions} sessions',
                            theme,
                          ),
                          const SizedBox(height: 12),
                          _buildProgressCard(
                            'Total Hours',
                            '${_progress!.totalHours} hours',
                            _progress!.completionPercentage,
                            '${(_progress!.completionPercentage * 100).toStringAsFixed(0)}% Complete',
                            theme,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildQuickActionCard(
    IconData icon,
    String label,
    Color color,
    ThemeData theme,
    VoidCallback onTap,
  ) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard(Session session, ThemeData theme) {
    final formattedDate = '${session.sessionDate.day}/${session.sessionDate.month}/${session.sessionDate.year}';
    final timeStr = '${session.startTime} - ${session.endTime}';

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.videocam,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.notes ?? 'English Session',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      'with ${session.mentorName ?? 'Mentor'}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: session.isConfirmed
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  session.statusDisplay,
                  style: TextStyle(
                    fontSize: 12,
                    color: session.isConfirmed ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: theme.textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4),
              Text(
                formattedDate,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 16,
                color: theme.textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4),
              Text(
                timeStr,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to session detail
              },
              icon: const Icon(Icons.info_outline, size: 20),
              label: const Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    String title,
    String subtitle,
    double progress,
    String progressText,
    ThemeData theme,
  ) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium,
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progressText,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
