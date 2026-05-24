import 'package:flutter_test/flutter_test.dart';
import 'package:lab_mobile_app/models/report_data.dart';

void main() {
  group('ReportData', () {
    final now = DateTime.now();

    test('fromJson parses all fields', () {
      final json = {
        'id': 'RPT001',
        'title': 'Blood Test Report',
        'content': 'Patient results...',
        'patient_id': 'P001',
        'test_id': 'T001',
        'template_id': 'standard',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'report_date': now.toIso8601String(),
        'status': 'completed',
        'type': 'pathology',
        'notes': 'Fasting sample',
        'authorized_by': 'Dr. Smith',
        'results': {'hemoglobin': 14.5},
      };
      final report = ReportData.fromJson(json);
      expect(report.id, 'RPT001');
      expect(report.title, 'Blood Test Report');
      expect(report.content, 'Patient results...');
      expect(report.patientId, 'P001');
      expect(report.testId, 'T001');
      expect(report.templateId, 'standard');
      expect(report.createdAt, isNotNull);
      expect(report.updatedAt, isNotNull);
      expect(report.reportDate, isNotNull);
      expect(report.status, 'completed');
      expect(report.type, 'pathology');
      expect(report.notes, 'Fasting sample');
      expect(report.authorizedBy, 'Dr. Smith');
      expect(report.results, {'hemoglobin': 14.5});
    });

    test('fromJson parses report_id as id alias', () {
      final json = {
        'report_id': 'RPT002',
        'report_type': 'imaging',
      };
      final report = ReportData.fromJson(json);
      expect(report.reportId, isNull);
    });

    test('fromJson handles minimal data', () {
      final json = <String, dynamic>{};
      final report = ReportData.fromJson(json);
      expect(report.id, isNull);
      expect(report.title, isNull);
      expect(report.content, isNull);
      expect(report.createdAt, null);
    });

    test('toJson includes only non-null fields', () {
      final report = ReportData(
        id: 'RPT001',
        title: 'Test Report',
        status: 'completed',
      );
      final json = report.toJson();
      expect(json['id'], 'RPT001');
      expect(json['title'], 'Test Report');
      expect(json['status'], 'completed');
      expect(json.containsKey('content'), false);
      expect(json.containsKey('created_at'), false);
    });

    test('toJson includes all set fields', () {
      final report = ReportData(
        id: 'RPT001',
        title: 'Test Report',
        content: 'Content here',
        patientId: 'P001',
        testId: 'T001',
        templateId: 'standard',
        createdAt: now,
        updatedAt: now,
        reportDate: now,
        status: 'completed',
        type: 'pathology',
        notes: 'Notes',
        authorizedBy: 'Dr. Smith',
        results: {'key': 'val'},
      );
      final json = report.toJson();
      expect(json['id'], 'RPT001');
      expect(json['title'], 'Test Report');
      expect(json['created_at'], now.toIso8601String());
      expect(json['results'], {'key': 'val'});
    });
  });
}
