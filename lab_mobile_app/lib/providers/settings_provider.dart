import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/lab_settings.dart';
import '../services/django_api_service.dart';

class SettingsProvider extends ChangeNotifier {
  final DjangoApiService _apiService = DjangoApiService();
  
  LabSettings? _labSettings;
  bool _isLoading = false;
  String? _error;

  LabSettings? get labSettings => _labSettings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters for easy access
  String get labName => _labSettings?.labName ?? 'SAEED Laboratory';
  String get labAddress => _labSettings?.address ?? '';
  String get labContact => _labSettings?.contactNumber ?? '';
  String get labEmail => _labSettings?.email ?? '';
  String get labWebsite => _labSettings?.website ?? '';
  String get labLicense => _labSettings?.licenseNumber ?? '';
  List<Doctor> get doctors => _labSettings?.doctors ?? [];
  List<Technician> get technicians => _labSettings?.technicians ?? [];

  // Initialize settings provider
  Future<void> initialize() async {
    await loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Try to load from backend API first
      try {
        final apiSettings = await _apiService.getLabUiSettings();
        if (apiSettings.isNotEmpty) {
          _labSettings = LabSettings.fromApiJson(apiSettings);
          _error = null;
          // Cache locally
          await _saveToLocalStorage();
          return;
        }
      } catch (e) {
        print('Failed to load settings from API: $e');
      }
      
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('lab_settings');
      
      if (settingsJson != null) {
        final settings = jsonDecode(settingsJson);
        _labSettings = LabSettings.fromJson(settings);
        _error = null;
      } else {
        initializeDefaultSettings();
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _labSettings = null;
      initializeDefaultSettings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void initializeDefaultSettings() {
    _labSettings = LabSettings(
      labName: 'SAEED Laboratory',
      address: '123 Medical Center, City, State',
      contactNumber: '+1-234-567-8900',
      email: 'info@saiedlab.com',
      website: 'www.saiedlab.com',
      licenseNumber: 'LAB-2024-001',
      doctors: [
        Doctor(
          id: 1,
          name: 'Dr. Sarah Johnson',
          specialization: 'Pathology',
          licenseNumber: 'MD-001',
          contactNumber: '+1-234-567-8901',
          email: 'sarah.johnson@saiedlab.com',
          isActive: true,
        ),
        Doctor(
          id: 2,
          name: 'Dr. Michael Chen',
          specialization: 'Hematology',
          licenseNumber: 'MD-002',
          contactNumber: '+1-234-567-8902',
          email: 'michael.chen@saiedlab.com',
          isActive: true,
        ),
      ],
      technicians: [
        Technician(
          id: 1,
          name: 'John Smith',
          specialization: 'Blood Analysis',
          employeeId: 'TECH-001',
          contactNumber: '+1-234-567-8903',
          email: 'john.smith@saiedlab.com',
          isActive: true,
        ),
        Technician(
          id: 2,
          name: 'Emily Davis',
          specialization: 'Microbiology',
          employeeId: 'TECH-002',
          contactNumber: '+1-234-567-8904',
          email: 'emily.davis@saiedlab.com',
          isActive: true,
        ),
      ],
    );
  }

  Future<bool> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lab_settings', jsonEncode(_labSettings!.toJson()));
      return true;
    } catch (e) {
      _error = 'Failed to save settings: $e';
      return false;
    }
  }

  Future<bool> updateLabSettings(LabSettings settings) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _labSettings = settings;
      // Try to sync with backend API
      try {
        await _apiService.updateLabUiSettings(settings.additionalSettings.isNotEmpty
            ? settings.additionalSettings
            : settings.toJson());
      } catch (e) {
        print('Failed to sync settings to backend: $e');
      }
      final success = await _saveToLocalStorage();
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateLabInfo({
    String? labName,
    String? address,
    String? contactNumber,
    String? email,
    String? website,
    String? licenseNumber,
  }) async {
    if (_labSettings == null) return false;

    final updatedSettings = _labSettings!.copyWith(
      labName: labName,
      address: address,
      contactNumber: contactNumber,
      email: email,
      website: website,
      licenseNumber: licenseNumber,
    );

    return await updateLabSettings(updatedSettings);
  }

  Future<bool> addDoctor(Doctor doctor) async {
    if (_labSettings == null) return false;

    final updatedDoctors = List<Doctor>.from(_labSettings!.doctors)..add(doctor);
    final updatedSettings = _labSettings!.copyWith(doctors: updatedDoctors);

    return await updateLabSettings(updatedSettings);
  }

  Future<bool> updateDoctor(Doctor doctor) async {
    if (_labSettings == null) return false;

    final updatedDoctors = _labSettings!.doctors.map((d) {
      return d.id == doctor.id ? doctor : d;
    }).toList();

    final updatedSettings = _labSettings!.copyWith(doctors: updatedDoctors);

    return await updateLabSettings(updatedSettings);
  }

  Future<bool> deleteDoctor(int doctorId) async {
    if (_labSettings == null) return false;

    final updatedDoctors = _labSettings!.doctors.where((d) => d.id != doctorId).toList();
    final updatedSettings = _labSettings!.copyWith(doctors: updatedDoctors);

    return await updateLabSettings(updatedSettings);
  }

  Future<bool> addTechnician(Technician technician) async {
    if (_labSettings == null) return false;

    final updatedTechnicians = List<Technician>.from(_labSettings!.technicians)..add(technician);
    final updatedSettings = _labSettings!.copyWith(technicians: updatedTechnicians);

    return await updateLabSettings(updatedSettings);
  }

  Future<bool> updateTechnician(Technician technician) async {
    if (_labSettings == null) return false;

    final updatedTechnicians = _labSettings!.technicians.map((t) {
      return t.id == technician.id ? technician : t;
    }).toList();

    final updatedSettings = _labSettings!.copyWith(technicians: updatedTechnicians);

    return await updateLabSettings(updatedSettings);
  }

  Future<bool> deleteTechnician(int technicianId) async {
    if (_labSettings == null) return false;

    final updatedTechnicians = _labSettings!.technicians.where((t) => t.id != technicianId).toList();
    final updatedSettings = _labSettings!.copyWith(technicians: updatedTechnicians);

    return await updateLabSettings(updatedSettings);
  }

  List<Doctor> getActiveDoctors() {
    return doctors.where((doctor) => doctor.isActive).toList();
  }

  List<Technician> getActiveTechnicians() {
    return technicians.where((technician) => technician.isActive).toList();
  }

  Doctor? getDoctorById(int id) {
    try {
      return doctors.firstWhere((doctor) => doctor.id == id);
    } catch (e) {
      return null;
    }
  }

  Technician? getTechnicianById(int id) {
    try {
      return technicians.firstWhere((technician) => technician.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Doctor> searchDoctors(String query) {
    if (query.isEmpty) return doctors;
    
    return doctors.where((doctor) {
      return doctor.name.toLowerCase().contains(query.toLowerCase()) ||
             doctor.specialization.toLowerCase().contains(query.toLowerCase()) ||
             doctor.licenseNumber.contains(query);
    }).toList();
  }

  List<Technician> searchTechnicians(String query) {
    if (query.isEmpty) return technicians;
    
    return technicians.where((technician) {
      return technician.name.toLowerCase().contains(query.toLowerCase()) ||
             technician.specialization.toLowerCase().contains(query.toLowerCase()) ||
             technician.employeeId.contains(query);
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // API Connection Test
  Future<bool> testApiConnection() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final isConnected = await _apiService.testApiConnection();
      _error = null;
      return isConnected;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Theme Management
  Future<bool> updateTheme(String theme) async {
    try {
      // Save theme preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme', theme);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Notification Settings
  Future<bool> updateNotificationSettings({
    bool? emailNotifications,
    bool? smsNotifications,
    bool? pushNotifications,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (emailNotifications != null) {
        await prefs.setBool('email_notifications', emailNotifications);
      }
      if (smsNotifications != null) {
        await prefs.setBool('sms_notifications', smsNotifications);
      }
      if (pushNotifications != null) {
        await prefs.setBool('push_notifications', pushNotifications);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Security Settings
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      await _apiService.changePassword(currentPassword, newPassword);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }
}
