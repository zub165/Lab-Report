import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';
import '../providers/test_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/user_provider.dart';
import '../utils/data_export_utils.dart';
import '../utils/constants.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _isLoading = false;
  String _status = '';
  Map<String, dynamic> _statistics = {};
  String _selectedDataType = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStatistics();
    });
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _status = 'Loading statistics...';
    });

    try {
      final patients = context.read<PatientProvider>().patients;
      final tests = context.read<TestProvider>().tests;
      final appointments = context.read<AppointmentProvider>().appointments;
      final payments = context.read<PaymentProvider>().payments;
      final users = context.read<UserProvider>().users;

      final stats = DataExportUtils.getDataStatistics(
        patients: patients,
        tests: tests,
        appointments: appointments,
        payments: payments,
        users: users,
      );

      setState(() {
        _statistics = stats;
        _status = 'Statistics loaded successfully';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to load statistics: $e';
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
      _status = 'Exporting to Excel...';
    });

    try {
      final patients = context.read<PatientProvider>().patients;
      final tests = context.read<TestProvider>().tests;
      final appointments = context.read<AppointmentProvider>().appointments;
      final payments = context.read<PaymentProvider>().payments;
      final users = context.read<UserProvider>().users;

      final filePath = await DataExportUtils.exportToExcel(
        patients: patients,
        tests: tests,
        appointments: appointments,
        payments: payments,
        users: users,
      );

      setState(() {
        _status = 'Excel export completed: $filePath';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Excel file exported successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _status = 'Export failed: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportToPDF() async {
    setState(() {
      _isLoading = true;
      _status = 'Exporting to PDF...';
    });

    try {
      final patients = context.read<PatientProvider>().patients;
      final tests = context.read<TestProvider>().tests;
      final appointments = context.read<AppointmentProvider>().appointments;
      final payments = context.read<PaymentProvider>().payments;
      final users = context.read<UserProvider>().users;

      final filePath = await DataExportUtils.exportToPDF(
        patients: patients,
        tests: tests,
        appointments: appointments,
        payments: payments,
        users: users,
      );

      setState(() {
        _status = 'PDF export completed: $filePath';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF file exported successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _status = 'Export failed: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportSpecificData() async {
    if (_selectedDataType == 'all') {
      await _exportToExcel();
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Exporting $_selectedDataType...';
    });

    try {
      List<dynamic> data = [];
      String dataType = '';

      switch (_selectedDataType) {
        case 'patients':
          data = context.read<PatientProvider>().patients;
          dataType = 'Patients';
          break;
        case 'tests':
          data = context.read<TestProvider>().tests;
          dataType = 'Tests';
          break;
        case 'appointments':
          data = context.read<AppointmentProvider>().appointments;
          dataType = 'Appointments';
          break;
        case 'payments':
          data = context.read<PaymentProvider>().payments;
          dataType = 'Payments';
          break;
        case 'users':
          data = context.read<UserProvider>().users;
          dataType = 'Users';
          break;
      }

      final filePath = await DataExportUtils.exportSpecificData(
        dataType: dataType,
        data: data,
      );

      setState(() {
        _status = '$dataType export completed: $filePath';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$dataType exported successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _status = 'Export failed: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDataViewer(String dataType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DataViewerScreen(dataType: dataType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Management'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isLoading ? Icons.hourglass_empty : Icons.check_circle,
                          color: _isLoading ? Colors.orange : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    if (_isLoading) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Statistics Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Database Statistics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_statistics.isNotEmpty) ...[
                      _buildStatRow('Patients', _statistics['totalPatients']?.toString() ?? '0'),
                      _buildStatRow('Tests', _statistics['totalTests']?.toString() ?? '0'),
                      _buildStatRow('Appointments', _statistics['totalAppointments']?.toString() ?? '0'),
                      _buildStatRow('Payments', _statistics['totalPayments']?.toString() ?? '0'),
                      _buildStatRow('Users', _statistics['totalUsers']?.toString() ?? '0'),
                      const Divider(),
                      _buildStatRow('Total Revenue', '\$${_statistics['totalRevenue']?.toStringAsFixed(2) ?? '0.00'}'),
                      _buildStatRow('Pending Appointments', _statistics['pendingAppointments']?.toString() ?? '0'),
                      _buildStatRow('Completed Appointments', _statistics['completedAppointments']?.toString() ?? '0'),
                      _buildStatRow('Average Test Price', '\$${_statistics['averageTestPrice']?.toStringAsFixed(2) ?? '0.00'}'),
                    ] else ...[
                      const Text('No data available'),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Data Type Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Export Options',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedDataType,
                      decoration: const InputDecoration(
                        labelText: 'Select Data Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Data')),
                        DropdownMenuItem(value: 'patients', child: Text('Patients Only')),
                        DropdownMenuItem(value: 'tests', child: Text('Tests Only')),
                        DropdownMenuItem(value: 'appointments', child: Text('Appointments Only')),
                        DropdownMenuItem(value: 'payments', child: Text('Payments Only')),
                        DropdownMenuItem(value: 'users', child: Text('Users Only')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedDataType = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _exportToExcel,
              icon: const Icon(Icons.table_chart),
              label: const Text('Export to Excel (CSV)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _exportToPDF,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Export to PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.secondaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _exportSpecificData,
              icon: const Icon(Icons.download),
              label: const Text('Export Selected Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.infoColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Data Viewer Buttons
            const Text(
              'View Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildViewButton('Patients', Icons.people),
                _buildViewButton('Tests', Icons.science),
                _buildViewButton('Appointments', Icons.calendar_today),
                _buildViewButton('Payments', Icons.payment),
                _buildViewButton('Users', Icons.person),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton(String dataType, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => _showDataViewer(dataType.toLowerCase()),
      icon: Icon(icon),
      label: Text(dataType),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black87,
      ),
    );
  }
}

class DataViewerScreen extends StatelessWidget {
  final String dataType;

  const DataViewerScreen({super.key, required this.dataType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$dataType Data'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              // TODO: Implement print functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Print functionality coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _buildDataList(context),
    );
  }

  Widget _buildDataList(BuildContext context) {
    switch (dataType) {
      case 'patients':
        return Consumer<PatientProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (provider.patients.isEmpty) {
              return const Center(child: Text('No patients found'));
            }
            
            return ListView.builder(
              itemCount: provider.patients.length,
              itemBuilder: (context, index) {
                final patient = provider.patients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      child: Text(patient.initials),
                    ),
                    title: Text(patient.fullName),
                    subtitle: Text('${patient.phone} • ${patient.age} years'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // TODO: Implement edit functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit functionality coming soon!')),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
        
      case 'tests':
        return Consumer<TestProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (provider.tests.isEmpty) {
              return const Center(child: Text('No tests found'));
            }
            
            return ListView.builder(
              itemCount: provider.tests.length,
              itemBuilder: (context, index) {
                final test = provider.tests[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: const Icon(
                      Icons.science,
                      color: AppConstants.primaryColor,
                    ),
                    title: Text(test.testName),
                    subtitle: Text('\$${test.price} • ${test.status}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // TODO: Implement edit functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit functionality coming soon!')),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
        
      default:
        return Center(
          child: Text('Data viewer for $dataType coming soon!'),
        );
    }
  }
}
