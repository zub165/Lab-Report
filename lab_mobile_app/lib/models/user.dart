import '../utils/constants.dart';
import 'user_create_request.dart';

class User {
  final int? id;
  final String username;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? labProfile;

  User({
    this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.role,
    this.isActive = true,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
    this.labProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // GET /lab/users/ returns LabUser rows: { id, user: {...}, lab_group, role, ... }
    final nestedUser = json['user'];
    final userMap = nestedUser is Map
        ? Map<String, dynamic>.from(nestedUser)
        : null;
    final isLabUserRow = userMap != null;

    Map<String, dynamic>? profile;
    if (json['lab_profile'] is Map) {
      profile = Map<String, dynamic>.from(json['lab_profile'] as Map);
    } else if (isLabUserRow) {
      profile = <String, dynamic>{};
      for (final key in [
        'department',
        'employee_id',
        'phone',
        'address',
        'hire_date',
        'license_number',
        'lab_group',
        'lab_group_name',
        'lab_group_id',
      ]) {
        if (json[key] != null) profile[key] = json[key];
      }
    }

    if (profile != null) {
      if (json['lab_group'] != null && profile['lab_group'] == null) {
        profile['lab_group'] = json['lab_group'];
      }
      if (json['lab_group_name'] != null && profile['lab_group_name'] == null) {
        profile['lab_group_name'] = json['lab_group_name'];
      }
      if (json['lab_group_id'] != null && profile['lab_group_id'] == null) {
        profile['lab_group_id'] = json['lab_group_id'];
      }
    } else if (json['lab_group'] != null || json['lab_group_name'] != null) {
      profile = {
        if (json['lab_group'] != null) 'lab_group': json['lab_group'],
        if (json['lab_group_name'] != null) 'lab_group_name': json['lab_group_name'],
        if (json['lab_group_id'] != null) 'lab_group_id': json['lab_group_id'],
      };
    }

    // PATCH/DELETE /lab/users/{id}/ uses LabUser primary key when row comes from /users/.
    final labUserId = JsonParse.intOrNull(json['id']);
    final djangoUserId =
        userMap != null ? JsonParse.intOrNull(userMap['id']) : labUserId;
    final apiId = isLabUserRow ? labUserId : djangoUserId;

    var username = json['username']?.toString() ?? profile?['username']?.toString() ?? '';
    if (username.isEmpty && userMap != null) {
      username = userMap['username']?.toString() ?? '';
    }

    var email = json['email']?.toString() ?? profile?['email']?.toString() ?? '';
    if (email.isEmpty && userMap != null) {
      email = userMap['email']?.toString() ?? '';
    }

    var fullName =
        json['full_name']?.toString() ?? profile?['full_name']?.toString() ?? '';
    if (fullName.isEmpty && userMap != null) {
      fullName =
          '${userMap['first_name'] ?? ''} ${userMap['last_name'] ?? ''}'.trim();
    }
    if (fullName.isEmpty) {
      fullName = '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim();
    }

    final role = json['role']?.toString() ??
        profile?['role']?.toString() ??
        userMap?['role']?.toString() ??
        'user';

    final rawActive =
        json['is_active'] ?? profile?['is_active'] ?? userMap?['is_active'];
    final isActive = rawActive == null ? true : rawActive == true || rawActive == 1;

    final lastLoginRaw = json['last_login'] ?? userMap?['last_login'];

    return User(
      id: apiId,
      username: username,
      fullName: fullName,
      email: email,
      role: role,
      isActive: isActive,
      lastLogin: lastLoginRaw != null
          ? DateTime.tryParse(lastLoginRaw.toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      labProfile: profile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'email': email,
      'role': role,
      'is_active': isActive,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      'username': username,
      'full_name': fullName,
      'email': email,
      'role': role,
      'is_active': isActive,
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? fullName,
    String? email,
    String? role,
    bool? isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAdmin {
    final r = role.toLowerCase();
    return r == 'admin' || r == 'administrator';
  }

  bool get isDoctor => role.toLowerCase() == 'doctor';

  bool get isTechnician {
    final r = role.toLowerCase();
    return r == 'technician' || r == 'lab_technician';
  }

  bool get isReceptionist => role.toLowerCase() == 'receptionist';

  String get roleDisplayName {
    return StaffRoles.labelForApiRole(role);
  }

  String? get departmentFromProfile => labProfile?['department']?.toString();

  String? get employeeIdFromProfile => labProfile?['employee_id']?.toString();

  /// Lab chain / branch partition (Django `lab_group`).
  String? get labGroupId {
    final fromProfile = labProfile?['lab_group'];
    if (fromProfile is Map) {
      return fromProfile['id']?.toString();
    }
    if (fromProfile != null) return fromProfile.toString();
    return labProfile?['lab_group_id']?.toString();
  }

  String? get labGroupName {
    final named = labProfile?['lab_group_name']?.toString().trim();
    if (named != null && named.isNotEmpty) return named;
    final fromProfile = labProfile?['lab_group'];
    if (fromProfile is Map) {
      final n = fromProfile['name']?.toString().trim();
      if (n != null && n.isNotEmpty) return n;
    }
    return null;
  }

  String get labGroupDisplay => labGroupName ?? 'Default lab group';

  @override
  String toString() {
    return 'User(id: $id, username: $username, fullName: $fullName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
