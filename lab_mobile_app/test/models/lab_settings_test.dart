import 'package:flutter_test/flutter_test.dart';
import 'package:lab_mobile_app/models/lab_settings.dart';

void main() {
  group('Doctor', () {
    final now = DateTime.now();

    test('fromJson parses correctly', () {
      final json = {
        'id': 1,
        'name': 'Dr. Smith',
        'specialization': 'Cardiology',
        'license_number': 'LIC123',
        'contact_number': '+1234567890',
        'email': 'smith@lab.com',
        'is_active': true,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      final doc = Doctor.fromJson(json);
      expect(doc.id, 1);
      expect(doc.name, 'Dr. Smith');
      expect(doc.specialization, 'Cardiology');
      expect(doc.licenseNumber, 'LIC123');
      expect(doc.contactNumber, '+1234567890');
      expect(doc.email, 'smith@lab.com');
      expect(doc.isActive, true);
    });

    test('toJson round-trips', () {
      final doc = Doctor(
        id: 1,
        name: 'Dr. Smith',
        specialization: 'Cardiology',
        licenseNumber: 'LIC123',
        contactNumber: '+1234567890',
        email: 'smith@lab.com',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      final json = doc.toJson();
      final restored = Doctor.fromJson(json);
      expect(restored.id, doc.id);
      expect(restored.name, doc.name);
      expect(restored.specialization, doc.specialization);
    });

    test('fromJson handles empty fields', () {
      final json = <String, dynamic>{};
      final doc = Doctor.fromJson(json);
      expect(doc.name, '');
      expect(doc.specialization, '');
      expect(doc.isActive, true);
    });

    test('copyWith preserves original', () {
      final doc = Doctor(
        name: 'Dr. Smith',
        specialization: 'Cardiology',
        licenseNumber: 'LIC123',
        contactNumber: '+1234567890',
      );
      final copy = doc.copyWith(name: 'Dr. Jones', specialization: 'Neurology');
      expect(copy.name, 'Dr. Jones');
      expect(copy.specialization, 'Neurology');
      expect(doc.name, 'Dr. Smith');
    });

    test('toString returns formatted string', () {
      final doc = Doctor(
        id: 1,
        name: 'Dr. Smith',
        specialization: 'Cardiology',
        licenseNumber: 'LIC123',
        contactNumber: '+1234567890',
      );
      expect(doc.toString(), contains('Dr. Smith'));
      expect(doc.toString(), contains('Cardiology'));
    });

    test('equality is based on id', () {
      final a = Doctor(id: 1, name: 'Dr. A', specialization: 'A', licenseNumber: 'L1', contactNumber: '1');
      final b = Doctor(id: 1, name: 'Dr. B', specialization: 'B', licenseNumber: 'L2', contactNumber: '2');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('Technician', () {
    final now = DateTime.now();

    test('fromJson parses correctly', () {
      final json = {
        'id': 1,
        'name': 'Tech Jane',
        'specialization': 'Hematology',
        'employee_id': 'EMP001',
        'contact_number': '+1234567890',
        'email': 'jane@lab.com',
        'is_active': true,
      };
      final tech = Technician.fromJson(json);
      expect(tech.id, 1);
      expect(tech.name, 'Tech Jane');
      expect(tech.specialization, 'Hematology');
      expect(tech.employeeId, 'EMP001');
      expect(tech.contactNumber, '+1234567890');
      expect(tech.email, 'jane@lab.com');
      expect(tech.isActive, true);
    });

    test('toJson round-trips', () {
      final tech = Technician(
        id: 1,
        name: 'Tech Jane',
        specialization: 'Hematology',
        employeeId: 'EMP001',
        contactNumber: '+1234567890',
        email: 'jane@lab.com',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      final json = tech.toJson();
      final restored = Technician.fromJson(json);
      expect(restored.id, tech.id);
      expect(restored.name, tech.name);
      expect(restored.employeeId, tech.employeeId);
    });

    test('fromJson handles empty fields', () {
      final json = <String, dynamic>{};
      final tech = Technician.fromJson(json);
      expect(tech.name, '');
      expect(tech.specialization, '');
      expect(tech.employeeId, '');
      expect(tech.isActive, true);
    });

    test('copyWith preserves original', () {
      final tech = Technician(
        name: 'Tech Jane',
        specialization: 'Hematology',
        employeeId: 'EMP001',
        contactNumber: '+1234567890',
      );
      final copy = tech.copyWith(name: 'Tech Bob', specialization: 'Microbiology');
      expect(copy.name, 'Tech Bob');
      expect(copy.specialization, 'Microbiology');
      expect(tech.name, 'Tech Jane');
    });

    test('toString returns formatted string', () {
      final tech = Technician(
        id: 1,
        name: 'Tech Jane',
        specialization: 'Hematology',
        employeeId: 'EMP001',
        contactNumber: '+1234567890',
      );
      expect(tech.toString(), contains('Tech Jane'));
      expect(tech.toString(), contains('Hematology'));
    });

    test('equality is based on id', () {
      final a = Technician(id: 1, name: 'A', specialization: 'A', employeeId: 'E1', contactNumber: '1');
      final b = Technician(id: 1, name: 'B', specialization: 'B', employeeId: 'E2', contactNumber: '2');
      expect(a, equals(b));
    });
  });

  group('LabSettings', () {
    test('fromJson parses full data', () {
      final json = {
        'lab_name': 'Test Lab',
        'address': '123 Test St',
        'contact_number': '+1234567890',
        'email': 'lab@test.com',
        'website': 'https://testlab.com',
        'license_number': 'LIC001',
        'doctors': [
          {'name': 'Dr. A', 'specialization': 'Cardiology', 'license_number': 'L1', 'contact_number': '1'},
        ],
        'technicians': [
          {'name': 'Tech B', 'specialization': 'Hematology', 'employee_id': 'E1', 'contact_number': '2'},
        ],
        'additional_settings': {'theme': 'dark'},
      };
      final settings = LabSettings.fromJson(json);
      expect(settings.labName, 'Test Lab');
      expect(settings.address, '123 Test St');
      expect(settings.contactNumber, '+1234567890');
      expect(settings.email, 'lab@test.com');
      expect(settings.website, 'https://testlab.com');
      expect(settings.licenseNumber, 'LIC001');
      expect(settings.doctors.length, 1);
      expect(settings.doctors.first.name, 'Dr. A');
      expect(settings.technicians.length, 1);
      expect(settings.technicians.first.name, 'Tech B');
      expect(settings.additionalSettings['theme'], 'dark');
    });

    test('fromJson handles empty fields', () {
      final json = <String, dynamic>{};
      final settings = LabSettings.fromJson(json);
      expect(settings.labName, '');
      expect(settings.address, '');
      expect(settings.contactNumber, '');
      expect(settings.doctors, isEmpty);
      expect(settings.technicians, isEmpty);
    });

    test('fromApiJson parses alternate field names', () {
      final json = {
        'name': 'SAEED Laboratory',
        'lab_address': '456 Hospital Rd',
        'lab_phone': '+9876543210',
        'lab_email': 'info@saeedlab.com',
        'lab_website': 'https://saeedlab.com',
        'lab_license': 'LIC002',
      };
      final settings = LabSettings.fromApiJson(json);
      expect(settings.labName, 'SAEED Laboratory');
      expect(settings.address, '456 Hospital Rd');
      expect(settings.contactNumber, '+9876543210');
      expect(settings.email, 'info@saeedlab.com');
      expect(settings.website, 'https://saeedlab.com');
      expect(settings.licenseNumber, 'LIC002');
    });

    test('fromApiJson uses defaults when missing', () {
      final json = <String, dynamic>{};
      final settings = LabSettings.fromApiJson(json);
      expect(settings.labName, 'SAEED Laboratory');
    });

    test('toJson round-trips', () {
      final settings = LabSettings(
        labName: 'Test Lab',
        address: '123 Test St',
        contactNumber: '+1234567890',
        email: 'lab@test.com',
        website: 'https://testlab.com',
        licenseNumber: 'LIC001',
        doctors: [
          Doctor(name: 'Dr. A', specialization: 'Cardiology', licenseNumber: 'L1', contactNumber: '1'),
        ],
        technicians: [
          Technician(name: 'Tech B', specialization: 'Hematology', employeeId: 'E1', contactNumber: '2'),
        ],
      );
      final json = settings.toJson();
      final restored = LabSettings.fromJson(json);
      expect(restored.labName, settings.labName);
      expect(restored.address, settings.address);
      expect(restored.doctors.length, 1);
      expect(restored.technicians.length, 1);
    });

    test('copyWith preserves original', () {
      final settings = LabSettings(
        labName: 'Old Lab',
        address: 'Old Address',
        contactNumber: '111',
      );
      final copy = settings.copyWith(labName: 'New Lab', address: 'New Address');
      expect(copy.labName, 'New Lab');
      expect(copy.address, 'New Address');
      expect(settings.labName, 'Old Lab');
    });
  });
}
