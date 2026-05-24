import 'dart:convert';
import 'package:http/http.dart' as http;

/// Test script to verify Django backend connection
/// Run this with: dart test_django_backend_connection.dart

void main() async {
  print('🧪 Testing Django Lab Management Backend Connection');
  print('=' * 60);
  
  const String baseUrl = 'http://208.109.215.53:3015/lab';
  
  // Test 1: Health Check
  print('\n1. Testing Health Check...');
  await testHealthCheck(baseUrl);
  
  // Test 2: Authentication
  print('\n2. Testing Authentication...');
  String? token = await testAuthentication(baseUrl);
  
  if (token != null) {
    // Test 3: API Endpoints
    print('\n3. Testing API Endpoints...');
    await testApiEndpoints(baseUrl, token);
  }
  
  print('\n${'=' * 60}');
  print('✅ Backend connection test completed!');
}

Future<void> testHealthCheck(String baseUrl) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/health/'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    
    print('   Status: ${response.statusCode}');
    print('   Response: ${response.body}');
    
    if (response.statusCode == 200) {
      print('   ✅ Health check passed');
    } else {
      print('   ❌ Health check failed');
    }
  } catch (e) {
    print('   ❌ Health check error: $e');
  }
}

Future<String?> testAuthentication(String baseUrl) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/token/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'username': 'admin',
        'password': 'admin123',
      }),
    ).timeout(const Duration(seconds: 10));
    
    print('   Status: ${response.statusCode}');
    print('   Response: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['access'] ?? data['access_token'];
      if (token != null) {
        print('   ✅ Authentication successful');
        print('   Token: ${token.substring(0, 20)}...');
        return token;
      }
    }
    print('   ❌ Authentication failed');
    return null;
  } catch (e) {
    print('   ❌ Authentication error: $e');
    return null;
  }
}

Future<void> testApiEndpoints(String baseUrl, String token) async {
  final endpoints = [
    '/patients/',
    '/tests/',
    '/appointments/',
    '/payments/',
    '/reports/',
    '/analytics/',
  ];
  
  for (final endpoint in endpoints) {
    print('\n   Testing $endpoint...');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('     Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          print('     ✅ Found ${data.length} items');
        } else if (data is Map) {
          print('     ✅ Response received');
        }
      } else {
        print('     ❌ Failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('     ❌ Error: $e');
    }
  }
}
