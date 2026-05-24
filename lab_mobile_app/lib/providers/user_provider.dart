import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/user_create_request.dart';
import '../models/user_update_request.dart';
import '../services/django_api_service.dart';

class UserProvider extends ChangeNotifier {
  final DjangoApiService _apiService = DjangoApiService();
  
  List<User> _users = [];
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered lists
  List<User> get activeUsers => _users.where((user) => user.isActive).toList();
  List<User> get adminUsers => _users.where((user) => user.isAdmin).toList();
  List<User> get doctorUsers => _users.where((user) => user.isDoctor).toList();
  List<User> get technicianUsers => _users.where((user) => user.isTechnician).toList();

  Future<void> loadUsers() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final users = await _apiService.getUsers();
      _users = users;
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      if (_users.isEmpty) {
        initializeDemoUsers();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser(UserCreateRequest userRequest) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newUser = await _apiService.createUser(userRequest);
      _users.add(newUser);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '').trim();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(int id, UserUpdateRequest userRequest) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _apiService.updateUser(id, userRequest);
      final index = _users.indexWhere((user) => user.id == id);
      if (index != -1) {
        _users[index] = updatedUser;
      }
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

  Future<bool> deleteUser(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteUser(id);
      _users.removeWhere((user) => user.id == id);
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

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.changePassword(currentPassword, newPassword);
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

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearCurrentUser() {
    _currentUser = null;
    notifyListeners();
  }

  User? getUserById(int id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  List<User> searchUsers(String query) {
    if (query.isEmpty) return _users;
    
    return _users.where((user) {
      return user.username.toLowerCase().contains(query.toLowerCase()) ||
             user.fullName.toLowerCase().contains(query.toLowerCase()) ||
             user.email.toLowerCase().contains(query.toLowerCase()) ||
             user.role.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<User> getUsersByRole(String role) {
    return _users.where((user) => user.role.toLowerCase() == role.toLowerCase()).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Initialize with demo users if none exist
  void initializeDemoUsers() {
    if (_users.isEmpty) {
      _users = [
        User(
          id: 1,
          username: 'admin',
          fullName: 'System Administrator',
          email: 'admin@saiedlab.com',
          role: 'admin',
          isActive: true,
        ),
        User(
          id: 2,
          username: 'doctor1',
          fullName: 'Dr. John Smith',
          email: 'john.smith@saiedlab.com',
          role: 'doctor',
          isActive: true,
        ),
        User(
          id: 3,
          username: 'tech1',
          fullName: 'Sarah Johnson',
          email: 'sarah.johnson@saiedlab.com',
          role: 'technician',
          isActive: true,
        ),
      ];
      notifyListeners();
    }
  }
}
