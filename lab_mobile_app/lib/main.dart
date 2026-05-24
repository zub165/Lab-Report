import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_provider.dart';
import 'providers/patient_provider.dart';
import 'providers/test_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/user_provider.dart';
import 'providers/report_provider.dart';
import 'services/simple_hybrid_storage_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/terms_screen.dart';
import 'services/django_api_service.dart';
import 'services/store_subscription_service.dart';
import 'utils/constants.dart';
import 'utils/lab_currency.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize shared preferences
  await SharedPreferences.getInstance();

  // Same API/database as https://zub165.github.io/SaeedLab/
  await LabApiConfig.initialize();
  await LabCurrency.loadFromApi();
  await DjangoApiService.applyStripePublishableToSdk();

  // Initialize hybrid storage service
  await SimpleHybridStorageService().initialize();

  await StoreSubscriptionService.instance.initialize();

  runApp(const LabManagementApp());
}

class LabManagementApp extends StatelessWidget {
  const LabManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth first: splash/login and other providers assume token/session context exists early.
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => TestProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return Directionality(
            textDirection: languageProvider.textDirection,
            child: MaterialApp(
            title: 'SAEED Laboratory',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            locale: languageProvider.locale,
            home: const SplashScreen(),
            navigatorKey: AppConstants.navigatorKey,
            navigatorObservers: [AppConstants.routeObserver],
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/privacy': (context) => const PrivacyPolicyScreen(),
              '/terms': (context) => const TermsScreen(),
            },
            onGenerateRoute: (settings) {
              // Handle any missing routes
              switch (settings.name) {
                case '/home':
                  return MaterialPageRoute(builder: (context) => const HomeScreen());
                case '/login':
                  return MaterialPageRoute(builder: (context) => const LoginScreen());
                default:
                  return MaterialPageRoute(builder: (context) => const SplashScreen());
              }
            },
          ),
          );
        },
      ),
    );
  }
}
