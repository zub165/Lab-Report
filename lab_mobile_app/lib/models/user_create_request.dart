import '../utils/env_config.dart';

/// POST /lab/users/ — same payload as SaeedLab Settings → Add clinical staff.
class StaffFormDefaults {
  StaffFormDefaults._();

  static String suggestEmployeeId() {
    final n = DateTime.now().millisecondsSinceEpoch % 1000000;
    return 'EMP-${n.toString().padLeft(6, '0')}';
  }

  static String suggestPassword() => EnvConfig.staffDefaultPassword;

  static String usernameFromEmail(String email) {
    final local = email.trim().split('@').first;
    return local.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '').toLowerCase();
  }

  static ({String first, String last}) splitFullName(String full) {
    final t = full.trim();
    if (t.isEmpty) return (first: 'Staff', last: 'Member');
    final i = t.indexOf(' ');
    if (i < 0) return (first: t, last: 'Staff');
    final last = t.substring(i + 1).trim();
    return (first: t.substring(0, i), last: last.isEmpty ? 'Staff' : last);
  }
}

/// POST /lab/users/ — same payload as SaeedLab Settings → Add clinical staff.
class UserCreateRequest {
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String employeeId;
  final String role;
  final String department;
  final String phone;
  final String address;
  final String hireDate;
  final String? labGroupId;

  UserCreateRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.employeeId,
    required this.role,
    required this.department,
    required this.phone,
    required this.address,
    required this.hireDate,
    this.labGroupId,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'employee_id': employeeId,
      'role': role,
      'department': department,
      'phone': phone,
      'address': address,
      'hire_date': hireDate,
      if (labGroupId != null && labGroupId!.trim().isNotEmpty)
        'lab_group': labGroupId!.trim(),
    };
  }
}

/// UI labels → Django role values (SaeedLab web).
class StaffRoles {
  StaffRoles._();

  /// Quick-add roles (most common).
  static const List<Map<String, String>> quickOptions = [
    {'label': 'Doctor', 'value': 'doctor'},
    {'label': 'Lab Technician', 'value': 'lab_technician'},
    {'label': 'Receptionist', 'value': 'receptionist'},
  ];

  static const List<Map<String, String>> options = [
    ...quickOptions,
    {'label': 'Pathologist', 'value': 'pathologist'},
    {'label': 'Administrator', 'value': 'admin'},
  ];

  /// Normalizes API role or UI label → dropdown value (API slug).
  static String apiRoleForAny(String? roleOrLabel) {
    if (roleOrLabel == null || roleOrLabel.trim().isEmpty) {
      return 'lab_technician';
    }
    final raw = roleOrLabel.trim();
    final slug = raw.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
    for (final o in options) {
      if (o['value'] == slug || o['label'] == raw) return o['value']!;
    }
    if (slug == 'employee' || slug == 'staff') return 'receptionist';
    if (slug == 'administrator') return 'admin';
    if (slug == 'technician') return 'lab_technician';
    return 'lab_technician';
  }

  static String labelForApiRole(String apiRole) {
    final slug = apiRoleForAny(apiRole);
    for (final o in options) {
      if (o['value'] == slug) return o['label']!;
    }
    return options.first['label']!;
  }

  static String apiRoleForLabel(String label) => apiRoleForAny(label);

  static bool isKnownApiRole(String? value) {
    if (value == null) return false;
    final slug = apiRoleForAny(value);
    return options.any((o) => o['value'] == slug);
  }
}
