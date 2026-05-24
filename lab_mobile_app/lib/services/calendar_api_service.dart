import '../models/appointment.dart';

// Calendar providers enum (moved outside class)
enum CalendarProvider { google, outlook, apple, local }

class CalendarApiService {


  // Get available time slots for a specific date
  static Future<List<TimeSlot>> getAvailableTimeSlots({
    required DateTime date,
    required String doctorId,
    CalendarProvider provider = CalendarProvider.google,
  }) async {
    try {
      // Mock implementation - in real app, this would call actual calendar APIs
      await Future.delayed(const Duration(milliseconds: 500));
      
      List<TimeSlot> availableSlots = [];
      DateTime startTime = DateTime(date.year, date.month, date.day, 9, 0); // 9:00 AM
      DateTime endTime = DateTime(date.year, date.month, date.day, 17, 0); // 5:00 PM
      
      // Generate 30-minute slots
      while (startTime.isBefore(endTime)) {
        availableSlots.add(TimeSlot(
          startTime: startTime,
          endTime: startTime.add(const Duration(minutes: 30)),
          isAvailable: true,
        ));
        startTime = startTime.add(const Duration(minutes: 30));
      }
      
      // Remove some random slots to simulate existing appointments
      availableSlots.removeWhere((slot) => 
        slot.startTime.hour == 10 || 
        slot.startTime.hour == 14 ||
        (slot.startTime.hour == 11 && slot.startTime.minute == 30)
      );
      
      return availableSlots;
    } catch (e) {
      print('Error getting available time slots: $e');
      return [];
    }
  }

  // Create a new appointment
  static Future<bool> createAppointment({
    required Appointment appointment,
    CalendarProvider provider = CalendarProvider.google,
  }) async {
    try {
      // Mock implementation - in real app, this would create actual calendar events
      await Future.delayed(const Duration(milliseconds: 1000));
      
      print('Creating appointment: ${appointment.patientName} at ${appointment.appointmentDate}');
      
      // In real implementation, this would:
      // 1. Create event in selected calendar provider
      // 2. Send confirmation email/SMS
      // 3. Add to local database
      // 4. Sync with backend
      
      return true;
    } catch (e) {
      print('Error creating appointment: $e');
      return false;
    }
  }

  // Update an existing appointment
  static Future<bool> updateAppointment({
    required Appointment appointment,
    CalendarProvider provider = CalendarProvider.google,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      print('Updating appointment: ${appointment.patientName}');
      return true;
    } catch (e) {
      print('Error updating appointment: $e');
      return false;
    }
  }

  // Cancel an appointment
  static Future<bool> cancelAppointment({
    required String appointmentId,
    CalendarProvider provider = CalendarProvider.google,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      print('Canceling appointment: $appointmentId');
      return true;
    } catch (e) {
      print('Error canceling appointment: $e');
      return false;
    }
  }

  // Get appointments for a date range
  static Future<List<Appointment>> getAppointments({
    required DateTime startDate,
    required DateTime endDate,
    CalendarProvider provider = CalendarProvider.google,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock appointments data
      List<Appointment> appointments = [
        Appointment(
          appointmentId: 'apt_001',
          patientId: 'patient_001',
          patientName: 'John Doe',
          testType: 'Consultation',
          testName: 'General Consultation',
          appointmentDate: DateTime.now().add(const Duration(days: 1)),
          appointmentTime: '10:00 AM',
          doctorName: 'Dr. Smith',
          notes: 'Follow-up visit',
          status: 'scheduled',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Appointment(
          appointmentId: 'apt_002',
          patientId: 'patient_002',
          patientName: 'Jane Smith',
          testType: 'Lab Test',
          testName: 'Blood Work',
          appointmentDate: DateTime.now().add(const Duration(days: 2)),
          appointmentTime: '2:00 PM',
          doctorName: 'Dr. Johnson',
          notes: 'Routine blood test',
          status: 'scheduled',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      
      return appointments;
    } catch (e) {
      print('Error getting appointments: $e');
      return [];
    }
  }

  // Send appointment reminder
  static Future<bool> sendAppointmentReminder({
    required Appointment appointment,
    required String reminderType, // 'email', 'sms', 'push'
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      print('Sending $reminderType reminder for appointment: ${appointment.patientName}');
      return true;
    } catch (e) {
      print('Error sending reminder: $e');
      return false;
    }
  }

  // Get doctor availability
  static Future<List<DoctorAvailability>> getDoctorAvailability({
    required String doctorId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      List<DoctorAvailability> availability = [];
      DateTime currentDate = startDate;
      
      while (currentDate.isBefore(endDate)) {
        // Mock availability - doctors work Monday to Friday, 9 AM to 5 PM
        if (currentDate.weekday >= 1 && currentDate.weekday <= 5) {
          availability.add(DoctorAvailability(
            date: currentDate,
            startTime: DateTime(currentDate.year, currentDate.month, currentDate.day, 9, 0),
            endTime: DateTime(currentDate.year, currentDate.month, currentDate.day, 17, 0),
            isAvailable: true,
          ));
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      return availability;
    } catch (e) {
      print('Error getting doctor availability: $e');
      return [];
    }
  }

  // Sync with Google Calendar
  static Future<bool> syncWithGoogleCalendar({
    required String accessToken,
    required List<Appointment> appointments,
  }) async {
    try {
      // Mock Google Calendar sync
      await Future.delayed(const Duration(milliseconds: 2000));
      print('Syncing ${appointments.length} appointments with Google Calendar');
      return true;
    } catch (e) {
      print('Error syncing with Google Calendar: $e');
      return false;
    }
  }

  // Sync with Outlook Calendar
  static Future<bool> syncWithOutlookCalendar({
    required String accessToken,
    required List<Appointment> appointments,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 2000));
      print('Syncing ${appointments.length} appointments with Outlook Calendar');
      return true;
    } catch (e) {
      print('Error syncing with Outlook Calendar: $e');
      return false;
    }
  }

  // Sync with Apple Calendar
  static Future<bool> syncWithAppleCalendar({
    required String accessToken,
    required List<Appointment> appointments,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 2000));
      print('Syncing ${appointments.length} appointments with Apple Calendar');
      return true;
    } catch (e) {
      print('Error syncing with Apple Calendar: $e');
      return false;
    }
  }

  // Get calendar settings
  static Future<CalendarSettings> getCalendarSettings() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      return CalendarSettings(
        defaultProvider: CalendarProvider.google,
        reminderMinutes: [15, 60, 1440], // 15 min, 1 hour, 1 day
        workingHours: WorkingHours(
          startTime: DateTime(2024, 1, 1, 9, 0),
          endTime: DateTime(2024, 1, 1, 17, 0),
          workingDays: [1, 2, 3, 4, 5], // Monday to Friday
        ),
        autoSync: true,
        syncInterval: const Duration(minutes: 15),
      );
    } catch (e) {
      print('Error getting calendar settings: $e');
      return CalendarSettings.defaultSettings();
    }
  }
}

// Supporting classes
class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final String? notes;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.notes,
  });
}

class DoctorAvailability {
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final String? notes;

  DoctorAvailability({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.notes,
  });
}

class CalendarSettings {
  final CalendarProvider defaultProvider;
  final List<int> reminderMinutes;
  final WorkingHours workingHours;
  final bool autoSync;
  final Duration syncInterval;

  CalendarSettings({
    required this.defaultProvider,
    required this.reminderMinutes,
    required this.workingHours,
    required this.autoSync,
    required this.syncInterval,
  });

  static CalendarSettings defaultSettings() {
    return CalendarSettings(
      defaultProvider: CalendarProvider.google,
      reminderMinutes: [15, 60, 1440],
      workingHours: WorkingHours(
        startTime: DateTime(2024, 1, 1, 9, 0),
        endTime: DateTime(2024, 1, 1, 17, 0),
        workingDays: [1, 2, 3, 4, 5],
      ),
      autoSync: true,
      syncInterval: const Duration(minutes: 15),
    );
  }
}

class WorkingHours {
  final DateTime startTime;
  final DateTime endTime;
  final List<int> workingDays; // 1 = Monday, 7 = Sunday

  WorkingHours({
    required this.startTime,
    required this.endTime,
    required this.workingDays,
  });
}
