class ApiConfig {
  // Production API URL - default
  static const String baseUrl = 'https://apitutor.openplp.com/api';

  // Use this for local development
  // static const String baseUrl = 'http://localhost:3000/api';
  // static const String baseUrl = 'http://10.0.2.2:3000/api'; // For Android emulator

  // Auth endpoints
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';

  // Mentor endpoints
  static const String mentors = '/mentors';
  static String mentorDetail(String id) => '/mentors/$id';
  static const String mentorMe = '/mentors/me';
  static const String mentorAvailability = '/mentors/me/availability';
}
