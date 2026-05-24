import 'package:flutter_test/flutter_test.dart';
import 'package:lab_mobile_app/models/payment.dart';

void main() {
  group('Payment', () {
    final now = DateTime.now();

    test('fromJson parses flat payment', () {
      final json = {
        'payment_id': 'PAY001',
        'test_order': 'ORD001',
        'test_name': 'Blood Test',
        'test_type': 'pathology',
        'patient_id': 'P001',
        'patient_name': 'John Doe',
        'amount': 1500.0,
        'payment_method': 'cash',
        'status': 'completed',
        'payment_date': now.toIso8601String(),
        'created_at': now.toIso8601String(),
      };
      final payment = Payment.fromJson(json);
      expect(payment.paymentId, 'PAY001');
      expect(payment.testId, 'ORD001');
      expect(payment.testName, 'Blood Test');
      expect(payment.patientId, 'P001');
      expect(payment.patientName, 'John Doe');
      expect(payment.amount, 1500.0);
      expect(payment.paymentMethod, 'cash');
      expect(payment.status, 'completed');
    });

    test('fromJson parses nested test_order object', () {
      final json = {
        'payment_id': 'PAY002',
        'amount': 2000.0,
        'payment_method': 'card',
        'status': 'pending',
        'payment_date': now.toIso8601String(),
        'created_at': now.toIso8601String(),
        'test_order': {
          'order_id': 'ORD002',
          'test_name': 'X-Ray',
          'test_type': 'imaging',
          'patient': {
            'patient_id': 'P002',
            'full_name': 'Jane Smith',
          },
        },
      };
      final payment = Payment.fromJson(json);
      expect(payment.paymentId, 'PAY002');
      expect(payment.testId, 'ORD002');
      expect(payment.testName, 'X-Ray');
      expect(payment.patientId, 'P002');
      expect(payment.patientName, 'Jane Smith');
      expect(payment.amount, 2000.0);
    });

    test('isCompleted returns correct boolean', () {
      final completed = Payment(
        paymentId: 'P001',
        testId: 'T001',
        patientId: 'P001',
        patientName: 'John',
        testType: 'Blood',
        testName: 'CBC',
        amount: 100.0,
        paymentMethod: 'cash',
        status: 'completed',
        paymentDate: now,
        createdAt: now,
      );
      expect(completed.isCompleted, true);
      expect(completed.isPending, false);

      final pending = completed.copyWith(status: 'pending');
      expect(pending.isPending, true);
      expect(pending.isCompleted, false);
    });

    test('formattedAmount formats correctly', () {
      final payment = Payment(
        paymentId: 'P001',
        testId: 'T001',
        patientId: 'P001',
        patientName: 'John',
        testType: 'Blood',
        testName: 'CBC',
        amount: 1500.0,
        paymentMethod: 'cash',
        status: 'completed',
        paymentDate: now,
        createdAt: now,
      );
      expect(payment.formattedAmount, r'$1500.00');
    });

    test('toApiJson strips null/empty values', () {
      final payment = Payment(
        paymentId: 'P001',
        testId: 'T001',
        patientId: 'P001',
        patientName: 'John',
        testType: 'Blood',
        testName: 'CBC',
        amount: 500.0,
        paymentMethod: 'cash',
        status: 'completed',
        paymentDate: now,
        createdAt: now,
      );
      final apiJson = payment.toApiJson();
      expect(apiJson.containsKey('payment_id'), false);
      expect(apiJson['amount'], 500.0);
      expect(apiJson['status'], 'completed');
    });

    test('fromJson handles empty/missing fields gracefully', () {
      final json = <String, dynamic>{};
      final payment = Payment.fromJson(json);
      expect(payment.patientName, 'Unknown');
      expect(payment.testName, 'Lab test');
      expect(payment.amount, 0.0);
      expect(payment.paymentMethod, 'cash');
      expect(payment.status, 'completed');
    });

    test('copyWith preserves original', () {
      final payment = Payment(
        paymentId: 'P001',
        testId: 'T001',
        patientId: 'P001',
        patientName: 'John',
        testType: 'Blood',
        testName: 'CBC',
        amount: 100.0,
        paymentMethod: 'cash',
        status: 'pending',
        paymentDate: now,
        createdAt: now,
      );
      final copy = payment.copyWith(status: 'completed', amount: 200.0);
      expect(copy.status, 'completed');
      expect(copy.amount, 200.0);
      expect(payment.status, 'pending');
      expect(payment.amount, 100.0);
    });
  });
}
