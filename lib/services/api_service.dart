import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/mentor.dart';
import '../models/student.dart';
import '../models/session.dart';
import '../models/message.dart';
import '../models/notification.dart';
import '../models/progress.dart';
import '../models/counselor_dashboard.dart';
import '../models/admin_analytics.dart';
import '../models/counselor.dart';
import '../models/financial.dart';
import 'storage_service.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final StorageService _storage = StorageService();

  // Save token to storage
  Future<void> saveToken(String token) async {
    await _storage.saveToken(token);
  }

  // Get token from storage
  Future<String?> getToken() async {
    return await _storage.getToken();
  }

  // Clear token
  Future<void> clearToken() async {
    await _storage.clearToken();
  }

  // Add auth header if token exists
  Future<Options> _getAuthOptions() async {
    final token = await getToken();
    if (token != null) {
      return Options(headers: {'Authorization': 'Bearer $token'});
    }
    return Options();
  }

  // Auth - Signup
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String english_level,
    String? contact,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.signup,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'english_level': english_level,
          'contact': contact,
        },
      );

      // Save token
      await saveToken(response.data['token']);

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Auth - Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      // Save token
      await saveToken(response.data['token']);

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get mentors with filters
  Future<List<Mentor>> getMentors({
    int? day,
    String? from,
    String? to,
    String? level,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (day != null) queryParams['day'] = day;
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;
      if (level != null) queryParams['level'] = level;

      final response = await _dio.get(
        ApiConfig.mentors,
        queryParameters: queryParams,
      );

      final List mentorsList = response.data['mentors'];
      return mentorsList.map((json) => Mentor.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get mentor detail
  Future<Mentor> getMentorDetail(String id) async {
    try {
      final response = await _dio.get(ApiConfig.mentorDetail(id));
      return Mentor.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get current mentor profile
  Future<Mentor> getMyProfile() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        ApiConfig.mentorMe,
        options: options,
      );

      return Mentor.fromJson(response.data['mentor']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update own profile
  Future<Mentor> updateProfile({
    String? name,
    String? english_level,
    String? contact,
    String? timezone,
  }) async {
    try {
      final options = await _getAuthOptions();
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (english_level != null) data['english_level'] = english_level;
      if (contact != null) data['contact'] = contact;
      if (timezone != null) data['timezone'] = timezone;

      final response = await _dio.patch(
        ApiConfig.mentorMe,
        data: data,
        options: options,
      );

      return Mentor.fromJson(response.data['mentor']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get own availability
  Future<List<AvailabilitySlot>> getMyAvailability() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        ApiConfig.mentorAvailability,
        options: options,
      );

      final List slotsList = response.data['availability_slots'];
      return slotsList.map((json) => AvailabilitySlot.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update own availability
  Future<List<AvailabilitySlot>> updateAvailability(
    List<Map<String, dynamic>> slots,
  ) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        ApiConfig.mentorAvailability,
        data: {'slots': slots},
        options: options,
      );

      final List slotsList = response.data['availability_slots'];
      return slotsList.map((json) => AvailabilitySlot.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Logout
  Future<void> logout() async {
    await clearToken();
  }

  // === STUDENT ENDPOINTS ===

  // Get current student profile
  Future<Student> getStudentProfile() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(ApiConfig.studentMe, options: options);
      return Student.fromJson(response.data['student']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get student progress
  Future<StudentProgress> getStudentProgress() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(ApiConfig.studentProgress, options: options);
      return StudentProgress.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update student profile
  Future<Student> updateStudentProfile({
    String? name,
    String? phoneNumber,
    String? englishLevel,
    String? learningGoals,
  }) async {
    try {
      final options = await _getAuthOptions();
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;
      if (englishLevel != null) data['english_level'] = englishLevel;
      if (learningGoals != null) data['learning_goals'] = learningGoals;

      final response = await _dio.patch(
        ApiConfig.studentMe,
        data: data,
        options: options,
      );
      return Student.fromJson(response.data['student']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // === SESSION ENDPOINTS ===

  // Get sessions (with optional filters)
  Future<List<Session>> getSessions({
    String? status,
    String? mentorId,
    String? studentId,
  }) async {
    try {
      final options = await _getAuthOptions();
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (mentorId != null) queryParams['mentor_id'] = mentorId;
      if (studentId != null) queryParams['student_id'] = studentId;

      final response = await _dio.get(
        ApiConfig.sessions,
        queryParameters: queryParams,
        options: options,
      );
      final List sessionsList = response.data['sessions'];
      return sessionsList.map((json) => Session.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Create session (book)
  Future<Session> createSession({
    required String mentorId,
    required String sessionDate,
    required String startTime,
    required String endTime,
    required int durationMinutes,
    String? notes,
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        ApiConfig.sessions,
        data: {
          'mentor_id': mentorId,
          'session_date': sessionDate,
          'start_time': startTime,
          'end_time': endTime,
          'duration_minutes': durationMinutes,
          if (notes != null) 'notes': notes,
        },
        options: options,
      );
      return Session.fromJson(response.data['session']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get session detail
  Future<Session> getSessionDetail(String id) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        ApiConfig.sessionDetail(id),
        options: options,
      );
      return Session.fromJson(response.data['session']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update session (confirm, cancel, complete)
  Future<Session> updateSession({
    required String id,
    String? status,
    String? mentorFeedback,
    String? studentFeedback,
    String? cancellationReason,
  }) async {
    try {
      final options = await _getAuthOptions();
      final data = <String, dynamic>{};
      if (status != null) data['status'] = status;
      if (mentorFeedback != null) data['mentor_feedback'] = mentorFeedback;
      if (studentFeedback != null) data['student_feedback'] = studentFeedback;
      if (cancellationReason != null) data['cancellation_reason'] = cancellationReason;

      final response = await _dio.patch(
        ApiConfig.sessionDetail(id),
        data: data,
        options: options,
      );
      return Session.fromJson(response.data['session']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // === MESSAGE ENDPOINTS ===

  // Get messages (conversation with specific user)
  Future<List<Message>> getMessages({
    String? recipientId,
  }) async {
    try {
      final options = await _getAuthOptions();
      final queryParams = <String, dynamic>{};
      if (recipientId != null) queryParams['recipient_id'] = recipientId;

      final response = await _dio.get(
        ApiConfig.messages,
        queryParameters: queryParams,
        options: options,
      );
      final List messagesList = response.data['messages'];
      return messagesList.map((json) => Message.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Send message
  Future<Message> sendMessage({
    required String recipientId,
    required String recipientType,
    required String content,
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        ApiConfig.messages,
        data: {
          'recipient_id': recipientId,
          'recipient_type': recipientType,
          'content': content,
        },
        options: options,
      );
      return Message.fromJson(response.data['message']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // === NOTIFICATION ENDPOINTS ===

  // Get notifications
  Future<List<AppNotification>> getNotifications({bool? unreadOnly}) async {
    try {
      final options = await _getAuthOptions();
      final queryParams = <String, dynamic>{};
      if (unreadOnly == true) queryParams['unread_only'] = 'true';

      final response = await _dio.get(
        ApiConfig.notifications,
        queryParameters: queryParams,
        options: options,
      );
      final List notificationsList = response.data['notifications'];
      return notificationsList.map((json) => AppNotification.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String id) async {
    try {
      final options = await _getAuthOptions();
      await _dio.patch(
        ApiConfig.notificationDetail(id),
        data: {'is_read': true},
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // === REVIEW ENDPOINTS ===

  // Create review (rate mentor)
  Future<Map<String, dynamic>> createReview({
    required String sessionId,
    required int rating,
    String? comment,
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        ApiConfig.reviews,
        data: {
          'session_id': sessionId,
          'rating': rating,
          if (comment != null) 'comment': comment,
        },
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get mentor reviews
  Future<List<Map<String, dynamic>>> getMentorReviews(String mentorId) async {
    try {
      final response = await _dio.get(ApiConfig.mentorReviews(mentorId));
      final List reviewsList = response.data['reviews'];
      return reviewsList.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // === COUNSELOR ENDPOINTS ===

  // Get counselor dashboard
  Future<CounselorDashboard> getCounselorDashboard() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        ApiConfig.counselorDashboard,
        options: options,
      );
      return CounselorDashboard.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // === ADMIN ENDPOINTS ===

  // Get admin analytics
  Future<AdminAnalytics> getAdminAnalytics() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        ApiConfig.adminAnalytics,
        options: options,
      );
      return AdminAnalytics.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get all students (admin only)
  Future<List<Student>> getAdminStudents() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        ApiConfig.adminStudents,
        options: options,
      );
      final List studentsList = response.data['students'];
      return studentsList.map((json) => Student.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get all counselors (admin only)
  Future<List<Counselor>> getAdminCounselors() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        ApiConfig.adminCounselors,
        options: options,
      );
      final List counselorsList = response.data['counselors'];
      return counselorsList.map((json) => Counselor.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get transaction summary (admin only)
  Future<TransactionSummary> getAdminTransactionSummary() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        ApiConfig.adminTransactionsSummary,
        options: options,
      );
      return TransactionSummary.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get transactions (admin only)
  Future<List<Transaction>> getAdminTransactions({int limit = 20}) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${ApiConfig.adminTransactions}?limit=$limit',
        options: options,
      );
      final List transactionsList = response.data['transactions'];
      return transactionsList.map((json) => Transaction.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Handle errors
  String _handleError(DioException e) {
    if (e.response != null && e.response!.data != null) {
      final error = e.response!.data['error'];
      if (error != null && error['message'] != null) {
        return error['message'];
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error. Please try again later.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'Network error. Please check your connection.';
    }
  }
}
