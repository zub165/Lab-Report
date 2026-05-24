import 'package:flutter_test/flutter_test.dart';
import 'package:lab_mobile_app/models/user_create_request.dart';

void main() {
  group('UserCreateRequest', () {
    test('toJson produces correct map', () {
      final req = UserCreateRequest(
        username: 'johndoe',
        email: 'john@example.com',
        password: 'Secret123',
        firstName: 'John',
        lastName: 'Doe',
        employeeId: 'EMP001',
        role: 'doctor',
        department: 'Pathology',
        phone: '+1234567890',
        address: '123 Main St',
        hireDate: '2024-01-15',
      );
      final json = req.toJson();
      expect(json['username'], 'johndoe');
      expect(json['email'], 'john@example.com');
      expect(json['password'], 'Secret123');
      expect(json['first_name'], 'John');
      expect(json['last_name'], 'Doe');
      expect(json['employee_id'], 'EMP001');
      expect(json['role'], 'doctor');
      expect(json['department'], 'Pathology');
      expect(json['phone'], '+1234567890');
      expect(json['address'], '123 Main St');
      expect(json['hire_date'], '2024-01-15');
    });
  });

  group('StaffFormDefaults', () {
    test('suggestEmployeeId returns EMP- pattern', () {
      final id = StaffFormDefaults.suggestEmployeeId();
      expect(id, startsWith('EMP-'));
      expect(id.length, greaterThan(4));
    });

    test('suggestPassword returns non-empty string', () {
      expect(StaffFormDefaults.suggestPassword(), isNotEmpty);
    });

    test('usernameFromEmail extracts local part', () {
      expect(StaffFormDefaults.usernameFromEmail('John.Doe@Example.com'), 'john.doe');
      expect(StaffFormDefaults.usernameFromEmail('alice@test.com'), 'alice');
    });

    test('usernameFromEmail handles special chars', () {
      expect(StaffFormDefaults.usernameFromEmail('bob!smith@test.com'), 'bobsmith');
    });

    test('splitFullName splits at first space', () {
      final result = StaffFormDefaults.splitFullName('John Michael Doe');
      expect(result.first, 'John');
      expect(result.last, 'Michael Doe');
    });

    test('splitFullName handles single name', () {
      final result = StaffFormDefaults.splitFullName('Madonna');
      expect(result.first, 'Madonna');
      expect(result.last, 'Staff');
    });

    test('splitFullName handles empty string', () {
      final result = StaffFormDefaults.splitFullName('');
      expect(result.first, 'Staff');
      expect(result.last, 'Member');
    });

    test('splitFullName handles trailing space', () {
      final result = StaffFormDefaults.splitFullName('John ');
      expect(result.first, 'John');
      expect(result.last, 'Staff');
    });
  });

  group('StaffRoles', () {
    test('quickOptions contains three common roles', () {
      expect(StaffRoles.quickOptions.length, 3);
      expect(StaffRoles.quickOptions[0]['value'], 'doctor');
      expect(StaffRoles.quickOptions[1]['value'], 'lab_technician');
      expect(StaffRoles.quickOptions[2]['value'], 'receptionist');
    });

    test('options contains quickOptions plus pathologist and admin', () {
      expect(StaffRoles.options.length, 5);
      expect(StaffRoles.options[3]['value'], 'pathologist');
      expect(StaffRoles.options[4]['value'], 'admin');
    });

    group('apiRoleForAny', () {
      test('returns lab_technician for null or empty', () {
        expect(StaffRoles.apiRoleForAny(null), 'lab_technician');
        expect(StaffRoles.apiRoleForAny(''), 'lab_technician');
        expect(StaffRoles.apiRoleForAny('  '), 'lab_technician');
      });

      test('normalizes exact values', () {
        expect(StaffRoles.apiRoleForAny('doctor'), 'doctor');
        expect(StaffRoles.apiRoleForAny('lab_technician'), 'lab_technician');
        expect(StaffRoles.apiRoleForAny('admin'), 'admin');
      });

      test('normalizes by label', () {
        expect(StaffRoles.apiRoleForAny('Doctor'), 'doctor');
        expect(StaffRoles.apiRoleForAny('Lab Technician'), 'lab_technician');
        expect(StaffRoles.apiRoleForAny('Administrator'), 'admin');
      });

      test('normalizes synonyms', () {
        expect(StaffRoles.apiRoleForAny('technician'), 'lab_technician');
        expect(StaffRoles.apiRoleForAny('employee'), 'receptionist');
        expect(StaffRoles.apiRoleForAny('staff'), 'receptionist');
      });

      test('falls back to lab_technician for unknown', () {
        expect(StaffRoles.apiRoleForAny('ceo'), 'lab_technician');
      });
    });

    group('labelForApiRole', () {
      test('returns correct label for known roles', () {
        expect(StaffRoles.labelForApiRole('doctor'), 'Doctor');
        expect(StaffRoles.labelForApiRole('lab_technician'), 'Lab Technician');
        expect(StaffRoles.labelForApiRole('receptionist'), 'Receptionist');
        expect(StaffRoles.labelForApiRole('admin'), 'Administrator');
      });

      test('returns lab_technician label for unknown (default fallback)', () {
        expect(StaffRoles.labelForApiRole('unknown'), 'Lab Technician');
      });
    });

    group('isKnownApiRole', () {
      test('returns true for known roles', () {
        expect(StaffRoles.isKnownApiRole('doctor'), true);
        expect(StaffRoles.isKnownApiRole('admin'), true);
        expect(StaffRoles.isKnownApiRole('lab_technician'), true);
      });

      test('returns true for unknown because apiRoleForAny normalizes it', () {
        expect(StaffRoles.isKnownApiRole('ceo'), true);
      });

      test('returns false for null', () {
        expect(StaffRoles.isKnownApiRole(null), false);
      });
    });

    test('apiRoleForLabel delegates to apiRoleForAny', () {
      expect(StaffRoles.apiRoleForLabel('Doctor'), 'doctor');
      expect(StaffRoles.apiRoleForLabel('technician'), 'lab_technician');
    });
  });
}
