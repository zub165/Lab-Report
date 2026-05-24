import 'package:flutter_test/flutter_test.dart';
import 'package:lab_mobile_app/utils/constants.dart';

void main() {
  group('LabSubscriptionConfig', () {
    test('default product id matches store listing', () {
      expect(
        LabSubscriptionConfig.storeProductId,
        'com.mywaitime.lab.monthly',
      );
    });

    test('isUnlockedStatus accepts active and trialing', () {
      expect(LabSubscriptionConfig.isUnlockedStatus('active'), isTrue);
      expect(LabSubscriptionConfig.isUnlockedStatus('trialing'), isTrue);
      expect(LabSubscriptionConfig.isUnlockedStatus('none'), isFalse);
      expect(
        LabSubscriptionConfig.isUnlockedStatus('canceled'),
        isFalse,
      );
    });

    test('price display is 7.99 per month', () {
      expect(LabSubscriptionConfig.monthlyPriceUsd, 7.99);
      expect(LabSubscriptionConfig.priceDisplay, r'$7.99/month');
    });

    test('manage URLs are store subscription pages', () {
      expect(
        LabSubscriptionConfig.appleManageSubscriptionsUrl,
        contains('apple.com'),
      );
      expect(
        LabSubscriptionConfig.googleManageSubscriptionsUrl,
        contains('play.google.com'),
      );
    });
  });
}
