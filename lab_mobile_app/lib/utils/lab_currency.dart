import 'package:intl/intl.dart';
import '../services/django_api_service.dart';

/// Display currency — same as SaeedLab web (`display_currency` in `/settings/ui/`).
class LabCurrency {
  LabCurrency._();

  static String _code = 'PKR';

  static const List<Map<String, String>> supported = [
    {'code': 'PKR', 'label': 'PKR — Pakistani Rupee'},
    {'code': 'USD', 'label': 'USD — US Dollar'},
    {'code': 'EUR', 'label': 'EUR — Euro'},
    {'code': 'GBP', 'label': 'GBP — British Pound'},
    {'code': 'AED', 'label': 'AED — UAE Dirham'},
    {'code': 'SAR', 'label': 'SAR — Saudi Riyal'},
    {'code': 'INR', 'label': 'INR — Indian Rupee'},
    {'code': 'CAD', 'label': 'CAD — Canadian Dollar'},
  ];

  static String get code => _code;

  static String get stripeCode => _code.toLowerCase();

  static Future<void> loadFromApi() async {
    try {
      final api = DjangoApiService();
      final s = await api.getLabUiSettings();
      final raw = s['display_currency'] ?? s['currency'];
      if (raw != null && raw.toString().trim().isNotEmpty) {
        _code = raw.toString().trim().toUpperCase();
      }
      await api.syncLabStripeConfig();
    } catch (_) {
      _code = 'PKR';
    }
  }

  static void setCode(String code) {
    final c = code.trim().toUpperCase();
    if (supported.any((e) => e['code'] == c)) {
      _code = c;
    }
  }

  static String _locale() {
    switch (_code) {
      case 'PKR':
        return 'en_PK';
      case 'AED':
        return 'en_AE';
      case 'SAR':
        return 'en_SA';
      case 'INR':
        return 'en_IN';
      case 'EUR':
        return 'de_DE';
      case 'GBP':
        return 'en_GB';
      case 'CAD':
        return 'en_CA';
      default:
        return 'en_US';
    }
  }

  /// Symbol for input prefixes (Rs, $, etc.).
  static String get symbol {
    switch (_code) {
      case 'PKR':
        return 'Rs ';
      case 'USD':
        return '\$ ';
      case 'EUR':
        return '€ ';
      case 'GBP':
        return '£ ';
      case 'AED':
        return 'AED ';
      case 'SAR':
        return 'SAR ';
      case 'INR':
        return '₹ ';
      case 'CAD':
        return 'CA\$ ';
      default:
        return '$_code ';
    }
  }

  static int get defaultDecimals => _code == 'PKR' ? 0 : 2;

  static String format(num amount, {int? decimals}) {
    final d = decimals ?? defaultDecimals;
    final n = amount.toDouble();
    try {
      return NumberFormat.currency(
        locale: _locale(),
        symbol: '',
        decimalDigits: d,
      ).format(n).trim();
    } catch (_) {
      return n.toStringAsFixed(d);
    }
  }

  static String formatWithSymbol(num amount, {int? decimals}) {
    return '${symbol.trim()} ${format(amount, decimals: decimals)}';
  }

  static String formatFull(num amount, {int? decimals}) {
    final d = decimals ?? defaultDecimals;
    final n = amount.toDouble();
    try {
      return NumberFormat.simpleCurrency(
        locale: _locale(),
        name: _code,
        decimalDigits: d,
      ).format(n);
    } catch (_) {
      return formatWithSymbol(n, decimals: d);
    }
  }
}
