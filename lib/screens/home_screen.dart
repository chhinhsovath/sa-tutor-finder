import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'student_dashboard_screen.dart';
import 'mentor_dashboard_screen.dart';
import 'guidance_counselor_dashboard_screen.dart';
import 'admin_analytics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentMentor;

    // Show loading while checking user
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Route to correct dashboard based on user_type
    final userType = user.userType?.toLowerCase() ?? 'student';

    Widget dashboard;
    switch (userType) {
      case 'mentor':
        dashboard = const MentorDashboardScreen();
        break;
      case 'student':
        dashboard = const StudentDashboardScreen();
        break;
      case 'counselor':
        dashboard = const GuidanceCounselorDashboardScreen();
        break;
      case 'admin':
        dashboard = const AdminAnalyticsScreen();
        break;
      default:
        dashboard = const StudentDashboardScreen();
    }

    // Use replacement to prevent going back to login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => dashboard),
        );
      }
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
