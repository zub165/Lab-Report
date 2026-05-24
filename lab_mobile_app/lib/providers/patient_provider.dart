import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/django_api_service.dart';
import '../services/local_storage_service.dart';
import '../utils/constants.dart';

class PatientProvider extends ChangeNotifier {
  final DjangoApiService _apiService = DjangoApiService();
  
  List<Patient> _patients = [];
  Patient? _selectedPatient;
  bool _isLoading = false;
  String? _error;

  List<Patient> get patients => _patients;
  Patient? get selectedPatient => _selectedPatient;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPatients() async {
    try {
      _isLoading = true;
      _error = null;
      scheduleProviderNotify(this);

      print('🔄 Loading patients from API...');
      _patients = await _apiService.getPatients();
      await LocalStorageService.savePatients(_patients);
      
      print('✅ Loaded ${_patients.length} patients (hybrid storage)');
      _error = null;
    } catch (e) {
      print('❌ Failed to load patients from API: $e');
      
      // Fallback to local storage
      try {
        print('🔄 Loading patients from local storage...');
        final localPatients = await LocalStorageService.loadPatients();
        _patients = localPatients;
        print('✅ Loaded ${localPatients.length} patients from local storage');
        _error = 'Using cached data - Backend unavailable';
      } catch (localError) {
        print('❌ Failed to load from local storage: $localError');
        _patients = [];
        _error = 'Failed to load patients: $e';
      }
    } finally {
      _isLoading = false;
      scheduleProviderNotify(this);
    }
  }

  Future<bool> addPatient(Patient patient) async {
    try {
      _isLoading = true;
      scheduleProviderNotify(this);

      print('🔄 Adding patient via API...');
      final newPatient = await _apiService.createPatient(patient);
      
      // Add to local list
      _patients.add(newPatient);
      
      print('✅ Patient added successfully (hybrid storage)');
      _error = null;
      return true;
    } catch (e) {
      print('❌ Failed to add patient to API: $e');
      
      // Fallback to local storage only
      try {
        // Generate a temporary ID for local storage
        final tempPatient = patient.copyWith(
          patientId: 'LOCAL_${DateTime.now().millisecondsSinceEpoch}',
        );
        
        _patients.add(tempPatient);
        await LocalStorageService.savePatients(_patients);
        
        print('✅ Patient added to local storage only');
        _error = 'Saved locally - Backend unavailable';
        return true;
      } catch (localError) {
        print('❌ Failed to save locally: $localError');
        _error = 'Failed to add patient: $e';
        return false;
      }
    } finally {
      _isLoading = false;
      scheduleProviderNotify(this);
    }
  }

  Future<bool> updatePatient(Patient patient) async {
    try {
      _isLoading = true;
      scheduleProviderNotify(this);

      print('🔄 Updating patient in backend API...');
      
      // Try to update in backend API first
      final pid = int.tryParse(patient.patientId ?? '');
      if (pid == null) throw Exception('Cannot sync local ID to backend');
      final updatedPatient = await _apiService.updatePatient(pid, patient);
      
      // Update in local list
      final index = _patients.indexWhere((p) => p.patientId == patient.patientId);
      if (index != -1) {
        _patients[index] = updatedPatient;
      }
      
      // Update local storage
      await LocalStorageService.savePatients(_patients);
      
      print('✅ Patient updated successfully in backend');
      _error = null;
      return true;
    } catch (e) {
      print('❌ Failed to update patient in API: $e');
      
      // Fallback to local storage only
      try {
        final index = _patients.indexWhere((p) => p.patientId == patient.patientId);
        if (index != -1) {
          _patients[index] = patient;
          await LocalStorageService.savePatients(_patients);
          
          print('✅ Patient updated in local storage only');
          _error = 'Updated locally - Backend unavailable';
          return true;
        }
        return false;
      } catch (localError) {
        print('❌ Failed to update locally: $localError');
        _error = 'Failed to update patient: $e';
        return false;
      }
    } finally {
      _isLoading = false;
      scheduleProviderNotify(this);
    }
  }

  Future<bool> deletePatient(String patientId) async {
    try {
      _isLoading = true;
      scheduleProviderNotify(this);

      print('🔄 Deleting patient from backend API...');
      
      // Try to delete from backend API first
      final pid = int.tryParse(patientId);
      if (pid != null) {
        await _apiService.deletePatient(pid);
      }
      
      // Remove from local list
      _patients.removeWhere((p) => p.patientId == patientId);
      
      // Update local storage
      await LocalStorageService.savePatients(_patients);
      
      print('✅ Patient deleted successfully from backend');
      _error = null;
      return true;
    } catch (e) {
      print('❌ Failed to delete patient from API: $e');
      
      // Fallback to local storage only
      try {
        _patients.removeWhere((p) => p.patientId == patientId);
        await LocalStorageService.savePatients(_patients);
        
        print('✅ Patient deleted from local storage only');
        _error = 'Deleted locally - Backend unavailable';
        return true;
      } catch (localError) {
        print('❌ Failed to delete locally: $localError');
        _error = 'Failed to delete patient: $e';
        return false;
      }
    } finally {
      _isLoading = false;
      scheduleProviderNotify(this);
    }
  }

  Future<Patient?> getPatient(int id) async {
    try {
      final patient = await _apiService.getPatient(id);
      _selectedPatient = patient;
      scheduleProviderNotify(this);
      return patient;
    } catch (e) {
      _error = e.toString();
      scheduleProviderNotify(this);
      return null;
    }
  }

  void selectPatient(Patient patient) {
    _selectedPatient = patient;
    scheduleProviderNotify(this);
  }

  void clearSelection() {
    _selectedPatient = null;
    scheduleProviderNotify(this);
  }

  void clearError() {
    _error = null;
    scheduleProviderNotify(this);
  }

  List<Patient> searchPatients(String query) {
    if (query.isEmpty) return _patients;
    
    return _patients.where((patient) =>
      patient.fullName.toLowerCase().contains(query.toLowerCase()) ||
      patient.phone.toLowerCase().contains(query.toLowerCase()) ||
      patient.email?.toLowerCase().contains(query.toLowerCase()) == true ||
      patient.patientId.toString().contains(query)
    ).toList();
  }

  List<Patient> getPatientsByGender(String gender) {
    return _patients.where((patient) => 
      patient.gender.toLowerCase() == gender.toLowerCase()
    ).toList();
  }

  List<Patient> getPatientsByAgeRange(int minAge, int maxAge) {
    return _patients.where((patient) {
      final age = patient.age;
      return age >= minAge && age <= maxAge;
    }).toList();
  }

  // Sorting functions
  List<Patient> getPatientsSortedByName({bool ascending = true}) {
    final sortedPatients = List<Patient>.from(_patients);
    if (ascending) {
      sortedPatients.sort((a, b) => a.fullName.compareTo(b.fullName));
    } else {
      sortedPatients.sort((a, b) => b.fullName.compareTo(a.fullName));
    }
    return sortedPatients;
  }

  List<Patient> getPatientsSortedByAge({bool ascending = true}) {
    final sortedPatients = List<Patient>.from(_patients);
    if (ascending) {
      sortedPatients.sort((a, b) => a.age.compareTo(b.age));
    } else {
      sortedPatients.sort((a, b) => b.age.compareTo(a.age));
    }
    return sortedPatients;
  }

  List<Patient> getPatientsSortedByRegistrationDate({bool ascending = true}) {
    final sortedPatients = List<Patient>.from(_patients);
    if (ascending) {
      sortedPatients.sort((a, b) => (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now()));
    } else {
      sortedPatients.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    }
    return sortedPatients;
  }

  List<Patient> getPatientsSortedByGender({bool ascending = true}) {
    final sortedPatients = List<Patient>.from(_patients);
    if (ascending) {
      sortedPatients.sort((a, b) => a.gender.compareTo(b.gender));
    } else {
      sortedPatients.sort((a, b) => b.gender.compareTo(a.gender));
    }
    return sortedPatients;
  }
}
