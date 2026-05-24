import 'package:flutter_test/flutter_test.dart';
import 'package:lab_mobile_app/models/report_template.dart';

void main() {
  group('ReportField', () {
    test('fromJson parses correctly', () {
      final json = {
        'name': 'hemoglobin',
        'label': 'Hemoglobin',
        'type': 'number',
        'unit': 'g/dL',
        'normal_range': '13.5-17.5',
        'is_required': true,
        'order': 1,
      };
      final field = ReportField.fromJson(json);
      expect(field.name, 'hemoglobin');
      expect(field.label, 'Hemoglobin');
      expect(field.type, 'number');
      expect(field.unit, 'g/dL');
      expect(field.normalRange, '13.5-17.5');
      expect(field.isRequired, true);
      expect(field.order, 1);
    });

    test('fromJson uses defaults for missing fields', () {
      final json = <String, dynamic>{};
      final field = ReportField.fromJson(json);
      expect(field.name, '');
      expect(field.label, '');
      expect(field.type, 'text');
      expect(field.isRequired, true);
      expect(field.order, 0);
    });

    test('fromJson parses optional fields as null', () {
      final json = {
        'name': 'test',
        'label': 'Test',
        'type': 'text',
        'order': 1,
      };
      final field = ReportField.fromJson(json);
      expect(field.name, 'test');
      expect(field.unit, isNull);
      expect(field.normalRange, isNull);
    });

    test('toJson round-trips', () {
      final field = ReportField(
        name: 'glucose',
        label: 'Glucose',
        type: 'number',
        unit: 'mg/dL',
        normalRange: '70-99',
        isRequired: true,
        order: 1,
      );
      final json = field.toJson();
      final restored = ReportField.fromJson(json);
      expect(restored.name, field.name);
      expect(restored.label, field.label);
      expect(restored.type, field.type);
      expect(restored.unit, field.unit);
      expect(restored.normalRange, field.normalRange);
      expect(restored.isRequired, field.isRequired);
      expect(restored.order, field.order);
    });

    test('equality is based on name', () {
      final a = ReportField(name: 'test', label: 'A', type: 'text', order: 1);
      final b = ReportField(name: 'test', label: 'B', type: 'number', order: 2);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('ReportTemplate', () {
    final sampleJson = {
      'id': 'standard_report',
      'name': 'Standard Report',
      'test_type': 'Blood Test',
      'description': 'Standard format',
      'fields': [
        {'name': 'hemoglobin', 'label': 'Hemoglobin', 'type': 'number', 'order': 1},
        {'name': 'wbc', 'label': 'WBC', 'type': 'number', 'order': 2},
      ],
      'header_template': 'HEADER',
      'footer_template': 'FOOTER',
      'styling': {'fontSize': 18.0},
    };

    test('fromJson parses correctly', () {
      final template = ReportTemplate.fromJson(sampleJson);
      expect(template.id, 'standard_report');
      expect(template.name, 'Standard Report');
      expect(template.testType, 'Blood Test');
      expect(template.description, 'Standard format');
      expect(template.fields.length, 2);
      expect(template.headerTemplate, 'HEADER');
      expect(template.footerTemplate, 'FOOTER');
      expect(template.styling['fontSize'], 18.0);
    });

    test('fromJson handles empty/missing fields', () {
      final json = <String, dynamic>{};
      final template = ReportTemplate.fromJson(json);
      expect(template.id, '');
      expect(template.name, '');
      expect(template.fields, isEmpty);
      expect(template.styling, isEmpty);
    });

    test('toJson round-trips', () {
      final template = ReportTemplate.fromJson(sampleJson);
      final json = template.toJson();
      final restored = ReportTemplate.fromJson(json);
      expect(restored.id, template.id);
      expect(restored.name, template.name);
      expect(restored.fields.length, template.fields.length);
      expect(restored.styling['fontSize'], template.styling['fontSize']);
    });

    test('copyWith preserves original', () {
      final template = ReportTemplate(
        id: 't1',
        name: 'Old',
        testType: 'Blood',
        description: 'Desc',
        fields: [],
        headerTemplate: 'H',
        footerTemplate: 'F',
      );
      final copy = template.copyWith(name: 'New', testType: 'Urine');
      expect(copy.name, 'New');
      expect(copy.testType, 'Urine');
      expect(template.name, 'Old');
    });

    test('equality is based on id', () {
      final a = ReportTemplate(id: 't1', name: 'A', testType: 'T', description: 'D', fields: [], headerTemplate: 'H', footerTemplate: 'F');
      final b = ReportTemplate(id: 't1', name: 'B', testType: 'T', description: 'D', fields: [], headerTemplate: 'H', footerTemplate: 'F');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('DefaultReportTemplates', () {
    test('contains at least 6 templates', () {
      expect(DefaultReportTemplates.templates.length, greaterThanOrEqualTo(6));
    });

    test('all templates have non-empty id and name', () {
      for (final t in DefaultReportTemplates.templates) {
        expect(t.id, isNotEmpty);
        expect(t.name, isNotEmpty);
      }
    });

    test('standard_report template exists', () {
      final standard = DefaultReportTemplates.templates.firstWhere(
        (t) => t.id == 'standard_report',
      );
      expect(standard.fields.length, greaterThan(0));
    });

    test('quest_diagnostics template exists', () {
      final quest = DefaultReportTemplates.templates.firstWhere(
        (t) => t.id == 'quest_diagnostics',
      );
      expect(quest.fields.length, greaterThan(0));
    });
  });
}
