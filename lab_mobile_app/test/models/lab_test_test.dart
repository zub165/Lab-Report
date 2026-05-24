import 'package:flutter_test/flutter_test.dart';
import 'package:lab_mobile_app/models/lab_test.dart';

void main() {
  group('LabTest', () {
    test('constructor assigns all fields', () {
      final test = LabTest(
        id: 'CBC001',
        name: 'Complete Blood Count',
        category: 'Hematology',
        description: 'Measures blood cells',
        normalRange: '4.5-11.0 K/μL',
        unit: 'K/μL',
        price: 1500.0,
        preparation: 'No special preparation',
        collectionMethod: 'Venipuncture',
        processingTime: '24 hours',
        parameters: [
          LabTestParameter(
            name: 'WBC',
            normalRange: '4.5-11.0',
            unit: 'K/μL',
            criticalLow: '2.0',
            criticalHigh: '30.0',
          ),
        ],
      );
      expect(test.id, 'CBC001');
      expect(test.name, 'Complete Blood Count');
      expect(test.category, 'Hematology');
      expect(test.price, 1500.0);
      expect(test.parameters.length, 1);
      expect(test.parameters.first.name, 'WBC');
    });

    test('const constructor works', () {
      const param = LabTestParameter(
        name: 'Test',
        normalRange: '0-100',
        unit: 'mg/dL',
        criticalLow: '',
        criticalHigh: '',
      );
      const test = LabTest(
        id: 'ID',
        name: 'Test',
        category: 'General',
        description: '',
        normalRange: '',
        unit: '',
        price: 0,
        preparation: '',
        collectionMethod: '',
        processingTime: '',
        parameters: [param],
      );
      expect(test.id, 'ID');
      expect(test.parameters.first.name, 'Test');
    });
  });
}
