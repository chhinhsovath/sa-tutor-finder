class ApiConfig {
  // Production API URL - CORS enabled, accessible from anywhere
  static const String baseUrl = 'https://apitutor.openplp.com/api';

  // Auth endpoints
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';

  // Mentor endpoints
  static const String mentors = '/mentors';
  static String mentorDetail(String id) => '/mentors/$id';
  static const String mentorMe = '/mentors/me';
  static const String mentorAvailability = '/mentors/me/availability';
  static String mentorReviews(String id) => '/mentors/$id/reviews';

  // Student endpoints
  static const String students = '/students';
  static const String studentMe = '/students/me';
  static const String studentProgress = '/students/me/progress';
  static String studentDetailProgress(String id) => '/students/$id/progress';

  // Session endpoints
  static const String sessions = '/sessions';
  static String sessionDetail(String id) => '/sessions/$id';
  static String sessionFeedback(String id) => '/sessions/$id/feedback';

  // Message endpoints
  static const String messages = '/messages';

  // Notification endpoints
  static const String notifications = '/notifications';
  static String notificationDetail(String id) => '/notifications/$id';
  static const String notificationPreferences = '/notifications/preferences';

  // Review endpoints
  static const String reviews = '/reviews';

  // Counselor endpoints
  static const String counselorMe = '/counselors/me';
  static const String counselorDashboard = '/counselors/dashboard';

  // Admin endpoints
  static const String adminAnalytics = '/admin/analytics';
  static const String adminMentors = '/admin/mentors';
  static const String adminStudents = '/admin/students';
  static const String adminCounselors = '/admin/counselors';
  static const String adminTransactions = '/admin/transactions';
  static const String adminTransactionsSummary = '/admin/transactions/summary';
  static String adminMentorStatus(String id) => '/admin/mentors/$id/status';
  static String adminStudentDetail(String id) => '/admin/students/$id';
  static String adminCounselorDetail(String id) => '/admin/counselors/$id';

  // Support endpoints
  static const String supportFaq = '/support/faq';
  static const String supportTickets = '/support/tickets';
}
