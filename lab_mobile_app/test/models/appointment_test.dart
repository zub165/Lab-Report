import 'package:flutter_test/flutter_test.dart';
import 'package:lab_mobile_app/models/appointment.dart';

void main() {
  group('Appointment', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    final sampleJson = {
      'appointment_id': 'A001',
      'patient_id': 'P001',
      'patient_name': 'John Doe',
      'test_type': 'Blood Test',
      'test_name': 'Complete Blood Count',
      'appointment_date': today.toIso8601String(),
      'appointment_time': '10:30 AM',
      'status': 'scheduled',
      'notes': 'Fasting required',
      'doctor_name': 'Dr. Smith',
      'room_number': '101',
      'price': 1500.0,
      'created_at': now.toIso8601String(),
    };

    test('fromJson parses correctly', () {
      final apt = Appointment.fromJson(sampleJson);
      expect(apt.appointmentId, 'A001');
      expect(apt.patientId, 'P001');
      expect(apt.patientName, 'John Doe');
      expect(apt.testType, 'Blood Test');
      expect(apt.testName, 'Complete Blood Count');
      expect(apt.appointmentTime, '10:30 AM');
      expect(apt.status, 'scheduled');
      expect(apt.notes, 'Fasting required');
      expect(apt.doctorName, 'Dr. Smith');
      expect(apt.roomNumber, '101');
      expect(apt.price, 1500.0);
    });

    test('fromJson handles alternate field names', () {
      final altJson = {
        'id': 'A002',
        'patient_id': 'P002',
        'patientName': 'Jane Smith',
        'testType': 'Urine Test',
        'testName': 'Urinalysis',
        'appointmentDate': today.toIso8601String(),
        'appointmentTime': '2:00 PM',
        'status': 'confirmed',
        'createdAt': now.toIso8601String(),
      };
      final apt = Appointment.fromJson(altJson);
      expect(apt.appointmentId, 'A002');
      expect(apt.patientName, 'Jane Smith');
      expect(apt.testType, 'Urine Test');
      expect(apt.status, 'confirmed');
    });

    test('isToday returns true for today', () {
      final apt = Appointment(
        appointmentId: 'A001',
        patientId: 'P001',
        patientName: 'John',
        testType: 'Blood',
        testName: 'CBC',
        appointmentDate: today,
        appointmentTime: '10:00',
        status: 'scheduled',
        createdAt: now,
      );
      expect(apt.isToday, true);
    });

    test('isToday returns false for yesterday', () {
      final apt = Appointment(
        appointmentId: 'A001',
        patientId: 'P001',
        patientName: 'John',
        testType: 'Blood',
        testName: 'CBC',
        appointmentDate: yesterday,
        appointmentTime: '10:00',
        status: 'scheduled',
        createdAt: now,
      );
      expect(apt.isToday, false);
    });

    test('isPast returns true for yesterday', () {
      final apt = Appointment(
        appointmentId: 'A001',
        patientId: 'P001',
        patientName: 'John',
        testType: 'Blood',
        testName: 'CBC',
        appointmentDate: yesterday,
        appointmentTime: '10:00',
        status: 'scheduled',
        createdAt: now,
      );
      expect(apt.isPast, true);
    });

    test('isFuture returns true for tomorrow', () {
      final apt = Appointment(
        appointmentId: 'A001',
        patientId: 'P001',
        patientName: 'John',
        testType: 'Blood',
        testName: 'CBC',
        appointmentDate: tomorrow,
        appointmentTime: '10:00',
        status: 'scheduled',
        createdAt: now,
      );
      expect(apt.isFuture, true);
    });

    test('statusDisplay returns correct labels', () {
      for (final entry in {
        'scheduled': 'Scheduled',
        'confirmed': 'Confirmed',
        'in_progress': 'In Progress',
        'completed': 'Completed',
        'cancelled': 'Cancelled',
        'no_show': 'No Show',
        'unknown': 'Unknown',
      }.entries) {
        final apt = Appointment(
          appointmentId: 'A001',
          patientId: 'P001',
          patientName: 'John',
          testType: 'Blood',
          testName: 'CBC',
          appointmentDate: now,
          appointmentTime: '10:00',
          status: entry.key,
          createdAt: now,
        );
        expect(apt.statusDisplay, entry.value);
      }
    });

    test('toJson round-trip preserves data', () {
      final original = Appointment(
        appointmentId: 'A001',
        patientId: 'P001',
        patientName: 'John Doe',
        testType: 'Blood Test',
        testName: 'CBC',
        appointmentDate: today,
        appointmentTime: '10:30 AM',
        status: 'scheduled',
        notes: 'Fasting',
        doctorName: 'Dr. Smith',
        roomNumber: '101',
        price: 1500.0,
        createdAt: now,
      );
      final json = original.toJson();
      final restored = Appointment.fromJson(json);
      expect(restored.appointmentId, original.appointmentId);
      expect(restored.patientName, original.patientName);
      expect(restored.testType, original.testType);
      expect(restored.status, original.status);
    });

    test('copyWith produces modified copy', () {
      final apt = Appointment(
        appointmentId: 'A001',
        patientId: 'P001',
        patientName: 'John',
        testType: 'Blood',
        testName: 'CBC',
        appointmentDate: today,
        appointmentTime: '10:00',
        status: 'scheduled',
        createdAt: now,
      );
      final copy = apt.copyWith(status: 'completed', price: 2000.0);
      expect(copy.status, 'completed');
      expect(copy.price, 2000.0);
      expect(copy.patientName, 'John');
    });
  });
}
