import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/test_provider.dart';
import '../providers/language_provider.dart';
import '../models/patient.dart';
import '../models/test.dart';
import '../utils/constants.dart';
import '../utils/lab_currency.dart';
import '../utils/tab_helpers.dart';
import 'comprehensive_test_details_screen.dart';
import 'report_preview_screen.dart';
import 'edit_test_screen.dart';

class TestsScreen extends StatelessWidget {
  const TestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('tests')),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final testProvider = Provider.of<TestProvider>(context, listen: false);
              testProvider.loadTests();
            },
          ),
        ],
      ),
      body: Consumer<TestProvider>(
        builder: (context, testProvider, child) {
          if (testProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (testProvider.tests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.science, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No tests found. Add some tests to get started.'),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: testsStatusMiniChart(testProvider.tests),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: testProvider.tests.length,
                  itemBuilder: (context, index) {
                    final test = testProvider.tests[index];
                    final patient = test.patient;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        isThreeLine: true,
                        leading: CircleAvatar(
                          backgroundColor: _getTestStatusColor(test.status),
                          child: const Icon(Icons.science, color: Colors.white),
                        ),
                        title: Text(
                          test.testName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${test.testType} • ${LabCurrency.formatWithSymbol(test.price)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Patient: ${patient?.fullName ?? test.patientName ?? 'Unknown'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Status: ${test.status}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'view':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ComprehensiveTestDetailsScreen(
                                      testId: test.testId ?? '',
                                      testName: test.testName,
                                    ),
                                  ),
                                );
                                break;
                              case 'report':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReportPreviewScreen(
                                      patient: patientFromTestOrder(test),
                                      test: test,
                                    ),
                                  ),
                                );
                                break;
                              case 'edit':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTestScreen(test: test),
                                  ),
                                );
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
                              value: 'report',
                              child: Row(
                                children: [
                                  Icon(Icons.description_outlined),
                                  SizedBox(width: 8),
                                  Text('View Report'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Edit Test'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComprehensiveTestDetailsScreen(
                              testId: test.testId ?? '',
                              testName: test.testName,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getTestStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature functionality - Coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
