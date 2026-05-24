import 'dart:io';
import 'package:flutter/material.dart';
import '../services/django_api_service.dart';
import '../utils/constants.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({Key? key}) : super(key: key);

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final DjangoApiService _apiService = DjangoApiService();
  Map<String, dynamic>? _testResults;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _printConfiguration();
  }

  void _printConfiguration() {
    print('=== API Test Screen Configuration ===');
    // ApiUtils.printApiConfiguration();
    print('Current Base URL: ${AppConstants.baseUrl}');
    print('=====================================');
  }

  Future<void> _runApiTests() async {
    setState(() {
      _isLoading = true;
      _testResults = null;
    });

    try {
      final results = await _apiService.testApiConnectionWithDetails();
      setState(() {
        _testResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResults = {
          'error': e.toString(),
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Connection Test'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Configuration',
                      style: AppConstants.subheadingStyle,
                    ),
                    const SizedBox(height: 8),
                    Text('Base URL: ${AppConstants.baseUrl}'),
                    Text('Platform: ${Platform.isAndroid ? 'Android' : 'iOS'}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _runApiTests,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Run API Tests'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_testResults != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Results',
                        style: AppConstants.subheadingStyle,
                      ),
                      const SizedBox(height: 16),
                      _buildTestResults(),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Troubleshooting Guide',
                      style: AppConstants.subheadingStyle,
                    ),
                    const SizedBox(height: 8),
                    _buildTroubleshootingGuide(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResults() {
    if (_testResults == null) return const SizedBox.shrink();

    if (_testResults!.containsKey('error')) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Error',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(_testResults!['error']),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_testResults!.containsKey('connectivity')) ...[
          const Text(
            'Connectivity Tests:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...(_testResults!['connectivity'] as Map<String, bool>).entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    entry.value ? Icons.check_circle : Icons.error,
                    color: entry.value ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text('${entry.key}: ${entry.value ? "Connected" : "Failed"}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (_testResults!.containsKey('api_health')) ...[
          const Text(
            'API Health Test:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _testResults!['api_health']['success']
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              border: Border.all(
                color: _testResults!['api_health']['success']
                    ? Colors.green.shade200
                    : Colors.red.shade200,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _testResults!['api_health']['success']
                      ? 'API is responding'
                      : 'API connection failed',
                  style: TextStyle(
                    color: _testResults!['api_health']['success']
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_testResults!['api_health']['status_code'] != null)
                  Text('Status Code: ${_testResults!['api_health']['status_code']}'),
                if (_testResults!['api_health']['response'] != null)
                  Text('Response: ${_testResults!['api_health']['response']}'),
                if (_testResults!['api_health']['error'] != null)
                  Text('Error: ${_testResults!['api_health']['error']}'),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTroubleshootingGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTroubleshootingItem(
          '1. Same API as SaeedLab web',
          'Mobile uses the same Django database as https://zub165.github.io/SaeedLab/',
          'API: ${AppConstants.baseUrl}',
        ),
        _buildTroubleshootingItem(
          '2. Login credentials',
          'Use the same username/password as the web lab login (JWT /auth/token/).',
          'Not the old local Node server on port 3003.',
        ),
        _buildTroubleshootingItem(
          '3. Network',
          'Device needs internet access to reach api.mywaitime.com (HTTPS).',
          'Check VPN/firewall if health check fails.',
        ),
        _buildTroubleshootingItem(
          '4. Optional override',
          'Web can set localStorage saeedlab_api_base; app uses SharedPreferences key saeedlab_api_base.',
          'Leave unset to use production API.',
        ),
      ],
    );
  }

  Widget _buildTroubleshootingItem(String title, String description, String code) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(description),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
