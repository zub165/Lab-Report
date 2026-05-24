class UserUpdateRequest {
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? role;
  final bool? isActive;
  final String? labGroupId;

  UserUpdateRequest({
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.fullName,
    this.role,
    this.isActive,
    this.labGroupId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (email != null) data['email'] = email;
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (role != null) data['role'] = role;
    if (isActive != null) data['is_active'] = isActive;
    if (labGroupId != null && labGroupId!.trim().isNotEmpty) {
      data['lab_group'] = labGroupId!.trim();
    }
    return data;
  }
}
