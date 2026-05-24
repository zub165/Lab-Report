import 'test_result.dart';
import 'patient.dart';
import '../utils/constants.dart';

class Test {
  final String? testId;
  final String patientId;
  final String testType;
  final String testName;
  final String? description;
  final double price;
  final String orderedBy;
  final DateTime orderedDate;
  final DateTime? completedDate;
  final String? results;
  final String? notes;
  final String status;
  final String? priority;
  final String? patientName;
  final Patient? patient;
  final List<TestResult>? testResults;
  final int? id;
  /// Django test-order UUID for `/payments/stripe/create-intent/` (`test_order` field).
  final String? djangoOrderId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? syncedToBackend;

  Test({
    this.testId,
    required this.patientId,
    required this.testType,
    required this.testName,
    this.description,
    required this.price,
    required this.orderedBy,
    required this.orderedDate,
    this.completedDate,
    this.results,
    this.notes,
    required this.status,
    this.priority,
    this.patientName,
    this.patient,
    this.testResults,
    this.id,
    this.djangoOrderId,
    this.createdAt,
    this.updatedAt,
    this.syncedToBackend,
  });

  /// Maps Django `/lab/test-orders/` payloads (same shape as SaeedLab web app).
  factory Test.fromTestOrderJson(Map<String, dynamic> json) {
    final patientField = json['patient'];
    String patientId = '';
    String? patientName;
    if (patientField is Map) {
      patientId = (patientField['id'] ?? patientField['patient_id'] ?? '').toString();
      patientName = patientField['full_name'] as String?;
    } else if (patientField != null) {
      patientId = patientField.toString();
    }
    patientId = patientId.isNotEmpty
        ? patientId
        : (json['patient_id'] ?? json['patient'] ?? '').toString();

    final items = json['test_items'] ?? json['items'];
    String testName = json['test_name'] as String? ?? '';
    String testType = json['test_type'] as String? ?? '';
    if (items is List && items.isNotEmpty) {
      final first = items.first;
      if (first is Map) {
        final testDef = first['test'];
        if (testDef is Map) {
          testName = testName.isEmpty
              ? (testDef['test_name'] ?? testDef['name'] ?? '').toString()
              : testName;
          testType = testType.isEmpty
              ? (testDef['category'] ?? testDef['test_type'] ?? 'General').toString()
              : testType;
        }
      }
    }
    if (testName.isEmpty) {
      testName = 'Order #${json['order_id'] ?? json['order_number'] ?? json['id'] ?? ''}';
    }
    if (testType.isEmpty) testType = 'Lab Order';

    final dateRaw = json['created_at'] ??
        json['order_date'] ??
        json['ordered_date'] ??
        DateTime.now().toIso8601String();

    final djangoId = (json['id'] ?? json['uuid'])?.toString();
    return Test(
      djangoOrderId: djangoId,
      testId: (json['order_id'] ?? json['order_number'] ?? djangoId)?.toString(),
      patientId: patientId,
      testType: testType,
      testName: testName,
      description: json['clinical_notes'] as String? ?? json['description'] as String?,
      price: double.tryParse(
            (json['total_amount'] ?? json['total_price'] ?? json['price'] ?? 0)
                .toString(),
          ) ??
          0.0,
      orderedBy: (json['doctor_name'] ?? json['doctor'] ?? json['ordered_by'] ?? '')
          .toString(),
      orderedDate: DateTime.tryParse(dateRaw.toString()) ?? DateTime.now(),
      completedDate: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      notes: json['clinical_notes'] as String? ?? json['notes'] as String?,
      status: (json['status'] ?? 'pending').toString(),
      priority: json['priority'] as String?,
      patientName: patientName ?? json['patient_name'] as String?,
      patient: patientField is Map
          ? Patient.fromJson(Map<String, dynamic>.from(patientField))
          : null,
      id: JsonParse.intOrNull(json['id']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toTestOrderApiJson() {
    final body = <String, dynamic>{
      'patient': patientId,
      'priority': (priority ?? 'routine').toLowerCase(),
      'clinical_notes': notes ?? '',
      'status': status.toLowerCase().replaceAll(' ', '_'),
    };
    if (results != null && results!.trim().isNotEmpty) {
      body['results'] = results!.trim();
    }
    if (completedDate != null) {
      body['completed_date'] = completedDate!.toIso8601String().split('T').first;
    }
    if (testName.isNotEmpty) {
      body['test_items'] = [
        {'test_id': testId ?? testName},
      ];
    }
    return body;
  }

  factory Test.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('order_id') ||
        json.containsKey('order_number') ||
        (json['test_items'] is List)) {
      return Test.fromTestOrderJson(json);
    }
    return Test(
      testId: json['test_id'] ?? json['TestID'] ?? json['id']?.toString(),
      patientId: (json['patient_id'] ?? json['PatientID'] ?? '').toString(),
      testType: json['category_name'] ??
          json['test_type'] ??
          json['TestType'] ??
          '',
      testName: json['test_name'] ?? json['TestName'] ?? json['name'] ?? '',
      description: json['description'] ?? json['Description'],
      price: double.tryParse((json['price'] ?? json['Price'] ?? 0.0).toString()) ?? 0.0,
      orderedBy: json['ordered_by'] ?? json['OrderedBy'] ?? '',
      orderedDate: DateTime.parse(json['ordered_date'] ?? json['OrderedDate'] ?? json['date'] ?? DateTime.now().toIso8601String()),
      completedDate: json['completed_date'] != null ? DateTime.parse(json['completed_date']) : null,
      results: json['results'] ?? json['Results'],
      notes: json['notes'] ?? json['Notes'],
      status: json['status'] ?? json['Status'] ?? 'pending',
      patientName: json['patient_name'],
      patient: json['patient'] != null ? Patient.fromJson(json['patient']) : null,
      testResults: json['test_results'] != null 
          ? (json['test_results'] as List).map((result) => TestResult.fromJson(result)).toList()
          : null,
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
      'test_id': testId,
      'patient_id': patientId,
      'test_type': testType,
      'test_name': testName,
      'description': description,
      'price': price,
      'ordered_by': orderedBy,
      'ordered_date': orderedDate.toIso8601String().split('T')[0],
      'completed_date': completedDate?.toIso8601String().split('T')[0],
      'results': results,
      'notes': notes,
      'status': status,
      'patient_name': patientName,
      'patient': patient?.toJson(),
      'test_results': testResults?.map((result) => result.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      'patient_id': patientId,
      'test_type': testType,
      'test_name': testName,
      'description': description,
      'price': price,
      'ordered_by': orderedBy,
      'ordered_date': orderedDate.toIso8601String().split('T')[0],
      'notes': notes,
    };
  }

  Test copyWith({
    String? testId,
    String? patientId,
    String? testType,
    String? testName,
    String? description,
    double? price,
    String? orderedBy,
    DateTime? orderedDate,
    DateTime? completedDate,
    String? results,
    String? notes,
    String? status,
    String? patientName,
    Patient? patient,
    List<TestResult>? testResults,
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Test(
      testId: testId ?? this.testId,
      patientId: patientId ?? this.patientId,
      testType: testType ?? this.testType,
      testName: testName ?? this.testName,
      description: description ?? this.description,
      price: price ?? this.price,
      orderedBy: orderedBy ?? this.orderedBy,
      orderedDate: orderedDate ?? this.orderedDate,
      completedDate: completedDate ?? this.completedDate,
      results: results ?? this.results,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      patientName: patientName ?? this.patientName,
      patient: patient ?? this.patient,
      testResults: testResults ?? this.testResults,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isInProgress => status.toLowerCase() == 'in progress';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  bool get isUrgent => status.toLowerCase() == 'urgent';
  bool get isEmergency => status.toLowerCase() == 'emergency';

  String get formattedDate {
    return '${orderedDate.day}/${orderedDate.month}/${orderedDate.year}';
  }

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return '#27AE60';
      case 'in progress':
        return '#3498DB';
      case 'pending':
        return '#F39C12';
      case 'cancelled':
        return '#E74C3C';
      default:
        return '#95A5A6';
    }
  }

  String get priorityColor {
    switch (status.toLowerCase()) {
      case 'emergency':
        return '#E74C3C';
      case 'urgent':
        return '#F39C12';
      case 'normal':
        return '#27AE60';
      default:
        return '#95A5A6';
    }
  }

  @override
  String toString() {
    return 'Test(testId: $testId, patientId: $patientId, testType: $testType, testName: $testName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Test && other.testId == testId;
  }

  @override
  int get hashCode => testId.hashCode;

  // Local storage methods
  Map<String, dynamic> toLocalJson() {
    return {
      'id': testId,
      'patient_id': patientId,
      'test_type': testType,
      'test_name': testName,
      'description': description,
      'price': price,
      'ordered_by': orderedBy,
      'ordered_date': orderedDate.toIso8601String(),
      'status': status,
      'completed_date': completedDate?.toIso8601String(),
      'notes': notes,
      'priority': priority ?? 'Normal',
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'synced_to_backend': 0,
      'backend_id': null,
    };
  }

  factory Test.fromLocalJson(Map<String, dynamic> json) {
    return Test(
      testId: json['id'],
      patientId: json['patient_id'],
      testType: json['test_type'],
      testName: json['test_name'],
      description: json['description'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      orderedBy: json['ordered_by'],
      orderedDate: json['ordered_date'] != null ? DateTime.parse(json['ordered_date']) : DateTime.now(),
      status: json['status'],
      completedDate: json['completed_date'] != null ? DateTime.parse(json['completed_date']) : null,
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}
