import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/mentor_search_screen.dart';
import 'screens/mentor_detail_screen.dart';
import 'screens/availability_management_screen.dart';
import 'screens/mentor_reviews_screen.dart';
import 'screens/messaging_screen.dart';
import 'screens/student_progress_reports_screen.dart';
import 'screens/profile_editing_screen.dart';
import 'screens/admin_mentor_management_screen.dart';
import 'screens/admin_student_management_screen.dart';
import 'screens/admin_financial_reporting_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  await StorageService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'SA Tutor Finder',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthChecker(),
        routes: {
          '/mentor_search': (context) => const MentorSearchScreen(),
          '/availability_management': (context) => const AvailabilityManagementScreen(),
          '/student_progress': (context) => const StudentProgressReportsScreen(),
          '/profile_edit': (context) => const ProfileEditingScreen(),
          '/admin_mentor_management': (context) => const AdminMentorManagementScreen(),
          '/admin_student_management': (context) => const AdminStudentManagementScreen(),
          '/admin_financial_reporting': (context) => const AdminFinancialReportingScreen(),
          '/messaging': (context) => const MessagingScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle routes that need arguments
          if (settings.name == '/mentor_detail') {
            final mentorId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) => MentorDetailScreen(mentorId: mentorId ?? ''),
            );
          }
          if (settings.name == '/mentor_reviews') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => MentorReviewsScreen(
                mentorId: args?['mentorId'] ?? '',
                mentorName: args?['mentorName'] ?? '',
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
