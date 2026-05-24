import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/patient.dart';
import '../models/test.dart';
import '../models/report_data.dart';
import '../providers/auth_provider.dart';
import '../services/django_api_service.dart';
import '../utils/constants.dart';
import 'lab_currency.dart';
import '../screens/delete_account_screen.dart';

Widget apiTabPlaceholder({
  required IconData icon,
  required String title,
  required String message,
  VoidCallback? onRetry,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Patient patientFromTestOrder(Test test) {
  if (test.patient != null) return test.patient!;
  return Patient(
    patientId: test.patientId,
    fullName: test.patientName ?? 'Patient',
    dateOfBirth: DateTime.now(),
    gender: '—',
    phone: '—',
  );
}

Widget miniBarChartCard({
  required String title,
  required String subtitle,
  required List<String> labels,
  required List<int> values,
  required List<Color> colors,
}) {
  if (labels.isEmpty || values.isEmpty || labels.length != values.length) {
    return const SizedBox.shrink();
  }
  final maxVal = values.reduce((a, b) => a > b ? a : b);
  final maxY = maxVal <= 0 ? 2.0 : (maxVal * 1.15).ceilToDouble();

  return Card(
    elevation: 1,
    margin: const EdgeInsets.only(bottom: 8),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppConstants.primaryColor,
            ),
          ),
          Text(
            '$subtitle · tap bars',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: const Color(0xFF37474F),
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final i = group.x.toInt();
                      if (i < 0 || i >= labels.length) return null;
                      return BarTooltipItem(
                        '${labels[i]}\n${rod.toY.toInt()}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.black.withValues(alpha: 0.06),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 24,
                      showTitles: true,
                      interval: maxY <= 4 ? 1 : maxY / 4,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: labels.length > 4 ? 28 : 22,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            labels[i],
                            style: const TextStyle(fontSize: 9),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(
                  labels.length,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i].toDouble(),
                        width: 14,
                        color: colors[i % colors.length],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget patientsGenderMiniChart(List<Patient> patients) {
  var male = 0;
  var female = 0;
  var other = 0;
  for (final p in patients) {
    switch (p.gender.toLowerCase()) {
      case 'male':
        male++;
        break;
      case 'female':
        female++;
        break;
      default:
        other++;
    }
  }
  final total = male + female + other;
  if (total == 0) return const SizedBox.shrink();
  return miniBarChartCard(
    title: 'Patients by gender',
    subtitle: '$total total',
    labels: const ['Male', 'Female', 'Other'],
    values: [male, female, other],
    colors: const [
      Color(0xFF1976D2),
      Color(0xFFE91E63),
      Color(0xFF00897B),
    ],
  );
}

Widget testsStatusMiniChart(List<Test> tests) {
  if (tests.isEmpty) return const SizedBox.shrink();
  final counts = <String, int>{};
  for (final t in tests) {
    final key = t.status.isEmpty ? 'Unknown' : t.status;
    counts[key] = (counts[key] ?? 0) + 1;
  }
  final entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  final top = entries.take(6).toList();
  final labels = top
      .map((e) => e.key.length > 10 ? '${e.key.substring(0, 9)}…' : e.key)
      .toList();
  final values = top.map((e) => e.value).toList();
  const palette = [
    Color(0xFF43A047),
    Color(0xFFFB8C00),
    Color(0xFF1E88E5),
    Color(0xFF8E24AA),
    Color(0xFFE53935),
    Color(0xFF00897B),
  ];
  return miniBarChartCard(
    title: 'Tests by status',
    subtitle: '${tests.length} tests',
    labels: labels,
    values: values,
    colors: palette,
  );
}

Future<void> runAccountDeletionRequest(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Request account deletion'),
      content: const Text(
        'This submits a deletion request to the lab (not instant delete). '
        'Your request is saved on this device and you can email lab support to complete it. '
        'Continue?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Submit request'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text('Submitting deletion request…')),
          ],
        ),
      ),
    ),
  );

  try {
    final result = await DjangoApiService().requestAccountDeletion();
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.isSuccess ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }
}

Future<void> runLabDataExport(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(
              child: Text('Loading data from server and building CSV…'),
            ),
          ],
        ),
      ),
    ),
  );

  try {
    final result = await DjangoApiService().exportAllLabData();
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Export shared: ${result.summary} (${result.filePaths.length} file(s))',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }
}
