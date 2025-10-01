import 'package:flutter/foundation.dart';
import '../models/mentor.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  Mentor? _currentMentor;
  bool _isLoading = false;
  String? _error;

  Mentor? get currentMentor => _currentMentor;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentMentor != null;

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String english_level,
    String? contact,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.signup(
        name: name,
        email: email,
        password: password,
        english_level: english_level,
        contact: contact,
      );

      _currentMentor = Mentor.fromJson(response['mentor']);
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

      _currentMentor = Mentor.fromJson(response['mentor']);
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
