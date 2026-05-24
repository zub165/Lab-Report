import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/env_config.dart';

/// Lab API only — never mix with Hospital Finder (`https://api.mywaitime.com/api/`).
enum ApiProfile { production, staging, localBackup }

class ApiEnv {
  final String labApiBase;
  final String? stripePublishableKey;
  final String label;

  const ApiEnv({
    required this.labApiBase,
    this.stripePublishableKey,
    required this.label,
  });
}

/// Primary + backup Lab API hosts. All paths are under `/lab/` with JWT.
class ApiEnvConfig {
  ApiEnvConfig._();

  static const String prefsProfileKey = 'lab_api_profile';
  static const String prefsApiOverrideKey = 'saeedlab_api_base';
  static const String prefsUsingBackupKey = 'lab_api_using_backup';

  /// Hospital Finder / ER — public; no Lab JWT. Do not use in [DjangoApiService].
  static const String hospitalFinderApiBase = 'https://api.mywaitime.com/api';

  static const production = ApiEnv(
    label: 'Production',
    labApiBase: 'https://api.mywaitime.com/lab',
    stripePublishableKey: null,
  );

  static const staging = ApiEnv(
    label: 'Staging',
    labApiBase: 'https://api.mywaitime.com/lab',
    stripePublishableKey: null,
  );

  static const localBackup = ApiEnv(
    label: 'Local backup',
    labApiBase: 'http://208.109.215.53:3015/lab',
    stripePublishableKey: null,
  );

  static ApiProfile activeProfile = ApiProfile.production;
  static bool usingBackup = false;
  static String? _customBaseOverride;

  static ApiEnv get current {
    if (usingBackup) return envForProfile(ApiProfile.localBackup);
    return envForProfile(activeProfile);
  }

  static ApiEnv envForProfile(ApiProfile profile) {
    switch (profile) {
      case ApiProfile.staging:
        return staging;
      case ApiProfile.localBackup:
        return localBackup;
      case ApiProfile.production:
        return production;
    }
  }

  /// Normalizes to `…/lab` (no trailing slash). Rejects `/api/` misuse.
  static String normalizeLabBase(String url) {
    var u = url.trim();
    if (u.isEmpty) return production.labApiBase;
    u = u.replaceAll(RegExp(r'/+$'), '');
    final lower = u.toLowerCase();
    if (lower.endsWith('/api') || lower.contains('/api/')) {
      throw ArgumentError(
        'Hospital Finder base ($u) is not the Lab API. Use a URL ending with /lab/',
      );
    }
    if (!lower.endsWith('/lab')) {
      u = '$u/lab';
    }
    return u;
  }

  static String get resolvedLabApiBase {
    if (_customBaseOverride != null && _customBaseOverride!.isNotEmpty) {
      return normalizeLabBase(_customBaseOverride!);
    }
    if (usingBackup) {
      final backup = EnvConfig.labApiBaseBackup.trim();
      if (backup.isNotEmpty) return normalizeLabBase(backup);
      return normalizeLabBase(localBackup.labApiBase);
    }
    final primary = EnvConfig.labApiBaseUrl.trim();
    if (primary.isNotEmpty && activeProfile == ApiProfile.production) {
      return normalizeLabBase(primary);
    }
    return normalizeLabBase(envForProfile(activeProfile).labApiBase);
  }

  static String? get profileStripePublishableKey {
    if (usingBackup) {
      final b = EnvConfig.stripePublishableKeyBackup.trim();
      if (b.isNotEmpty) return b;
    }
    final e = EnvConfig.stripePublishableKey.trim();
    return e.isNotEmpty ? e : null;
  }

  static String get activeProfileLabel {
    if (_customBaseOverride != null && _customBaseOverride!.isNotEmpty) {
      return 'Custom URL';
    }
    if (usingBackup) return '${localBackup.label} (backup)';
    return current.label;
  }

  static Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(prefsProfileKey);
    activeProfile = ApiProfile.values.firstWhere(
      (p) => p.name == stored,
      orElse: () => ApiProfile.production,
    );
    usingBackup = prefs.getBool(prefsUsingBackupKey) ?? false;
    _customBaseOverride = prefs.getString(prefsApiOverrideKey)?.trim();
  }

  static Future<void> saveProfile(ApiProfile profile) async {
    activeProfile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsProfileKey, profile.name);
  }

  static Future<void> setUsingBackup(bool value) async {
    usingBackup = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsUsingBackupKey, value);
  }

  static Future<void> saveCustomBaseUrl(String? url) async {
    final trimmed = url?.trim();
    _customBaseOverride = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    final prefs = await SharedPreferences.getInstance();
    if (_customBaseOverride == null) {
      await prefs.remove(prefsApiOverrideKey);
    } else {
      await prefs.setString(prefsApiOverrideKey, _customBaseOverride!);
    }
  }

  static Future<bool> healthCheck(String base) async {
    try {
      final uri = Uri.parse('${normalizeLabBase(base)}/health/');
      final request = await HttpClient()
          .getUrl(uri)
          .timeout(const Duration(seconds: 12));
      final response = await request.close().timeout(const Duration(seconds: 12));
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) return false;
      final data = jsonDecode(body);
      if (data is Map) {
        final status = data['status']?.toString().toLowerCase();
        return status == 'success' || status == 'ok';
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
