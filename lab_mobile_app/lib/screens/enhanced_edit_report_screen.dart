import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/report_data.dart';
import '../providers/report_provider.dart';
import '../services/lab_reference_service.dart';
import '../utils/constants.dart';

class EnhancedEditReportScreen extends StatefulWidget {
  final ReportData report;

  const EnhancedEditReportScreen({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  State<EnhancedEditReportScreen> createState() => _EnhancedEditReportScreenState();
}

class _EnhancedEditReportScreenState extends State<EnhancedEditReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _labReferenceService = LabReferenceService();
  
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorizedByController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedReportType = 'General';
  String _selectedStatus = 'Draft';
  String _selectedTestType = 'CBC';
  DateTime _selectedDate = DateTime.now();
  
  bool _isLoading = false;
  bool _showReferenceData = false;
  
  Map<String, dynamic> _testResults = {};
  Map<String, dynamic> _onlineReference = {};

  final List<String> _reportTypes = [
    'General',
    'CBC',
    'BMP',
    'Lipid Panel',
    'Thyroid Panel',
    'Liver Panel',
    'Custom',
  ];

  final List<String> _statuses = [
    'Draft',
    'Preliminary',
    'Final',
    'Amended',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeFields();
    _loadOnlineReference();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _authorizedByController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    _titleController.text = widget.report.title ?? '';
    _contentController.text = widget.report.content ?? '';
    _authorizedByController.text = widget.report.authorizedBy ?? '';
    _selectedReportType = widget.report.reportType ?? widget.report.type ?? 'General';
    _selectedStatus = widget.report.status ?? 'Draft';
    _selectedDate = widget.report.reportDate ?? DateTime.now();
    _notesController.text = widget.report.notes ?? '';
    
    // Initialize test results from content
    _parseTestResultsFromContent();
  }

  void _parseTestResultsFromContent() {
    // Parse test results from report content
    final content = _contentController.text;
    _testResults = {};
    
    // Simple parsing - in real implementation, this would be more sophisticated
    final lines = content.split('\n');
    for (final line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        if (parts.length == 2) {
          final key = parts[0].trim();
          final value = parts[1].trim();
          _testResults[key] = value;
        }
      }
    }
  }

  Future<void> _loadOnlineReference() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reference = await _labReferenceService.searchOnlineReference(_selectedTestType);
      setState(() {
        _onlineReference = reference;
        _showReferenceData = true;
      });
    } catch (e) {
      print('Error loading online reference: $e');
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
        title: const Text('Edit Report'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.edit), text: 'Edit'),
            Tab(icon: Icon(Icons.science), text: 'Lab Data'),
            Tab(icon: Icon(Icons.library_books), text: 'Reference'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveReport,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEditTab(),
          _buildLabDataTab(),
          _buildReferenceTab(),
        ],
      ),
    );
  }

  Widget _buildEditTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfoCard(),
          const SizedBox(height: 16),
          _buildReportDetailsCard(),
          const SizedBox(height: 16),
          _buildContentCard(),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildLabDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTestTypeSelector(),
          const SizedBox(height: 16),
          _buildTestResultsCard(),
          const SizedBox(height: 16),
          _buildNormalRangesCard(),
        ],
      ),
    );
  }

  Widget _buildReferenceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOnlineReferenceCard(),
          const SizedBox(height: 16),
          _buildReferenceLinksCard(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Report Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedReportType,
                    decoration: const InputDecoration(
                      labelText: 'Report Type',
                      border: OutlineInputBorder(),
                    ),
                    items: _reportTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedReportType = value ?? 'General';
                        _selectedTestType = value ?? 'CBC';
                      });
                      _loadOnlineReference();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: _statuses.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value ?? 'Draft';
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _authorizedByController,
              decoration: const InputDecoration(
                labelText: 'Authorized By',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Report ID',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: widget.report.reportId ?? widget.report.id ?? 'N/A',
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Patient ID',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: widget.report.patientId ?? 'N/A',
                    readOnly: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Report Date',
                  border: OutlineInputBorder(),
                ),
                child: Text(_selectedDate.toString().split(' ')[0]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Content',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
              onChanged: (value) {
                _parseTestResultsFromContent();
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Type Selection',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedTestType,
              decoration: const InputDecoration(
                labelText: 'Select Test Type',
                border: OutlineInputBorder(),
              ),
              items: _labReferenceService.getAvailableTestTypes().map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTestType = value ?? 'CBC';
                });
                _loadOnlineReference();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResultsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Results',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (_testResults.isEmpty)
              const Text('No test results found. Add results in the content section.')
            else
              ..._testResults.entries.map((entry) {
                return _buildTestResultRow(entry.key, entry.value);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResultRow(String parameter, String value) {
    final refRange = _labReferenceService.getParameterReference(_selectedTestType, parameter);
    final numValue = double.tryParse(value.replaceAll(RegExp(r'[^\d.-]'), ''));
    final isNormal = numValue != null ? _labReferenceService.isValueNormal(_selectedTestType, parameter, numValue) : false;
    final isCritical = numValue != null ? _labReferenceService.isValueCritical(_selectedTestType, parameter, numValue) : false;
    final statusColor = numValue != null ? _labReferenceService.getValueStatusColor(_selectedTestType, parameter, numValue) : 'grey';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(parameter),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Value: $value'),
            if (refRange != null) ...[
              Text('Normal Range: ${refRange['normal']} ${refRange['unit'] ?? ''}'),
              Text(
                isCritical ? 'CRITICAL' : (isNormal ? 'Normal' : 'Abnormal'),
                style: TextStyle(
                  color: statusColor == 'red' ? Colors.red : 
                         statusColor == 'green' ? Colors.green : 
                         statusColor == 'orange' ? Colors.orange : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        trailing: Icon(
          isCritical ? Icons.warning : (isNormal ? Icons.check_circle : Icons.info),
          color: statusColor == 'red' ? Colors.red : 
                 statusColor == 'green' ? Colors.green : 
                 statusColor == 'orange' ? Colors.orange : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildNormalRangesCard() {
    final refRange = _labReferenceService.getReferenceRange(_selectedTestType);
    
    if (refRange == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No reference data available for this test type.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Normal Reference Ranges - ${refRange.testName}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...refRange.parameters.entries.map((entry) {
              final param = entry.key;
              final values = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(param),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Normal: ${values['normal']} ${values['unit'] ?? ''}'),
                      if (values['critical_low'] != null)
                        Text('Critical Low: ${values['critical_low']} ${values['unit'] ?? ''}'),
                      if (values['critical_high'] != null)
                        Text('Critical High: ${values['critical_high']} ${values['unit'] ?? ''}'),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            Text(
              'Notes: ${refRange.notes}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineReferenceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Online Reference Data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_onlineReference.isEmpty)
              const Text('No reference data available.')
            else ...[
              _buildReferenceInfo('Test Name', _onlineReference['test_name'] ?? 'N/A'),
              _buildReferenceInfo('Description', _onlineReference['description'] ?? 'N/A'),
              _buildReferenceInfo('Preparation', _onlineReference['preparation'] ?? 'N/A'),
              _buildReferenceInfo('Turnaround Time', _onlineReference['turnaround_time'] ?? 'N/A'),
              _buildReferenceInfo('Last Updated', _onlineReference['last_updated'] ?? 'N/A'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceInfo(String label, String value) {
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

  Widget _buildReferenceLinksCard() {
    final links = _labReferenceService.getReferenceLinks();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Online Reference Sources',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...links.entries.map((entry) {
              return ListTile(
                leading: const Icon(Icons.link),
                title: Text(entry.key.replaceAll('_', ' ').toUpperCase()),
                subtitle: Text(entry.value),
                onTap: () {
                  // In a real app, this would open the URL
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening ${entry.key}...')),
                  );
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _saveReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Report'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  Future<void> _saveReport() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a report title')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedReport = ReportData(
        id: widget.report.id ?? widget.report.reportId,
        reportId: widget.report.reportId ?? widget.report.id,
        patientId: widget.report.patientId ?? '',
        testId: widget.report.testId ?? '',
        title: _titleController.text,
        content: _contentController.text,
        reportDate: _selectedDate,
        status: _selectedStatus,
        reportType: _selectedReportType,
        type: _selectedReportType,
        authorizedBy: _authorizedByController.text,
        notes: _notesController.text,
        createdAt: widget.report.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final reportProvider = Provider.of<ReportProvider>(context, listen: false);
      final updateId = updatedReport.id ?? updatedReport.reportId;
      if (updateId == null || updateId.isEmpty) {
        throw StateError('Report has no id; cannot update');
      }
      await reportProvider.updateReport(updateId, updatedReport);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating report: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
