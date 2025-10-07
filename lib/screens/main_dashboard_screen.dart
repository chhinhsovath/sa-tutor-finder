import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'student_dashboard_screen.dart';
import 'mentor_dashboard_screen.dart';
import 'guidance_counselor_dashboard_screen.dart';
import 'admin_analytics_screen.dart';

/// Main dashboard that routes users to their role-specific home screen
class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentMentor;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Route to appropriate dashboard based on user_type from API
    final userType = user.userType;

    switch (userType) {
      case 'student':
        return const StudentDashboardScreen();
      case 'mentor':
        return const MentorDashboardScreen();
      case 'counselor':
        return const GuidanceCounselorDashboardScreen();
      case 'admin':
        return const AdminAnalyticsScreen();
      default:
        // Fallback to mentor dashboard if user_type is null or unknown
        return const MentorDashboardScreen();
    }
  }
}
