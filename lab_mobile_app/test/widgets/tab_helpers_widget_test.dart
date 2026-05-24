import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_mobile_app/models/patient.dart';
import 'package:lab_mobile_app/models/test.dart';
import 'package:lab_mobile_app/utils/tab_helpers.dart';

Widget wrapApp(Widget w) => MaterialApp(home: Scaffold(body: w));

void main() {
  group('apiTabPlaceholder', () {
    testWidgets('renders title and message', (tester) async {
      await tester.pumpWidget(wrapApp(apiTabPlaceholder(
        icon: Icons.error,
        title: 'Something went wrong',
        message: 'Please try again later',
      )));
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Please try again later'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrapApp(apiTabPlaceholder(
        icon: Icons.refresh,
        title: 'No data',
        message: 'Could not load',
        onRetry: () => tapped = true,
      )));
      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(tapped, true);
    });

    testWidgets('no retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(wrapApp(apiTabPlaceholder(
        icon: Icons.info,
        title: 'Info',
        message: 'Just a message',
      )));
      expect(find.text('Retry'), findsNothing);
    });
  });

  group('miniBarChartCard', () {
    testWidgets('renders chart with valid data', (tester) async {
      await tester.pumpWidget(wrapApp(miniBarChartCard(
        title: 'Test Chart',
        subtitle: '5 total',
        labels: const ['A', 'B', 'C'],
        values: const [10, 20, 30],
        colors: const [Colors.red, Colors.green, Colors.blue],
      )));
      expect(find.text('Test Chart'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('returns SizedBox.shrink for mismatched lengths', (tester) async {
      await tester.pumpWidget(wrapApp(miniBarChartCard(
        title: 'Bad',
        subtitle: 'bad',
        labels: const ['A', 'B'],
        values: const [10],
        colors: const [Colors.red],
      )));
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('returns SizedBox.shrink for empty labels', (tester) async {
      await tester.pumpWidget(wrapApp(miniBarChartCard(
        title: 'Empty',
        subtitle: 'empty',
        labels: const [],
        values: const [],
        colors: const [],
      )));
      expect(find.byType(Card), findsNothing);
    });
  });

  group('patientsGenderMiniChart', () {
    testWidgets('renders chart with mixed patients', (tester) async {
      final patients = [
        Patient(patientId: '1', fullName: 'John', dateOfBirth: DateTime(1990, 1, 1), gender: 'Male', phone: '1'),
        Patient(patientId: '2', fullName: 'Jane', dateOfBirth: DateTime(1992, 2, 2), gender: 'Female', phone: '2'),
        Patient(patientId: '3', fullName: 'Alex', dateOfBirth: DateTime(1988, 3, 3), gender: 'Male', phone: '3'),
        Patient(patientId: '4', fullName: 'Sam', dateOfBirth: DateTime(1995, 4, 4), gender: 'Other', phone: '4'),
      ];
      await tester.pumpWidget(wrapApp(patientsGenderMiniChart(patients)));
      expect(find.text('Patients by gender'), findsOneWidget);
      expect(find.textContaining('4 total'), findsOneWidget);
    });

    testWidgets('returns SizedBox.shrink for empty list', (tester) async {
      await tester.pumpWidget(wrapApp(patientsGenderMiniChart([])));
      expect(find.byType(Card), findsNothing);
    });
  });

  group('testsStatusMiniChart', () {
    final now = DateTime.now();

    testWidgets('renders chart with tests by status', (tester) async {
      final tests = <Test>[
        Test(testId: '1', patientId: 'P1', testType: 'Blood', testName: 'CBC', price: 100, orderedBy: 'Dr', orderedDate: now, status: 'completed', patientName: 'John'),
        Test(testId: '2', patientId: 'P2', testType: 'Blood', testName: 'CBC', price: 100, orderedBy: 'Dr', orderedDate: now, status: 'pending', patientName: 'Jane'),
        Test(testId: '3', patientId: 'P3', testType: 'Urine', testName: 'UA', price: 100, orderedBy: 'Dr', orderedDate: now, status: 'pending', patientName: 'Bob'),
      ];
      await tester.pumpWidget(wrapApp(testsStatusMiniChart(tests)));
      expect(find.textContaining('3 tests'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('returns SizedBox.shrink for empty list', (tester) async {
      await tester.pumpWidget(wrapApp(testsStatusMiniChart([])));
      expect(find.byType(Card), findsNothing);
    });
  });

  group('patientFromTestOrder', () {
    final _now = DateTime.now();
    Test _makeTest({String? patientName, Patient? patient}) => Test(
      testId: 'T1', patientId: 'P1', testType: 'Blood', testName: 'CBC',
      price: 100, orderedBy: 'Dr', orderedDate: _now, status: 'pending',
      patientName: patientName, patient: patient,
    );

    test('returns patient from test.patient if available', () {
      final patient = Patient(patientId: 'P1', fullName: 'John', dateOfBirth: DateTime(1990, 1, 1), gender: 'M', phone: '123');
      final test = _makeTest(patient: patient);
      final result = patientFromTestOrder(test);
      expect(result.fullName, 'John');
      expect(result.patientId, 'P1');
    });

    test('constructs Patient from test fields when patient is null', () {
      final test = _makeTest(patientName: 'Jane');
      final result = patientFromTestOrder(test);
      expect(result.fullName, 'Jane');
      expect(result.patientId, 'P1');
    });

    test('uses fallback for missing patientName', () {
      final test = _makeTest();
      final result = patientFromTestOrder(test);
      expect(result.fullName, 'Patient');
    });
  });
}
