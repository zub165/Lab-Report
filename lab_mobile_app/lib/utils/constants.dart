import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_env.dart';
import 'env_config.dart';

/// iOS/Android only — not web or desktop (Windows, macOS, Linux).
bool get isMobileStorePlatform {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;
}

/// Windows, macOS, or Linux Flutter embedder.
bool get isDesktopPlatform {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;
}

/// Avoids "setState/markNeedsBuild during build" when a screen loads data in [State.initState].
void scheduleProviderNotify(ChangeNotifier notifier) {
  final phase = SchedulerBinding.instance.schedulerPhase;
  if (phase == SchedulerPhase.idle ||
      phase == SchedulerPhase.postFrameCallbacks) {
    notifier.notifyListeners();
  } else {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (notifier.hasListeners) notifier.notifyListeners();
    });
  }
}

/// API base URL — must match [SaeedLab web](https://zub165.github.io/SaeedLab/) (`common.js` → `resolveApiBaseUrl`).
class LabApiConfig {
  LabApiConfig._();

  static const String saeedLabWebUrl = 'https://zub165.github.io/SaeedLab/';

  /// Production Django lab API (same database as GitHub Pages SaeedLab).
  static const String productionApiBase = 'https://api.mywaitime.com/lab';

  /// Same key as web `localStorage.saeedlab_api_base` (custom Lab URL override).
  static const String prefsApiOverrideKey = ApiEnvConfig.prefsApiOverrideKey;

  static String _resolved = productionApiBase;

  static String get resolvedBaseUrl => _resolved;

  static bool get isUsingBackupServer => ApiEnvConfig.usingBackup;

  static String get activeApiProfileLabel => ApiEnvConfig.activeProfileLabel;

  static Future<void> initialize() async {
    try {
      await ApiEnvConfig.loadFromPrefs();
      _resolved = ApiEnvConfig.resolvedLabApiBase;
      await StripeConfig.initialize();
    } catch (_) {
      _resolved = productionApiBase;
    }
  }

  static Future<void> applyResolvedBase() async {
    _resolved = ApiEnvConfig.resolvedLabApiBase;
  }
}

/// Stripe: per-lab keys via `/settings/ui/` (same as [display_currency]).
/// Publishable (`pk_`) on app; secret (`sk_`) only on Django server.
class StripeConfig {
  StripeConfig._();

  static const String prefsPublishableKey = 'stripe_publishable_key';
  static const String settingsPublishableField = 'stripe_publishable_key';
  static const String settingsSecretField = 'stripe_secret_key';
  static const String stripePaymentIntentPath = '/payments/stripe/create-intent/';
  static const String stripeConfirmPath = '/payments/stripe/confirm/';

  static String _publishableKey = '';
  static bool _fromDevicePrefs = false;
  static bool _fromLabApi = false;
  static String _labScope = 'default';

  static String get publishableKey => _publishableKey;
  static String get labScope => _labScope;

  static bool get isConfigured => _isValidPublishableKey(_publishableKey);

  static bool get hasEnvDefault => _isValidPublishableKey(EnvConfig.stripePublishableKey);

  static bool get isFromLabApi => isConfigured && _fromLabApi;

  static bool get isFromEnvOnly =>
      isConfigured && !_fromDevicePrefs && !_fromLabApi;

  static String get activeKeySource {
    if (!isConfigured) return 'Not set';
    if (_fromLabApi) return 'This lab (server settings)';
    if (_fromDevicePrefs) return 'This device only (API Connection override)';
    if (hasEnvDefault) return 'From .env / build (dev fallback)';
    return 'Set';
  }

  static String maskedKey(String key) {
    final k = key.trim();
    if (k.isEmpty) return '—';
    if (k.length <= 12) return k;
    return '${k.substring(0, 8)}…${k.substring(k.length - 4)}';
  }

  static String get envKeyPreview =>
      hasEnvDefault ? maskedKey(EnvConfig.stripePublishableKey) : 'Not set in .env';

  static bool _isValidPublishableKey(String key) {
    final k = key.trim();
    return k.startsWith('pk_test_') || k.startsWith('pk_live_');
  }

  static bool _isValidSecretKey(String key) {
    final k = key.trim();
    return k.startsWith('sk_test_') || k.startsWith('sk_live_');
  }

  /// Stable scope so each lab’s cached key does not leak to another lab on the same phone.
  static String labScopeFromSettings(Map<String, dynamic> s) {
    final id = s['lab_id'] ?? s['id'];
    if (id != null) return 'lab_$id';
    final name = s['lab_name']?.toString().trim();
    if (name != null && name.isNotEmpty) {
      return 'lab_${name.hashCode.abs()}';
    }
    return 'default';
  }

  static String? publishableFromSettings(Map<String, dynamic> s) {
    for (final field in [
      settingsPublishableField,
      'stripe_publishable',
      'publishable_key',
    ]) {
      final v = s[field]?.toString().trim() ?? '';
      if (_isValidPublishableKey(v)) return v;
    }
    return null;
  }

  static bool secretConfiguredInSettings(Map<String, dynamic> s) {
    if (s['stripe_secret_configured'] == true) return true;
    final hint = s['stripe_secret_key']?.toString().trim() ?? '';
    if (hint.isEmpty) return false;
    if (hint == '***' || hint.toLowerCase() == 'configured') return true;
    return _isValidSecretKey(hint);
  }

  static String _scopedPrefsKey(String scope) => '${prefsPublishableKey}_$scope';

  static Future<void> applyLabSettings(Map<String, dynamic> settings) async {
    _labScope = labScopeFromSettings(settings);
    final apiPk = publishableFromSettings(settings);
    if (apiPk != null) {
      _publishableKey = apiPk;
      _fromLabApi = true;
      _fromDevicePrefs = false;
      await _persistScoped(_labScope, apiPk);
      return;
    }
    await initialize(labScopeId: _labScope);
  }

  static Future<void> initialize({String? labScopeId}) async {
    final envKey = EnvConfig.stripePublishableKey.trim();
    final scope = labScopeId ?? _labScope;
    _labScope = scope;
    try {
      final prefs = await SharedPreferences.getInstance();
      final scoped = prefs.getString(_scopedPrefsKey(scope))?.trim() ?? '';
      final legacy = prefs.getString(prefsPublishableKey)?.trim() ?? '';
      if (_isValidPublishableKey(scoped)) {
        _publishableKey = scoped;
        _fromDevicePrefs = true;
        _fromLabApi = false;
      } else if (_isValidPublishableKey(legacy)) {
        _publishableKey = legacy;
        _fromDevicePrefs = true;
        _fromLabApi = false;
      } else if (_isValidPublishableKey(envKey)) {
        _publishableKey = envKey;
        _fromDevicePrefs = false;
        _fromLabApi = false;
      } else {
        _publishableKey = '';
        _fromDevicePrefs = false;
        _fromLabApi = false;
      }
    } catch (_) {
      _publishableKey = _isValidPublishableKey(envKey) ? envKey : '';
      _fromDevicePrefs = false;
      _fromLabApi = false;
    }
  }

  static Future<void> _persistScoped(String scope, String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scopedPrefsKey(scope), key);
  }

  /// Device-only override (developers). Labs should use Laboratory Information.
  static Future<void> savePublishableKey(String key) async {
    _publishableKey = key.trim();
    final prefs = await SharedPreferences.getInstance();
    if (_publishableKey.isEmpty) {
      await prefs.remove(prefsPublishableKey);
      await prefs.remove(_scopedPrefsKey(_labScope));
      _fromDevicePrefs = false;
      _fromLabApi = false;
      if (_isValidPublishableKey(EnvConfig.stripePublishableKey)) {
        _publishableKey = EnvConfig.stripePublishableKey.trim();
      }
    } else {
      await prefs.setString(prefsPublishableKey, _publishableKey);
      await _persistScoped(_labScope, _publishableKey);
      _fromDevicePrefs = true;
      _fromLabApi = false;
    }
  }

  /// Payload for `POST /settings/ui/` — admin saves per-lab Stripe.
  static Map<String, dynamic> labSettingsPayload({
    required String publishableKey,
    String? secretKey,
    bool clearSecret = false,
  }) {
    final body = <String, dynamic>{
      settingsPublishableField: publishableKey.trim(),
    };
    final sk = secretKey?.trim() ?? '';
    if (sk.isNotEmpty) {
      if (_isValidSecretKey(sk)) {
        body[settingsSecretField] = sk;
      }
    } else if (clearSecret) {
      body[settingsSecretField] = '';
    }
    return body;
  }

  static String get envPublishableKeyForEditor => EnvConfig.stripePublishableKey.trim();
}

/// Isolates offline cache per Django `lab_group` (same idea as [StripeConfig.labScope]).
class LabGroupScope {
  LabGroupScope._();

  static const String prefsActiveGroupIdKey = 'active_lab_group_id';
  static const String prefsActiveGroupNameKey = 'active_lab_group_name';

  static String _groupId = 'default';
  static String _groupName = 'Default lab group';

  static String get groupId => _groupId;
  static String get groupName => _groupName;

  /// Suffix for SharedPreferences / restore and SQLite file names.
  static String get storageSuffix =>
      _groupId == 'default' ? 'default' : 'lg_$_groupId';

  static String scopedPrefsKey(String baseKey) => '${baseKey}_$storageSuffix';

  static String get sqliteFileName =>
      storageSuffix == 'default'
          ? 'lab_management_simple.db'
          : 'lab_management_$storageSuffix.db';

  /// Extract lab_group id/name from `/auth/profile/` or LabUser JSON.
  static ({String? id, String? name}) parseFromMap(Map<String, dynamic> json) {
    dynamic lg = json['lab_group'] ?? json['lab_group_id'];
    final lp = json['lab_profile'];
    if (lp is Map) {
      final m = Map<String, dynamic>.from(lp);
      lg ??= m['lab_group'] ?? m['lab_group_id'];
    }
    var name = json['lab_group_name']?.toString().trim();
    if ((name == null || name.isEmpty) && lp is Map) {
      name = lp['lab_group_name']?.toString().trim();
    }
    String? id;
    if (lg is Map) {
      id = lg['id']?.toString();
      name ??= lg['name']?.toString().trim();
    } else if (lg != null) {
      id = lg.toString();
    }
    if (id != null && id.isEmpty) id = null;
    if (name != null && name.isEmpty) name = null;
    return (id: id, name: name);
  }

  static Future<void> applyFromProfile(Map<String, dynamic> profile) async {
    final parsed = parseFromMap(profile);
    _groupId = parsed.id ?? 'default';
    _groupName = parsed.name ?? 'Default lab group';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsActiveGroupIdKey, _groupId);
    await prefs.setString(prefsActiveGroupNameKey, _groupName);
  }

  static Future<void> loadCachedScope() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _groupId = prefs.getString(prefsActiveGroupIdKey) ?? 'default';
      _groupName = prefs.getString(prefsActiveGroupNameKey) ?? 'Default lab group';
    } catch (_) {
      _groupId = 'default';
      _groupName = 'Default lab group';
    }
  }

  static Future<void> clearActiveScope() async {
    _groupId = 'default';
    _groupName = 'Default lab group';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefsActiveGroupIdKey);
    await prefs.remove(prefsActiveGroupNameKey);
  }
}

/// In-app subscription — Apple App Store + Google Play only ($7.99/mo).
class LabSubscriptionConfig {
  LabSubscriptionConfig._();

  static const double monthlyPriceUsd = 7.99;
  static const String planLabel = 'Saeed Lab Pro';

  /// Product ID in App Store Connect and Google Play Console.
  static String get storeProductId => EnvConfig.labSubscriptionProductId;

  static bool isUnlockedStatus(String? status) {
    final s = status?.toLowerCase();
    return s == 'active' || s == 'trialing';
  }

  static const String appleManageSubscriptionsUrl =
      'https://apps.apple.com/account/subscriptions';
  static const String googleManageSubscriptionsUrl =
      'https://play.google.com/store/account/subscriptions';

  static String get priceDisplay => '\$${monthlyPriceUsd.toStringAsFixed(2)}/month';
}

class AppConstants {
  static const String appName = 'SAEED Laboratory';
  static const String appVersion = '2.2.0+21';

  /// Django admin — reset passwords (same as SaeedLab web “Forgot password”).
  static const String djangoAdminUrl = 'https://api.mywaitime.com/admin/';

  /// Lab superuser — see `.env` / `EnvConfig` / `--dart-define`.
  static String get labSuperuserUsername => EnvConfig.labAdminUsername;
  static String get labSuperuserDefaultPassword => EnvConfig.labAdminPassword;
  static int get labSuperuserId => EnvConfig.labAdminUserId;

  /// Same backend as https://zub165.github.io/SaeedLab/ — use [LabApiConfig.resolvedBaseUrl] at runtime.
  static const String djangoBackendUrl = LabApiConfig.productionApiBase;

  static String get baseUrl => LabApiConfig.resolvedBaseUrl;

  static String get baseUrlForPhysicalDevice => LabApiConfig.resolvedBaseUrl;

  static String get baseUrlProduction => LabApiConfig.productionApiBase;
  static const String djangoBackendPort = '443';
  static const String djangoBackendProtocol = 'https';
  static const String labManagementPrefix = '/lab';
  
  // Apple App Store Connect API
  static const String appleApiBaseUrl = 'https://api.appstoreconnect.apple.com';
  static const String appStoreConnectApiKey = 'YOUR_API_KEY';
  static const String appStoreConnectIssuerId = 'YOUR_ISSUER_ID';
  static const String appStoreConnectKeyId = 'YOUR_KEY_ID';
  
  // Google Play Console API
  static const String googlePlayApiBaseUrl = 'https://www.googleapis.com/androidpublisher/v3';
  static const String googlePlayServiceAccountEmail = 'YOUR_SERVICE_ACCOUNT_EMAIL';
  static const String googlePlayPrivateKey = 'YOUR_PRIVATE_KEY';
  
  // Django Lab Management API Endpoints
  static const String tokenEndpoint = '/auth/token/';
  static const String tokenRefreshEndpoint = '/auth/token/refresh/';
  static const String loginEndpoint = '/auth/login/';
  static const String registerEndpoint = '/auth/register/';
  static const String logoutEndpoint = '/auth/logout/';
  static const String profileEndpoint = '/auth/profile/';
  static const String ensureLabProfileEndpoint = '/auth/ensure-my-lab-profile/';
  static const String settingsUiEndpoint = '/settings/ui/';

  /// Bundled legal docs (used when API has no `/legal/*` endpoint).
  static const String privacyPolicyAsset = 'assets/legal/privacy.html';
  static const String termsOfServiceAsset = 'assets/legal/terms.html';

  /// Privacy / account requests (mailto when API has no deletion endpoint).
  static const String labSupportEmail = 'support@saeedlab.com';
  static const String labSupportEmailAlt = 'zub165@yahoo.com';
  static const String pendingDeletionRequestsKey = 'pending_account_deletion_requests';
  
  // Patient Management Endpoints
  static const String patientsEndpoint = '/patients/';
  static const String patientsCreateEndpoint = '/patients/create/';
  static const String patientsUpdateEndpoint = '/patients/';
  static const String patientsDeleteEndpoint = '/patients/';
  
  // Test Management Endpoints
  static const String testCategoriesEndpoint = '/test-categories/';
  static const String testsEndpoint = '/tests/';
  static const String panelDefinitionsEndpoint = '/tests/panel-definitions/';
  static const String testOrdersEndpoint = '/test-orders/';
  static const String uploadsEndpoint = '/uploads/';
  static const String testOrdersCreateEndpoint = '/test-orders/create/';
  static const String testOrderItemsEndpoint = '/test-order-items/';
  static const String testResultsEndpoint = '/test-results/';
  static const String dashboardStatsEndpoint = '/dashboard-stats/';
  static const String labGroupsEndpoint = '/lab-groups/';
  
  // Appointment Management Endpoints
  static const String appointmentsEndpoint = '/appointments/';
  static const String appointmentsCreateEndpoint = '/appointments/create/';
  
  // Payment Management Endpoints
  static const String paymentsEndpoint = '/payments/';
  static const String paymentsCreateEndpoint = '/payments/create/';
  
  // User Management Endpoints
  static const String usersEndpoint = '/users/';
  
  // Report Management Endpoints
  static const String reportsEndpoint = '/reports/';
  static const String reportsGenerateEndpoint = '/reports/generate/';
  
  // System & Utility Endpoints
  static const String settingsEndpoint = '/settings/';
  static const String analyticsEndpoint = '/analytics/';
  static const String systemStatusEndpoint = '/system/status/';
  
  // Data Export Endpoints
  static const String exportPatientsCsvEndpoint = '/export/patients/csv/';
  static const String exportOrdersCsvEndpoint = '/export/orders/csv/';
  
  // AI Enhancement Endpoints (disabled for now)
  // static const String aiAnalysisEndpoint = '/ai/analysis/';
  // static const String aiPredictionEndpoint = '/ai/prediction/';
  // static const String aiRecommendationEndpoint = '/ai/recommendations/';
  // static const String aiInsightsEndpoint = '/ai/insights/';
  // static const String aiReportGenerationEndpoint = '/ai/report-generation/';
  // static const String aiDataProcessingEndpoint = '/ai/data-processing/';
  
  // New Comprehensive Data Management Endpoints
  static const String dataPatientsEndpoint = '/data/patients';
  static const String dataTestsEndpoint = '/data/tests';
  static const String dataAppointmentsEndpoint = '/data/appointments';
  static const String dataPaymentsEndpoint = '/data/payments';
  static const String dataResearchEndpoint = '/data/research';
  static const String dataTestResultsEndpoint = '/data/tests';
  
  // Apple App Store Connect Endpoints
  static const String appStoreAppsEndpoint = '/v1/apps';
  static const String appStoreBuildsEndpoint = '/v1/builds';
  static const String appStoreTestFlightEndpoint = '/v1/testflight';
  
  // Google Play Console Endpoints
  static const String playStoreEditsEndpoint = '/edits';
  static const String playStoreBundlesEndpoint = '/bundles';
  static const String playStoreTracksEndpoint = '/tracks';
  
  // Shared Preferences Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String notificationsKey = 'notifications_enabled';
  
  // App Colors
  static const Color primaryColor = Color(0xFF2C3E50);
  static const Color secondaryColor = Color(0xFF3498DB);
  static const Color accentColor = Color(0xFFE74C3C);
  static const Color successColor = Color(0xFF27AE60);
  static const Color warningColor = Color(0xFFF39C12);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color infoColor = Color(0xFF17A2B8);
  
  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );
  
  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryColor,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );
  
  // Dimensions
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // Test Types
  static const List<String> testTypes = [
    'Blood Test (CBC)',
    'Lipid Profile',
    'Urine Analysis',
    'Liver Function Test',
    'Kidney Function Test',
    'Thyroid Function Test',
    'Diabetes Screening',
    'Cardiac Markers',
    'Inflammatory Markers',
    'X-Ray',
    'MRI',
    'CT Scan',
    'Ultrasound',
    'ECG',
  ];
  
  /// SaeedLab web payment modal: cash, card, insurance, online.
  static const List<Map<String, String>> paymentMethodOptions = [
    {'value': 'cash', 'label': 'Cash', 'icon': 'payments'},
    {'value': 'card', 'label': 'Credit / Debit Card (Stripe)', 'icon': 'credit_card'},
    {'value': 'insurance', 'label': 'Insurance', 'icon': 'health_and_safety'},
    {'value': 'online', 'label': 'Online / Bank Transfer', 'icon': 'account_balance'},
  ];

  static const List<String> paymentMethods = ['Cash', 'Card', 'Insurance', 'Online'];

  /// International insurers (not US-only). Matches global lab / travel coverage.
  static const List<String> globalInsuranceProviders = [
    'None / Self-pay',
    'Allianz Care',
    'AXA Global Healthcare',
    'Bupa Global',
    'Cigna Global',
    'GeoBlue (BCBS Global)',
    'IMG Global',
    'International SOS',
    'MetLife International',
    'MSH International',
    'Now Health International',
    'Pacific Prime',
    'William Russell',
    'Aetna International',
    'UnitedHealthcare Global',
    'Cigna (US)',
    'Blue Cross Blue Shield (US)',
    'Medicare (US)',
    'Medicaid (US)',
    'NHS / UK National',
    'EHIC / GHIC (EU)',
    'GCC / Local Government Scheme',
    'Other — specify in policy number',
  ];
  
  // Test Status
  static const List<String> testStatuses = [
    'Pending',
    'In Progress',
    'Completed',
    'Cancelled',
  ];
  
  // Appointment Status
  static const List<String> appointmentStatuses = [
    'Scheduled',
    'Completed',
    'Cancelled',
    'No Show',
  ];
  
  // Payment Status
  static const List<String> paymentStatuses = [
    'Pending',
    'Completed',
    'Failed',
    'Refunded',
  ];
  
  // Navigation
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';
  static const String invalidCredentials = 'Invalid username or password.';
  static const String requiredField = 'This field is required.';
  static const String invalidEmail = 'Please enter a valid email address.';
  static const String invalidPhone = 'Please enter a valid phone number.';
  
  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String logoutSuccess = 'Logout successful!';
  static const String saveSuccess = 'Data saved successfully!';
  static const String deleteSuccess = 'Item deleted successfully!';
  static const String updateSuccess = 'Data updated successfully!';
  
  // Confirmation Messages
  static const String deleteConfirmation = 'Are you sure you want to delete this item?';
  static const String logoutConfirmation = 'Are you sure you want to logout?';
  static const String unsavedChanges = 'You have unsaved changes. Do you want to leave?';
}

/// Safe parsing when Django returns ids as int or string.
class JsonParse {
  JsonParse._();

  static int? intOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static String string(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    return value.toString();
  }

  static String? stringOrNull(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }
}
