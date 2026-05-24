class Appointment {
  final String? appointmentId;
  final String patientId;
  final String patientName;
  final String testType;
  final String testName;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String status; // 'scheduled', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show'
  final String? notes;
  final String? doctorName;
  final String? roomNumber;
  final double? price;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  Appointment({
    this.appointmentId,
    required this.patientId,
    required this.patientName,
    required this.testType,
    required this.testName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.notes,
    this.doctorName,
    this.roomNumber,
    this.price,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointment_id'] ?? json['id']?.toString(),
      patientId: json['patient_id']?.toString() ?? '',
      patientName: json['patient_name'] ?? json['patientName'] ?? '',
      testType: json['test_type'] ?? json['testType'] ?? '',
      testName: json['test_name'] ?? json['testName'] ?? '',
      appointmentDate: DateTime.parse(json['appointment_date'] ?? json['appointmentDate']),
      appointmentTime: json['appointment_time'] ?? json['appointmentTime'] ?? '',
      status: json['status'] ?? 'scheduled',
      notes: json['notes'],
      doctorName: json['doctor_name'] ?? json['doctorName'],
      roomNumber: json['room_number'] ?? json['roomNumber'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      createdBy: json['created_by'] ?? json['createdBy'],
      updatedBy: json['updated_by'] ?? json['updatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointment_id': appointmentId,
      'patient_id': patientId,
      'patient_name': patientName,
      'test_type': testType,
      'test_name': testName,
      'appointment_date': appointmentDate.toIso8601String(),
      'appointment_time': appointmentTime,
      'status': status,
      'notes': notes,
      'doctor_name': doctorName,
      'room_number': roomNumber,
      'price': price,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      'patient_id': patientId,
      'patient_name': patientName,
      'test_type': testType,
      'test_name': testName,
      'appointment_date': appointmentDate.toIso8601String(),
      'appointment_time': appointmentTime,
      'status': status,
      'notes': notes,
      'doctor_name': doctorName,
      'room_number': roomNumber,
      'price': price,
    };
  }

  Appointment copyWith({
    String? appointmentId,
    String? patientId,
    String? patientName,
    String? testType,
    String? testName,
    DateTime? appointmentDate,
    String? appointmentTime,
    String? status,
    String? notes,
    String? doctorName,
    String? roomNumber,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Appointment(
      appointmentId: appointmentId ?? this.appointmentId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      testType: testType ?? this.testType,
      testName: testName ?? this.testName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      doctorName: doctorName ?? this.doctorName,
      roomNumber: roomNumber ?? this.roomNumber,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  // Helper getters
  String get formattedDate => '${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}';
  String get formattedTime => appointmentTime;
  String get formattedDateTime => '$formattedDate at $formattedTime';
  
  bool get isScheduled => status == 'scheduled';
  bool get isConfirmed => status == 'confirmed';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isNoShow => status == 'no_show';
  
  bool get isToday {
    final now = DateTime.now();
    return appointmentDate.year == now.year &&
           appointmentDate.month == now.month &&
           appointmentDate.day == now.day;
  }
  bool get isPast => appointmentDate.isBefore(DateTime.now());
  bool get isFuture => appointmentDate.isAfter(DateTime.now());
  
  String get statusDisplay {
    switch (status) {
      case 'scheduled':
        return 'Scheduled';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'no_show':
        return 'No Show';
      default:
        return 'Unknown';
    }
  }

  String get statusColor {
    switch (status) {
      case 'scheduled':
        return '#3498db'; // Blue
      case 'confirmed':
        return '#2ecc71'; // Green
      case 'in_progress':
        return '#f39c12'; // Orange
      case 'completed':
        return '#27ae60'; // Dark Green
      case 'cancelled':
        return '#e74c3c'; // Red
      case 'no_show':
        return '#95a5a6'; // Gray
      default:
        return '#7f8c8d'; // Default Gray
    }
  }
}
