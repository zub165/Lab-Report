import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

/// Apple App Store + Google Play only — no Django / Stripe platform billing.
class StoreSubscriptionService {
  StoreSubscriptionService._();
  static final StoreSubscriptionService instance = StoreSubscriptionService._();

  static const String _localStatusKey = 'store_subscription_status';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  void Function(String message, {bool isError})? onPurchaseMessage;

  Future<void> initialize() async {
    if (kIsWeb || !isMobileStorePlatform) return;
    _purchaseSub ??= _iap.purchaseStream.listen(
      _handlePurchases,
      onError: (Object e) {
        onPurchaseMessage?.call('$e', isError: true);
      },
    );
  }

  Future<bool> get isStoreAvailable async {
    if (kIsWeb) return false;
    return _iap.isAvailable();
  }

  Future<ProductDetails?> loadStoreProduct() async {
    if (kIsWeb || !isMobileStorePlatform) return null;
    final response = await _iap.queryProductDetails(
      {LabSubscriptionConfig.storeProductId},
    );
    if (response.error != null) {
      throw Exception(response.error!.message);
    }
    if (response.productDetails.isEmpty) {
      return null;
    }
    return response.productDetails.first;
  }

  String storePriceLabel(ProductDetails? product) {
    if (product != null && product.price.isNotEmpty) {
      return '${product.price}/month';
    }
    return LabSubscriptionConfig.priceDisplay;
  }

  Future<Map<String, dynamic>> loadLocalStatus() async {
    await LabGroupScope.loadCachedScope();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(LabGroupScope.scopedPrefsKey(_localStatusKey));
    if (raw == null || raw.isEmpty) {
      return {'status': 'none', 'source': 'store'};
    }
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {'status': 'none', 'source': 'store'};
    }
  }

  Future<bool> isSubscribed() async {
    final s = await loadLocalStatus();
    return LabSubscriptionConfig.isUnlockedStatus(s['status']?.toString());
  }

  Future<bool> subscribeViaStore() async {
    if (kIsWeb || !isMobileStorePlatform) {
      throw Exception('In-app purchase is only available on iPhone and Android');
    }
    final available = await isStoreAvailable;
    if (!available) {
      throw Exception('App Store / Google Play billing is not available on this device');
    }
    final product = await loadStoreProduct();
    if (product == null) {
      throw Exception(
        'Subscription "${LabSubscriptionConfig.storeProductId}" not found. '
        'Create it in App Store Connect and Google Play Console, activate it, '
        'then install a store build (not sideload APK).',
      );
    }
    final param = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() async {
    if (kIsWeb || !isMobileStorePlatform) return;
    await _iap.restorePurchases();
  }

  Future<void> _persistActive(PurchaseDetails purchase) async {
    await LabGroupScope.loadCachedScope();
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'status': 'active',
      'source': defaultTargetPlatform == TargetPlatform.iOS ? 'apple' : 'google',
      'product_id': purchase.productID,
      'purchase_id': purchase.purchaseID,
      'lab_group_id': LabGroupScope.groupId,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await prefs.setString(
      LabGroupScope.scopedPrefsKey(_localStatusKey),
      jsonEncode(payload),
    );
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          onPurchaseMessage?.call('Purchase pending…');
          break;
        case PurchaseStatus.error:
          onPurchaseMessage?.call(
            purchase.error?.message ?? 'Purchase failed',
            isError: true,
          );
          break;
        case PurchaseStatus.canceled:
          onPurchaseMessage?.call('Purchase canceled', isError: true);
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (purchase.productID != LabSubscriptionConfig.storeProductId) {
            break;
          }
          await _persistActive(purchase);
          onPurchaseMessage?.call(
            'Subscription active — billed by ${defaultTargetPlatform == TargetPlatform.iOS ? "App Store" : "Google Play"}',
          );
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
      }
    }
  }

  void dispose() {
    _purchaseSub?.cancel();
    _purchaseSub = null;
  }
}
