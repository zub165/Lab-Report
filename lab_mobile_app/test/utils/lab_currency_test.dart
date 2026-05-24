import 'package:flutter_test/flutter_test.dart';
import 'package:lab_mobile_app/utils/lab_currency.dart';

void main() {
  group('LabCurrency', () {
    setUp(() {
      LabCurrency.setCode('PKR');
    });

    test('default code is PKR', () {
      expect(LabCurrency.code, 'PKR');
    });

    test('setCode validates supported currencies', () {
      LabCurrency.setCode('USD');
      expect(LabCurrency.code, 'USD');

      LabCurrency.setCode('INVALID');
      expect(LabCurrency.code, 'USD');
    });

    test('symbol returns correct prefix', () {
      LabCurrency.setCode('PKR');
      expect(LabCurrency.symbol, 'Rs ');

      LabCurrency.setCode('USD');
      expect(LabCurrency.symbol, '\$ ');

      LabCurrency.setCode('EUR');
      expect(LabCurrency.symbol, '€ ');

      LabCurrency.setCode('GBP');
      expect(LabCurrency.symbol, '£ ');
    });

    test('defaultDecimals is 0 for PKR', () {
      LabCurrency.setCode('PKR');
      expect(LabCurrency.defaultDecimals, 0);
    });

    test('defaultDecimals is 2 for USD', () {
      LabCurrency.setCode('USD');
      expect(LabCurrency.defaultDecimals, 2);
    });

    test('format returns numeric string without symbol', () {
      LabCurrency.setCode('PKR');
      final formatted = LabCurrency.format(1500);
      expect(formatted.contains('Rs'), false);
      expect(formatted, isNotEmpty);
    });

    test('formatWithSymbol includes symbol', () {
      LabCurrency.setCode('PKR');
      final formatted = LabCurrency.formatWithSymbol(1500);
      expect(formatted.contains('Rs'), true);
    });

    test('formatFull uses simpleCurrency', () {
      LabCurrency.setCode('PKR');
      final formatted = LabCurrency.formatFull(1500);
      expect(formatted, isNotEmpty);
    });

    test('formatWithSymbol handles zero', () {
      LabCurrency.setCode('PKR');
      expect(LabCurrency.formatWithSymbol(0), isNotEmpty);
    });
  });
}
