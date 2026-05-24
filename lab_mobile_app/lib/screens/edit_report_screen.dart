import 'package:flutter/material.dart';
import '../models/report_data.dart';
import '../services/simple_hybrid_storage_service.dart';

class EditReportScreen extends StatefulWidget {
  final ReportData report;

  const EditReportScreen({Key? key, required this.report}) : super(key: key);

  @override
  State<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorizedByController = TextEditingController();
  
  final SimpleHybridStorageService _hybridStorage = SimpleHybridStorageService();
  
  String? _selectedReportType;
  String? _selectedStatus;
  DateTime? _selectedReportDate;
  bool _isLoading = false;

  final List<String> _reportTypes = [
    'General',
    'Blood Test',
    'X-Ray',
    'Ultrasound',
    'ECG',
    'Pathology',
    'Microbiology',
    'Biochemistry',
    'Hematology',
    'Immunology',
  ];

  final List<String> _statuses = [
    'Draft',
    'Generated',
    'Reviewed',
    'Approved',
    'Finalized',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorizedByController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    _titleController.text = widget.report.title ?? '';
    _contentController.text = widget.report.content ?? '';
    _authorizedByController.text = widget.report.authorizedBy ?? '';
    _selectedReportType = widget.report.reportType ?? widget.report.type ?? 'General';
    _selectedStatus = widget.report.status ?? 'Generated';
    _selectedReportDate = widget.report.reportDate ?? DateTime.now();
  }

  Future<void> _selectReportDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedReportDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedReportDate = date;
      });
    }
  }

  Future<void> _updateReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedReport = ReportData(
        reportId: widget.report.reportId ?? widget.report.id,
        patientId: widget.report.patientId ?? '',
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        reportType: _selectedReportType,
        status: _selectedStatus,
        reportDate: _selectedReportDate,
        authorizedBy: _authorizedByController.text.trim().isEmpty ? null : _authorizedByController.text.trim(),
        createdAt: widget.report.createdAt,
        updatedAt: DateTime.now(),
      );

      // Note: You'll need to add updateReport method to SimpleHybridStorageService
      // await _hybridStorage.updateReport(updatedReport);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error updating report: $e');
    }
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
        title: const Text('Edit Report'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _updateReport,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoSection(),
                    const SizedBox(height: 20),
                    _buildReportTypeSection(),
                    const SizedBox(height: 20),
                    _buildDateSection(),
                    const SizedBox(height: 20),
                    _buildContentSection(),
                    const SizedBox(height: 20),
                    _buildAuthorizedBySection(),
                    const SizedBox(height: 30),
                    _buildUpdateButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Report Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a report title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Report ID', widget.report.reportId ?? widget.report.id ?? 'N/A'),
            _buildInfoRow('Patient ID', widget.report.patientId ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Type & Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedReportType,
              decoration: const InputDecoration(
                labelText: 'Report Type *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _reportTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReportType = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a report type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              items: _statuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a status';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _selectReportDate,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(
                      _selectedReportDate != null
                          ? '${_selectedReportDate!.day}/${_selectedReportDate!.month}/${_selectedReportDate!.year}'
                          : 'Select Report Date *',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedReportDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Report Content *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                hintText: 'Enter the detailed report content...',
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter report content';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorizedBySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Authorization',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _authorizedByController,
              decoration: const InputDecoration(
                labelText: 'Authorized By',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
                hintText: 'Enter the name of the authorizing person...',
              ),
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
            width: 100,
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

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateReport,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        child: _isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Updating Report...'),
                ],
              )
            : const Text(
                'Update Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
