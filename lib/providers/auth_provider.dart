import 'package:flutter/foundation.dart';
import '../models/mentor.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  Mentor? _currentMentor;
  bool _isLoading = true; // Start with loading true
  String? _error;

  Mentor? get currentMentor => _currentMentor;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentMentor != null;

  AuthProvider() {
    // CRITICAL: Initialize auth state on app start to prevent redirect to login on refresh
    _initializeAuth();
  }

  // Initialize auth state
  Future<void> _initializeAuth() async {
    // Try to restore saved session
    await restoreSession();
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String user_type, // 'mentor', 'student', 'counselor'
    String? english_level,
    String? contact,
    String? phone_number,
    String? learning_goals,
    String? specialization,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.signup(
        name: name,
        email: email,
        password: password,
        user_type: user_type,
        english_level: english_level,
        contact: contact,
        phone_number: phone_number,
        learning_goals: learning_goals,
        specialization: specialization,
      );

      // API returns 'user' object with user_type field
      _currentMentor = Mentor.fromJson(response['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      // API returns 'user' not 'mentor' - works for all user types
      _currentMentor = Mentor.fromJson(response['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check for existing session on app start
  Future<bool> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _apiService.getToken();
      if (token == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Fetch current user profile using stored token
      _currentMentor = await _apiService.getMyProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Token is invalid or expired, clear it
      await _apiService.clearToken();
      _currentMentor = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _currentMentor = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
