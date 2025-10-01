class ApiConfig {
  // Production API URL - default
  static const String baseUrl = 'https://tutor.openplp.com/api';

  // Use this for local development
  // static const String baseUrl = 'http://localhost:3000/api';

  // Auth endpoints
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';

  // Mentor endpoints
  static const String mentors = '/mentors';
  static String mentorDetail(String id) => '/mentors/$id';
  static const String mentorMe = '/mentors/me';
  static const String mentorAvailability = '/mentors/me/availability';
}
