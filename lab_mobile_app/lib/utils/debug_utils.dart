import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import '../services/django_api_service.dart';
import '../services/apple_api_service.dart';
import '../services/google_play_api_service.dart';

class DebugUtils {
  static Future<void> testBackendConnection() async {
    print('🔍 Testing SaeedLab API (${LabApiConfig.resolvedBaseUrl})...');
    try {
      final api = DjangoApiService();
      final healthy = await api.testBackendConnection();
      print('   Health: ${healthy ? "OK" : "FAILED"}');
      print('   Web app: ${LabApiConfig.saeedLabWebUrl}');
    } catch (e) {
      print('❌ Error testing backend: $e');
    }
  }
  
  static Future<void> checkLocalStorage() async {
    print('🔍 Checking Local Storage...');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      final userData = prefs.getString(AppConstants.userKey);
      
      print('   Token: ${token != null ? '${token.substring(0, 20)}...' : 'null'}');
      print('   User Data: ${userData ?? 'null'}');
      
    } catch (e) {
      print('❌ Error checking local storage: $e');
    }
  }
  
  static Future<void> clearLocalStorage() async {
    print('🧹 Clearing Local Storage...');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('   Local storage cleared successfully');
      
    } catch (e) {
      print('❌ Error clearing local storage: $e');
    }
  }
  
  static void printApiEndpoints() {
    print('🔍 Available API Endpoints:');
    print('   Base URL: ${AppConstants.baseUrl}');
    print('   Login: ${AppConstants.loginEndpoint}');
    print('   Patients: ${AppConstants.patientsEndpoint}');
    print('   Tests: ${AppConstants.testsEndpoint}');
    print('   Appointments: ${AppConstants.appointmentsEndpoint}');
    print('   Payments: ${AppConstants.paymentsEndpoint}');
  }

  static Future<void> testSettingsFunctionality() async {
    print('🔍 Testing Settings Functionality...');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Test 1: Check if settings exist
      final settingsJson = prefs.getString('lab_settings');
      print('1. Settings exist: ${settingsJson != null}');
      
      if (settingsJson != null) {
        final settings = jsonDecode(settingsJson);
        print('   Lab Name: ${settings['lab_name']}');
        print('   Doctors Count: ${(settings['doctors'] as List).length}');
        print('   Technicians Count: ${(settings['technicians'] as List).length}');
      }
      
      // Test 2: Create test settings
      print('2. Creating test settings...');
      final testSettings = {
        'lab_name': 'Test Laboratory',
        'address': 'Test Address',
        'contact_number': 'Test Contact',
        'email': 'test@lab.com',
        'website': 'test.com',
        'license_number': 'TEST-001',
        'doctors': [
          {
            'id': 999,
            'name': 'Test Doctor',
            'specialization': 'Test Specialization',
            'license_number': 'TEST-MD-001',
            'contact_number': 'Test Contact',
            'email': 'test@doctor.com',
            'is_active': true,
          }
        ],
        'technicians': [
          {
            'id': 999,
            'name': 'Test Technician',
            'specialization': 'Test Tech',
            'employee_id': 'TEST-TECH-001',
            'contact_number': 'Test Contact',
            'email': 'test@tech.com',
            'is_active': true,
          }
        ],
        'additional_settings': {},
      };
      
      await prefs.setString('lab_settings', jsonEncode(testSettings));
      print('   Test settings saved successfully');
      
      // Test 3: Verify settings were saved
      final savedSettingsJson = prefs.getString('lab_settings');
      if (savedSettingsJson != null) {
        final savedSettings = jsonDecode(savedSettingsJson);
        print('3. Verification: ${savedSettings['lab_name'] == 'Test Laboratory'}');
        print('   Lab Name: ${savedSettings['lab_name']}');
        print('   Doctors: ${(savedSettings['doctors'] as List).length}');
        print('   Technicians: ${(savedSettings['technicians'] as List).length}');
      }
      
    } catch (e) {
      print('❌ Error testing settings: $e');
    }
  }

  static Future<void> testAllBackendEndpoints() async {
    print('🔍 Testing All Backend API Endpoints...');
    print('Base URL: ${AppConstants.baseUrl}');
    
    final endpoints = [
      {'name': 'Health Check', 'endpoint': '/health', 'method': 'GET'},
      {'name': 'Login', 'endpoint': AppConstants.loginEndpoint, 'method': 'POST'},
      {'name': 'Patients', 'endpoint': AppConstants.patientsEndpoint, 'method': 'GET'},
      {'name': 'Tests', 'endpoint': AppConstants.testsEndpoint, 'method': 'GET'},
      {'name': 'Appointments', 'endpoint': AppConstants.appointmentsEndpoint, 'method': 'GET'},
      {'name': 'Payments', 'endpoint': AppConstants.paymentsEndpoint, 'method': 'GET'},
      {'name': 'Reports', 'endpoint': AppConstants.reportsEndpoint, 'method': 'GET'},
      {'name': 'Stats', 'endpoint': AppConstants.analyticsEndpoint, 'method': 'GET'},
      {'name': 'System Status', 'endpoint': AppConstants.systemStatusEndpoint, 'method': 'GET'},
      {'name': 'Settings', 'endpoint': AppConstants.settingsEndpoint, 'method': 'GET'},
      {'name': 'Data Patients', 'endpoint': AppConstants.dataPatientsEndpoint, 'method': 'GET'},
      {'name': 'Data Tests', 'endpoint': AppConstants.dataTestsEndpoint, 'method': 'GET'},
      {'name': 'Data Appointments', 'endpoint': AppConstants.dataAppointmentsEndpoint, 'method': 'GET'},
      {'name': 'Data Payments', 'endpoint': AppConstants.dataPaymentsEndpoint, 'method': 'GET'},
      {'name': 'Data Research', 'endpoint': AppConstants.dataResearchEndpoint, 'method': 'GET'},
    ];

    for (final endpoint in endpoints) {
      try {
        print('\n📡 Testing ${endpoint['name']} (${endpoint['method']} ${endpoint['endpoint']})');
        
        if (endpoint['method'] == 'GET') {
          final response = await http.get(
            Uri.parse('${AppConstants.baseUrl}${endpoint['endpoint']}'),
            headers: {'Content-Type': 'application/json'},
          );
          print('   Status: ${response.statusCode}');
          print('   Response: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
        } else if (endpoint['method'] == 'POST' && endpoint['name'] == 'Login') {
          final response = await http.post(
            Uri.parse('${AppConstants.baseUrl}${endpoint['endpoint']}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': 'saied_admin',
              'password': 'saied123',
            }),
          );
          print('   Status: ${response.statusCode}');
          print('   Response: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
        }
      } catch (e) {
        print('   ❌ Error: $e');
      }
    }
  }

  static Future<void> testAuthenticationFlow() async {
    print('🔐 Testing Authentication Flow...');
    
    try {
      final apiService = DjangoApiService();
      
      // Test 1: Try to login
      print('1. Testing login...');
      final loginResult = await apiService.login('saied_admin', 'saied123');
      print('   Login successful: ${loginResult.containsKey('access_token')}');
      
      if (loginResult.containsKey('access_token')) {
        print('   Token: ${loginResult['access_token']?.toString().substring(0, 20)}...');
        
        // Test 2: Try to get patients with auth
        print('2. Testing authenticated request...');
        try {
          final patients = await apiService.getPatients();
          print('   Patients loaded: ${patients.length}');
        } catch (e) {
          print('   ❌ Failed to load patients: $e');
        }
        
        // Test 3: Try to get tests with auth
        print('3. Testing tests endpoint...');
        try {
          final tests = await apiService.getTests();
          print('   Tests loaded: ${tests.length}');
        } catch (e) {
          print('   ❌ Failed to load tests: $e');
        }
      }
      
    } catch (e) {
      print('❌ Authentication test failed: $e');
    }
  }

  static Future<void> testAppleApiConnection() async {
    print('🍎 Testing Apple App Store Connect API...');
    
    try {
      final appleApi = AppleApiService();
      
      // Test connection
      print('1. Testing connection...');
      final isConnected = await appleApi.testConnection();
      print('   Connection status: $isConnected');
      
      if (isConnected) {
        // Test getting apps
        print('2. Testing get apps...');
        final apps = await appleApi.getApps();
        print('   Apps count: ${apps.length}');
        
        if (apps.isNotEmpty) {
          print('   First app: ${apps.first}');
        }
      }
      
    } catch (e) {
      print('❌ Error testing Apple API: $e');
    }
  }

  static Future<void> testGooglePlayApiConnection() async {
    print('🤖 Testing Google Play Console API...');
    
    try {
      final googleApi = GooglePlayApiService();
      
      // Test connection
      print('1. Testing connection...');
      final isConnected = await googleApi.testConnection();
      print('   Connection status: $isConnected');
      
      if (isConnected) {
        // Test getting applications
        print('2. Testing get applications...');
        final applications = await googleApi.getApplications();
        print('   Applications count: ${applications.length}');
        
        if (applications.isNotEmpty) {
          print('   First application: ${applications.first}');
        }
      }
      
    } catch (e) {
      print('❌ Error testing Google Play API: $e');
    }
  }

  static Future<void> testAllStoreApis() async {
    print('🛍️ Testing All Store APIs...');
    
    print('\n=== Apple App Store Connect API ===');
    await testAppleApiConnection();
    
    print('\n=== Google Play Console API ===');
    await testGooglePlayApiConnection();
    
    print('\n=== Summary ===');
    print('Note: These APIs require proper authentication credentials');
    print('To use them, you need to:');
    print('1. Set up Apple App Store Connect API keys');
    print('2. Set up Google Play Console service account');
    print('3. Update the API services with real credentials');
  }
}
