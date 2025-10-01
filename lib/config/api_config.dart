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
}
