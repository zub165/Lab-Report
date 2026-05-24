import 'package:flutter_test/flutter_test.dart';
import 'package:lab_mobile_app/models/test.dart';
import 'package:lab_mobile_app/models/patient.dart';

void main() {
  group('Test', () {
    final now = DateTime.now();

    final sampleJson = {
      'order_id': 'T001',
      'patient_id': 'P001',
      'test_type': 'Blood Test',
      'test_name': 'Complete Blood Count',
      'price': 1500.0,
      'ordered_by': 'Dr. Smith',
      'ordered_date': now.toIso8601String(),
      'status': 'pending',
      'priority': 'normal',
      'patient_name': 'John Doe',
      'description': 'Routine checkup',
      'id': 'ORD001',
    };

    test('fromTestOrderJson parses correctly', () {
      final test = Test.fromTestOrderJson(sampleJson);
      expect(test.testId, 'T001');
      expect(test.patientId, 'P001');
      expect(test.testType, 'Blood Test');
      expect(test.testName, 'Complete Blood Count');
      expect(test.price, 1500.0);
      expect(test.orderedBy, 'Dr. Smith');
      expect(test.status, 'pending');
      expect(test.patientName, 'John Doe');
      expect(test.djangoOrderId, 'ORD001');
    });

    test('fromTestOrderJson includes nested patient', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['patient'] = {
        'patient_id': 'P001',
        'full_name': 'John Doe',
        'gender': 'Male',
        'phone': '+1234567890',
      };
      final test = Test.fromTestOrderJson(json);
      expect(test.patient, isNotNull);
      expect(test.patient!.fullName, 'John Doe');
      expect(test.patient!.gender, 'Male');
    });

    test('toJson round-trips with fromJson', () {
      final original = Test(
        testId: 'T001',
        patientId: 'P001',
        testType: 'Blood Test',
        testName: 'CBC',
        price: 1500.0,
        orderedBy: 'Dr. Smith',
        orderedDate: now,
        status: 'completed',
        patientName: 'John Doe',
      );
      final json = original.toJson();
      final restored = Test.fromJson(json);
      expect(restored.testId, original.testId);
      expect(restored.patientId, original.patientId);
      expect(restored.testName, original.testName);
      expect(restored.status, original.status);
    });

    test('fromTestOrderJson handles missing fields', () {
      final emptyJson = <String, dynamic>{};
      final test = Test.fromTestOrderJson(emptyJson);
      expect(test.testName, startsWith('Order #'));
      expect(test.patientName, null);
      expect(test.price, 0.0);
    });
  });
}
