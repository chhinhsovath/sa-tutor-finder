import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../models/mentor.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Save token to secure storage
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // Get token from secure storage
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Clear token
  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
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

      return Mentor.fromJson(response.data);
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
