import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';
import '../providers/language_provider.dart';
import '../providers/test_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/payment_provider.dart';
import '../models/patient.dart';
import '../utils/constants.dart';
import '../utils/lab_currency.dart';
import '../utils/tab_helpers.dart';
import 'comprehensive_patient_details_screen.dart';
import 'lab_test_selection_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PatientProvider>(context, listen: false).loadPatients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('patients')),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<PatientProvider>(context, listen: false).loadPatients();
            },
          ),
        ],
      ),
      body: Consumer2<PatientProvider, TestProvider>(
        builder: (context, patientProvider, testProvider, child) {
          final tests = testProvider.tests;
          final patientTests = <String, int>{};
          final patientAppts = <String, int>{};
          final patientPayments = <String, double>{};
          for (final t in tests) {
            final pid = t.patientId;
            patientTests[pid] = (patientTests[pid] ?? 0) + 1;
          }
          final appts = context.watch<AppointmentProvider>().appointments;
          for (final a in appts) {
            final pid = a.patientId;
            patientAppts[pid] = (patientAppts[pid] ?? 0) + 1;
          }
          final payments = context.watch<PaymentProvider>().payments;
          for (final p in payments) {
            final pid = p.patientId;
            patientPayments[pid] = (patientPayments[pid] ?? 0) + p.amount;
          }

          if (patientProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (patientProvider.patients.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No patients found. Add some patients to get started.'),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: patientsGenderMiniChart(patientProvider.patients),
              ),
              Expanded(
                child: ListView.builder(
            itemCount: patientProvider.patients.length,
            itemBuilder: (context, index) {
              final patient = patientProvider.patients[index];
              final pid = patient.patientId ?? '';
              final testCount = patientTests[pid] ?? 0;
              final apptCount = patientAppts[pid] ?? 0;
              final payTotal = patientPayments[pid] ?? 0.0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  isThreeLine: true,
                  leading: CircleAvatar(
                    backgroundColor: AppConstants.primaryColor,
                    child: Text(
                      (patient.fullName ?? 'Unknown')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    patient.fullName ?? 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.phone ?? 'No phone',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          _buildSummaryChip('Tests', '$testCount', Colors.blue),
                          _buildSummaryChip('Appts', '$apptCount', Colors.green),
                          _buildSummaryChip(
                            'Pay',
                            LabCurrency.formatWithSymbol(payTotal, decimals: 0),
                            Colors.orange,
                          ),
                        ],
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
                              builder: (context) => ComprehensivePatientDetailsScreen(
                                patientId: patient.patientId ?? '',
                                patientName: patient.fullName ?? 'Unknown',
                              ),
                            ),
                          );
                          break;
                        case 'order_test':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LabTestSelectionScreen(selectedPatient: null),
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
                        value: 'order_test',
                        child: Row(
                          children: [
                            Icon(Icons.science),
                            SizedBox(width: 8),
                            Text('Order Test'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ComprehensivePatientDetailsScreen(
                        patientId: patient.patientId ?? '',
                        patientName: patient.fullName ?? 'Unknown',
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

  Widget _buildSummaryChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
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
