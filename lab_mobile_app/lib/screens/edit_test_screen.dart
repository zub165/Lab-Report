import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/test.dart';
import '../models/test_result.dart';
import '../providers/test_provider.dart';
import '../services/django_api_service.dart';
import '../utils/constants.dart';

class EditTestScreen extends StatefulWidget {
  final Test test;

  const EditTestScreen({Key? key, required this.test}) : super(key: key);

  @override
  State<EditTestScreen> createState() => _EditTestScreenState();
}

class _EditTestScreenState extends State<EditTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final DjangoApiService _api = DjangoApiService();

  String? _selectedStatus;
  String? _selectedPriority;
  DateTime? _selectedOrderDate;
  DateTime? _selectedCompletedDate;
  bool _isLoading = false;
  bool _loadingResults = true;
  String? _resultsLoadError;
  List<LabResultRow> _resultRows = [];
  final Map<int, TextEditingController> _valueControllers = {};

  final List<String> _statuses = [
    'Pending',
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  final List<String> _priorities = [
    'Low',
    'Normal',
    'High',
    'Urgent',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _loadResultTable();
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (final c in _valueControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? get _orderApiId =>
      widget.test.djangoOrderId?.trim().isNotEmpty == true
          ? widget.test.djangoOrderId
          : widget.test.testId?.trim();

  void _initializeFields() {
    _selectedStatus =
        _statuses.contains(widget.test.status) ? widget.test.status : 'Pending';
    _selectedPriority = _priorities.contains(widget.test.priority)
        ? widget.test.priority
        : 'Normal';
    _selectedOrderDate = widget.test.orderedDate;
    _selectedCompletedDate = widget.test.completedDate;
    _notesController.text = widget.test.notes ?? '';
  }

  void _syncControllersFromRows() {
    for (final c in _valueControllers.values) {
      c.dispose();
    }
    _valueControllers.clear();
    for (var i = 0; i < _resultRows.length; i++) {
      _valueControllers[i] = TextEditingController(text: _resultRows[i].value);
    }
  }

  Future<void> _loadResultTable() async {
    final id = _orderApiId;
    if (id == null || id.isEmpty) {
      setState(() {
        _loadingResults = false;
        _resultsLoadError = 'No order ID — cannot load result table';
      });
      return;
    }
    setState(() {
      _loadingResults = true;
      _resultsLoadError = null;
    });
    try {
      final rows = await _api.loadLabResultRowsForOrder(id);
      if (!mounted) return;
      setState(() {
        _resultRows = rows;
        _syncControllersFromRows();
        _loadingResults = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingResults = false;
        _resultsLoadError = e.toString();
        _resultRows = [];
      });
    }
  }

  Future<void> _selectOrderDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedOrderDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedOrderDate = date);
  }

  Future<void> _selectCompletedDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedCompletedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedCompletedDate = date);
  }

  void _applyValuesFromControllers() {
    for (var i = 0; i < _resultRows.length; i++) {
      final c = _valueControllers[i];
      if (c != null) _resultRows[i].value = c.text.trim();
    }
  }

  Future<void> _updateTest() async {
    if (!_formKey.currentState!.validate()) return;
    final orderId = _orderApiId;
    if (orderId == null || orderId.isEmpty) {
      _showErrorDialog('Missing test order ID');
      return;
    }

    setState(() => _isLoading = true);

    try {
      _applyValuesFromControllers();
      if (_resultRows.isNotEmpty) {
        await _api.saveLabResultRows(orderId: orderId, rows: _resultRows);
      }

      final updatedTest = Test(
        testId: widget.test.testId,
        djangoOrderId: widget.test.djangoOrderId,
        patientId: widget.test.patientId,
        testName: widget.test.testName,
        testType: widget.test.testType,
        status: _selectedStatus!,
        priority: _selectedPriority,
        orderedDate: _selectedOrderDate!,
        completedDate: _selectedCompletedDate,
        orderedBy: widget.test.orderedBy,
        price: widget.test.price,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        results: widget.test.results,
        testResults: widget.test.testResults,
        createdAt: widget.test.createdAt,
        updatedAt: DateTime.now(),
      );

      final ok = await Provider.of<TestProvider>(context, listen: false)
          .updateTest(updatedTest);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Results and order saved' : 'Order update failed'),
            backgroundColor: ok ? Colors.green : Colors.red,
          ),
        );
        if (ok) Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Error saving: $e');
      }
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
    final busy = _isLoading || _loadingResults;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Test Order / Report'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: busy ? null : _updateTest,
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
                    _buildTestInfoSection(),
                    const SizedBox(height: 20),
                    _buildStatusSection(),
                    const SizedBox(height: 20),
                    _buildDateSection(),
                    const SizedBox(height: 20),
                    _buildResultsSection(),
                    const SizedBox(height: 20),
                    _buildNotesSection(),
                    const SizedBox(height: 30),
                    _buildUpdateButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTestInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Test Name', widget.test.testName),
            _buildInfoRow('Test Type', widget.test.testType),
            _buildInfoRow('Order ID', _orderApiId ?? '—'),
            _buildInfoRow('Patient ID', widget.test.patientId),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status & Priority',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              items: _statuses
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedStatus = v),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Please select a status' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: _priorities
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedPriority = v),
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
              'Dates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _dateTile(
              icon: Icons.calendar_today,
              label: _selectedOrderDate != null
                  ? '${_selectedOrderDate!.day}/${_selectedOrderDate!.month}/${_selectedOrderDate!.year}'
                  : 'Select Order Date *',
              onTap: _selectOrderDate,
            ),
            const SizedBox(height: 16),
            _dateTile(
              icon: Icons.check_circle,
              label: _selectedCompletedDate != null
                  ? '${_selectedCompletedDate!.day}/${_selectedCompletedDate!.month}/${_selectedCompletedDate!.year}'
                  : 'Select Completed Date (Optional)',
              onTap: _selectCompletedDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Lab results',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Reload table',
                  onPressed: _loadingResults ? null : _loadResultTable,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Enter your result beside each normal (reference) range — matches the printed lab report.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            if (_loadingResults)
              const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ))
            else if (_resultsLoadError != null)
              Column(
                children: [
                  Text(_resultsLoadError!, style: const TextStyle(color: Colors.red)),
                  TextButton(onPressed: _loadResultTable, child: const Text('Retry')),
                ],
              )
            else if (_resultRows.isEmpty)
              const Text(
                'No test parameters on this order. Add tests to the order on the Lab Tests tab first.',
                style: TextStyle(color: Colors.grey),
              )
            else
              _LabResultsTable(
                rows: _resultRows,
                controllers: _valueControllers,
                onChanged: (index, value) {
                  _resultRows[index].value = value;
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clinical notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
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
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateTest,
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
                  Text('Saving…'),
                ],
              )
            : const Text(
                'Save results & update order',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

/// Report-style table: Test Parameter | Result | Reference Range | Unit
class _LabResultsTable extends StatelessWidget {
  final List<LabResultRow> rows;
  final Map<int, TextEditingController> controllers;
  final void Function(int index, String value) onChanged;

  const _LabResultsTable({
    required this.rows,
    required this.controllers,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    String? lastPanel;
    final children = <Widget>[];

    children.add(
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          color: Colors.grey.shade200,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: const Row(
          children: [
            Expanded(flex: 3, child: Text('Test Parameter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            Expanded(flex: 2, child: Text('Your result', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            Expanded(flex: 2, child: Text('Normal range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            Expanded(child: Text('Unit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ],
        ),
      ),
    );

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row.panelTitle != null &&
          row.panelTitle!.isNotEmpty &&
          row.panelTitle != lastPanel) {
        lastPanel = row.panelTitle;
        children.add(
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.green.shade100,
            child: Text(
              row.panelTitle!,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        );
      }
      final ctrl = controllers[i]!;
      children.add(
        Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.grey.shade400),
              right: BorderSide(color: Colors.grey.shade400),
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Text(row.parameter, style: const TextStyle(fontSize: 13)),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: ctrl,
                  onChanged: (v) => onChanged(i, v),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.\-<>≥≤%/+ ]')),
                  ],
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(),
                    hintText: '—',
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  decoration: BoxDecoration(
                    color: row.hasNormalRange
                        ? Colors.teal.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: row.hasNormalRange
                          ? Colors.teal.shade200
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.straighten,
                        size: 14,
                        color: row.hasNormalRange
                            ? Colors.teal.shade700
                            : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          row.hasNormalRange
                              ? row.displayReference
                              : 'Not in catalog',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: row.hasNormalRange
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: row.hasNormalRange
                                ? Colors.teal.shade900
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  row.unit.isEmpty ? '—' : row.unit,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      );
    }

    children.add(
      Container(
        height: 1,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
        ),
      ),
    );

    return Column(children: children);
  }
}
