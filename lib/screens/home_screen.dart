import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'student_dashboard_screen.dart';
import 'mentor_dashboard_screen.dart';
import 'guidance_counselor_dashboard_screen.dart';
import 'admin_analytics_screen.dart';
import 'availability_management_screen.dart';
import 'profile_editing_screen.dart';
import 'mentor_reviews_screen.dart';
import 'session_feedback_screen.dart';
import 'messaging_screen.dart';
import 'notification_settings_screen.dart';
import 'help_support_screen.dart';
import 'mentor_search_screen.dart';
import 'session_booking_screen.dart';
import 'rate_mentor_screen.dart';
import 'student_progress_reports_screen.dart';
import 'admin_mentor_management_screen.dart';
import 'admin_student_management_screen.dart';
import 'admin_counselor_management_screen.dart';
import 'admin_financial_reporting_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentMentor;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userType = user.userType?.toLowerCase() ?? 'student';
    final roleDisplayName = _getRoleDisplayName(userType);
    final roleColor = _getRoleColor(userType);
    final screens = _getScreensForRole(userType, user.id, user.name);

    return Scaffold(
      appBar: AppBar(
        title: Text('$roleDisplayName Features'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [roleColor, roleColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
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
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          roleDisplayName,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Screen Count
            Text(
              'Available Features (${screens.length} screens)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Screens organized by category
            ...screens.map((category) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      category['category'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: roleColor,
                          ),
                    ),
                  ),
                  ...((category['items'] as List).map((screen) {
                    return _buildScreenCard(
                      context,
                      screen['title'] as String,
                      screen['description'] as String,
                      screen['icon'] as IconData,
                      screen['route'] as Widget?,
                      roleColor,
                    );
                  })),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Widget? route,
    Color roleColor,
  ) {
    final theme = Theme.of(context);
    final isAvailable = route != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable ? roleColor.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
        ),
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
          onTap: isAvailable
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => route),
                  );
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? roleColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isAvailable ? roleColor : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  isAvailable ? Icons.chevron_right : Icons.lock_outline,
                  color: isAvailable ? roleColor : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getRoleDisplayName(String userType) {
    switch (userType) {
      case 'mentor':
        return '🔵 Mentor Role';
      case 'student':
        return '🟢 Student Role';
      case 'counselor':
        return '🟡 Counselor Role';
      case 'admin':
        return '🔴 Admin Role';
      default:
        return 'User';
    }
  }

  Color _getRoleColor(String userType) {
    switch (userType) {
      case 'mentor':
        return Colors.blue;
      case 'student':
        return Colors.green;
      case 'counselor':
        return Colors.orange;
      case 'admin':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _getScreensForRole(String userType, String userId, String userName) {
    switch (userType) {
      case 'mentor':
        return _getMentorScreens(userId, userName);
      case 'student':
        return _getStudentScreens();
      case 'counselor':
        return _getCounselorScreens();
      case 'admin':
        return _getAdminScreens();
      default:
        return _getStudentScreens();
    }
  }

  List<Map<String, dynamic>> _getMentorScreens(String mentorId, String mentorName) {
    return [
      {
        'category': 'Dashboard & Core',
        'items': [
          {
            'title': 'Mentor Dashboard',
            'description': 'Profile header, pending requests, upcoming sessions, stats',
            'icon': Icons.dashboard,
            'route': const MentorDashboardScreen(),
          },
          {
            'title': 'Availability Management',
            'description': 'Manage weekly recurring schedule (day of week + time slots)',
            'icon': Icons.calendar_today,
            'route': const AvailabilityManagementScreen(),
          },
          {
            'title': 'Profile Editing',
            'description': 'Edit: Name, Email, Phone, Password, English Level',
            'icon': Icons.edit,
            'route': const ProfileEditingScreen(),
          },
          {
            'title': 'Mentor Reviews',
            'description': 'View ratings and reviews from students (1-5 stars)',
            'icon': Icons.star,
            'route': MentorReviewsScreen(mentorId: mentorId, mentorName: mentorName),
          },
        ],
      },
      {
        'category': 'Session Management',
        'items': [
          {
            'title': 'Session Feedback',
            'description': 'Provide feedback after completing sessions',
            'icon': Icons.feedback,
            'route': const SessionFeedbackScreen(),
          },
        ],
      },
      {
        'category': 'Communication',
        'items': [
          {
            'title': 'Messaging',
            'description': '1-on-1 chat with students',
            'icon': Icons.message,
            'route': const MessagingScreen(),
          },
        ],
      },
      {
        'category': 'Settings & Support',
        'items': [
          {
            'title': 'Notification Settings',
            'description': 'Configure push notification preferences',
            'icon': Icons.notifications,
            'route': const NotificationSettingsScreen(),
          },
          {
            'title': 'Help & Support',
            'description': 'FAQ, contact support',
            'icon': Icons.help,
            'route': const HelpSupportScreen(),
          },
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getStudentScreens() {
    return [
      {
        'category': 'Dashboard & Core',
        'items': [
          {
            'title': 'Student Dashboard',
            'description': 'Quick actions: Find Mentor, My Sessions, Messages, Progress',
            'icon': Icons.dashboard,
            'route': const StudentDashboardScreen(),
          },
          {
            'title': 'Profile Editing',
            'description': 'Edit: Name, Email, Phone, Password, English Level',
            'icon': Icons.edit,
            'route': const ProfileEditingScreen(),
          },
        ],
      },
      {
        'category': 'Mentor Discovery',
        'items': [
          {
            'title': 'Mentor Search',
            'description': 'Search bar, filter by day/time/English level',
            'icon': Icons.search,
            'route': const MentorSearchScreen(),
          },
        ],
      },
      {
        'category': 'Session Management',
        'items': [
          {
            'title': 'Session Booking',
            'description': 'Calendar view - select date/time for session',
            'icon': Icons.book_online,
            'route': const SessionBookingScreen(),
          },
          {
            'title': 'Rate Mentor',
            'description': 'Give 1-5 star rating after session',
            'icon': Icons.rate_review,
            'route': const RateMentorScreen(),
          },
        ],
      },
      {
        'category': 'Progress Tracking',
        'items': [
          {
            'title': 'Student Progress Reports',
            'description': 'View: English level progression, total hours, completed sessions',
            'icon': Icons.assessment,
            'route': const StudentProgressReportsScreen(),
          },
        ],
      },
      {
        'category': 'Communication',
        'items': [
          {
            'title': 'Messaging',
            'description': 'Chat with mentor',
            'icon': Icons.message,
            'route': const MessagingScreen(),
          },
        ],
      },
      {
        'category': 'Settings & Support',
        'items': [
          {
            'title': 'Notification Settings',
            'description': 'Configure notification preferences',
            'icon': Icons.notifications,
            'route': const NotificationSettingsScreen(),
          },
          {
            'title': 'Help & Support',
            'description': 'FAQ, contact support',
            'icon': Icons.help,
            'route': const HelpSupportScreen(),
          },
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCounselorScreens() {
    return [
      {
        'category': 'Dashboard & Monitoring',
        'items': [
          {
            'title': 'Counselor Dashboard',
            'description': 'Platform stats, Students Needing Attention, Recent Sessions',
            'icon': Icons.dashboard,
            'route': const GuidanceCounselorDashboardScreen(),
          },
          {
            'title': 'Profile Editing',
            'description': 'Edit counselor profile details',
            'icon': Icons.edit,
            'route': const ProfileEditingScreen(),
          },
        ],
      },
      {
        'category': 'Communication',
        'items': [
          {
            'title': 'Messaging',
            'description': 'Communicate with students/mentors',
            'icon': Icons.message,
            'route': const MessagingScreen(),
          },
        ],
      },
      {
        'category': 'Settings & Support',
        'items': [
          {
            'title': 'Notification Settings',
            'description': 'Configure notification preferences',
            'icon': Icons.notifications,
            'route': const NotificationSettingsScreen(),
          },
          {
            'title': 'Help & Support',
            'description': 'FAQ, contact support',
            'icon': Icons.help,
            'route': const HelpSupportScreen(),
          },
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getAdminScreens() {
    return [
      {
        'category': 'Analytics Dashboard',
        'items': [
          {
            'title': 'Admin Analytics',
            'description': 'Platform Overview: Total users, mentors, sessions, avg rating',
            'icon': Icons.analytics,
            'route': const AdminAnalyticsScreen(),
          },
        ],
      },
      {
        'category': 'User Management',
        'items': [
          {
            'title': 'Mentor Management',
            'description': 'List all mentors, search, filter by level/status',
            'icon': Icons.school,
            'route': const AdminMentorManagementScreen(),
          },
          {
            'title': 'Student Management',
            'description': 'List all students, search by name, view details',
            'icon': Icons.people,
            'route': const AdminStudentManagementScreen(),
          },
          {
            'title': 'Counselor Management',
            'description': 'List all counselors, search, view specialization',
            'icon': Icons.support_agent,
            'route': const AdminCounselorManagementScreen(),
          },
        ],
      },
      {
        'category': 'Financial',
        'items': [
          {
            'title': 'Financial Reporting',
            'description': 'Revenue summary, transaction stats, recent transactions',
            'icon': Icons.attach_money,
            'route': const AdminFinancialReportingScreen(),
          },
        ],
      },
      {
        'category': 'Settings',
        'items': [
          {
            'title': 'Profile Editing',
            'description': 'Edit admin profile',
            'icon': Icons.edit,
            'route': const ProfileEditingScreen(),
          },
        ],
      },
      {
        'category': 'Communication',
        'items': [
          {
            'title': 'Messaging',
            'description': 'System-wide communication',
            'icon': Icons.message,
            'route': const MessagingScreen(),
          },
        ],
      },
    ];
  }
}
