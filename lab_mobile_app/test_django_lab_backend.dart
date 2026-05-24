import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  print('🧪 Testing Django Lab Management Backend Connection');
  print('=' * 60);
  
  const String baseUrl = 'http://208.109.215.53:3015/lab';
  
  // Test 1: Analytics/Health Check
  print('\n1. Testing Analytics/Health Check...');
  await testAnalytics(baseUrl);
  
  // Test 2: Authentication
  print('\n2. Testing Authentication...');
  String? token = await testAuthentication(baseUrl);
  
  // Test 3: Patient Management
  print('\n3. Testing Patient Management...');
  await testPatientManagement(baseUrl, token);
  
  // Test 4: Test Categories
  print('\n4. Testing Test Categories...');
  await testTestCategories(baseUrl, token);
  
  // Test 5: Lab Tests
  print('\n5. Testing Lab Tests...');
  await testLabTests(baseUrl, token);
  
  // Test 6: Test Orders
  print('\n6. Testing Test Orders...');
  await testTestOrders(baseUrl, token);
  
  // Test 7: Appointments
  print('\n7. Testing Appointments...');
  await testAppointments(baseUrl, token);
  
  // Test 8: Payments
  print('\n8. Testing Payments...');
  await testPayments(baseUrl, token);
  
  // Test 9: Reports
  print('\n9. Testing Reports...');
  await testReports(baseUrl, token);
  
  // Test 10: Data Export
  print('\n10. Testing Data Export...');
  await testDataExport(baseUrl, token);
  
  print('\n${'=' * 60}');
  print('🎯 Django Lab Management Backend Test Complete!');
}

Future<void> testAnalytics(String baseUrl) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/analytics/'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      print('✅ Analytics: SUCCESS');
      print('   Status Code: ${response.statusCode}');
      print('   Response: ${response.body}');
    } else {
      print('❌ Analytics: FAILED');
      print('   Status Code: ${response.statusCode}');
      print('   Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Analytics: ERROR');
    print('   Error: $e');
  }
}

Future<String?> testAuthentication(String baseUrl) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': 'admin',
        'password': 'admin123',
      }),
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      print('✅ Authentication: SUCCESS');
      print('   Status Code: ${response.statusCode}');
      final data = jsonDecode(response.body);
      if (data['access_token'] != null) {
        print('   Access Token: ${data['access_token'].substring(0, 20)}...');
        return data['access_token'];
      }
    } else {
      print('❌ Authentication: FAILED');
      print('   Status Code: ${response.statusCode}');
      print('   Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Authentication: ERROR');
    print('   Error: $e');
  }
  return null;
}

Future<void> testPatientManagement(String baseUrl, String? token) async {
  final headers = {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  
  try {
    // Test GET patients
    final response = await http.get(
      Uri.parse('$baseUrl/patients/'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      print('✅ Patient Management: SUCCESS');
      print('   Status Code: ${response.statusCode}');
      final data = jsonDecode(response.body);
      print('   Patients Count: ${data['results']?.length ?? data.length}');
    } else {
      print('❌ Patient Management: FAILED');
      print('   Status Code: ${response.statusCode}');
      print('   Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Patient Management: ERROR');
    print('   Error: $e');
  }
}

Future<void> testTestCategories(String baseUrl, String? token) async {
  final headers = {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/test-categories/'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      print('✅ Test Categories: SUCCESS');
      print('   Status Code: ${response.statusCode}');
      final data = jsonDecode(response.body);
      print('   Categories Count: ${data['results']?.length ?? data.length}');
    } else {
      print('❌ Test Categories: FAILED');
      print('   Status Code: ${response.statusCode}');
      print('   Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Test Categories: ERROR');
    print('   Error: $e');
  }
}

Future<void> testLabTests(String baseUrl, String? token) async {
  final headers = {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/tests/'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      print('✅ Lab Tests: SUCCESS');
      print('   Status Code: ${response.statusCode}');
      final data = jsonDecode(response.body);
      print('   Tests Count: ${data['results']?.length ?? data.length}');
    } else {
      print('❌ Lab Tests: FAILED');
      print('   Status Code: ${response.statusCode}');
      print('   Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Lab Tests: ERROR');
    print('   Error: $e');
  }
}

Future<void> testTestOrders(String baseUrl, String? token) async {
  final headers = {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/test-orders/'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      print('✅ Test Orders: SUCCESS');
      print('   Status Code: ${response.statusCode}');
      final data = jsonDecode(response.body);
      print('   Orders Count: ${data['results']?.length ?? data.length}');
    } else {
      print('❌ Test Orders: FAILED');
      print('   Status Code: ${response.statusCode}');
      print('   Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Test Orders: ERROR');
    print('   Error: $e');
  }
}

Future<void> testAppointments(String baseUrl, String? token) async {
  final headers = {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/appointments/'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      print('✅ Appointments: SUCCESS');
      print('   Status Code: ${response.statusCode}');
      final data = jsonDecode(response.body);
      print('   Appointments Count: ${data['results']?.length ?? data.length}');
    } else {
      print('❌ Appointments: FAILED');
      print('   Status Code: ${response.statusCode}');
      print('   Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Appointments: ERROR');
    print('   Error: $e');
  }
}

Future<void> testPayments(String baseUrl, String? token) async {
  final headers = {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/payments/'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      print('✅ Payments: SUCCESS');
      print('   Status Code: ${response.statusCode}');
      final data = jsonDecode(response.body);
      print('   Payments Count: ${data['results']?.length ?? data.length}');
    } else {
      print('❌ Payments: FAILED');
      print('   Status Code: ${response.statusCode}');
      print('   Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Payments: ERROR');
    print('   Error: $e');
  }
}

Future<void> testReports(String baseUrl, String? token) async {
  final headers = {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      print('✅ Reports: SUCCESS');
      print('   Status Code: ${response.statusCode}');
      final data = jsonDecode(response.body);
      print('   Reports Count: ${data['results']?.length ?? data.length}');
    } else {
      print('❌ Reports: FAILED');
      print('   Status Code: ${response.statusCode}');
      print('   Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Reports: ERROR');
    print('   Error: $e');
  }
}

Future<void> testDataExport(String baseUrl, String? token) async {
  final headers = {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  
  try {
    // Test CSV export endpoints
    final csvResponse = await http.get(
      Uri.parse('$baseUrl/export/patients/csv/'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));
    
    if (csvResponse.statusCode == 200) {
      print('✅ Data Export: SUCCESS');
      print('   Status Code: ${csvResponse.statusCode}');
      print('   CSV Export: Available');
    } else {
      print('❌ Data Export: FAILED');
      print('   Status Code: ${csvResponse.statusCode}');
      print('   Response: ${csvResponse.body}');
    }
  } catch (e) {
    print('❌ Data Export: ERROR');
    print('   Error: $e');
  }
}
