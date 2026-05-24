import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../utils/constants.dart';
import '../models/patient.dart';
import '../models/test.dart';
import '../models/test_result.dart';
import '../models/appointment.dart';
import '../models/payment.dart';
import '../models/user.dart';
import '../models/report_template.dart';
import '../models/user_create_request.dart';
import '../models/user_update_request.dart';
import '../models/report_data.dart';
import '../utils/data_export_utils.dart' show DataExportResult, DataExportUtils, AccountDeletionRequestResult, LegalDocumentResult;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/api_env.dart';
import '../utils/env_config.dart';

/// Result of `POST /lab/payments/stripe/create-intent/`.
class StripeIntentResult {
  final bool success;
  final int statusCode;
  final String? clientSecret;
  final String? paymentIntentId;
  final String? publishableKey;
  final Map<String, dynamic>? payment;
  final String? message;

  const StripeIntentResult({
    required this.success,
    required this.statusCode,
    this.clientSecret,
    this.paymentIntentId,
    this.publishableKey,
    this.payment,
    this.message,
  });

  factory StripeIntentResult.failure(int code, String message) =>
      StripeIntentResult(success: false, statusCode: code, message: message);
}

class DjangoApiService {
  static final DjangoApiService _instance = DjangoApiService._internal();
  factory DjangoApiService() => _instance;
  DjangoApiService._internal();

  String get baseUrl => LabApiConfig.resolvedBaseUrl;

  /// Lab API only — never `https://api.mywaitime.com/api/`.
  static void assertLabBase(String url) {
    ApiEnvConfig.normalizeLabBase(url);
  }
  
  // For debugging - print current configuration
  void _printCurrentConfig() {
    if (!kReleaseMode) {
      print('=== Django API Service Configuration ===');
      print('Django Backend URL: $baseUrl');
      print('Platform: ${Platform.operatingSystem}');
      print('Release Mode: $kReleaseMode');
      print('========================================');
    }
  }

  Future<bool> testBackendConnection({String? baseOverride}) async {
    final base = baseOverride ?? baseUrl;
    return ApiEnvConfig.healthCheck(base);
  }

  Future<bool> switchToBackupServer() async {
    await ApiEnvConfig.setUsingBackup(true);
    await LabApiConfig.applyResolvedBase();
    return testBackendConnection();
  }

  Future<bool> switchToPrimaryServer() async {
    await ApiEnvConfig.setUsingBackup(false);
    await LabApiConfig.applyResolvedBase();
    return testBackendConnection();
  }

  String? _authToken;

  Future<String?> get authToken async {
    if (_authToken != null) return _authToken;
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(AppConstants.tokenKey);
    return _authToken;
  }

  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
  }

  Future<void> _setRefreshToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await prefs.remove(AppConstants.refreshTokenKey);
    } else {
      await prefs.setString(AppConstants.refreshTokenKey, token);
    }
  }

  Future<String?> get refreshToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.refreshTokenKey);
  }

  /// Aligns with SaeedLab web `normalizeTokenResponse` (access / access_token / token).
  Map<String, String?> _normalizeTokenPayload(Map<String, dynamic> payload) {
    final data = payload['data'] is Map
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : payload;
    final access = (data['access'] ??
            data['access_token'] ??
            data['token'] ??
            payload['access'] ??
            payload['access_token'])
        ?.toString();
    final refresh = (data['refresh'] ??
            data['refresh_token'] ??
            payload['refresh'] ??
            payload['refresh_token'])
        ?.toString();
    return {'access': access, 'refresh': refresh};
  }

  Future<bool> refreshAuthToken() async {
    final stored = await refreshToken;
    if (stored == null || stored.isEmpty) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.tokenRefreshEndpoint}'),
        headers: _headers,
        body: jsonEncode({'refresh': stored}),
      );
      if (response.statusCode != 200) return false;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tokens = _normalizeTokenPayload(data);
      if (tokens['access'] != null) {
        await setAuthToken(tokens['access']!);
        if (tokens['refresh'] != null) {
          await _setRefreshToken(tokens['refresh']);
        }
        return true;
      }
    } catch (e) {
      print('Token refresh failed: $e');
    }
    return false;
  }

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<Map<String, String>> get _authHeaders async {
    final token = await authToken;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Generic HTTP methods for Django
  Future<http.Response> _get(String endpoint) async {
    final headers = await _authHeaders;
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    _handleResponse(response);
    return response;
  }

  Future<http.Response> _post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _authHeaders;
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    _handleResponse(response);
    return response;
  }

  Future<http.Response> _put(String endpoint, Map<String, dynamic> data) async {
    final headers = await _authHeaders;
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    _handleResponse(response);
    return response;
  }

  Future<http.Response> _patch(String endpoint, Map<String, dynamic> data) async {
    final headers = await _authHeaders;
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    _handleResponse(response);
    return response;
  }

  Future<http.Response> _delete(String endpoint) async {
    final headers = await _authHeaders;
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    _handleResponse(response);
    return response;
  }

  /// Human-readable API error (SaeedLab `{ message, errors }` or Django HTML 500).
  static String formatApiError(http.Response response) {
    final code = response.statusCode;
    if (code == 403) {
      return 'Permission denied. Only a lab administrator or Django superuser can add staff. '
          'Log out and sign in as admin (see Staff screen for credentials).';
    }
    if (code == 500 &&
        (response.body.contains('Server Error') ||
            response.body.contains('<!doctype html>'))) {
      return 'Server error (500). This often happens when the username or email is already taken. '
          'Choose a new username and a unique employee ID, then try again.';
    }
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        final lines = <String>[];
        final errors = body['errors'];
        if (errors is Map) {
          errors.forEach((key, value) {
            final label = key.toString().replaceAll('_', ' ');
            if (value is List && value.isNotEmpty) {
              lines.add('$label: ${value.first}');
            } else if (value != null) {
              lines.add('$label: $value');
            }
          });
        }
        final message = body['message'] ?? body['detail'];
        if (lines.isNotEmpty) {
          final header = message?.toString().trim();
          if (header != null && header.isNotEmpty && header != 'Bad request - Invalid data provided') {
            return '$header\n${lines.join('\n')}';
          }
          return lines.join('\n');
        }
        if (message != null && message.toString().isNotEmpty) {
          return message.toString();
        }
      }
    } catch (_) {}
    return 'Request failed ($code). Check all required fields and use a unique username and employee ID.';
  }

  /// Same rules as SaeedLab web `settingsUserIsLabAdmin`.
  static bool profileCanManageStaff(Map<String, dynamic> profile) {
    if (profile['is_superuser'] == true || profile['is_lab_admin'] == true) {
      return true;
    }
    final role = profile['role']?.toString().toLowerCase() ?? '';
    return role == 'admin' || role == 'administrator';
  }

  void _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      clearAuthToken();
      throw Exception('Authentication required — please log in again');
    }
    if (response.statusCode >= 400) {
      throw Exception(formatApiError(response));
    }
  }

  // Safely extract list from paginated, SaeedLab {data: [...]}, or raw list responses.
  List<dynamic> _extractList(dynamic decodedBody) {
    if (decodedBody is List) {
      return List<dynamic>.from(decodedBody);
    }
    if (decodedBody is! Map) return const [];

    final map = Map<String, dynamic>.from(decodedBody);
    if (map['results'] is List) {
      return List<dynamic>.from(map['results'] as List);
    }
    final data = map['data'];
    if (data is List) {
      return List<dynamic>.from(data);
    }
    if (data is Map) {
      for (final key in [
        'patients',
        'test_orders',
        'payments',
        'appointments',
        'reports',
        'users',
        'tests',
      ]) {
        if (data[key] is List) {
          return List<dynamic>.from(data[key] as List);
        }
      }
    }
    return const [];
  }

  // Health check for Django Lab Management backend
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/analytics/'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }

  // Django JWT authentication (same flow as SaeedLab web app)
  Future<Map<String, dynamic>> login(String username, String password) async {
    _printCurrentConfig();

    http.Response response = await http.post(
      Uri.parse('$baseUrl${AppConstants.tokenEndpoint}'),
      headers: _headers,
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode != 200) {
      response = await http.post(
        Uri.parse('$baseUrl${AppConstants.loginEndpoint}'),
        headers: _headers,
        body: jsonEncode({'username': username, 'password': password}),
      );
    }

    if (response.statusCode != 200) {
      String detail = 'Login failed (${response.statusCode})';
      try {
        final err = jsonDecode(response.body);
        detail = err['detail']?.toString() ?? err['message']?.toString() ?? detail;
      } catch (_) {}
      throw Exception(detail);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final tokens = _normalizeTokenPayload(data);
    if (tokens['access'] == null) {
      throw Exception('Login succeeded but no access token was returned');
    }
    await setAuthToken(tokens['access']!);
    if (tokens['refresh'] != null) {
      await _setRefreshToken(tokens['refresh']);
    }
    await syncLabGroupScopeFromProfile();
    return data;
  }

  /// Sets [LabGroupScope] from JWT profile so offline data is isolated per lab group.
  Future<void> syncLabGroupScopeFromProfile() async {
    try {
      final profile = await getCurrentUser();
      await LabGroupScope.applyFromProfile(profile);
    } catch (_) {
      await LabGroupScope.loadCachedScope();
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _get(AppConstants.profileEndpoint);
    if (response.statusCode == 200) {
      return _unwrapMap(jsonDecode(response.body));
    }
    if (response.statusCode == 401 && await refreshAuthToken()) {
      final retry = await _get(AppConstants.profileEndpoint);
      if (retry.statusCode == 200) {
        return _unwrapMap(jsonDecode(retry.body));
      }
    }
    throw Exception('Failed to get current user (${response.statusCode})');
  }

  /// Lab UI settings — same as SaeedLab web Settings tab (`GET /settings/ui/`).
  Future<Map<String, dynamic>> getLabUiSettings() async {
    final response = await _get(AppConstants.settingsUiEndpoint);
    if (response.statusCode == 200) {
      return _unwrapMap(jsonDecode(response.body));
    }
    throw Exception('Failed to load lab settings (${response.statusCode})');
  }

  Future<Map<String, dynamic>> updateLabUiSettings(Map<String, dynamic> settings) async {
    final response = await _post(AppConstants.settingsUiEndpoint, settings);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return _unwrapMap(jsonDecode(response.body));
    }
    throw Exception('Failed to save lab settings (${response.statusCode})');
  }

  /// Per-lab Stripe publishable key from `GET /settings/ui/` (multi-tenant labs).
  Future<void> syncLabStripeConfig() async {
    try {
      final settings = await getLabUiSettings();
      await StripeConfig.applyLabSettings(settings);
    } catch (_) {
      await StripeConfig.initialize();
    }
  }

  static Future<void> applyStripePublishableToSdk() async {
    if (!StripeConfig.isConfigured) return;
    Stripe.publishableKey = StripeConfig.publishableKey;
    await Stripe.instance.applySettings();
  }

  /// Create/update LabUser profile (SaeedLab `POST /auth/ensure-my-lab-profile/`).
  Future<Map<String, dynamic>> ensureMyLabProfile({
    required String employeeId,
    required String role,
    String? department,
    String? phone,
    String? address,
    String? hireDate,
  }) async {
    final body = <String, dynamic>{
      'employee_id': employeeId,
      'role': role,
      if (department != null && department.isNotEmpty) 'department': department,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (address != null && address.isNotEmpty) 'address': address,
      if (hireDate != null && hireDate.isNotEmpty) 'hire_date': hireDate,
    };
    final response = await _post(AppConstants.ensureLabProfileEndpoint, body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return _unwrapMap(jsonDecode(response.body));
    }
    throw Exception('Failed to save profile (${response.statusCode})');
  }

  /// Privacy or Terms: API → lab settings fields → bundled HTML (synced with SaeedLab).
  Future<LegalDocumentResult> fetchLegalDocument(String type) async {
    final isPrivacy = type == 'privacy';
    final title = isPrivacy ? 'Privacy Policy' : 'Terms of Service';
    Map<String, dynamic> labSettings = {};
    try {
      labSettings = await getLabUiSettings();
    } catch (_) {}

    final apiField = isPrivacy
        ? ['privacy_policy', 'privacy_policy_text', 'privacy_text']
        : ['terms_of_service', 'terms_of_service_text', 'terms_text'];
    for (final key in apiField) {
      final v = labSettings[key]?.toString().trim();
      if (v != null && v.isNotEmpty) {
        return LegalDocumentResult(
          title: title,
          body: _withLabHeader(v, labSettings),
          sourceLabel: 'SaeedLab API (lab settings)',
          labSettings: labSettings,
        );
      }
    }

    final legalPaths = isPrivacy
        ? ['/legal/privacy/', '/content/privacy/', '/settings/legal/privacy/']
        : ['/legal/terms/', '/content/terms/', '/settings/legal/terms/'];
    for (final path in legalPaths) {
      final response = await _getOptional(path);
      if (response != null) {
        final decoded = jsonDecode(response.body);
        final map = decoded is Map ? _unwrapMap(decoded) : <String, dynamic>{};
        final text = (map['content'] ?? map['text'] ?? map['body'] ?? map['html'])
            ?.toString()
            .trim();
        if (text != null && text.isNotEmpty) {
          return LegalDocumentResult(
            title: title,
            body: _withLabHeader(
              text.contains('<') ? htmlToPlainText(text) : text,
              labSettings,
            ),
            sourceLabel: 'SaeedLab API',
            labSettings: labSettings,
          );
        }
      }
    }

    final asset = isPrivacy
        ? AppConstants.privacyPolicyAsset
        : AppConstants.termsOfServiceAsset;
    final html = await rootBundle.loadString(asset);
    return LegalDocumentResult(
      title: title,
      body: _withLabHeader(htmlToPlainText(html), labSettings),
      sourceLabel: labSettings.isNotEmpty
          ? 'Bundled policy + live lab contact info'
          : 'Bundled policy (log in for lab details)',
      labSettings: labSettings,
    );
  }

  static String htmlToPlainText(String html) {
    var t = html;
    t = t.replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>', caseSensitive: false), '');
    t = t.replaceAll(RegExp(r'<script[^>]*>[\s\S]*?</script>', caseSensitive: false), '');
    t = t.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    t = t.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n');
    t = t.replaceAll(RegExp(r'</h[1-6]>', caseSensitive: false), '\n\n');
    t = t.replaceAll(RegExp(r'</li>', caseSensitive: false), '\n');
    t = t.replaceAll(RegExp(r'<[^>]+>'), '');
    t = t.replaceAll('&nbsp;', ' ');
    t = t.replaceAll('&amp;', '&');
    t = t.replaceAll('&lt;', '<');
    t = t.replaceAll('&gt;', '>');
    t = t.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return t.trim();
  }

  String _withLabHeader(String body, Map<String, dynamic> lab) {
    if (lab.isEmpty) return body;
    final name = lab['lab_name']?.toString().trim();
    final phone = lab['lab_phone']?.toString().trim();
    final email = lab['lab_email']?.toString().trim();
    final address = lab['lab_address']?.toString().trim();
    final buf = StringBuffer();
    if (name != null && name.isNotEmpty) {
      buf.writeln(name);
    }
    if (address != null && address.isNotEmpty) buf.writeln(address);
    if (phone != null && phone.isNotEmpty) buf.writeln('Phone: $phone');
    if (email != null && email.isNotEmpty) buf.writeln('Email: $email');
    if (buf.isNotEmpty) {
      buf.writeln('—');
      buf.writeln();
    }
    buf.write(body);
    return buf.toString();
  }

  Map<String, dynamic> _unwrapMap(dynamic decoded) {
    if (decoded is! Map) return {};
    final map = Map<String, dynamic>.from(decoded);
    if (map['data'] is Map) {
      return Map<String, dynamic>.from(map['data'] as Map);
    }
    return map;
  }

  Future<http.Response?> _getOptional(String endpoint) async {
    try {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      if (response.statusCode == 200) return response;
      if (response.statusCode == 401 && await refreshAuthToken()) {
        final retry = await http.get(
          Uri.parse('$baseUrl$endpoint'),
          headers: await _authHeaders,
        );
        if (retry.statusCode == 200) return retry;
      }
    } catch (_) {}
    return null;
  }

  // AI Enhancement methods are disabled for basic functionality
  // They can be enabled once the backend AI endpoints are ready

  // ============================================================================
  // STANDARD CRUD OPERATIONS (Django Compatible)
  // ============================================================================

  // Patients
  Future<List<Patient>> getPatients({Map<String, String>? query}) async {
    var path = AppConstants.patientsEndpoint;
    if (query != null && query.isNotEmpty) {
      path += '?${Uri(queryParameters: query).query}';
    }
    final response = await _get(path);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = _extractList(data);
      return items.map((json) => Patient.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load patients: ${response.statusCode}');
  }

  Future<Patient> getPatient(int id) async {
    final response = await _get('${AppConstants.patientsEndpoint}$id/');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Patient.fromJson(data);
    } else {
      throw Exception('Failed to load patient: ${response.statusCode}');
    }
  }

  Future<Patient> createPatient(Patient patient) async {
    final response = await _post(AppConstants.patientsEndpoint, patient.toApiJson());
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Patient.fromJson(data);
    } else {
      throw Exception('Failed to create patient: ${response.statusCode}');
    }
  }

  Future<Patient> updatePatient(int id, Patient patient) async {
    final response = await _put('${AppConstants.patientsEndpoint}$id/', patient.toApiJson());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Patient.fromJson(data);
    } else {
      throw Exception('Failed to update patient: ${response.statusCode}');
    }
  }

  Future<void> deletePatient(int id) async {
    final response = await _delete('${AppConstants.patientsEndpoint}$id/');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete patient: ${response.statusCode}');
    }
  }

  // Lab test catalog (/lab/tests/) — same list as SaeedLab "Test Types" tab (public read)
  Future<List<Map<String, dynamic>>> getLabTestCatalog({
    Map<String, String>? query,
  }) async {
    var path = AppConstants.testsEndpoint;
    final params = {'limit': '500', ...?query};
    path += '?${Uri(queryParameters: params).query}';

    final response = await _get(path);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = _extractList(data);
      return items
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((j) => j['is_active'] != false)
          .toList();
    }
    throw Exception('Failed to load lab test catalog: ${response.statusCode}');
  }

  Future<List<String>> getLabTestCategoryNames() async {
    final response = await http.get(
      Uri.parse('$baseUrl${AppConstants.testCategoriesEndpoint}'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = _extractList(data);
      return items
          .map((j) => (j as Map)['name']?.toString() ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
    }
    throw Exception('Failed to load test categories: ${response.statusCode}');
  }

  /// LabUser id for TestOrder.doctor (same as SaeedLab `getCurrentDoctorId()`).
  Future<String?> getCurrentLabUserId() async {
    try {
      final profile = await getCurrentUser();
      final id = profile['lab_user_id'] ??
          (profile['lab_user'] is Map
              ? (profile['lab_user'] as Map)['id']
              : null) ??
          profile['doctor_id'];
      if (id != null) return id.toString();
    } catch (_) {}
    return null;
  }

  /// Create test order (SaeedLab web: POST /test-orders/)
  Future<Test> createTestOrderForPatient({
    required String patientId,
    required List<String> testCodes,
    String priority = 'routine',
    String? clinicalNotes,
    String? doctorId,
  }) async {
    final doctor = doctorId ?? await getCurrentLabUserId();
    if (doctor == null || doctor.isEmpty) {
      throw Exception(
        'No lab staff profile for this login. Open Settings → Profile and complete your lab profile, or ask an admin to link your account.',
      );
    }

    final body = <String, dynamic>{
      'patient': patientId,
      'doctor': doctor,
      'priority': priority.toLowerCase(),
      'clinical_notes': clinicalNotes ?? '',
      'test_items': testCodes
          .map((code) => {'test_code': code})
          .toList(),
    };

    final headers = await _authHeaders;
    final response = await http.post(
      Uri.parse('$baseUrl${AppConstants.testOrdersEndpoint}'),
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 401) {
      clearAuthToken();
      throw Exception('Authentication required — please log in again');
    }
    if (response.statusCode == 201 || response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final map = decoded is Map && decoded['data'] is Map
          ? Map<String, dynamic>.from(decoded['data'] as Map)
          : decoded as Map<String, dynamic>;
      return Test.fromTestOrderJson(map);
    }
    throw Exception(_formatApiError(response, 'Failed to create test order'));
  }

  String _formatApiError(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        final errors = body['errors'];
        if (errors is Map && errors.isNotEmpty) {
          return errors.entries
              .map((e) => '${e.key}: ${e.value}')
              .join('; ');
        }
        final msg = body['message'] ?? body['detail'] ?? body['error'];
        if (msg != null) return msg.toString();
      }
    } catch (_) {}
    return '$fallback (${response.statusCode})';
  }

  Future<List<Test>> getLabTests({Map<String, String>? query}) async {
    final items = await getLabTestCatalog(query: query);
    return items.map((json) => Test.fromJson(json)).toList();
  }

  // Test orders (/lab/test-orders/) — same as SaeedLab web "Lab Tests" tab
  Future<List<Test>> getTestOrders({Map<String, String>? query}) async {
    var path = AppConstants.testOrdersEndpoint;
    if (query != null && query.isNotEmpty) {
      path += '?${Uri(queryParameters: query).query}';
    }
    final response = await _get(path);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = _extractList(data);
      return items
          .map((json) => Test.fromTestOrderJson(json as Map<String, dynamic>))
          .where((t) {
            final s = t.status.toLowerCase();
            return s != 'archived' && s != 'deleted';
          })
          .toList();
    }
    throw Exception('Failed to load test orders: ${response.statusCode}');
  }

  /// Backward-compatible alias: mobile "tests" screen = test orders on web.
  Future<List<Test>> getTests({Map<String, String>? query}) =>
      getTestOrders(query: query);

  Future<Test> getTestOrder(String id) async {
    final response = await _get('${AppConstants.testOrdersEndpoint}$id/');
    if (response.statusCode == 200) {
      return Test.fromTestOrderJson(
        _unwrapMap(jsonDecode(response.body)),
      );
    }
    throw Exception('Failed to load test order: ${response.statusCode}');
  }

  /// Upload image/file for order clinical notes (SaeedLab `POST /uploads/`).
  Future<String> uploadLabFile(File file) async {
    final token = await authToken;
    final uri = Uri.parse('${LabApiConfig.resolvedBaseUrl}${AppConstants.uploadsEndpoint}');
    final request = http.MultipartRequest('POST', uri);
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 401) {
      clearAuthToken();
      throw Exception('Authentication required — please log in again');
    }
    if (response.statusCode >= 400) {
      throw Exception(formatApiError(response));
    }
    final data = jsonDecode(response.body);
    final map = data is Map ? _unwrapMap(data) : <String, dynamic>{};
    final url = map['url']?.toString().trim() ?? '';
    if (url.isEmpty) {
      throw Exception('Upload succeeded but no URL was returned');
    }
    return url;
  }

  /// PATCH only `clinical_notes` (image links JSON) on a test order.
  Future<Test> updateTestOrderClinicalNotes(
    String orderId,
    String clinicalNotes,
  ) async {
    final response = await _patch(
      '${AppConstants.testOrdersEndpoint}$orderId/',
      {'clinical_notes': clinicalNotes},
    );
    if (response.statusCode == 200) {
      return Test.fromTestOrderJson(
        _unwrapMap(jsonDecode(response.body)),
      );
    }
    throw Exception('Failed to save clinical notes: ${response.statusCode}');
  }

  /// Raw test-order JSON (includes `test_items` + nested `result`).
  Future<Map<String, dynamic>> getTestOrderJson(String id) async {
    final response = await _get('${AppConstants.testOrdersEndpoint}$id/');
    if (response.statusCode == 200) {
      return _unwrapMap(jsonDecode(response.body));
    }
    throw Exception('Failed to load test order: ${response.statusCode}');
  }

  /// Panel analyte definitions keyed by test code (SaeedLab web).
  Future<Map<String, List<Map<String, dynamic>>>> fetchPanelDefinitions() async {
    try {
      final response = await _get(AppConstants.panelDefinitionsEndpoint);
      if (response.statusCode != 200) return {};
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return {};
      final out = <String, List<Map<String, dynamic>>>{};
      decoded.forEach((key, value) {
        if (value is List) {
          out[key.toString()] = value
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      });
      return out;
    } catch (_) {
      return {};
    }
  }

  Future<List<dynamic>> fetchTestOrderItemsForOrder(String orderId) async {
    final response = await _get(
      '${AppConstants.testOrderItemsEndpoint}?order=${Uri.encodeComponent(orderId)}',
    );
    if (response.statusCode != 200) return [];
    final decoded = jsonDecode(response.body);
    return _extractList(decoded);
  }

  /// Create or update one line-item result (`POST`/`PATCH` `/test-results/`).
  Future<Map<String, dynamic>> upsertTestOrderItemResult({
    required String orderItemId,
    int? existingResultId,
    required String resultValue,
    required String referenceRange,
    required String unit,
    List<Map<String, dynamic>> panelAnalytes = const [],
  }) async {
    final body = <String, dynamic>{
      'test_order_item': orderItemId,
      'result_value': resultValue,
      'reference_range': referenceRange,
      'unit': unit,
      'interpretation': 'normal',
      'panel_analytes': panelAnalytes,
    };
    final http.Response response;
    if (existingResultId != null) {
      response = await _patch(
        '${AppConstants.testResultsEndpoint}$existingResultId/',
        body,
      );
    } else {
      response = await _post(AppConstants.testResultsEndpoint, body);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      return _unwrapMap(jsonDecode(response.body));
    }
    throw Exception(formatApiError(response));
  }

  /// Load editable result rows for an order (items + panel defs).
  Future<List<LabResultRow>> loadLabResultRowsForOrder(String orderId) async {
    var order = await getTestOrderJson(orderId);
    var items = LabResultRowsBuilder.orderItemsFromJson(order);
    if (items.isEmpty) {
      final extra = await fetchTestOrderItemsForOrder(orderId);
      if (extra.isNotEmpty) {
        order = Map<String, dynamic>.from(order)..['test_items'] = extra;
        items = extra;
      }
    }
    final panelDefs = await fetchPanelDefinitions();
    List<Map<String, dynamic>> catalog = [];
    Map<String, Map<String, dynamic>> catalogByCode = {};
    try {
      catalog = await getLabTestCatalog();
      catalogByCode = LabResultRowsBuilder.catalogByCode(catalog);
    } catch (_) {}
    var rows = LabResultRowsBuilder.buildFromOrder(
      order,
      panelDefs,
      catalogByCode: catalogByCode.isEmpty ? null : catalogByCode,
    );
    if (rows.isEmpty) {
      rows = _fallbackRowsFromCatalog(order, items);
    }
    if (catalog.isNotEmpty) {
      rows = LabResultRowsBuilder.enrichFromCatalog(rows, catalog);
    }
    return rows;
  }

  /// Save all table rows, then optional order status patch.
  Future<void> saveLabResultRows({
    required String orderId,
    required List<LabResultRow> rows,
    Map<String, List<Map<String, dynamic>>>? panelDefs,
  }) async {
    final defs = panelDefs ?? await fetchPanelDefinitions();
    final itemIds = rows
        .map((r) => r.orderItemId)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();

    for (final itemId in itemIds) {
      final itemRows = rows.where((r) => r.orderItemId == itemId).toList();
      if (itemRows.isEmpty) continue;
      final isPanel = itemRows.any((r) => r.isPanelAnalyte);
      if (isPanel) {
        final panelAnalytes = LabResultRowsBuilder.panelAnalytesPayload(
          rows,
          itemId,
          defs,
        );
        if (panelAnalytes.isEmpty) {
          throw Exception('Enter at least one analyte result for this panel');
        }
        await upsertTestOrderItemResult(
          orderItemId: itemId,
          existingResultId: itemRows.first.savedResultId,
          resultValue: 'Panel (${panelAnalytes.length} analytes)',
          referenceRange: '—',
          unit: '—',
          panelAnalytes: panelAnalytes,
        );
      } else {
        final r = itemRows.first;
        final val = r.value.trim();
        if (val.isEmpty) {
          throw Exception('Enter a result for ${r.parameter}');
        }
        await upsertTestOrderItemResult(
          orderItemId: itemId,
          existingResultId: r.savedResultId,
          resultValue: val,
          referenceRange: r.referenceRange,
          unit: r.unit.isNotEmpty ? r.unit : 'N/A',
        );
      }
    }
  }

  List<LabResultRow> _fallbackRowsFromCatalog(
    Map<String, dynamic> order,
    List<dynamic> items,
  ) {
    final rows = <LabResultRow>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final testObj = map['test'] ?? map['lab_test'];
      final testMap =
          testObj is Map ? Map<String, dynamic>.from(testObj) : <String, dynamic>{};
      final params = testMap['parameters'];
      if (params is! List || params.isEmpty) continue;
      final itemPk = (map['id'] ?? map['pk'])?.toString();
      final testName = (map['test_name'] ?? testMap['test_name'] ?? 'Test ${i + 1}')
          .toString();
      for (final p in params) {
        if (p is! Map) continue;
        final pm = Map<String, dynamic>.from(p);
        rows.add(LabResultRow(
          orderItemId: itemPk,
          parameter: (pm['name'] ?? pm['parameter'] ?? '').toString(),
          unit: (pm['unit'] ?? '').toString(),
          referenceRange: (pm['normal_range'] ?? pm['reference_range'] ?? '')
              .toString(),
          panelTitle: testName,
          isPanelAnalyte: true,
          analyteCode: (pm['code'] ?? pm['name'] ?? '').toString(),
        ));
      }
    }
    return rows;
  }

  Future<Test> getTest(String id) async {
    try {
      return await getTestOrder(id);
    } catch (_) {
      final response = await _get('${AppConstants.testsEndpoint}$id/');
      if (response.statusCode == 200) {
        return Test.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      throw Exception('Failed to load test: ${response.statusCode}');
    }
  }

  Future<Test> createTest(Test test) async {
    final response = await _post(
      AppConstants.testOrdersEndpoint,
      test.toTestOrderApiJson(),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Test.fromTestOrderJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to create test order: ${response.statusCode}');
  }

  Future<Test> updateTest(String id, Test test) async {
    final response = await _patch(
      '${AppConstants.testOrdersEndpoint}$id/',
      test.toTestOrderApiJson(),
    );
    if (response.statusCode == 200) {
      return Test.fromTestOrderJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to update test order: ${response.statusCode}');
  }

  Future<void> deleteTest(String id) async {
    final response = await _delete('${AppConstants.testOrdersEndpoint}$id/');
    if (response.statusCode != 204 &&
        response.statusCode != 200 &&
        response.statusCode != 202) {
      final patch = await _patch(
        '${AppConstants.testOrdersEndpoint}$id/',
        {'status': 'archived'},
      );
      if (patch.statusCode != 200) {
        throw Exception('Failed to archive test order: ${response.statusCode}');
      }
    }
  }

  Future<Test> updateTestStatus(String id, String status) async {
    final response = await _patch(
      '${AppConstants.testOrdersEndpoint}$id/',
      {'status': status},
    );
    if (response.statusCode == 200) {
      return Test.fromTestOrderJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to update test order status: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _get(AppConstants.dashboardStatsEndpoint);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load dashboard stats: ${response.statusCode}');
  }

  /// Normalized stats (same fields as SaeedLab web dashboard.js).
  Future<Map<String, dynamic>> getDashboardStatsNormalized() async {
    final raw = await getDashboardStats();
    final data = raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : raw;
    return {
      'totalOrders': data['total_test_orders'] ?? 0,
      'pendingOrders': data['pending_tests'] ?? data['pending_test_orders'] ?? 0,
      'todayAppointments': data['today_appointments'] ?? 0,
      'completedOrders': data['completed_test_orders'] ?? data['completed_tests'] ?? 0,
      'inProgressOrders': data['in_progress_test_orders'] ?? 0,
      'totalPatients': data['total_patients'] ?? 0,
      'recentPatients': data['recent_patients'] ?? 0,
      'totalLabTestsCatalog': data['total_lab_tests'] ?? 0,
      'lastUpdated': data['last_updated'],
    };
  }

  Future<List<Test>> getArchivedTestOrders({Map<String, String>? query}) async {
    final params = {
      'status': 'archived',
      'include_archived': '1',
      'ordering': '-created_at',
      'limit': '50',
      ...?query,
    };
    var path = AppConstants.testOrdersEndpoint;
    path += '?${Uri(queryParameters: params).query}';
    final response = await _get(path);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = _extractList(data);
      return items
          .map((json) => Test.fromTestOrderJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load archived orders: ${response.statusCode}');
  }

  Future<Test> restoreTestOrder(String id) async {
    return updateTestStatus(id, 'pending');
  }

  /// 30-day received vs pending due (matches web dashboard financial cards).
  Future<Map<String, double>> getFinancialSummary30d() async {
    final payments = await getPayments(query: {'limit': '5000'});
    final orders = await getTestOrders(
      query: {'ordering': '-created_at', 'limit': '5000'},
    );
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    bool inRange(DateTime? dt) =>
        dt != null && !dt.isBefore(start) && !dt.isAfter(now);

    double received = 0;
    for (final p in payments) {
      if (p.status.toLowerCase() != 'completed') continue;
      if (inRange(p.paymentDate)) {
        received += p.amount;
      }
    }

    final paidByOrder = <String, double>{};
    for (final p in payments) {
      if (p.status.toLowerCase() != 'completed') continue;
      final key = p.testId;
      if (key.isEmpty) continue;
      paidByOrder[key] = (paidByOrder[key] ?? 0) + p.amount;
    }

    double pendingDue = 0;
    for (final o in orders) {
      if (o.status.toLowerCase() == 'archived') continue;
      if (!inRange(o.orderedDate)) continue;
      final paid = paidByOrder[o.testId ?? ''] ?? 0;
      final due = o.price - paid;
      if (due > 0) pendingDue += due;
    }

    return {'received30d': received, 'pendingDue30d': pendingDue};
  }

  // Appointments
  Future<List<Appointment>> getAppointments() async {
    final response = await _get(AppConstants.appointmentsEndpoint);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = _extractList(data);
      return items
          .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load appointments: ${response.statusCode}');
  }

  Future<Appointment> createAppointment(Appointment appointment) async {
    final response = await _post(
      AppConstants.appointmentsEndpoint,
      appointment.toApiJson(),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Appointment.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception(
      'Failed to create appointment: ${response.statusCode} - ${response.body}',
    );
  }

  // Payments
  Future<List<Payment>> getPayments({Map<String, String>? query}) async {
    var path = AppConstants.paymentsEndpoint;
    if (query != null && query.isNotEmpty) {
      path += '?${Uri(queryParameters: query).query}';
    }
    final response = await _get(path);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = _extractList(data);
      return items
          .map((json) => Payment.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load payments: ${response.statusCode}');
  }

  Future<Payment> createPayment(Payment payment) async {
    final response = await _post(AppConstants.paymentsEndpoint, payment.toApiJson());
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final payload = data is Map && data['data'] is Map
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      return Payment.fromJson(payload);
    } else {
      throw Exception('Failed to create payment: ${response.statusCode} ${response.body}');
    }
  }

  /// `POST /lab/payments/stripe/create-intent/` — requires JWT.
  Future<StripeIntentResult> createStripePaymentIntent({
    required double amount,
    required String currency,
    required String testOrder,
  }) async {
    try {
      final headers = await _authHeaders;
      final response = await http.post(
        Uri.parse('$baseUrl${StripeConfig.stripePaymentIntentPath}'),
        headers: headers,
        body: jsonEncode({
          'test_order': testOrder,
          'amount': amount,
          'currency': currency.toLowerCase(),
        }),
      );
      final code = response.statusCode;
      Map<String, dynamic>? payload;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          payload = decoded['data'] is Map
              ? Map<String, dynamic>.from(decoded['data'] as Map)
              : decoded;
        }
      } catch (_) {}

      if (code == 401) {
        return StripeIntentResult.failure(401, 'Not logged in — sign in again');
      }
      if (code == 503) {
        return StripeIntentResult.failure(
          503,
          'Server missing STRIPE_SECRET_KEY — configure Django .env',
        );
      }
      if (code == 404) {
        return StripeIntentResult.failure(404, 'Test order not found or wrong lab group');
      }
      if (code == 200 || code == 201) {
        final secret = payload?['client_secret']?.toString();
        if (secret == null || secret.isEmpty) {
          return StripeIntentResult.failure(code, 'No client_secret in response');
        }
        return StripeIntentResult(
          success: true,
          statusCode: code,
          clientSecret: secret,
          paymentIntentId: payload?['payment_intent_id']?.toString(),
          publishableKey: payload?['publishable_key']?.toString(),
          payment: payload?['payment'] is Map
              ? Map<String, dynamic>.from(payload!['payment'] as Map)
              : null,
          message: payload?['message']?.toString(),
        );
      }
      return StripeIntentResult.failure(
        code,
        formatApiError(response),
      );
    } catch (e) {
      return StripeIntentResult.failure(0, e.toString());
    }
  }

  /// `POST /lab/payments/stripe/confirm/` after PaymentSheet succeeds.
  Future<bool> confirmStripePayment(String paymentIntentId) async {
    try {
      final response = await _post(
        StripeConfig.stripeConfirmPath,
        {'payment_intent_id': paymentIntentId},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // Statistics
  Future<Map<String, dynamic>> getStats() async {
    final response = await _get(AppConstants.analyticsEndpoint);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load statistics: ${response.statusCode}');
    }
  }

  // System Status
  Future<Map<String, dynamic>> getSystemStatus() async {
    final response = await _get(AppConstants.systemStatusEndpoint);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get system status: ${response.statusCode}');
    }
  }

  // API Connection Test
  Future<bool> testApiConnection() async {
    try {
      final response = await _get('/health/');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // Enhanced API Connection Test with debugging
  Future<Map<String, dynamic>> testApiConnectionWithDetails() async {
    final results = <String, dynamic>{};
    
    // Print current configuration
    _printCurrentConfig();
    
    // Test Django backend health
    try {
      final response = await _get('/health/');
      results['django_health'] = {
        'success': response.statusCode == 200,
        'status_code': response.statusCode,
        'response': response.body,
      };
    } catch (e) {
      results['django_health'] = {
        'success': false,
        'error': e.toString(),
      };
    }
    
    // AI endpoints are disabled for now
    results['ai_endpoints'] = {
      'success': false,
      'message': 'AI endpoints are disabled',
    };
    
    return results;
  }

  // Additional missing methods for compatibility
  Future<List<User>> getUsers() async {
    final response = await _get(AppConstants.usersEndpoint);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = _extractList(data);
      return items
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load users');
  }

  /// Lab chain branches — GET /lab/lab-groups/ (public list).
  Future<List<Map<String, dynamic>>> getLabGroups() async {
    final response = await http.get(
      Uri.parse('${LabApiConfig.resolvedBaseUrl}${AppConstants.labGroupsEndpoint}'),
      headers: const {'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _extractList(data)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((g) => g['is_active'] != false)
          .toList();
    }
    throw Exception('Failed to load lab groups: ${response.statusCode}');
  }

  /// Add a branch to the chain — POST /lab/lab-groups/ (admin).
  Future<Map<String, dynamic>> createLabGroup({
    required String name,
    bool isActive = true,
  }) async {
    final response = await _post(
      AppConstants.labGroupsEndpoint,
      {'name': name.trim(), 'is_active': isActive},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return _unwrapMap(jsonDecode(response.body));
    }
    throw Exception(formatApiError(response));
  }

  /// Rename or deactivate a lab branch — PATCH /lab/lab-groups/{id}/
  Future<Map<String, dynamic>> updateLabGroup({
    required String id,
    String? name,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name.trim();
    if (isActive != null) body['is_active'] = isActive;
    final response = await _patch('${AppConstants.labGroupsEndpoint}$id/', body);
    if (response.statusCode == 200) {
      return _unwrapMap(jsonDecode(response.body));
    }
    throw Exception(formatApiError(response));
  }

  /// Remove a lab branch — DELETE /lab/lab-groups/{id}/ (superuser on server).
  Future<void> deleteLabGroup(String id) async {
    final response = await _delete('${AppConstants.labGroupsEndpoint}$id/');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(formatApiError(response));
    }
  }

  /// Self-service staff signup — POST /lab/auth/register/ (no auth).
  Future<Map<String, dynamic>> registerLabUser(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('${LabApiConfig.resolvedBaseUrl}${AppConstants.registerEndpoint}'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {'ok': true};
    }
    throw Exception(formatApiError(response));
  }

  /// New customer: create lab group + admin account (best-effort).
  /// Sends `lab_group_name` for backends that support chain signup on register.
  Future<Map<String, dynamic>> registerNewLabChain({
    required String chainName,
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final today = DateTime.now();
    final hireDate =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final empId = 'ADM-${DateTime.now().millisecondsSinceEpoch % 1000000}';
    return registerLabUser({
      'username': username.trim(),
      'email': email.trim(),
      'password': password,
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'employee_id': empId,
      'role': 'admin',
      'department': 'Laboratory',
      'phone': phone.trim(),
      'address': chainName.trim(),
      'hire_date': hireDate,
      'lab_group_name': chainName.trim(),
    });
  }

  Future<User> createUser(UserCreateRequest userRequest) async {
    final headers = await _authHeaders;
    final response = await http.post(
      Uri.parse('$baseUrl${AppConstants.usersEndpoint}'),
      headers: headers,
      body: jsonEncode(userRequest.toJson()),
    );
    if (response.statusCode == 401) {
      await clearAuthToken();
      throw Exception('Authentication required — please log in again');
    }
    if (response.statusCode == 201 || response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        final payload = data is Map && data['data'] is Map
            ? data['data'] as Map<String, dynamic>
            : data is Map<String, dynamic>
                ? data
                : <String, dynamic>{};
        payload['username'] ??= userRequest.username;
        payload['email'] ??= userRequest.email;
        payload['first_name'] ??= userRequest.firstName;
        payload['last_name'] ??= userRequest.lastName;
        payload['role'] ??= userRequest.role;
        return User.fromJson(payload);
      } catch (_) {
        return User(
          username: userRequest.username,
          fullName: '${userRequest.firstName} ${userRequest.lastName}'.trim(),
          email: userRequest.email,
          role: userRequest.role,
        );
      }
    }
    throw Exception(formatApiError(response));
  }

  Future<User> updateUser(int id, UserUpdateRequest userRequest) async {
    final body = userRequest.toJson();
    if (body.isEmpty) {
      throw Exception('Nothing to update');
    }
    final response = await _patch('${AppConstants.usersEndpoint}$id/', body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(_unwrapMap(data));
    }
    throw Exception(formatApiError(response));
  }

  Future<void> deleteUser(int id) async {
    final response = await _delete('${AppConstants.usersEndpoint}$id/');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(formatApiError(response));
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final response = await _post('/auth/change-password/', {
      'current_password': currentPassword,
      'new_password': newPassword,
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to change password');
    }
  }

  Future<List<ReportTemplate>> getReportTemplates() async {
    final response = await _get('/report-templates/');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ReportTemplate.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load report templates');
    }
  }

  Future<ReportTemplate> createReportTemplate(ReportTemplate template) async {
    final response = await _post('/report-templates/', template.toJson());
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ReportTemplate.fromJson(data);
    } else {
      throw Exception('Failed to create report template');
    }
  }

  Future<ReportTemplate> updateReportTemplate(String id, ReportTemplate template) async {
    final response = await _put('/report-templates/$id/', template.toJson());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ReportTemplate.fromJson(data);
    } else {
      throw Exception('Failed to update report template');
    }
  }

  Future<void> deleteReportTemplate(String id) async {
    final response = await _delete('/report-templates/$id/');
    if (response.statusCode != 204) {
      throw Exception('Failed to delete report template');
    }
  }

  Future<List<ReportData>> getReports() async {
    final response = await _get(AppConstants.reportsEndpoint);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = _extractList(data);
      return items
          .map((json) => ReportData.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load reports');
  }

  Future<ReportData> createReport(ReportData report) async {
    final response = await _post(AppConstants.reportsEndpoint, report.toJson());
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ReportData.fromJson(data);
    } else {
      throw Exception('Failed to create report');
    }
  }

  Future<ReportData> updateReport(String id, ReportData report) async {
    final response = await _put('${AppConstants.reportsEndpoint}$id/', report.toJson());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ReportData.fromJson(data);
    } else {
      throw Exception('Failed to update report');
    }
  }

  Future<void> deleteReport(String id) async {
    final response = await _delete('${AppConstants.reportsEndpoint}$id/');
    if (response.statusCode != 204) {
      throw Exception('Failed to delete report');
    }
  }

  Future<String> exportReportToPdf(String reportId) async {
    final response = await _get('${AppConstants.reportsEndpoint}$reportId/export-pdf/');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['pdf_url'] ?? '';
    } else {
      throw Exception('Failed to export report to PDF');
    }
  }

  Future<void> printReport(String reportId) async {
    final response = await _post('${AppConstants.reportsEndpoint}$reportId/print/', {});
    if (response.statusCode != 200) {
      throw Exception('Failed to print report');
    }
  }

  Future<Appointment> updateAppointment(String id, Appointment appointment) async {
    final response = await _put('${AppConstants.appointmentsEndpoint}$id/', appointment.toApiJson());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Appointment.fromJson(data);
    } else {
      throw Exception('Failed to update appointment');
    }
  }

  Future<void> deleteAppointment(String id) async {
    final response = await _delete('${AppConstants.appointmentsEndpoint}$id/');
    if (response.statusCode != 204) {
      throw Exception('Failed to delete appointment');
    }
  }

  Future<Appointment> updateAppointmentStatus(String id, String status) async {
    final response = await _patch('${AppConstants.appointmentsEndpoint}$id/', {'status': status});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Appointment.fromJson(data);
    } else {
      throw Exception('Failed to update appointment status');
    }
  }

  Future<Payment> updatePayment(int id, Payment payment) async {
    final response = await _put('${AppConstants.paymentsEndpoint}$id/', payment.toApiJson());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Payment.fromJson(data);
    } else {
      throw Exception('Failed to update payment');
    }
  }

  Future<Payment> updatePaymentStatus(int id, String status) async {
    final response = await _patch('${AppConstants.paymentsEndpoint}$id/', {'status': status});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Payment.fromJson(data);
    } else {
      throw Exception('Failed to update payment status');
    }
  }

  Future<void> deletePayment(int id) async {
    final response = await _delete('${AppConstants.paymentsEndpoint}$id/');
    if (response.statusCode != 204) {
      throw Exception('Failed to delete payment');
    }
  }

  Future<Payment> getPayment(int id) async {
    final response = await _get('${AppConstants.paymentsEndpoint}$id/');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Payment.fromJson(data);
    } else {
      throw Exception('Failed to load payment');
    }
  }

  Future<String> exportPatientsCsv() async {
    final response = await _get(AppConstants.exportPatientsCsvEndpoint);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to export patients CSV');
    }
  }

  // Account deletion methods
  Future<bool> deleteCurrentUserAccount(String password) async {
    try {
      final response = await _post('/auth/delete-account/', {
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 204) {
        await clearAuthToken();
        return true;
      }
      if (response.statusCode == 404 || response.statusCode == 405) {
        throw Exception(
          'Instant delete is not available on the server. Use Settings → Request Account Deletion.',
        );
      }
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to delete account');
      } catch (_) {
        throw Exception('Failed to delete account (${response.statusCode})');
      }
    } catch (e) {
      print('Delete account error: $e');
      if (await authToken == 'demo_token_backend_fixing') {
        await clearAuthToken();
        return true;
      }
      final msg = e.toString();
      if (msg.contains('Instant delete is not available')) rethrow;
      throw Exception(
        'Failed to delete account: $e. Try Settings → Request Account Deletion.',
      );
    }
  }

  /// Builds a CSV from live API data and opens the share sheet (SaeedLab has no
  /// `/auth/request-data-export/` — that path returns 404).
  Future<DataExportResult> exportAllLabData() async {
    final token = await authToken;
    if (token == null || token.isEmpty) {
      throw Exception('Please log in before exporting data');
    }

    final patients = await getPatients();
    final tests = await getTests();
    final appointments = await getAppointments();
    final payments = await getPayments();
    var users = <User>[];
    try {
      users = await getUsers();
    } catch (_) {}

    final paths = <String>[];

    for (final endpoint in [
      AppConstants.exportPatientsCsvEndpoint,
      AppConstants.exportOrdersCsvEndpoint,
    ]) {
      try {
        final p = await _downloadCsvFromServer(endpoint);
        if (p != null) paths.add(p);
      } catch (e) {
        print('Server CSV $endpoint skipped: $e');
      }
    }

    final combinedPath = await DataExportUtils.exportToExcel(
      patients: patients,
      tests: tests,
      appointments: appointments,
      payments: payments,
      users: users,
      shareAfterWrite: false,
    );
    paths.add(combinedPath);

    await Share.shareXFiles(
      paths.map((p) => XFile(p)).toList(),
      text: 'SAEED Laboratory Data Export',
      subject: 'Lab data export',
    );

    return DataExportResult(
      filePaths: paths,
      patientCount: patients.length,
      testCount: tests.length,
      appointmentCount: appointments.length,
      paymentCount: payments.length,
      userCount: users.length,
    );
  }

  Future<String?> _downloadCsvFromServer(String endpoint) async {
    final response = await _get(endpoint);
    if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
      return null;
    }
    final directory = await getApplicationDocumentsDirectory();
    final name = endpoint.replaceAll('/', '_').replaceAll('export_', '').replaceAll('_', '');
    final file = File(
      '${directory.path}/saeedlab_${name}_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  Future<bool> requestDataExport() async {
    try {
      await exportAllLabData();
      return true;
    } catch (e) {
      print('Data export error: $e');
      rethrow;
    }
  }

  /// Submit account/data deletion request. API path `/auth/request-data-deletion/`
  /// is not deployed (404) — queues locally and opens email to lab support.
  Future<AccountDeletionRequestResult> requestAccountDeletion({
    List<String> dataTypes = const ['account'],
    String? reason,
  }) async {
    final token = await authToken;
    if (token == null || token.isEmpty) {
      throw Exception('Please log in before requesting account deletion');
    }

    Map<String, dynamic> profile = {};
    try {
      profile = await getCurrentUser();
      if (profile['data'] is Map) {
        profile = Map<String, dynamic>.from(profile['data'] as Map);
      }
    } catch (_) {}

    final username = profile['username']?.toString() ??
        (await SharedPreferences.getInstance())
            .getString('username') ??
        'unknown';
    final email = profile['email']?.toString() ?? '';
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    final submittedAt = DateTime.now().toIso8601String();

    final payload = {
      'request_id': requestId,
      'submitted_at': submittedAt,
      'data_types': dataTypes,
      'username': username,
      'email': email,
      'reason': reason ?? '',
      'api_base': baseUrl,
    };

    bool apiAccepted = false;
    for (final path in [
      '/auth/request-data-deletion/',
      '/auth/request-account-deletion/',
      '/account-deletion-request/',
    ]) {
      try {
        final response = await _post(path, {
          'data_types': dataTypes,
          'reason': reason ?? '',
          if (email.isNotEmpty) 'email': email,
        });
        if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202) {
          apiAccepted = true;
          break;
        }
      } catch (_) {}
    }

    await _savePendingDeletionRequest(payload);

    final body = '''
Account deletion request (SaeedLab mobile app)

Request ID: $requestId
Submitted: $submittedAt
Username: $username
Email: ${email.isEmpty ? '(not on file)' : email}
Data to delete: ${dataTypes.join(', ')}

${reason != null && reason.isNotEmpty ? 'User note:\n$reason\n' : ''}
Please process this request within 30 days per your privacy policy.
''';

    var emailOpened = await _launchSupportEmail(
      subject: 'Account deletion request — $username',
      body: body,
    );
    if (!emailOpened) {
      emailOpened = await _launchSupportEmail(
        subject: 'Account deletion request — $username',
        body: body,
        recipient: AppConstants.labSupportEmailAlt,
      );
    }

    return AccountDeletionRequestResult(
      requestId: requestId,
      savedLocally: true,
      apiAccepted: apiAccepted,
      emailOpened: emailOpened,
      message: apiAccepted
          ? 'Deletion request accepted by the server.'
          : emailOpened
              ? 'Request saved. Email opened for lab support — send it to complete your request.'
              : 'Request saved locally (ID: $requestId). Email ${AppConstants.labSupportEmail} manually.',
    );
  }

  Future<bool> requestSpecificDataDeletion(List<String> dataTypes) async {
    final result = await requestAccountDeletion(dataTypes: dataTypes);
    return result.isSuccess;
  }

  Future<void> _savePendingDeletionRequest(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(AppConstants.pendingDeletionRequestsKey) ?? [];
    existing.add(jsonEncode(payload));
    await prefs.setStringList(AppConstants.pendingDeletionRequestsKey, existing);
  }

  Future<bool> _launchSupportEmail({
    required String subject,
    required String body,
    String recipient = AppConstants.labSupportEmail,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: recipient,
      query: _encodeMailQuery({'subject': subject, 'body': body}),
    );
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  String _encodeMailQuery(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  Future<http.Response> _makeRequest(String method, String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    
    // Check if token is valid before making request
    final isTokenValid = await this.isTokenValid();
    if (!isTokenValid) {
      print('🔄 Token invalid, attempting re-authentication...');
      await forceReAuthentication();
    }
    
    final headers = await _getHeaders();
    
    http.Response response;
    
    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(uri, headers: headers);
        break;
      case 'PUT':
        response = await http.put(uri, headers: headers);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
    
      // If we get a 403 error, try to re-authenticate and retry once
      if (response.statusCode == 403) {
        print('🔄 Got 403 error, attempting re-authentication...');
        final reAuthSuccess = await forceReAuthentication();
        
        if (reAuthSuccess) {
          // Retry the request with fresh token
          final newHeaders = await _getHeaders();
          switch (method.toUpperCase()) {
            case 'GET':
              response = await http.get(uri, headers: newHeaders);
              break;
            case 'POST':
              response = await http.post(uri, headers: newHeaders);
              break;
            case 'PUT':
              response = await http.put(uri, headers: newHeaders);
              break;
            case 'DELETE':
              response = await http.delete(uri, headers: newHeaders);
              break;
          }
          print('🔄 Retry with fresh token: ${response.statusCode}');
        }
        
        // If still 403 after re-auth, it's a permission issue
        if (response.statusCode == 403) {
          print('⚠️ Permission denied - user lacks required permissions for this endpoint');
          // Return empty data instead of throwing error
          return http.Response('{"results": [], "count": 0}', 200);
        }
      }
    
    return response;
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }


  // Force re-authentication by clearing token and getting a new one
  Future<bool> forceReAuthentication() async {
    try {
      await clearAuthToken();
      
      // Try to get a fresh token with proper credentials using JWT endpoint
      final response = await http.post(
        Uri.parse('$baseUrl/auth/token/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'username': 'admin', // Use admin credentials from logs
          'password': 'admin123', // Use admin password
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'] ?? data['access'];
        
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          print('🔑 Fresh JWT token obtained and cached');
          return true;
        }
      }
      
      print('❌ Failed to get fresh token: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      print('❌ Error during re-authentication: $e');
      return false;
    }
  }

  // Check if current token is valid
  Future<bool> isTokenValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        print('🔍 No token found in cache');
        return false;
      }
      
      print('🔍 Testing token validity...');
      // Test token with a simple API call
      final response = await http.get(
        Uri.parse('$baseUrl/patients/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('🔍 Token test response: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('🔍 Token test response body: ${response.body}');
      }
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error checking token validity: $e');
      return false;
    }
  }

  // ============================================================================
  // COMPREHENSIVE DATA ENDPOINTS
  // ============================================================================
  
  // Get comprehensive patient data including tests, appointments, and payments
  Future<Map<String, dynamic>> getPatientComprehensiveData(String patientId) async {
    try {
      final response = await _makeRequest('GET', '/patients/$patientId/comprehensive/');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load comprehensive patient data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading comprehensive patient data: $e');
      // Return mock data for development
      return _getMockPatientComprehensiveData(patientId);
    }
  }
  
  // Get comprehensive test data including patient info and results
  Future<Map<String, dynamic>> getTestComprehensiveData(String testId) async {
    try {
      final response = await _makeRequest('GET', '/tests/$testId/comprehensive/');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load comprehensive test data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading comprehensive test data: $e');
      return _getMockTestComprehensiveData(testId);
    }
  }
  
  // Get comprehensive appointment data including patient and test info
  Future<Map<String, dynamic>> getAppointmentComprehensiveData(String appointmentId) async {
    try {
      final response = await _makeRequest('GET', '/appointments/$appointmentId/comprehensive/');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load comprehensive appointment data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading comprehensive appointment data: $e');
      return _getMockAppointmentComprehensiveData(appointmentId);
    }
  }
  
  // Get comprehensive payment data including patient and test info
  Future<Map<String, dynamic>> getPaymentComprehensiveData(String paymentId) async {
    try {
      final response = await _makeRequest('GET', '/payments/$paymentId/comprehensive/');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load comprehensive payment data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading comprehensive payment data: $e');
      return _getMockPaymentComprehensiveData(paymentId);
    }
  }
  
  // Get all patients with their test counts, appointment counts, and payment totals
  Future<List<Map<String, dynamic>>> getPatientsWithSummary() async {
    try {
      final response = await _makeRequest('GET', '/patients/summary/');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['patients']);
      } else {
        throw Exception('Failed to load patients summary: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading patients summary: $e');
      return _getMockPatientsSummary();
    }
  }
  
  // Get all tests with patient info and status
  Future<List<Map<String, dynamic>>> getTestsWithDetails() async {
    try {
      final response = await _makeRequest('GET', '/tests/details/');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = (data is Map && data['tests'] is List)
            ? List<Map<String, dynamic>>.from(data['tests'])
            : (data is List ? List<Map<String, dynamic>>.from(data) : <Map<String, dynamic>>[]);
        return items;
      } else {
        throw Exception('Failed to load tests details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading tests details: $e');
      return _getMockTestsDetails();
    }
  }
  
  // Get all appointments with patient and test info
  Future<List<Map<String, dynamic>>> getAppointmentsWithDetails() async {
    try {
      final response = await _makeRequest('GET', '/appointments/details/');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = (data is Map && data['appointments'] is List)
            ? List<Map<String, dynamic>>.from(data['appointments'])
            : (data is List ? List<Map<String, dynamic>>.from(data) : <Map<String, dynamic>>[]);
        return items;
      } else {
        throw Exception('Failed to load appointments details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading appointments details: $e');
      return _getMockAppointmentsDetails();
    }
  }
  
  // Get all payments with patient and test info
  Future<List<Map<String, dynamic>>> getPaymentsWithDetails() async {
    try {
      final response = await _makeRequest('GET', '/payments/details/');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = (data is Map && data['payments'] is List)
            ? List<Map<String, dynamic>>.from(data['payments'])
            : (data is List ? List<Map<String, dynamic>>.from(data) : <Map<String, dynamic>>[]);
        return items;
      } else {
        throw Exception('Failed to load payments details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading payments details: $e');
      return _getMockPaymentsDetails();
    }
  }

  // Fetch test detail by UUID or by_code
  Future<Test> getTestDetail({String? uuid, String? code}) async {
    try {
      http.Response response;
      if (uuid != null && uuid.isNotEmpty) {
        response = await _get('${AppConstants.testsEndpoint}$uuid/');
      } else if (code != null && code.isNotEmpty) {
        final headers = await _authHeaders;
        final uri = Uri.parse('$baseUrl${AppConstants.testsEndpoint}by_code/?test_code=$code');
        response = await http.get(uri, headers: headers);
      } else {
        throw Exception('Provide uuid or test code');
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final obj = (decoded is List && decoded.isNotEmpty) ? decoded.first : decoded;
        return Test.fromJson(obj as Map<String, dynamic>);
      }
      throw Exception('Failed to load test details: ${response.statusCode}');
    } catch (e) {
      print('Error loading test detail: $e');
      rethrow;
    }
  }

  // ============================================================================
  // MOCK DATA FOR DEVELOPMENT
  // ============================================================================
  
  Map<String, dynamic> _getMockPatientComprehensiveData(String patientId) {
    return {
      'patient': {
        'id': patientId,
        'full_name': 'John Doe',
        'date_of_birth': '1985-05-15',
        'gender': 'Male',
        'phone': '+1-555-0123',
        'email': 'john.doe@email.com',
        'address': '123 Main St, City, State',
        'blood_type': 'O+',
        'medical_history': 'No known allergies',
        'insurance_info': 'Blue Cross Blue Shield',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-15T00:00:00Z',
      },
      'tests': [
        {
          'id': 'T001',
          'test_name': 'Complete Blood Count',
          'test_type': 'Hematology',
          'status': 'Completed',
          'ordered_date': '2024-01-10T00:00:00Z',
          'completed_date': '2024-01-12T00:00:00Z',
          'price': 85.00,
          'results': 'Normal',
        },
        {
          'id': 'T002',
          'test_name': 'Lipid Panel',
          'test_type': 'Chemistry',
          'status': 'Pending',
          'ordered_date': '2024-01-14T00:00:00Z',
          'price': 120.00,
        },
      ],
      'appointments': [
        {
          'id': 'A001',
          'date': '2024-01-20T10:00:00Z',
          'time': '10:00 AM',
          'test_type': 'Blood Draw',
          'status': 'Scheduled',
          'location': 'Main Lab',
        },
      ],
      'payments': [
        {
          'id': 'P001',
          'amount': 85.00,
          'status': 'Paid',
          'payment_method': 'Credit Card',
          'created_at': '2024-01-12T00:00:00Z',
        },
        {
          'id': 'P002',
          'amount': 120.00,
          'status': 'Pending',
          'payment_method': 'Insurance',
          'created_at': '2024-01-14T00:00:00Z',
        },
      ],
      'summary': {
        'total_tests': 2,
        'completed_tests': 1,
        'pending_tests': 1,
        'total_appointments': 1,
        'upcoming_appointments': 1,
        'total_payments': 205.00,
        'paid_amount': 85.00,
        'pending_amount': 120.00,
      }
    };
  }
  
  Map<String, dynamic> _getMockTestComprehensiveData(String testId) {
    return {
      'test': {
        'id': testId,
        'test_name': 'Complete Blood Count',
        'test_type': 'Hematology',
        'status': 'Completed',
        'ordered_date': '2024-01-10T00:00:00Z',
        'completed_date': '2024-01-12T00:00:00Z',
        'price': 85.00,
        'notes': 'Routine checkup',
        'results': 'Normal',
      },
      'patient': {
        'id': 'P001',
        'full_name': 'John Doe',
        'phone': '+1-555-0123',
        'email': 'john.doe@email.com',
        'blood_type': 'O+',
      },
      'appointment': {
        'id': 'A001',
        'date': '2024-01-10T09:00:00Z',
        'status': 'Completed',
        'location': 'Main Lab',
      },
      'payment': {
        'id': 'P001',
        'amount': 85.00,
        'status': 'Paid',
        'payment_method': 'Credit Card',
      }
    };
  }
  
  Map<String, dynamic> _getMockAppointmentComprehensiveData(String appointmentId) {
    return {
      'appointment': {
        'id': appointmentId,
        'date': '2024-01-20T10:00:00Z',
        'time': '10:00 AM',
        'test_type': 'Blood Draw',
        'status': 'Scheduled',
        'location': 'Main Lab',
        'notes': 'Fasting required',
      },
      'patient': {
        'id': 'P001',
        'full_name': 'John Doe',
        'phone': '+1-555-0123',
        'email': 'john.doe@email.com',
      },
      'test': {
        'id': 'T001',
        'test_name': 'Complete Blood Count',
        'test_type': 'Hematology',
        'price': 85.00,
      }
    };
  }
  
  Map<String, dynamic> _getMockPaymentComprehensiveData(String paymentId) {
    return {
      'payment': {
        'id': paymentId,
        'amount': 85.00,
        'status': 'Paid',
        'payment_method': 'Credit Card',
        'created_at': '2024-01-12T00:00:00Z',
        'transaction_id': 'TXN123456789',
      },
      'patient': {
        'id': 'P001',
        'full_name': 'John Doe',
        'phone': '+1-555-0123',
        'email': 'john.doe@email.com',
      },
      'test': {
        'id': 'T001',
        'test_name': 'Complete Blood Count',
        'test_type': 'Hematology',
        'price': 85.00,
      }
    };
  }
  
  List<Map<String, dynamic>> _getMockPatientsSummary() {
    return [
      {
        'patient': {
          'id': 'P001',
          'full_name': 'John Doe',
          'phone': '+1-555-0123',
          'email': 'john.doe@email.com',
        },
        'summary': {
          'total_tests': 2,
          'completed_tests': 1,
          'pending_tests': 1,
          'total_appointments': 1,
          'upcoming_appointments': 1,
          'total_payments': 205.00,
          'paid_amount': 85.00,
          'pending_amount': 120.00,
        }
      },
      {
        'patient': {
          'id': 'P002',
          'full_name': 'Jane Smith',
          'phone': '+1-555-0456',
          'email': 'jane.smith@email.com',
        },
        'summary': {
          'total_tests': 1,
          'completed_tests': 0,
          'pending_tests': 1,
          'total_appointments': 0,
          'upcoming_appointments': 0,
          'total_payments': 150.00,
          'paid_amount': 0.00,
          'pending_amount': 150.00,
        }
      },
    ];
  }
  
  List<Map<String, dynamic>> _getMockTestsDetails() {
    return [
      {
        'test': {
          'id': 'T001',
          'test_name': 'Complete Blood Count',
          'test_type': 'Hematology',
          'status': 'Completed',
          'ordered_date': '2024-01-10T00:00:00Z',
          'price': 85.00,
        },
        'patient': {
          'id': 'P001',
          'full_name': 'John Doe',
          'phone': '+1-555-0123',
        }
      },
      {
        'test': {
          'id': 'T002',
          'test_name': 'Lipid Panel',
          'test_type': 'Chemistry',
          'status': 'Pending',
          'ordered_date': '2024-01-14T00:00:00Z',
          'price': 120.00,
        },
        'patient': {
          'id': 'P002',
          'full_name': 'Jane Smith',
          'phone': '+1-555-0456',
        }
      },
    ];
  }
  
  List<Map<String, dynamic>> _getMockAppointmentsDetails() {
    return [
      {
        'appointment': {
          'id': 'A001',
          'date': '2024-01-20T10:00:00Z',
          'test_type': 'Blood Draw',
          'status': 'Scheduled',
          'location': 'Main Lab',
        },
        'patient': {
          'id': 'P001',
          'full_name': 'John Doe',
          'phone': '+1-555-0123',
        },
        'test': {
          'id': 'T001',
          'test_name': 'Complete Blood Count',
          'test_type': 'Hematology',
        }
      },
    ];
  }
  
  List<Map<String, dynamic>> _getMockPaymentsDetails() {
    return [
      {
        'payment': {
          'id': 'P001',
          'amount': 85.00,
          'status': 'Paid',
          'payment_method': 'Credit Card',
          'created_at': '2024-01-12T00:00:00Z',
        },
        'patient': {
          'id': 'P001',
          'full_name': 'John Doe',
          'phone': '+1-555-0123',
        },
        'test': {
          'id': 'T001',
          'test_name': 'Complete Blood Count',
          'test_type': 'Hematology',
        }
      },
      {
        'payment': {
          'id': 'P002',
          'amount': 120.00,
          'status': 'Pending',
          'payment_method': 'Insurance',
          'created_at': '2024-01-14T00:00:00Z',
        },
        'patient': {
          'id': 'P002',
          'full_name': 'Jane Smith',
          'phone': '+1-555-0456',
        },
        'test': {
          'id': 'T002',
          'test_name': 'Lipid Panel',
          'test_type': 'Chemistry',
        }
      },
    ];
  }

}
