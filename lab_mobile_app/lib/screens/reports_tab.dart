import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/test_provider.dart';
import '../providers/language_provider.dart';
import '../providers/patient_provider.dart';
import '../providers/report_provider.dart';
import '../models/patient.dart';
import '../models/test.dart';
import '../utils/constants.dart';
import '../utils/tab_helpers.dart';
import '../services/advanced_report_service.dart';
import 'report_preview_screen.dart';
import 'edit_test_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReportsData());
  }

  Future<void> _loadReportsData() async {
    await Future.wait([
      Provider.of<TestProvider>(context, listen: false).loadTests(),
      Provider.of<PatientProvider>(context, listen: false).loadPatients(),
      Provider.of<ReportProvider>(context, listen: false).loadReports(),
    ]);
  }

  List<Test> _filteredOrders(List<Test> orders) {
    var list = orders
        .where((t) => t.status.toLowerCase() != 'archived')
        .toList();
    switch (_statusFilter) {
      case 'completed':
        return list.where((t) => t.status.toLowerCase() == 'completed').toList();
      case 'pending':
        return list.where((t) => t.status.toLowerCase() == 'pending').toList();
      case 'in_progress':
        return list
            .where((t) =>
                t.status.toLowerCase() == 'in progress' ||
                t.status.toLowerCase() == 'in_progress')
            .toList();
      default:
        return list;
    }
  }

  Patient _patientForTest(List<Patient> patients, Test test) {
    for (final p in patients) {
      if (labPatientMatchesTest(p, test)) return p;
    }
    return Patient(
      patientId: test.patientId,
      fullName: test.patientName ?? 'Patient',
      dateOfBirth: DateTime.now(),
      gender: '—',
      phone: '—',
    );
  }

  Future<void> _viewReport(Test order, Patient patient) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportPreviewScreen(patient: patient, test: order),
      ),
    );
  }

  Future<void> _editReport(Test order) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditTestScreen(test: order)),
    );
    if (updated == true) _loadReportsData();
  }

  Future<void> _archiveReport(Test order) async {
    final id = order.testId;
    if (id == null || id.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive report?'),
        content: const Text(
          'This archives the test order (same as Delete on SaeedLab web). '
          'You can restore it from Archive.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Archive', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final success =
        await Provider.of<TestProvider>(context, listen: false).deleteTest(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Report archived' : 'Archive failed'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
    if (success) _loadReportsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('reports')),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReportsData,
          ),
        ],
      ),
      body: Consumer<TestProvider>(
        builder: (context, testProvider, _) {
          final patientProvider = context.watch<PatientProvider>();
          final reportProvider = context.watch<ReportProvider>();

          if (testProvider.isLoading && testProvider.tests.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = _filteredOrders(testProvider.tests);
          final completed =
              testProvider.tests.where((t) => t.status.toLowerCase() == 'completed').length;
          final pending =
              testProvider.tests.where((t) => t.status.toLowerCase() == 'pending').length;
          final reportCount = reportProvider.reports.length;

          if (orders.isEmpty) {
            return apiTabPlaceholder(
              icon: Icons.assessment_outlined,
              title: 'No reports',
              message: testProvider.error ??
                  'Test orders from /test-orders/ appear here. Tap + to generate a report.',
              onRetry: _loadReportsData,
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Card(
                  color: Colors.blue.shade50,
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                    title: const Text(
                      'How to manage reports',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    children: const [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Text(
                          '• Tap a row or ⋮ → View / Print — preview & PDF\n'
                          '• ⋮ → Enter results — type lab results, set Completed\n'
                          '• ⋮ → Archive — hide order (restore in Archive tab)\n'
                          '• + button — build printable report (Advanced)\n\n'
                          'Who can enter results: Admin, Doctor, Lab Technician, Pathologist '
                          '(any logged-in staff with access to test orders).',
                          style: TextStyle(fontSize: 12, height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _reportStatChip('Orders', orders.length, 'all'),
                      const SizedBox(width: 8),
                      _reportStatChip('Done', completed, 'completed'),
                      const SizedBox(width: 8),
                      _reportStatChip('Pending', pending, 'pending'),
                      if (reportCount > 0) ...[
                        const SizedBox(width: 8),
                        _reportStatChip('Saved', reportCount, 'saved'),
                      ],
                    ],
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadReportsData,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final patient =
                          _patientForTest(patientProvider.patients, order);
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppConstants.primaryColor.withValues(alpha: 0.12),
                            child: const Icon(Icons.assignment,
                                color: AppConstants.primaryColor),
                          ),
                          title: Text(
                            order.patientName ?? patient.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${order.testName} · ${order.status} · ${order.orderedDate.toString().split(' ')[0]}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) async {
                              switch (v) {
                                case 'view':
                                  await _viewReport(order, patient);
                                  break;
                                case 'edit':
                                  await _editReport(order);
                                  break;
                                case 'delete':
                                  await _archiveReport(order);
                                  break;
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility),
                                    SizedBox(width: 8),
                                    Text('View / Print PDF'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.science, color: Colors.green),
                                    SizedBox(width: 8),
                                    Text('Enter lab results'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.archive, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Archive (delete)',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _viewReport(order, patient),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _reportStatChip(String label, int count, String filter) {
    final selected = _statusFilter == filter;
    return SizedBox(
      width: 110,
      child: FilterChip(
        label: Text('$label ($count)', overflow: TextOverflow.ellipsis),
        selected: selected,
        onSelected: (_) => setState(() => _statusFilter = filter),
      ),
    );
  }
}
