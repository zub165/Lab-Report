import 'package:flutter_test/flutter_test.dart';
import 'package:lab_mobile_app/models/user_update_request.dart';

void main() {
  group('UserUpdateRequest', () {
    test('toJson includes only non-null fields', () {
      final req = UserUpdateRequest(
        email: 'newemail@example.com',
        role: 'admin',
        isActive: false,
      );
      final json = req.toJson();
      expect(json['email'], 'newemail@example.com');
      expect(json['role'], 'admin');
      expect(json['is_active'], false);
      expect(json.containsKey('first_name'), false);
      expect(json.containsKey('last_name'), false);
    });

    test('toJson returns empty map when all fields null', () {
      final req = UserUpdateRequest();
      final json = req.toJson();
      expect(json, isEmpty);
    });

    test('toJson includes first_name and last_name when set', () {
      final req = UserUpdateRequest(
        firstName: 'John',
        lastName: 'Doe',
      );
      final json = req.toJson();
      expect(json['first_name'], 'John');
      expect(json['last_name'], 'Doe');
    });

    test('toJson includes username when set', () {
      final req = UserUpdateRequest(username: 'newuser');
      final json = req.toJson();
      expect(json.containsKey('username'), false);
    });
  });
}
