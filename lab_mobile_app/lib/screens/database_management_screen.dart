import 'package:flutter/material.dart';
import '../services/django_api_service.dart';
import '../utils/constants.dart';

class DatabaseManagementScreen extends StatefulWidget {
  const DatabaseManagementScreen({super.key});

  @override
  State<DatabaseManagementScreen> createState() => _DatabaseManagementScreenState();
}

class _DatabaseManagementScreenState extends State<DatabaseManagementScreen> {
  bool _isLoading = false;
  String _status = '';
  Map<String, int> _databaseStats = {};
  bool _backendConnected = false;
  final DjangoApiService _apiService = DjangoApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBackendConnection();
      _loadDatabaseStats();
    });
  }

  Future<void> _checkBackendConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking backend connection...';
    });

    try {
      final connected = await _apiService.checkHealth();
      setState(() {
        _backendConnected = connected;
        _status = connected ? 'Backend connected' : 'Backend disconnected';
      });
    } catch (e) {
      setState(() {
        _backendConnected = false;
        _status = 'Connection error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDatabaseStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await _apiService.getStats();
      setState(() {
        _databaseStats = {
          'patients': stats['total_patients'] ?? 0,
          'tests': stats['total_tests'] ?? 0,
          'appointments': stats['total_appointments'] ?? 0,
          'payments': stats['total_payments'] ?? 0,
          'users': stats['total_users'] ?? 0,
        };
      });
    } catch (e) {
      setState(() {
        _databaseStats = {};
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _syncAllData() async {
    setState(() {
      _isLoading = true;
      _status = 'Syncing all data...';
    });

    try {
      // Sync patients
      await _apiService.getPatients();
      
      // Sync tests
      await _apiService.getTests();
      
      // Sync appointments
      await _apiService.getAppointments();
      
      // Sync payments
      await _apiService.getPayments();
      
      setState(() {
        _status = 'Data sync completed successfully';
      });
      
      // Reload stats
      await _loadDatabaseStats();
    } catch (e) {
      setState(() {
        _status = 'Sync error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportToExcel() async {
    setState(() {
      _isLoading = true;
      _status = 'Exporting data to Excel...';
    });

    try {
      // Export patients CSV
      await _apiService.exportPatientsCsv();
      
      setState(() {
        _status = 'Data exported successfully';
      });
    } catch (e) {
      setState(() {
        _status = 'Export error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backend Connection Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Backend Connection',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _backendConnected ? Icons.check_circle : Icons.error,
                          color: _backendConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _status,
                            style: TextStyle(
                              color: _backendConnected ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Backend URL: ${AppConstants.djangoBackendUrl}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Database Statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Database Statistics',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    if (_databaseStats.isNotEmpty) ...[
                      _buildStatRow('Patients', _databaseStats['patients'] ?? 0),
                      _buildStatRow('Tests', _databaseStats['tests'] ?? 0),
                      _buildStatRow('Appointments', _databaseStats['appointments'] ?? 0),
                      _buildStatRow('Payments', _databaseStats['payments'] ?? 0),
                      _buildStatRow('Users', _databaseStats['users'] ?? 0),
                    ] else ...[
                      const Text('No statistics available'),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _checkBackendConnection,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Check Connection'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _syncAllData,
                          icon: const Icon(Icons.sync),
                          label: const Text('Sync All Data'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _exportToExcel,
                          icon: const Icon(Icons.download),
                          label: const Text('Export to Excel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Loading Indicator
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            count.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}