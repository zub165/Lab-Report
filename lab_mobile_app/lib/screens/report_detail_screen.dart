import 'package:flutter/material.dart';
import '../models/report_data.dart';
import '../models/patient.dart';
import '../models/test.dart';
import '../services/simple_hybrid_storage_service.dart';
import 'edit_report_screen.dart';
import 'report_preview_screen.dart';

class ReportDetailScreen extends StatefulWidget {
  final ReportData report;

  const ReportDetailScreen({Key? key, required this.report}) : super(key: key);

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
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
        (p) => p.patientId == widget.report.patientId,
        orElse: () => Patient(
          patientId: widget.report.patientId,
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

  Future<void> _editReport() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReportScreen(report: widget.report),
      ),
    );

    if (result == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report updated successfully')),
        );
        Navigator.pop(context, true); // Return to refresh the list
      }
    }
  }

  Future<void> _deleteReport() async {
    final confirmed = await _showDeleteConfirmationDialog();
    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Note: You'll need to add deleteReport method to SimpleHybridStorageService
        // await _hybridStorage.deleteReport(widget.report.reportId!);
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate deletion
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report deleted successfully')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Error deleting report: $e');
      }
    }
  }

  Future<void> _printReport() async {
    if (_patient == null) {
      _showErrorDialog('Patient data not available');
      return;
    }

    try {
      // Create a mock test for the report preview
      final mockTest = Test(
        testId: 'report_${widget.report.reportId ?? widget.report.id}',
        patientId: widget.report.patientId ?? '',
        testName: widget.report.title ?? 'Report',
        testType: 'Report',
        status: 'Completed',
        orderedBy: 'System',
        orderedDate: widget.report.reportDate ?? DateTime.now(),
        price: 0.0,
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportPreviewScreen(
            patient: _patient!,
            test: mockTest,
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
        title: const Text('Delete Report'),
        content: Text('Are you sure you want to delete ${widget.report.title ?? 'this report'}? This action cannot be undone.'),
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
        title: const Text('Report Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editReport,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printReport,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _deleteReport();
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
                    Text('Delete Report'),
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
                  _buildReportInfoCard(),
                  const SizedBox(height: 16),
                  _buildPatientInfoCard(),
                  const SizedBox(height: 16),
                  _buildReportContentCard(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildReportInfoCard() {
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
                  child: const Icon(
                    Icons.assessment,
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
                        widget.report.title ?? 'Untitled Report',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${widget.report.reportId ?? widget.report.id}',
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
            _buildInfoRow('Report Type', widget.report.reportType ?? widget.report.type ?? 'General'),
            _buildInfoRow('Status', widget.report.status ?? 'Generated'),
            _buildInfoRow('Report Date', widget.report.reportDate != null
                ? '${widget.report.reportDate!.day}/${widget.report.reportDate!.month}/${widget.report.reportDate!.year}'
                : 'Not specified'),
            if (widget.report.authorizedBy != null)
              _buildInfoRow('Authorized By', widget.report.authorizedBy!),
            if (widget.report.createdAt != null)
              _buildInfoRow('Created', '${widget.report.createdAt!.day}/${widget.report.createdAt!.month}/${widget.report.createdAt!.year}'),
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

  Widget _buildReportContentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Content',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (widget.report.content != null && widget.report.content!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  widget.report.content!,
                  style: const TextStyle(fontSize: 14),
                ),
              )
            else
              const Text(
                'No content available for this report.',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _editReport,
            icon: const Icon(Icons.edit),
            label: const Text('Edit Report'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _printReport,
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
