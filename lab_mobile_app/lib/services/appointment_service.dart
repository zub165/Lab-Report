import '../models/appointment.dart';
import 'django_api_service.dart';

class AppointmentService {
  final DjangoApiService _apiService = DjangoApiService();
  
  // Calendar API integration
  Future<Map<String, dynamic>> createCalendarEvent({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String description,
    required String patientName,
    required String patientPhone,
    String? location,
  }) async {
    try {
      // Mock calendar integration - replace with actual calendar API
      await Future.delayed(const Duration(milliseconds: 500));
      
      return {
        'event_id': 'cal_${DateTime.now().millisecondsSinceEpoch}',
        'title': title,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'description': description,
        'patient_name': patientName,
        'patient_phone': patientPhone,
        'location': location ?? 'SAEED Laboratory',
        'status': 'confirmed',
        'created_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to create calendar event: $e');
    }
  }

  // Create appointment with backend and calendar integration
  Future<Appointment> createAppointment({
    required String patientId,
    required String patientName,
    required String patientPhone,
    required DateTime appointmentDate,
    required String appointmentTime,
    required String appointmentType,
    String? notes,
    String? location,
  }) async {
    try {
      // Create calendar event
      final calendarEvent = await createCalendarEvent(
        title: '$appointmentType - $patientName',
        startTime: appointmentDate,
        endTime: appointmentDate.add(const Duration(hours: 1)),
        description: notes ?? 'Medical appointment',
        patientName: patientName,
        patientPhone: patientPhone,
        location: location,
      );

      // Create appointment in backend
      final appointment = Appointment(
        appointmentId: 'apt_${DateTime.now().millisecondsSinceEpoch}',
        patientId: patientId,
        patientName: patientName,
        testType: appointmentType,
        testName: appointmentType,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        status: 'Scheduled',
        notes: notes,
        roomNumber: location ?? 'SAEED Laboratory',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to backend
      await _apiService.createAppointment(appointment);
      
      // Schedule reminder
      await _scheduleAppointmentReminder(appointment);
      
      return appointment;
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  // Update appointment
  Future<Appointment> updateAppointment({
    required String appointmentId,
    DateTime? appointmentDate,
    String? appointmentTime,
    String? appointmentType,
    String? status,
    String? notes,
    String? location,
  }) async {
    try {
      // Get existing appointment
      final appointments = await _apiService.getAppointments();
      final existingAppointment = appointments.firstWhere(
        (apt) => apt.appointmentId == appointmentId,
        orElse: () => throw Exception('Appointment not found'),
      );

      // Update appointment
      final updatedAppointment = Appointment(
        appointmentId: appointmentId,
        patientId: existingAppointment.patientId,
        patientName: existingAppointment.patientName,
        testType: appointmentType ?? existingAppointment.testType,
        testName: appointmentType ?? existingAppointment.testName,
        appointmentDate: appointmentDate ?? existingAppointment.appointmentDate,
        appointmentTime: appointmentTime ?? existingAppointment.appointmentTime,
        status: status ?? existingAppointment.status,
        notes: notes ?? existingAppointment.notes,
        roomNumber: location ?? existingAppointment.roomNumber,
        createdAt: existingAppointment.createdAt,
        updatedAt: DateTime.now(),
      );

      // Update in backend
      await _apiService.updateAppointment(appointmentId, updatedAppointment);
      
      // Update calendar event if needed
      if (appointmentDate != null || appointmentTime != null) {
        await _updateCalendarEvent(updatedAppointment);
      }
      
      return updatedAppointment;
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  // Cancel appointment
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      // Get existing appointment
      final appointments = await _apiService.getAppointments();
      final appointment = appointments.firstWhere(
        (apt) => apt.appointmentId == appointmentId,
        orElse: () => throw Exception('Appointment not found'),
      );

      // Update status to cancelled
      final cancelledAppointment = Appointment(
        appointmentId: appointmentId,
        patientId: appointment.patientId,
        patientName: appointment.patientName,
        testType: appointment.testType,
        testName: appointment.testName,
        appointmentDate: appointment.appointmentDate,
        appointmentTime: appointment.appointmentTime,
        status: 'Cancelled',
        notes: appointment.notes,
        roomNumber: appointment.roomNumber,
        createdAt: appointment.createdAt,
        updatedAt: DateTime.now(),
      );

      // Update in backend
      await _apiService.updateAppointment(appointmentId, cancelledAppointment);
      
      // Cancel calendar event
      await _cancelCalendarEvent(null); // No calendar event ID in current model
    } catch (e) {
      throw Exception('Failed to cancel appointment: $e');
    }
  }

  // Get appointments by date range
  Future<List<Appointment>> getAppointmentsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final appointments = await _apiService.getAppointments();
      return appointments.where((apt) {
        return apt.appointmentDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
               apt.appointmentDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      throw Exception('Failed to get appointments by date range: $e');
    }
  }

  // Get appointments by patient
  Future<List<Appointment>> getAppointmentsByPatient(String patientId) async {
    try {
      final appointments = await _apiService.getAppointments();
      return appointments.where((apt) => apt.patientId == patientId).toList();
    } catch (e) {
      throw Exception('Failed to get appointments by patient: $e');
    }
  }

  // Schedule appointment reminder
  Future<void> _scheduleAppointmentReminder(Appointment appointment) async {
    try {
      // Calculate reminder time (24 hours before appointment)
      final reminderTime = appointment.appointmentDate.subtract(const Duration(hours: 24));
      
      // In a real implementation, this would integrate with device notifications
      print('📅 Appointment reminder scheduled for ${appointment.patientName} at $reminderTime');
      
      // Mock reminder data
      final reminderData = {
        'appointment_id': appointment.appointmentId,
        'patient_name': appointment.patientName,
        'appointment_date': appointment.appointmentDate.toIso8601String(),
        'appointment_time': appointment.appointmentTime,
        'reminder_time': reminderTime.toIso8601String(),
        'message': 'Reminder: You have an appointment tomorrow at ${appointment.appointmentTime}',
      };
      
      // Store reminder (in real implementation, this would be stored in device notification system)
      print('🔔 Reminder data: $reminderData');
    } catch (e) {
      print('❌ Failed to schedule reminder: $e');
    }
  }

  // Update calendar event
  Future<void> _updateCalendarEvent(Appointment appointment) async {
    try {
      // Mock calendar update - replace with actual calendar API
      await Future.delayed(const Duration(milliseconds: 300));
      print('📅 Calendar event updated for appointment ${appointment.appointmentId}');
    } catch (e) {
      print('❌ Failed to update calendar event: $e');
    }
  }

  // Cancel calendar event
  Future<void> _cancelCalendarEvent(String? calendarEventId) async {
    try {
      if (calendarEventId != null) {
        // Mock calendar cancellation - replace with actual calendar API
        await Future.delayed(const Duration(milliseconds: 300));
        print('📅 Calendar event cancelled: $calendarEventId');
      }
    } catch (e) {
      print('❌ Failed to cancel calendar event: $e');
    }
  }

  // Get available time slots for a specific date
  Future<List<String>> getAvailableTimeSlots(DateTime date) async {
    try {
      // Mock available time slots - in real implementation, this would check existing appointments
      final timeSlots = [
        '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
        '11:00 AM', '11:30 AM', '02:00 PM', '02:30 PM',
        '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM',
      ];
      
      // Filter out already booked slots
      final appointments = await getAppointmentsByDateRange(
        startDate: date,
        endDate: date,
      );
      
      final bookedSlots = appointments.map((apt) => apt.appointmentTime).toSet();
      return timeSlots.where((slot) => !bookedSlots.contains(slot)).toList();
    } catch (e) {
      throw Exception('Failed to get available time slots: $e');
    }
  }

  // Send appointment confirmation
  Future<void> sendAppointmentConfirmation(Appointment appointment) async {
    try {
      // Mock SMS/Email sending - replace with actual notification service
      final message = '''
Appointment Confirmed
Patient: ${appointment.patientName}
Date: ${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year}
Time: ${appointment.appointmentTime}
Type: ${appointment.testType}
Location: ${appointment.roomNumber ?? 'SAEED Laboratory'}

Please arrive 15 minutes early.
      ''';
      
      print('📱 Appointment confirmation sent: $message');
    } catch (e) {
      print('❌ Failed to send appointment confirmation: $e');
    }
  }
}
