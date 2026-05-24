import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient.dart';
import '../models/test.dart';
import '../models/report_template.dart';
import '../providers/patient_provider.dart';
import '../providers/test_provider.dart';
import '../services/advanced_report_service.dart';
import '../utils/constants.dart';
import '../utils/lab_currency.dart';
import 'report_preview_screen.dart';

class AdvancedReportScreen extends StatefulWidget {
  final Patient? selectedPatient;
  final List<Test>? selectedTests;

  const AdvancedReportScreen({
    super.key,
    this.selectedPatient,
    this.selectedTests,
  });

  @override
  State<AdvancedReportScreen> createState() => _AdvancedReportScreenState();
}

class _AdvancedReportScreenState extends State<AdvancedReportScreen> {
  final AdvancedReportService _reportService = AdvancedReportService();

  List<Patient> _patients = [];
  List<Test> _tests = [];
  List<Test> _selectedTests = [];
  String? _selectedPatientKey;
  String _selectedTemplate = AdvancedReportService.standardTemplate;
  String? _customTitle;
  String? _customHeader;
  String? _customFooter;
  bool _isLoading = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.selectedPatient != null) {
      _selectedPatientKey = labPatientSelectionKey(widget.selectedPatient!);
    }
    if (widget.selectedTests != null) {
      _selectedTests = List.from(widget.selectedTests!);
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final patientProvider = Provider.of<PatientProvider>(context, listen: false);
      final testProvider = Provider.of<TestProvider>(context, listen: false);
      await Future.wait([
        patientProvider.loadPatients(),
        testProvider.loadTests(),
      ]);
      if (!mounted) return;
      setState(() {
        _patients = patientProvider.patients;
        _tests = testProvider.tests
            .where((t) => t.status.toLowerCase() != 'archived')
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Error loading data: $e');
      }
    }
  }

  Patient? get _selectedPatient {
    if (_selectedPatientKey == null) return null;
    for (final p in _patients) {
      if (labPatientSelectionKey(p) == _selectedPatientKey) return p;
    }
    return null;
  }

  Future<void> _generateReport() async {
    final patient = _selectedPatient;
    if (patient == null) {
      _showErrorDialog('Please select a patient');
      return;
    }
    if (_selectedTests.isEmpty) {
      _showErrorDialog('Please select at least one test order');
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final reportData = await _reportService.generateReport(
        patient: patient,
        tests: _selectedTests,
        templateType: _selectedTemplate,
        customTitle: _customTitle,
        customHeader: _customHeader,
        customFooter: _customFooter,
      );

      final primaryTest = _selectedTests.first;
      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReportPreviewScreen(
            patient: patient,
            test: primaryTest,
            initialTemplate: _templateForType(_selectedTemplate),
          ),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report generated — use Print/PDF/Share on preview'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Error generating report: $e');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  ReportTemplate? _templateForType(String type) {
    final t = type.toLowerCase();
    for (final template in DefaultReportTemplates.templates) {
      if (template.id.toLowerCase().contains(t) ||
          template.name.toLowerCase().contains(t)) {
        return template;
      }
    }
    return DefaultReportTemplates.templates.isNotEmpty
        ? DefaultReportTemplates.templates.first
        : null;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Report'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTemplateSelector(),
                  const SizedBox(height: 20),
                  _buildPatientSelector(),
                  const SizedBox(height: 20),
                  _buildTestSelector(),
                  if (_selectedTemplate == AdvancedReportService.customTemplate) ...[
                    const SizedBox(height: 20),
                    _buildCustomFields(),
                  ],
                  const SizedBox(height: 20),
                  _buildGenerateButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildTemplateSelector() {
    final templates = _reportService.getAvailableTemplates();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Report Template',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...templates.map((template) => RadioListTile<String>(
                  title: Text(template['name'] as String),
                  subtitle: Text(template['description'] as String),
                  value: template['id'] as String,
                  groupValue: _selectedTemplate,
                  onChanged: (value) => setState(() => _selectedTemplate = value!),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Patient',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _patients.any((p) => labPatientSelectionKey(p) == _selectedPatientKey)
                  ? _selectedPatientKey
                  : null,
              decoration: const InputDecoration(
                labelText: 'Patient *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              items: _patients.map((patient) {
                final key = labPatientSelectionKey(patient);
                return DropdownMenuItem(
                  value: key,
                  child: Text(patient.fullName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPatientKey = value;
                  _selectedTests.clear();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSelector() {
    final patient = _selectedPatient;
    final patientTests = patient == null
        ? <Test>[]
        : _tests.where((t) => labPatientMatchesTest(patient, t)).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Test Orders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (patientTests.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (_selectedTests.length == patientTests.length) {
                          _selectedTests.clear();
                        } else {
                          _selectedTests = List.from(patientTests);
                        }
                      });
                    },
                    child: Text(
                      _selectedTests.length == patientTests.length
                          ? 'Clear all'
                          : 'Select all',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (patient == null)
              const Text('Select a patient first', style: TextStyle(color: Colors.grey))
            else if (patientTests.isEmpty)
              const Text(
                'No test orders for this patient. Create one under Lab Tests.',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...patientTests.map((test) {
                final id = test.testId ?? '';
                return CheckboxListTile(
                  title: Text(test.testName),
                  subtitle: Text(
                    '${test.testType} · ${test.status} · ${LabCurrency.formatWithSymbol(test.price)}',
                  ),
                  value: _selectedTests.any((s) => s.testId == id),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        if (!_selectedTests.any((s) => s.testId == id)) {
                          _selectedTests.add(test);
                        }
                      } else {
                        _selectedTests.removeWhere((s) => s.testId == id);
                      }
                    });
                  },
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Custom Report Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Custom Title',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _customTitle = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Custom Header',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) => _customHeader = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Custom Footer',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) => _customFooter = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _isGenerating ? null : _generateReport,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppConstants.primaryColor,
        ),
        child: _isGenerating
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text('Generating…'),
                ],
              )
            : const Text(
                'Generate Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
