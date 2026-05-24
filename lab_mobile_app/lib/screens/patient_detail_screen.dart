import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/test.dart';
import '../services/simple_hybrid_storage_service.dart';
import 'report_preview_screen.dart';
import 'edit_patient_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen({Key? key, required this.patient}) : super(key: key);

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final SimpleHybridStorageService _hybridStorage = SimpleHybridStorageService();
  List<Test> _patientTests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPatientTests();
    });
  }

  Future<void> _loadPatientTests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tests = await _hybridStorage.getTests();
      setState(() {
        _patientTests = tests.where((test) => test.patientId == widget.patient.patientId).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error loading patient tests: $e');
    }
  }

  Future<void> _editPatient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPatientScreen(patient: widget.patient),
      ),
    );

    if (result == true) {
      // Refresh patient data
      await _loadPatientTests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient updated successfully')),
        );
      }
    }
  }

  Future<void> _deletePatient() async {
    final confirmed = await _showDeleteConfirmationDialog();
    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _hybridStorage.deletePatient(widget.patient.patientId!);
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate deletion
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient deleted successfully')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Error deleting patient: $e');
      }
    }
  }

  Future<void> _printPatientReport() async {
    if (_patientTests.isEmpty) {
      _showErrorDialog('No tests found for this patient');
      return;
    }

    try {
      // For now, show the first test or create a summary
      if (_patientTests.isNotEmpty) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportPreviewScreen(
              patient: widget.patient,
              test: _patientTests.first,
            ),
          ),
        );
      } else {
        _showErrorDialog('No tests found for this patient');
      }
    } catch (e) {
      _showErrorDialog('Error generating report: $e');
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient'),
        content: Text('Are you sure you want to delete ${widget.patient.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editPatient,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printPatientReport,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _deletePatient();
                  break;
                case 'refresh':
                  _loadPatientTests();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Patient'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientInfoCard(),
                  const SizedBox(height: 16),
                  _buildTestsCard(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    widget.patient.fullName.isNotEmpty
                        ? widget.patient.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.patient.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${widget.patient.patientId}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Date of Birth', widget.patient.dateOfBirth != null
                ? '${widget.patient.dateOfBirth.day}/${widget.patient.dateOfBirth.month}/${widget.patient.dateOfBirth.year}'
                : 'Not specified'),
            _buildInfoRow('Gender', widget.patient.gender),
            _buildInfoRow('Phone', widget.patient.phone),
            _buildInfoRow('Email', widget.patient.email ?? 'Not specified'),
            _buildInfoRow('Address', widget.patient.address ?? 'Not specified'),
            _buildInfoRow('Blood Type', widget.patient.bloodType ?? 'Not specified'),
            _buildInfoRow('Emergency Contact', widget.patient.emergencyContact ?? 'Not specified'),
            _buildInfoRow('Insurance Info', widget.patient.insuranceInfo ?? 'Not specified'),
            _buildInfoRow('Created', widget.patient.createdAt != null
                ? '${widget.patient.createdAt!.day}/${widget.patient.createdAt!.month}/${widget.patient.createdAt!.year}'
                : 'Unknown'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildTestsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Patient Tests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_patientTests.length} tests',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_patientTests.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No tests found for this patient',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ..._patientTests.map((test) => _buildTestItem(test)),
          ],
        ),
      ),
    );
  }

  Widget _buildTestItem(Test test) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(test.status),
          child: Icon(
            _getStatusIcon(test.status),
            color: Colors.white,
          ),
        ),
        title: Text(test.testType),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${test.status}'),
            Text('Ordered: ${test.orderedDate.day}/${test.orderedDate.month}/${test.orderedDate.year}'),
            Text('Ordered by: ${test.orderedBy}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view':
                _viewTestDetails(test);
                break;
              case 'print':
                _printTestReport(test);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'print',
              child: Row(
                children: [
                  Icon(Icons.print),
                  SizedBox(width: 8),
                  Text('Print Report'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check;
      case 'in progress':
        return Icons.hourglass_empty;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  void _viewTestDetails(Test test) {
    // Navigate to test details screen
    // This would be implemented based on your test detail screen
  }

  void _printTestReport(Test test) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportPreviewScreen(
          patient: widget.patient,
          test: test,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _editPatient,
            icon: const Icon(Icons.edit),
            label: const Text('Edit Patient'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _printPatientReport,
            icon: const Icon(Icons.print),
            label: const Text('Print Report'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
