import '../utils/constants.dart';

class Patient {
  final String? patientId;
  final String fullName;
  final DateTime dateOfBirth;
  final String gender;
  final String phone;
  final String? email;
  final String? address;
  final String? emergencyContact;
  final String? bloodType;
  final String? medicalHistory;
  final String? insuranceInfo;
  final int? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? syncedToBackend;

  Patient({
    this.patientId,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.phone,
    this.email,
    this.address,
    this.emergencyContact,
    this.bloodType,
    this.medicalHistory,
    this.insuranceInfo,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.syncedToBackend,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    final dobRaw = json['date_of_birth'] ?? json['DateOfBirth'] ?? json['dob'];
    return Patient(
      patientId: JsonParse.stringOrNull(
            json['patient_id'] ?? json['PatientID'] ?? json['id']) ??
          JsonParse.string(json['id']),
      fullName: json['full_name'] ?? json['FullName'] ?? json['name'] ?? '',
      dateOfBirth: dobRaw != null
          ? DateTime.tryParse(dobRaw.toString()) ?? DateTime.now()
          : DateTime.now(),
      gender: json['gender'] ?? json['Gender'] ?? '',
      phone: json['phone'] ?? json['Phone'] ?? json['contact_number'] ?? json['ContactNumber'] ?? '',
      email: json['email'] ?? json['Email'],
      address: json['address'] ?? json['Address'],
      emergencyContact: json['emergency_contact'] ?? json['EmergencyContact'],
      bloodType: json['blood_type'] ?? json['BloodType'],
      medicalHistory: json['medical_history'] ?? json['MedicalHistory'],
      insuranceInfo: json['insurance_info'] ?? json['InsuranceInfo'],
      id: JsonParse.intOrNull(json['id']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'full_name': fullName,
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
      'gender': gender,
      'phone': phone,
      'email': email,
      'address': address,
      'emergency_contact': emergencyContact,
      'blood_type': bloodType,
      'medical_history': medicalHistory,
      'insurance_info': insuranceInfo,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      'full_name': fullName,
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
      'gender': gender,
      'phone': phone,
      'email': email,
      'address': address,
      'emergency_contact': emergencyContact,
      'blood_type': bloodType,
      'medical_history': medicalHistory,
      'insurance_info': insuranceInfo,
    };
  }

  Patient copyWith({
    String? patientId,
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    String? email,
    String? address,
    String? emergencyContact,
    String? bloodType,
    String? medicalHistory,
    String? insuranceInfo,
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      patientId: patientId ?? this.patientId,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      bloodType: bloodType ?? this.bloodType,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      insuranceInfo: insuranceInfo ?? this.insuranceInfo,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  String get formattedDateOfBirth {
    return '${dateOfBirth.day}/${dateOfBirth.month}/${dateOfBirth.year}';
  }

  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  @override
  String toString() {
    return 'Patient(patientId: $patientId, fullName: $fullName, age: $age, gender: $gender)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Patient && other.patientId == patientId;
  }

  @override
  int get hashCode => patientId.hashCode;

  // Local storage methods
  Map<String, dynamic> toLocalJson() {
    return {
      'id': patientId,
      'full_name': fullName,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'phone': phone,
      'email': email,
      'address': address,
      'blood_type': bloodType,
      'medical_history': medicalHistory,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'synced_to_backend': 0,
      'backend_id': null,
    };
  }

  factory Patient.fromLocalJson(Map<String, dynamic> json) {
    return Patient(
      patientId: json['id'],
      fullName: json['full_name'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      gender: json['gender'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      bloodType: json['blood_type'],
      medicalHistory: json['medical_history'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}
