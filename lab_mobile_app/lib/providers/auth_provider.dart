import 'package:flutter/foundation.dart';
import '../services/django_api_service.dart';
import '../services/simple_hybrid_storage_service.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  final DjangoApiService _apiService = DjangoApiService();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  String? _username;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get username => _username;

  // Initialize authentication state
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _apiService.authToken;
      if (token != null) {
        // Try to validate the token by making a test API call
        try {
          await _apiService.getCurrentUser();
          await _apiService.syncLabGroupScopeFromProfile();
          await SimpleHybridStorageService().ensureLabGroupScope();
          _isAuthenticated = true;
          await _apiService.syncLabStripeConfig();
          await DjangoApiService.applyStripePublishableToSdk();
          print('✅ Token is valid - user is authenticated');
        } catch (e) {
          print('❌ Token expired - clearing authentication');
          await _apiService.clearAuthToken();
          _isAuthenticated = false;
        }
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.login(username, password);
      await _apiService.syncLabGroupScopeFromProfile();
      await SimpleHybridStorageService().ensureLabGroupScope();
      await _apiService.syncLabStripeConfig();
      await DjangoApiService.applyStripePublishableToSdk();
      _isAuthenticated = true;
      _username = username;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isAuthenticated = false;
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.clearAuthToken();
      await LabGroupScope.clearActiveScope();
      _isAuthenticated = false;
      _username = null;
      _error = null;
    } catch (e) {
      // Even if logout fails, clear local state
      _isAuthenticated = false;
      _username = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
