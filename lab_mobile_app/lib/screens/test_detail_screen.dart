import 'package:flutter/material.dart';
import '../models/test.dart';
import '../models/patient.dart';
import '../services/simple_hybrid_storage_service.dart';
import 'edit_test_screen.dart';
import 'report_preview_screen.dart';

class TestDetailScreen extends StatefulWidget {
  final Test test;

  const TestDetailScreen({Key? key, required this.test}) : super(key: key);

  @override
  State<TestDetailScreen> createState() => _TestDetailScreenState();
}

class _TestDetailScreenState extends State<TestDetailScreen> {
  final SimpleHybridStorageService _hybridStorage = SimpleHybridStorageService();
  Patient? _patient;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPatientData();
    });
  }

  Future<void> _loadPatientData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final patients = await _hybridStorage.getPatients();
      _patient = patients.firstWhere(
        (p) => p.patientId == widget.test.patientId,
        orElse: () => Patient(
          patientId: widget.test.patientId,
          fullName: 'Unknown Patient',
          dateOfBirth: DateTime.now(),
          gender: 'Unknown',
          phone: 'N/A',
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error loading patient data: $e');
    }
  }

  Future<void> _editTest() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTestScreen(test: widget.test),
      ),
    );

    if (result == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test updated successfully')),
        );
        Navigator.pop(context, true); // Return to refresh the list
      }
    }
  }

  Future<void> _deleteTest() async {
    final confirmed = await _showDeleteConfirmationDialog();
    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _hybridStorage.deleteTest(widget.test.testId!);
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate deletion
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Test deleted successfully')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Error deleting test: $e');
      }
    }
  }

  Future<void> _printTestReport() async {
    if (_patient == null) {
      _showErrorDialog('Patient data not available');
      return;
    }

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportPreviewScreen(
            patient: _patient!,
            test: widget.test,
          ),
        ),
      );
    } catch (e) {
      _showErrorDialog('Error generating report: $e');
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Test'),
        content: Text('Are you sure you want to delete ${widget.test.testName}? This action cannot be undone.'),
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
        title: const Text('Test Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editTest,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printTestReport,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _deleteTest();
                  break;
                case 'refresh':
                  _loadPatientData();
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
                    Text('Delete Test'),
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
                  _buildTestInfoCard(),
                  const SizedBox(height: 16),
                  _buildPatientInfoCard(),
                  const SizedBox(height: 16),
                  _buildTestResultsCard(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildTestInfoCard() {
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
                  backgroundColor: _getStatusColor(widget.test.status),
                  child: Icon(
                    _getStatusIcon(widget.test.status),
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.test.testName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${widget.test.testId}',
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
            _buildInfoRow('Test Type', widget.test.testType),
            _buildInfoRow('Status', widget.test.status),
            _buildInfoRow('Priority', widget.test.priority ?? 'Normal'),
            _buildInfoRow('Price', '\$${widget.test.price.toStringAsFixed(2)}'),
            _buildInfoRow('Ordered Date', '${widget.test.orderedDate.day}/${widget.test.orderedDate.month}/${widget.test.orderedDate.year}'),
            if (widget.test.completedDate != null)
              _buildInfoRow('Completed Date', '${widget.test.completedDate!.day}/${widget.test.completedDate!.month}/${widget.test.completedDate!.year}'),
            _buildInfoRow('Ordered By', widget.test.orderedBy),
            if (widget.test.notes != null && widget.test.notes!.isNotEmpty)
              _buildInfoRow('Notes', widget.test.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    if (_patient == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Name', _patient!.fullName),
            _buildInfoRow('Phone', _patient!.phone),
            if (_patient!.email != null)
              _buildInfoRow('Email', _patient!.email!),
            if (_patient!.address != null)
              _buildInfoRow('Address', _patient!.address!),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResultsCard() {
    if (widget.test.testResults == null || widget.test.testResults!.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.science, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'No test results available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                'Results will appear here once the test is completed',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.test.testResults!.map((result) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(result.parameter),
                subtitle: Text('${result.value} ${result.unit ?? ''}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      result.referenceRange ?? 'N/A',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Icon(
                      result.isAbnormal ? Icons.warning : Icons.check_circle,
                      color: result.isAbnormal ? Colors.red : Colors.green,
                      size: 16,
                    ),
                  ],
                ),
              ),
            )).toList(),
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _editTest,
            icon: const Icon(Icons.edit),
            label: const Text('Edit Test'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _printTestReport,
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
