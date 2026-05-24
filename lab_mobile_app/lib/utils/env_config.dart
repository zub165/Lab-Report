/// Reads secrets from `--dart-define` (optional). Local `.env` is not bundled in the app.
///
/// Run with values from `.env`, e.g.:
/// ```bash
/// ./scripts/run_with_env.sh
/// # or: flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_...
/// ```
class EnvConfig {
  EnvConfig._();

  static String get labApiBaseUrl => const String.fromEnvironment(
        'LAB_API_BASE_URL',
        defaultValue: 'https://api.mywaitime.com/lab',
      );

  /// Backup Lab API when primary DNS/host fails (VPS IP or local emulator).
  static String get labApiBaseBackup => const String.fromEnvironment(
        'LAB_API_BASE_BACKUP',
        defaultValue: 'http://208.109.215.53:3015/lab',
      );

  static String get labAdminUsername => const String.fromEnvironment(
        'LAB_ADMIN_USERNAME',
        defaultValue: 'admin',
      );

  static String get labAdminPassword => const String.fromEnvironment(
        'LAB_ADMIN_PASSWORD',
        defaultValue: 'admin123',
      );

  static int get labAdminUserId => int.tryParse(
            const String.fromEnvironment('LAB_ADMIN_USER_ID', defaultValue: '1'),
          ) ??
          1;

  static String get labDemoDoctorUsername => const String.fromEnvironment(
        'LAB_DEMO_DOCTOR_USERNAME',
        defaultValue: 'labdoctor',
      );

  static String get labDemoDoctorPassword => const String.fromEnvironment(
        'LAB_DEMO_DOCTOR_PASSWORD',
        defaultValue: 'labdoctor123',
      );

  static String get staffDefaultPassword => const String.fromEnvironment(
        'LAB_STAFF_DEFAULT_PASSWORD',
        defaultValue: 'Staff@2026',
      );

  /// Stripe publishable key only (`pk_test_…` / `pk_live_…`). Never put secret `sk_` here.
  /// Set in `lab_mobile_app/.env` as STRIPE_PUBLISHABLE_KEY=… and run `./scripts/run_with_env.sh`,
  /// or override in Settings → API Connection (saved on device).
  static String get stripePublishableKey => const String.fromEnvironment(
        'STRIPE_PUBLISHABLE_KEY',
        defaultValue: '',
      );

  static String get stripePublishableKeyBackup => const String.fromEnvironment(
        'STRIPE_PUBLISHABLE_KEY_BACKUP',
        defaultValue: '',
      );

  /// IAP SKU — App Store Connect + Google Play Console product ID.
  static String get labSubscriptionProductId => const String.fromEnvironment(
        'LAB_SUBSCRIPTION_PRODUCT_ID',
        defaultValue: 'com.mywaitime.lab.monthly',
      );
}
