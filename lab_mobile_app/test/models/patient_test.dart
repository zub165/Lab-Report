import 'package:flutter_test/flutter_test.dart';
import 'package:lab_mobile_app/models/patient.dart';

void main() {
  group('Patient', () {
    final now = DateTime.now();
    final sampleJson = {
      'patient_id': 'P001',
      'full_name': 'John Doe',
      'date_of_birth': '1990-05-15',
      'gender': 'Male',
      'phone': '+1234567890',
      'email': 'john@example.com',
      'address': '123 Main St',
      'emergency_contact': '+1987654321',
      'blood_type': 'O+',
      'medical_history': 'None',
      'insurance_info': 'ABC Insurance',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    test('fromJson parses correctly', () {
      final patient = Patient.fromJson(sampleJson);
      expect(patient.patientId, 'P001');
      expect(patient.fullName, 'John Doe');
      expect(patient.dateOfBirth.year, 1990);
      expect(patient.dateOfBirth.month, 5);
      expect(patient.dateOfBirth.day, 15);
      expect(patient.gender, 'Male');
      expect(patient.phone, '+1234567890');
      expect(patient.email, 'john@example.com');
      expect(patient.address, '123 Main St');
      expect(patient.emergencyContact, '+1987654321');
      expect(patient.bloodType, 'O+');
      expect(patient.medicalHistory, 'None');
      expect(patient.insuranceInfo, 'ABC Insurance');
    });

    test('fromJson handles alternate field names', () {
      final altJson = {
        'PatientID': 'P002',
        'name': 'Jane Smith',
        'dob': '1985-12-01',
        'Gender': 'Female',
        'Phone': '+9876543210',
        'ContactNumber': '+1112223333',
      };
      final patient = Patient.fromJson(altJson);
      expect(patient.patientId, 'P002');
      expect(patient.fullName, 'Jane Smith');
      expect(patient.phone, '+9876543210');
    });

    test('fromJson handles empty/missing fields', () {
      final emptyJson = <String, dynamic>{};
      final patient = Patient.fromJson(emptyJson);
      expect(patient.fullName, '');
      expect(patient.gender, '');
      expect(patient.phone, '');
      expect(patient.patientId, '');
    });

    test('toJson produces correct map', () {
      final patient = Patient(
        patientId: 'P001',
        fullName: 'John Doe',
        dateOfBirth: DateTime(1990, 5, 15),
        gender: 'Male',
        phone: '+1234567890',
        email: 'john@example.com',
        address: '123 Main St',
        emergencyContact: '+1987654321',
        bloodType: 'O+',
        medicalHistory: 'None',
        insuranceInfo: 'ABC Insurance',
        createdAt: now,
        updatedAt: now,
      );
      final json = patient.toJson();
      expect(json['patient_id'], 'P001');
      expect(json['full_name'], 'John Doe');
      expect(json['gender'], 'Male');
      expect(json['date_of_birth'], '1990-05-15');
    });

    test('toApiJson excludes id and timestamps', () {
      final patient = Patient(
        patientId: 'P001',
        fullName: 'John Doe',
        dateOfBirth: DateTime(1990, 5, 15),
        gender: 'Male',
        phone: '+1234567890',
      );
      final apiJson = patient.toApiJson();
      expect(apiJson.containsKey('patient_id'), false);
      expect(apiJson.containsKey('created_at'), false);
      expect(apiJson.containsKey('updated_at'), false);
      expect(apiJson['full_name'], 'John Doe');
    });

    test('copyWith produces modified copy', () {
      final patient = Patient(
        patientId: 'P001',
        fullName: 'John Doe',
        dateOfBirth: DateTime(1990, 5, 15),
        gender: 'Male',
        phone: '+1234567890',
      );
      final copy = patient.copyWith(fullName: 'Jane Doe', phone: '+9999999999');
      expect(copy.patientId, 'P001');
      expect(copy.fullName, 'Jane Doe');
      expect(copy.phone, '+9999999999');
      expect(copy.gender, 'Male');
      expect(patient.fullName, 'John Doe');
    });

    test('age calculates correctly', () {
      final patient = Patient(
        patientId: 'P001',
        fullName: 'John',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: 'M',
        phone: '123',
      );
      final expectedAge = DateTime.now().year - 1990;
      expect(patient.age, expectedAge);
    });

    test('initials returns first letters', () {
      final patient = Patient(
        patientId: 'P001',
        fullName: 'john doe',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: 'M',
        phone: '123',
      );
      expect(patient.initials, 'JD');
    });

    test('initials handles single name', () {
      final patient = Patient(
        patientId: 'P001',
        fullName: 'madonna',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: 'F',
        phone: '123',
      );
      expect(patient.initials, 'M');
    });

    test('initials handles empty name', () {
      final patient = Patient(
        patientId: 'P001',
        fullName: '',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: 'F',
        phone: '123',
      );
      expect(patient.initials, '?');
    });

    test('equality is based on patientId', () {
      final a = Patient(
        patientId: 'P001',
        fullName: 'John',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: 'M',
        phone: '123',
      );
      final b = Patient(
        patientId: 'P001',
        fullName: 'Jane',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: 'F',
        phone: '456',
      );
      expect(a, equals(b));
    });

    test('local storage round-trip', () {
      final patient = Patient(
        patientId: 'P001',
        fullName: 'John Doe',
        dateOfBirth: DateTime(1990, 5, 15),
        gender: 'Male',
        phone: '+1234567890',
        email: 'john@example.com',
        address: '123 Main St',
        bloodType: 'O+',
        medicalHistory: 'None',
        createdAt: now,
        updatedAt: now,
      );
      final localJson = patient.toLocalJson();
      final restored = Patient.fromLocalJson(localJson);
      expect(restored.patientId, patient.patientId);
      expect(restored.fullName, patient.fullName);
      expect(restored.dateOfBirth, patient.dateOfBirth);
      expect(restored.gender, patient.gender);
    });
  });
}
