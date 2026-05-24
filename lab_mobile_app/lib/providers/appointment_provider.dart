import 'package:flutter/foundation.dart';
import '../models/appointment.dart';
import '../services/django_api_service.dart';
import '../utils/constants.dart';
import '../services/local_storage_service.dart';

class AppointmentProvider with ChangeNotifier {
  final DjangoApiService _apiService = DjangoApiService();
  
  List<Appointment> _appointments = [];
  Appointment? _selectedAppointment;
  bool _isLoading = false;
  String? _error;

  List<Appointment> get appointments => _appointments;
  Appointment? get selectedAppointment => _selectedAppointment;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered lists
  List<Appointment> get scheduledAppointments => _appointments.where((apt) => apt.isScheduled).toList();
  List<Appointment> get confirmedAppointments => _appointments.where((apt) => apt.isConfirmed).toList();
  List<Appointment> get inProgressAppointments => _appointments.where((apt) => apt.isInProgress).toList();
  List<Appointment> get completedAppointments => _appointments.where((apt) => apt.isCompleted).toList();
  List<Appointment> get cancelledAppointments => _appointments.where((apt) => apt.isCancelled).toList();
  List<Appointment> get noShowAppointments => _appointments.where((apt) => apt.isNoShow).toList();
  
  List<Appointment> get todayAppointments => _appointments.where((apt) => apt.isToday).toList();
  List<Appointment> get pastAppointments => _appointments.where((apt) => apt.isPast).toList();
  List<Appointment> get futureAppointments => _appointments.where((apt) => apt.isFuture).toList();

  Future<void> loadAppointments() async {
    try {
      _isLoading = true;
      _error = null;
      scheduleProviderNotify(this);

      print('🔄 Loading appointments from backend API...');
      
      // Try to load from backend API first
      final appointments = await _apiService.getAppointments();
      _appointments = appointments;
      
      // Save to local storage as backup
      await LocalStorageService.saveAppointments(appointments);
      
      print('✅ Loaded ${appointments.length} appointments from backend API');
      _error = null;
    } catch (e) {
      print('❌ Failed to load appointments from API: $e');
      
      // Fallback to local storage
      try {
        print('🔄 Loading appointments from local storage...');
        final localAppointments = await LocalStorageService.loadAppointments();
        _appointments = localAppointments;
        print('✅ Loaded ${localAppointments.length} appointments from local storage');
        _error = 'Using cached data - Backend unavailable';
      } catch (localError) {
        print('❌ Failed to load from local storage: $localError');
        _appointments = [];
        _error = 'Failed to load appointments: $e';
      }
    } finally {
      _isLoading = false;
      scheduleProviderNotify(this);
    }
  }

  Future<bool> addAppointment(Appointment appointment) async {
    try {
      _isLoading = true;
      scheduleProviderNotify(this);

      print('🔄 Adding appointment to backend API...');
      
      // Try to add to backend API first
      final newAppointment = await _apiService.createAppointment(appointment);
      
      // Add to local list
      _appointments.add(newAppointment);
      
      // Update local storage
      await LocalStorageService.saveAppointments(_appointments);
      
      print('✅ Appointment added successfully to backend');
      _error = null;
      return true;
    } catch (e) {
      print('❌ Failed to add appointment to API: $e');
      
      // Fallback to local storage only
      try {
        // Generate a temporary ID for local storage
        final tempAppointment = appointment.copyWith(
          appointmentId: 'LOCAL_${DateTime.now().millisecondsSinceEpoch}',
        );
        
        _appointments.add(tempAppointment);
        await LocalStorageService.saveAppointments(_appointments);
        
        print('✅ Appointment added to local storage only');
        _error = 'Saved locally - Backend unavailable';
        return true;
      } catch (localError) {
        print('❌ Failed to save locally: $localError');
        _error = 'Failed to add appointment: $e';
        return false;
      }
    } finally {
      _isLoading = false;
      scheduleProviderNotify(this);
    }
  }

  Future<bool> updateAppointment(Appointment appointment) async {
    try {
      _isLoading = true;
      scheduleProviderNotify(this);

      print('🔄 Updating appointment in backend API...');
      
      // Try to update in backend API first
      final updatedAppointment = await _apiService.updateAppointment(
        appointment.appointmentId!,
        appointment,
      );
      
      // Update in local list
      final index = _appointments.indexWhere((a) => a.appointmentId == appointment.appointmentId);
      if (index != -1) {
        _appointments[index] = updatedAppointment;
      }
      
      // Update local storage
      await LocalStorageService.saveAppointments(_appointments);
      
      print('✅ Appointment updated successfully in backend');
      _error = null;
      return true;
    } catch (e) {
      print('❌ Failed to update appointment in API: $e');
      
      // Fallback to local storage only
      try {
        final index = _appointments.indexWhere((a) => a.appointmentId == appointment.appointmentId);
        if (index != -1) {
          _appointments[index] = appointment;
          await LocalStorageService.saveAppointments(_appointments);
          
          print('✅ Appointment updated in local storage only');
          _error = 'Updated locally - Backend unavailable';
          return true;
        }
        return false;
      } catch (localError) {
        print('❌ Failed to update locally: $localError');
        _error = 'Failed to update appointment: $e';
        return false;
      }
    } finally {
      _isLoading = false;
      scheduleProviderNotify(this);
    }
  }

  Future<bool> deleteAppointment(String appointmentId) async {
    try {
      _isLoading = true;
      scheduleProviderNotify(this);

      print('🔄 Deleting appointment from backend API...');
      
      // Try to delete from backend API first
      await _apiService.deleteAppointment(appointmentId);
      
      // Remove from local list
      _appointments.removeWhere((a) => a.appointmentId == appointmentId);
      
      // Update local storage
      await LocalStorageService.saveAppointments(_appointments);
      
      print('✅ Appointment deleted successfully from backend');
      _error = null;
      return true;
    } catch (e) {
      print('❌ Failed to delete appointment from API: $e');
      
      // Fallback to local storage only
      try {
        _appointments.removeWhere((a) => a.appointmentId == appointmentId);
        await LocalStorageService.saveAppointments(_appointments);
        
        print('✅ Appointment deleted from local storage only');
        _error = 'Deleted locally - Backend unavailable';
        return true;
      } catch (localError) {
        print('❌ Failed to delete locally: $localError');
        _error = 'Failed to delete appointment: $e';
        return false;
      }
    } finally {
      _isLoading = false;
      scheduleProviderNotify(this);
    }
  }

  Future<bool> updateAppointmentStatus(String appointmentId, String status) async {
    _isLoading = true;
    _error = null;
    scheduleProviderNotify(this);

    try {
      final updatedAppointment = await _apiService.updateAppointmentStatus(appointmentId, status);
      final index = _appointments.indexWhere((apt) => apt.appointmentId == appointmentId);
      if (index != -1) {
        _appointments[index] = updatedAppointment;
      }
      // Save to local storage
      await LocalStorageService.saveAppointments(_appointments);
      _isLoading = false;
      scheduleProviderNotify(this);
      return true;
    } catch (e) {
      _error = e.toString();
      // If API fails, update local storage only
      final index = _appointments.indexWhere((apt) => apt.appointmentId == appointmentId);
      if (index != -1) {
        final updatedAppointment = _appointments[index].copyWith(status: status);
        _appointments[index] = updatedAppointment;
        await LocalStorageService.updateAppointment(updatedAppointment);
      }
      _isLoading = false;
      scheduleProviderNotify(this);
      return true; // Return true since we saved locally
    }
  }

  void selectAppointment(Appointment appointment) {
    _selectedAppointment = appointment;
    scheduleProviderNotify(this);
  }

  void clearSelectedAppointment() {
    _selectedAppointment = null;
    scheduleProviderNotify(this);
  }

  void clearError() {
    _error = null;
    scheduleProviderNotify(this);
  }

  Map<String, int> getAppointmentStatistics() {
    return {
      'total': _appointments.length,
      'scheduled': scheduledAppointments.length,
      'confirmed': confirmedAppointments.length,
      'inProgress': inProgressAppointments.length,
      'completed': completedAppointments.length,
      'cancelled': cancelledAppointments.length,
      'noShow': noShowAppointments.length,
      'today': todayAppointments.length,
      'past': pastAppointments.length,
      'future': futureAppointments.length,
    };
  }

  List<Appointment> searchAppointments(String query) {
    if (query.isEmpty) return _appointments;
    
    return _appointments.where((apt) =>
      apt.patientName.toLowerCase().contains(query.toLowerCase()) ||
      apt.testType.toLowerCase().contains(query.toLowerCase()) ||
      apt.testName.toLowerCase().contains(query.toLowerCase()) ||
      apt.status.toLowerCase().contains(query.toLowerCase()) ||
      apt.doctorName?.toLowerCase().contains(query.toLowerCase()) == true
    ).toList();
  }

  List<Appointment> getAppointmentsByStatus(String status) {
    return _appointments.where((apt) => apt.status == status).toList();
  }

  List<Appointment> getAppointmentsByDate(DateTime date) {
    return _appointments.where((apt) => 
      apt.appointmentDate.year == date.year &&
      apt.appointmentDate.month == date.month &&
      apt.appointmentDate.day == date.day
    ).toList();
  }

  List<Appointment> getAppointmentsByPatient(String patientId) {
    return _appointments.where((apt) => apt.patientId == patientId).toList();
  }

  List<Appointment> getAppointmentsByDoctor(String doctorName) {
    return _appointments.where((apt) => apt.doctorName == doctorName).toList();
  }

  // Sorting functions
  List<Appointment> getAppointmentsSortedByDate({bool ascending = true}) {
    final sortedAppointments = List<Appointment>.from(_appointments);
    if (ascending) {
      sortedAppointments.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    } else {
      sortedAppointments.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
    }
    return sortedAppointments;
  }

  List<Appointment> getAppointmentsSortedByTime({bool ascending = true}) {
    final sortedAppointments = List<Appointment>.from(_appointments);
    if (ascending) {
      sortedAppointments.sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));
    } else {
      sortedAppointments.sort((a, b) => b.appointmentTime.compareTo(a.appointmentTime));
    }
    return sortedAppointments;
  }

  List<Appointment> getAppointmentsSortedByPatientName({bool ascending = true}) {
    final sortedAppointments = List<Appointment>.from(_appointments);
    if (ascending) {
      sortedAppointments.sort((a, b) => a.patientName.compareTo(b.patientName));
    } else {
      sortedAppointments.sort((a, b) => b.patientName.compareTo(a.patientName));
    }
    return sortedAppointments;
  }

  List<Appointment> getAppointmentsSortedByStatus({bool ascending = true}) {
    final sortedAppointments = List<Appointment>.from(_appointments);
    if (ascending) {
      sortedAppointments.sort((a, b) => a.status.compareTo(b.status));
    } else {
      sortedAppointments.sort((a, b) => b.status.compareTo(a.status));
    }
    return sortedAppointments;
  }

  List<Appointment> getAppointmentsSortedByPrice({bool ascending = true}) {
    final sortedAppointments = List<Appointment>.from(_appointments);
    if (ascending) {
      sortedAppointments.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
    } else {
      sortedAppointments.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
    }
    return sortedAppointments;
  }
}
