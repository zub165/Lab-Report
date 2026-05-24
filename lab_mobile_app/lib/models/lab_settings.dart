class LabSettings {
  final String labName;
  final String address;
  final String contactNumber;
  final String email;
  final String website;
  final String licenseNumber;
  final List<Doctor> doctors;
  final List<Technician> technicians;
  final Map<String, dynamic> additionalSettings;

  LabSettings({
    required this.labName,
    required this.address,
    required this.contactNumber,
    this.email = '',
    this.website = '',
    this.licenseNumber = '',
    this.doctors = const [],
    this.technicians = const [],
    this.additionalSettings = const {},
  });

  factory LabSettings.fromJson(Map<String, dynamic> json) {
    return LabSettings(
      labName: json['lab_name'] ?? '',
      address: json['address'] ?? json['lab_address'] ?? '',
      contactNumber: json['contact_number'] ?? json['lab_phone'] ?? '',
      email: json['email'] ?? json['lab_email'] ?? '',
      website: json['website'] ?? '',
      licenseNumber: json['license_number'] ?? '',
      doctors: (json['doctors'] as List<dynamic>?)
          ?.map((doctor) => Doctor.fromJson(doctor))
          .toList() ?? [],
      technicians: (json['technicians'] as List<dynamic>?)
          ?.map((technician) => Technician.fromJson(technician))
          .toList() ?? [],
      additionalSettings: json['additional_settings'] ?? {},
    );
  }

  factory LabSettings.fromApiJson(Map<String, dynamic> json) {
    return LabSettings(
      labName: json['lab_name'] ?? json['name'] ?? 'SAEED Laboratory',
      address: json['lab_address'] ?? json['address'] ?? '',
      contactNumber: json['lab_phone'] ?? json['contact_number'] ?? json['phone'] ?? '',
      email: json['lab_email'] ?? json['email'] ?? '',
      website: json['lab_website'] ?? json['website'] ?? '',
      licenseNumber: json['lab_license'] ?? json['license_number'] ?? '',
      doctors: [],
      technicians: [],
      additionalSettings: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lab_name': labName,
      'address': address,
      'contact_number': contactNumber,
      'email': email,
      'website': website,
      'license_number': licenseNumber,
      'doctors': doctors.map((doctor) => doctor.toJson()).toList(),
      'technicians': technicians.map((technician) => technician.toJson()).toList(),
      'additional_settings': additionalSettings,
    };
  }

  LabSettings copyWith({
    String? labName,
    String? address,
    String? contactNumber,
    String? email,
    String? website,
    String? licenseNumber,
    List<Doctor>? doctors,
    List<Technician>? technicians,
    Map<String, dynamic>? additionalSettings,
  }) {
    return LabSettings(
      labName: labName ?? this.labName,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      doctors: doctors ?? this.doctors,
      technicians: technicians ?? this.technicians,
      additionalSettings: additionalSettings ?? this.additionalSettings,
    );
  }
}

class Doctor {
  final int? id;
  final String name;
  final String specialization;
  final String licenseNumber;
  final String contactNumber;
  final String email;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Doctor({
    this.id,
    required this.name,
    required this.specialization,
    required this.licenseNumber,
    required this.contactNumber,
    this.email = '',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      licenseNumber: json['license_number'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      email: json['email'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'license_number': licenseNumber,
      'contact_number': contactNumber,
      'email': email,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Doctor copyWith({
    int? id,
    String? name,
    String? specialization,
    String? licenseNumber,
    String? contactNumber,
    String? email,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Doctor(id: $id, name: $name, specialization: $specialization)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Doctor && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Technician {
  final int? id;
  final String name;
  final String specialization;
  final String employeeId;
  final String contactNumber;
  final String email;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Technician({
    this.id,
    required this.name,
    required this.specialization,
    required this.employeeId,
    required this.contactNumber,
    this.email = '',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Technician.fromJson(Map<String, dynamic> json) {
    return Technician(
      id: json['id'],
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      employeeId: json['employee_id'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      email: json['email'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'employee_id': employeeId,
      'contact_number': contactNumber,
      'email': email,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Technician copyWith({
    int? id,
    String? name,
    String? specialization,
    String? employeeId,
    String? contactNumber,
    String? email,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Technician(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      employeeId: employeeId ?? this.employeeId,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Technician(id: $id, name: $name, specialization: $specialization)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Technician && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
