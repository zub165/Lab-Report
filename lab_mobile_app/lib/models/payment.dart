class Payment {
  final String? paymentId;
  final String testId;
  final String patientId;
  final String patientName;
  final String testType;
  final String testName;
  final double amount;
  final String paymentMethod;
  final String status; // 'pending', 'completed', 'failed', 'refunded', 'cancelled'
  final String? notes;
  final String? transactionId;
  final String? receiptNumber;
  final DateTime paymentDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  Payment({
    this.paymentId,
    required this.testId,
    required this.patientId,
    required this.patientName,
    required this.testType,
    required this.testName,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.notes,
    this.transactionId,
    this.receiptNumber,
    required this.paymentDate,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  static String _str(dynamic v, [String fallback = '']) {
    if (v == null) return fallback;
    final s = v.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  /// Maps Django `/lab/payments/` (same fields as SaeedLab web payments tab).
  factory Payment.fromJson(Map<String, dynamic> json) {
    final testOrder = json['test_order'];
    var testId = '';
    var testName = '';
    var testType = '';
    var patientId = '';
    var patientName = '';

    if (testOrder is Map) {
      final order = Map<String, dynamic>.from(testOrder);
      testId = order['order_id']?.toString() ??
          order['id']?.toString() ??
          '';
      testName = order['test_name']?.toString() ?? '';
      testType = order['test_type']?.toString() ?? '';
      final p = order['patient'];
      if (p is Map) {
        final pm = Map<String, dynamic>.from(p);
        patientId = pm['patient_id']?.toString() ?? pm['id']?.toString() ?? '';
        patientName = pm['full_name']?.toString() ?? pm['name']?.toString() ?? '';
      }
    } else {
      testId = json['test_order']?.toString() ??
          json['test_order_id']?.toString() ??
          json['order_id']?.toString() ??
          json['test_id']?.toString() ??
          '';
    }

    final patientField = json['patient'];
    if (patientField is Map) {
      final pm = Map<String, dynamic>.from(patientField);
      patientId = pm['patient_id']?.toString() ?? pm['id']?.toString() ?? patientId;
      patientName = pm['full_name']?.toString() ?? pm['name']?.toString() ?? patientName;
    } else if (patientField != null) {
      patientId = patientField.toString();
    }

    patientId = patientId.isNotEmpty
        ? patientId
        : (json['patient_id']?.toString() ?? '');
    patientName = patientName.isNotEmpty
        ? patientName
        : (json['patient_name']?.toString() ??
            json['patientName']?.toString() ??
            'Unknown');
    testName = testName.isNotEmpty
        ? testName
        : (json['test_name']?.toString() ?? json['testName']?.toString() ?? '');
    testType = testType.isNotEmpty
        ? testType
        : (json['test_type']?.toString() ?? json['testType']?.toString() ?? '');

    return Payment(
      paymentId: _str(json['payment_id'] ?? json['id'], '').isEmpty
          ? null
          : _str(json['payment_id'] ?? json['id']),
      testId: _str(testId),
      patientId: _str(patientId),
      patientName: _str(patientName, 'Unknown'),
      testType: _str(testType, 'general'),
      testName: _str(testName, 'Lab test'),
      amount: double.tryParse((json['amount'] ?? 0.0).toString()) ?? 0.0,
      paymentMethod: _str(json['payment_method'] ?? json['method'], 'cash'),
      status: _str(json['status'], 'completed').toLowerCase(),
      notes: json['notes']?.toString(),
      transactionId: json['transaction_id']?.toString() ?? json['transactionId']?.toString(),
      receiptNumber: json['receipt_number']?.toString() ?? json['receiptNumber']?.toString(),
      paymentDate: _parsePaymentDate(
        json['payment_date'] ?? json['paymentDate'] ?? json['date'] ?? json['created_at'],
      ),
      createdAt: _parsePaymentDate(
        json['created_at'] ?? json['createdAt'] ?? json['payment_date'],
      ),
      updatedAt: json['updated_at'] != null
          ? _parsePaymentDate(json['updated_at'])
          : null,
      createdBy: json['created_by']?.toString() ?? json['createdBy']?.toString(),
      updatedBy: json['updated_by']?.toString() ?? json['updatedBy']?.toString(),
    );
  }

  static DateTime _parsePaymentDate(dynamic value) {
    if (value == null) return DateTime.now();
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'test_id': testId,
      'patient_id': patientId,
      'patient_name': patientName,
      'test_type': testType,
      'test_name': testName,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': status,
      'notes': notes,
      'transaction_id': transactionId,
      'receipt_number': receiptNumber,
      'payment_date': paymentDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  Map<String, dynamic> toApiJson() {
    final body = <String, dynamic>{
      'test_order': testId,
      'test_id': testId,
      'patient_id': patientId,
      'patient_name': patientName,
      'test_type': testType,
      'test_name': testName,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': status,
      'notes': notes,
      'transaction_id': transactionId,
      'receipt_number': receiptNumber,
    };
    body.removeWhere((_, v) => v == null || (v is String && v.isEmpty));
    return body;
  }

  Payment copyWith({
    String? paymentId,
    String? testId,
    String? patientId,
    String? patientName,
    String? testType,
    String? testName,
    double? amount,
    String? paymentMethod,
    String? status,
    String? notes,
    String? transactionId,
    String? receiptNumber,
    DateTime? paymentDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Payment(
      paymentId: paymentId ?? this.paymentId,
      testId: testId ?? this.testId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      testType: testType ?? this.testType,
      testName: testName ?? this.testName,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      transactionId: transactionId ?? this.transactionId,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
  bool get isRefunded => status == 'refunded';
  bool get isCancelled => status == 'cancelled';

  String get formattedDate {
    return '${paymentDate.day}/${paymentDate.month}/${paymentDate.year}';
  }

  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2)}';
  }

  String get statusColor {
    switch (status) {
      case 'completed':
        return '#27ae60'; // Green
      case 'pending':
        return '#f39c12'; // Orange
      case 'failed':
        return '#e74c3c'; // Red
      case 'refunded':
        return '#95a5a6'; // Gray
      case 'cancelled':
        return '#7f8c8d'; // Dark Gray
      default:
        return '#7f8c8d'; // Default Gray
    }
  }

  String get paymentMethodIcon {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return '💵';
      case 'card':
        return '💳';
      case 'credit_card':
        return '💳';
      case 'debit_card':
        return '💳';
      case 'insurance':
        return '🏥';
      case 'bank_transfer':
        return '🏦';
      case 'online':
        return '🌐';
      default:
        return '💰';
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  @override
  String toString() {
    return 'Payment(paymentId: $paymentId, testId: $testId, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Payment && other.paymentId == paymentId;
  }

  @override
  int get hashCode => paymentId.hashCode;
}
