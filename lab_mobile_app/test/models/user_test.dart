import 'package:flutter_test/flutter_test.dart';
import 'package:lab_mobile_app/models/user.dart';

void main() {
  group('User', () {
    final now = DateTime.now();

    test('fromJson parses flat JSON correctly', () {
      final json = {
        'id': 1,
        'username': 'johndoe',
        'full_name': 'John Doe',
        'email': 'john@example.com',
        'role': 'doctor',
        'is_active': true,
        'last_login': now.toIso8601String(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      final user = User.fromJson(json);
      expect(user.id, 1);
      expect(user.username, 'johndoe');
      expect(user.fullName, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.role, 'doctor');
      expect(user.isActive, true);
      expect(user.lastLogin, isNotNull);
      expect(user.createdAt, isNotNull);
      expect(user.updatedAt, isNotNull);
    });

    test('fromJson parses with lab_profile fallback', () {
      final json = {
        'id': 2,
        'lab_profile': {
          'username': 'janes',
          'full_name': 'Jane Smith',
          'email': 'jane@lab.com',
          'role': 'admin',
          'department': 'Pathology',
          'employee_id': 'EMP001',
        },
      };
      final user = User.fromJson(json);
      expect(user.id, 2);
      expect(user.username, 'janes');
      expect(user.fullName, 'Jane Smith');
      expect(user.email, 'jane@lab.com');
      expect(user.role, 'admin');
      expect(user.departmentFromProfile, 'Pathology');
      expect(user.employeeIdFromProfile, 'EMP001');
    });

    test('fromJson parses LabUser list row from GET /lab/users/', () {
      final json = {
        'id': 12,
        'user': {
          'id': 3,
          'username': 'drsmith',
          'email': 'smith@lab.com',
          'first_name': 'John',
          'last_name': 'Smith',
        },
        'lab_group': 7,
        'lab_group_name': 'Saeed Lab',
        'role': 'doctor',
        'is_active': true,
        'full_name': 'Dr John Smith',
      };
      final user = User.fromJson(json);
      expect(user.id, 12);
      expect(user.username, 'drsmith');
      expect(user.email, 'smith@lab.com');
      expect(user.fullName, 'Dr John Smith');
      expect(user.role, 'doctor');
      expect(user.labGroupId, '7');
      expect(user.labGroupName, 'Saeed Lab');
      expect(user.labGroupDisplay, 'Saeed Lab');
    });

    test('fromJson combines first_name and last_name', () {
      final json = {
        'first_name': 'John',
        'last_name': 'Doe',
        'role': 'technician',
      };
      final user = User.fromJson(json);
      expect(user.fullName, 'John Doe');
      expect(user.role, 'technician');
    });

    test('fromJson handles empty/missing fields', () {
      final json = <String, dynamic>{};
      final user = User.fromJson(json);
      expect(user.id, isNull);
      expect(user.username, '');
      expect(user.fullName, '');
      expect(user.email, '');
      expect(user.role, 'user');
      expect(user.isActive, true);
    });

    test('toJson produces correct map', () {
      final user = User(
        id: 1,
        username: 'johndoe',
        fullName: 'John Doe',
        email: 'john@example.com',
        role: 'doctor',
        isActive: true,
        lastLogin: now,
        createdAt: now,
        updatedAt: now,
      );
      final json = user.toJson();
      expect(json['id'], 1);
      expect(json['username'], 'johndoe');
      expect(json['full_name'], 'John Doe');
      expect(json['email'], 'john@example.com');
      expect(json['role'], 'doctor');
      expect(json['is_active'], true);
    });

    test('toApiJson excludes id and timestamps', () {
      final user = User(
        id: 1,
        username: 'johndoe',
        fullName: 'John Doe',
        email: 'john@example.com',
        role: 'doctor',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      final apiJson = user.toApiJson();
      expect(apiJson.containsKey('id'), false);
      expect(apiJson.containsKey('created_at'), false);
      expect(apiJson.containsKey('updated_at'), false);
      expect(apiJson['username'], 'johndoe');
    });

    test('copyWith preserves original', () {
      final user = User(
        id: 1,
        username: 'johndoe',
        fullName: 'John Doe',
        email: 'john@example.com',
        role: 'doctor',
      );
      final copy = user.copyWith(fullName: 'Jane Doe', role: 'admin');
      expect(copy.fullName, 'Jane Doe');
      expect(copy.role, 'admin');
      expect(user.fullName, 'John Doe');
      expect(user.role, 'doctor');
    });

    group('role helpers', () {
      test('isAdmin returns true for admin and administrator', () {
        expect(User(id: null, username: '', fullName: '', email: '', role: 'admin').isAdmin, true);
        expect(User(id: null, username: '', fullName: '', email: '', role: 'administrator').isAdmin, true);
        expect(User(id: null, username: '', fullName: '', email: '', role: 'Admin').isAdmin, true);
        expect(User(id: null, username: '', fullName: '', email: '', role: 'doctor').isAdmin, false);
      });

      test('isDoctor returns true for doctor', () {
        expect(User(id: null, username: '', fullName: '', email: '', role: 'doctor').isDoctor, true);
        expect(User(id: null, username: '', fullName: '', email: '', role: 'Doctor').isDoctor, true);
        expect(User(id: null, username: '', fullName: '', email: '', role: 'admin').isDoctor, false);
      });

      test('isTechnician returns true for technician roles', () {
        expect(User(id: null, username: '', fullName: '', email: '', role: 'technician').isTechnician, true);
        expect(User(id: null, username: '', fullName: '', email: '', role: 'lab_technician').isTechnician, true);
        expect(User(id: null, username: '', fullName: '', email: '', role: 'doctor').isTechnician, false);
      });

      test('isReceptionist returns true for receptionist', () {
        expect(User(id: null, username: '', fullName: '', email: '', role: 'receptionist').isReceptionist, true);
        expect(User(id: null, username: '', fullName: '', email: '', role: 'Receptionist').isReceptionist, true);
        expect(User(id: null, username: '', fullName: '', email: '', role: 'doctor').isReceptionist, false);
      });

      test('roleDisplayName delegates to StaffRoles', () {
        final doctor = User(id: null, username: '', fullName: '', email: '', role: 'doctor');
        expect(doctor.roleDisplayName, isNotEmpty);
      });
    });

    test('equality is based on id', () {
      final a = User(id: 1, username: 'john', fullName: 'John', email: 'a@b.com', role: 'doctor');
      final b = User(id: 1, username: 'jane', fullName: 'Jane', email: 'c@d.com', role: 'admin');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString returns formatted string', () {
      final user = User(id: 1, username: 'johndoe', fullName: 'John Doe', email: 'john@example.com', role: 'doctor');
      expect(user.toString(), contains('johndoe'));
      expect(user.toString(), contains('doctor'));
    });
  });
}
