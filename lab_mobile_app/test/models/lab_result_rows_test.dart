import 'package:flutter_test/flutter_test.dart';
import 'package:lab_mobile_app/models/test_result.dart';

void main() {
  group('LabResultRowsBuilder', () {
    test('enrichFromCatalog fills See reference from catalog', () {
      final rows = [
        LabResultRow(
          parameter: 'Blood Culture',
          testCode: 'BCULT',
          referenceRange: 'See reference',
        ),
      ];
      final catalog = [
        {
          'test_code': 'BCULT',
          'test_name': 'Blood Culture',
          'normal_range': 'No growth',
          'unit': '—',
        },
      ];
      final enriched = LabResultRowsBuilder.enrichFromCatalog(rows, catalog);
      expect(enriched.first.hasNormalRange, isTrue);
      expect(enriched.first.referenceRange, 'No growth');
    });

    test('buildFromOrder fills normal range from catalog when test is UUID', () {
      final order = {
        'test_items': [
          {
            'id': 34,
            'test_name': 'Blood Culture',
            'test_code': 'CULTURE',
            'test': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
          },
        ],
      };
      final catalogByCode = LabResultRowsBuilder.catalogByCode([
        {'test_code': 'CULTURE', 'normal_range': 'No growth', 'unit': '—'},
      ]);
      final rows = LabResultRowsBuilder.buildFromOrder(
        order,
        {},
        catalogByCode: catalogByCode,
      );
      expect(rows.length, 1);
      expect(rows.first.hasNormalRange, isTrue);
      expect(rows.first.referenceRange, 'No growth');
    });

    test('buildFromOrder parses simple test item', () {
      final order = {
        'test_items': [
          {
            'id': 34,
            'test_name': 'Blood Culture',
            'test_code': 'BCULT',
            'test': {'normal_range': 'Negative', 'unit': 'N/A'},
          },
        ],
      };
      final rows = LabResultRowsBuilder.buildFromOrder(order, {});
      expect(rows.length, 1);
      expect(rows.first.parameter, 'Blood Culture');
      expect(rows.first.referenceRange, contains('Negative'));
    });
  });
}
