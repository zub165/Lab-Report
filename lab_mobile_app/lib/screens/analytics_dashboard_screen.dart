import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';
import '../providers/test_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/payment_provider.dart';
import '../models/patient.dart';
import '../models/test.dart';
import '../models/appointment.dart';
import '../models/payment.dart';
import '../utils/constants.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  String _selectedTimeRange = '30d';
  // String _selectedMetric = 'all'; // For future use

  final List<String> _timeRanges = ['7d', '30d', '90d', '1y'];
  final List<String> _metrics = ['all', 'patients', 'tests', 'appointments', 'payments'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _selectedTimeRange = value),
            itemBuilder: (context) => _timeRanges.map((range) {
              return PopupMenuItem(
                value: range,
                child: Text(_getTimeRangeLabel(range)),
              );
            }).toList(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.analytics),
            onSelected: (value) => setState(() {
              // _selectedMetric = value; // For future use
            }),
            itemBuilder: (context) => _metrics.map((metric) {
              return PopupMenuItem(
                value: metric,
                child: Text(_getMetricLabel(metric)),
              );
            }).toList(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            _buildOverviewCards(),
            const SizedBox(height: 24),

            // Key Metrics
            _buildKeyMetrics(),
            const SizedBox(height: 24),

            // Charts Section
            _buildChartsSection(),
            const SizedBox(height: 24),

            // Recent Activity
            _buildRecentActivity(),
            const SizedBox(height: 24),

            // Performance Indicators
            _buildPerformanceIndicators(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Consumer4<PatientProvider, TestProvider, AppointmentProvider, PaymentProvider>(
      builder: (context, patientProvider, testProvider, appointmentProvider, paymentProvider, child) {
        final patients = patientProvider.patients;
        final tests = testProvider.tests;
        final appointments = appointmentProvider.appointments;
        final payments = paymentProvider.payments;

        final filteredData = _getFilteredData(patients, tests, appointments, payments);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Total Patients',
                    filteredData['patients'].toString(),
                    Icons.people,
                    Colors.blue,
                                         _getPatientGrowth(filteredData['patients'] as int, patients.length),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Total Tests',
                    filteredData['tests'].toString(),
                    Icons.science,
                    Colors.green,
                                         _getTestGrowth(filteredData['tests'] as int, tests.length),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Appointments',
                    filteredData['appointments'].toString(),
                    Icons.calendar_today,
                    Colors.orange,
                                         _getAppointmentGrowth(filteredData['appointments'] as int, appointments.length),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                                         'Revenue',
                     '\$${(filteredData['revenue'] as double).toStringAsFixed(0)}',
                     Icons.attach_money,
                     Colors.purple,
                     _getRevenueGrowth(filteredData['revenue'] as double, _calculateTotalRevenue(payments)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, double growth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: growth >= 0 ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: growth >= 0 ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return Consumer4<PatientProvider, TestProvider, AppointmentProvider, PaymentProvider>(
      builder: (context, patientProvider, testProvider, appointmentProvider, paymentProvider, child) {
        final patients = patientProvider.patients;
        final tests = testProvider.tests;
        final appointments = appointmentProvider.appointments;
        final payments = paymentProvider.payments;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Key Metrics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildKeyMetricItem(
                    'Test Completion Rate',
                    '${_calculateTestCompletionRate(tests)}%',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKeyMetricItem(
                    'Patient Satisfaction',
                    '${_calculatePatientSatisfaction(patients)}%',
                    Icons.sentiment_satisfied,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildKeyMetricItem(
                    'Appointment Attendance',
                    '${_calculateAppointmentAttendance(appointments)}%',
                    Icons.event_available,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKeyMetricItem(
                    'Payment Collection',
                    '${_calculatePaymentCollection(payments)}%',
                    Icons.payment,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildKeyMetricItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trends & Insights',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildLabVolumeBarChart(),
        const SizedBox(height: 16),

        // Test Types Distribution
        _buildTestTypesChart(),
        const SizedBox(height: 16),
        
        // Patient Demographics
        _buildPatientDemographics(),
        const SizedBox(height: 16),
        
        // Revenue Trends
        _buildRevenueTrends(),
      ],
    );
  }

  Widget _buildLabVolumeBarChart() {
    return Consumer4<PatientProvider, TestProvider, AppointmentProvider, PaymentProvider>(
      builder: (context, patientProvider, testProvider, appointmentProvider, paymentProvider, _) {
        final p = patientProvider.patients.length;
        final t = testProvider.tests.length;
        final a = appointmentProvider.appointments.length;
        final pay = paymentProvider.payments.length;
        final values = [p, t, a, pay];
        final maxVal = values.fold<int>(0, (m, v) => math.max(m, v));
        final maxY = maxVal <= 0 ? 4.0 : (maxVal * 1.15).ceilToDouble();
        const colors = [Color(0xFF1E88E5), Color(0xFF43A047), Color(0xFFFB8C00), Color(0xFF8E24AA)];
        const labels = ['Patients', 'Tests', 'Appts', 'Payments'];

        return _chartCard(
          title: 'Workspace volume',
          subtitle: 'Current totals · tap bars for values',
          child: SizedBox(
            height: 200,
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
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY <= 8 ? 1 : maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
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
                      reservedSize: 32,
                      showTitles: true,
                      interval: maxY <= 8 ? 1 : maxY / 4,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) {
                        final i = value.toInt();
                        if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            labels[i],
                            style: const TextStyle(fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(4, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i].toDouble(),
                        width: 22,
                        color: colors[i],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _chartCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildTestTypesChart() {
    return Consumer<TestProvider>(
      builder: (context, testProvider, child) {
        final tests = testProvider.tests;
        if (tests.isEmpty) {
          return _chartCard(
            title: 'Test types distribution',
            subtitle: 'No tests recorded yet',
            child: const SizedBox(
              height: 160,
              child: Center(child: Text('Add tests to see a chart')),
            ),
          );
        }

        final raw = _getTestTypeDistribution(tests);
        final entries = raw.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        const topN = 5;
        final top = entries.take(topN).toList();
        int otherSum = 0;
        if (entries.length > topN) {
          otherSum = entries.skip(topN).fold(0, (s, e) => s + e.value);
        }
        final slices = <MapEntry<String, int>>[...top];
        if (otherSum > 0) {
          slices.add(MapEntry('Other', otherSum));
        }

        final total = tests.length;
        final pieSections = <PieChartSectionData>[];
        for (final e in slices) {
          final pct = (e.value / total * 100);
          final color = e.key == 'Other' ? Colors.blueGrey : _getTestTypeColor(e.key);
          pieSections.add(
            PieChartSectionData(
              color: color,
              value: e.value.toDouble(),
              title: '${e.value}\n${pct.toStringAsFixed(0)}%',
              radius: 52,
              titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
              ),
            ),
          );
        }

        return _chartCard(
          title: 'Test types distribution',
          subtitle: 'Share by type · counts on slices',
          child: Row(
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 1,
                    centerSpaceRadius: 28,
                    sections: pieSections,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: slices.map((e) {
                    final color = e.key == 'Other' ? Colors.blueGrey : _getTestTypeColor(e.key);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              e.key,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${e.value}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPatientDemographics() {
    return Consumer<PatientProvider>(
      builder: (context, patientProvider, child) {
        final patients = patientProvider.patients;
        final demographics = _getPatientDemographics(patients);
        final male = demographics['male']!;
        final female = demographics['female']!;
        final other = patients.length - male - female;
        final genderTotal = male + female + other;

        if (genderTotal == 0) {
          return _chartCard(
            title: 'Patient demographics',
            subtitle: 'No patients yet',
            child: const SizedBox(
              height: 140,
              child: Center(child: Text('Add patients to see gender mix')),
            ),
          );
        }

        final sections = <PieChartSectionData>[];
        void addSlice(int count, Color color) {
          if (count <= 0) return;
          final pct = count / genderTotal * 100;
          sections.add(
            PieChartSectionData(
              color: color,
              value: count.toDouble(),
              title: '$count\n${pct.toStringAsFixed(0)}%',
              radius: 48,
              titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
              ),
            ),
          );
        }

        addSlice(male, Colors.blue);
        addSlice(female, Colors.pink);
        addSlice(other, Colors.teal);

        return _chartCard(
          title: 'Patient demographics',
          subtitle: 'Avg age ${demographics['avgAge']} · counts on slices',
          child: Row(
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 1,
                    centerSpaceRadius: 36,
                    sections: sections,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _demoLegendRow(Colors.blue, 'Male', male),
                    _demoLegendRow(Colors.pink, 'Female', female),
                    if (other > 0) _demoLegendRow(Colors.teal, 'Other / not specified', other),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _demoLegendRow(Color color, String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRevenueTrends() {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, child) {
        final revenueData = _getRevenueTrends(paymentProvider.payments);
        final entries = revenueData.entries.toList();
        final amounts = entries.map((e) => e.value).toList();
        final maxVal = amounts.fold<double>(0, (m, v) => v > m ? v : m);
        final maxY = maxVal <= 0 ? 100.0 : (maxVal * 1.2).ceilToDouble();
        const barColor = Color(0xFF6A1B9A);

        return _chartCard(
          title: 'Revenue by period',
          subtitle: 'Payments in each window · tap bars',
          child: Column(
            children: [
              SizedBox(
                height: 200,
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
                          if (i < 0 || i >= entries.length) return null;
                          return BarTooltipItem(
                            '${entries[i].key}\n\$${rod.toY.toStringAsFixed(0)}',
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
                      getDrawingHorizontalLine: (value) => FlLine(
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
                          reservedSize: 40,
                          showTitles: true,
                          interval: maxY > 500 ? maxY / 4 : null,
                          getTitlesWidget: (v, _) => Text(
                            '\$${v.toInt()}',
                            style: const TextStyle(fontSize: 9, color: Colors.grey),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          getTitlesWidget: (value, _) {
                            final i = value.toInt();
                            if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                entries[i].key,
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(entries.length, (i) {
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: entries[i].value,
                            width: 26,
                            color: barColor,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: entries
                    .map(
                      (e) => Text(
                        '${e.key}: \$${e.value.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return Consumer4<PatientProvider, TestProvider, AppointmentProvider, PaymentProvider>(
      builder: (context, patientProvider, testProvider, appointmentProvider, paymentProvider, child) {
        final recentActivity = _getRecentActivity(
          patientProvider.patients,
          testProvider.tests,
          appointmentProvider.appointments,
          paymentProvider.payments,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentActivity.length,
                itemBuilder: (context, index) {
                  final activity = recentActivity[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: activity['color'],
                      child: Icon(activity['icon'], color: Colors.white, size: 20),
                    ),
                    title: Text(activity['title']),
                    subtitle: Text(activity['subtitle']),
                    trailing: Text(
                      activity['time'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPerformanceIndicators() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Indicators',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPerformanceCard(
                'Efficiency',
                '85%',
                Icons.speed,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPerformanceCard(
                'Quality',
                '92%',
                Icons.verified,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPerformanceCard(
                'Customer Satisfaction',
                '88%',
                Icons.thumb_up,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPerformanceCard(
                'Revenue Growth',
                '+12%',
                Icons.trending_up,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  Map<String, dynamic> _getFilteredData(List<Patient> patients, List<Test> tests, List<Appointment> appointments, List<Payment> payments) {
    final now = DateTime.now();
    final days = _getDaysFromTimeRange(_selectedTimeRange);
    final startDate = now.subtract(Duration(days: days));

    return {
      'patients': patients.where((p) => p.createdAt != null && p.createdAt!.isAfter(startDate)).length,
      'tests': tests.where((t) => t.createdAt != null && t.createdAt!.isAfter(startDate)).length,
      'appointments': appointments.where((a) => a.appointmentDate.isAfter(startDate)).length,
      'revenue': _calculateFilteredRevenue(payments, startDate),
    };
  }

  int _getDaysFromTimeRange(String range) {
    switch (range) {
      case '7d': return 7;
      case '30d': return 30;
      case '90d': return 90;
      case '1y': return 365;
      default: return 30;
    }
  }

  String _getTimeRangeLabel(String range) {
    switch (range) {
      case '7d': return 'Last 7 Days';
      case '30d': return 'Last 30 Days';
      case '90d': return 'Last 90 Days';
      case '1y': return 'Last Year';
      default: return 'Last 30 Days';
    }
  }

  String _getMetricLabel(String metric) {
    switch (metric) {
      case 'all': return 'All Metrics';
      case 'patients': return 'Patients Only';
      case 'tests': return 'Tests Only';
      case 'appointments': return 'Appointments Only';
      case 'payments': return 'Payments Only';
      default: return 'All Metrics';
    }
  }

  double _getPatientGrowth(int filtered, int total) {
    if (total == 0) return 0;
    return ((filtered - (total - filtered)) / total * 100);
  }

  double _getTestGrowth(int filtered, int total) {
    if (total == 0) return 0;
    return ((filtered - (total - filtered)) / total * 100);
  }

  double _getAppointmentGrowth(int filtered, int total) {
    if (total == 0) return 0;
    return ((filtered - (total - filtered)) / total * 100);
  }

  double _getRevenueGrowth(double filtered, double total) {
    if (total == 0) return 0;
    return ((filtered - (total - filtered)) / total * 100);
  }

  double _calculateTestCompletionRate(List<Test> tests) {
    if (tests.isEmpty) return 0;
    final completed = tests.where((t) => t.status.toLowerCase() == 'completed').length;
    return (completed / tests.length * 100);
  }

  double _calculatePatientSatisfaction(List<Patient> patients) {
    // Mock calculation - in real app, this would come from patient feedback
    return 85.0;
  }

  double _calculateAppointmentAttendance(List<Appointment> appointments) {
    if (appointments.isEmpty) return 0;
    final attended = appointments.where((a) => a.status.toLowerCase() == 'completed').length;
    return (attended / appointments.length * 100);
  }

  double _calculatePaymentCollection(List<Payment> payments) {
    if (payments.isEmpty) return 0;
    final collected = payments.where((p) => p.status.toLowerCase() == 'completed').length;
    return (collected / payments.length * 100);
  }

  double _calculateTotalRevenue(List<Payment> payments) {
    return payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  double _calculateFilteredRevenue(List<Payment> payments, DateTime startDate) {
    return payments
        .where((p) => p.createdAt.isAfter(startDate))
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  Map<String, int> _getTestTypeDistribution(List<Test> tests) {
    final distribution = <String, int>{};
    for (final test in tests) {
      distribution[test.testType] = (distribution[test.testType] ?? 0) + 1;
    }
    return distribution;
  }

  Color _getTestTypeColor(String testType) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    return colors[testType.hashCode % colors.length];
  }

  Map<String, int> _getPatientDemographics(List<Patient> patients) {
    final male = patients.where((p) => p.gender.toLowerCase() == 'male').length;
    final female = patients.where((p) => p.gender.toLowerCase() == 'female').length;
    final totalAge = patients.fold(0, (sum, p) => sum + p.age);
    final avgAge = patients.isEmpty ? 0 : (totalAge / patients.length).round();

    return {
      'male': male,
      'female': female,
      'avgAge': avgAge,
    };
  }

  Map<String, double> _getRevenueTrends(List<Payment> payments) {
    final now = DateTime.now();
    final lastMonth = now.subtract(const Duration(days: 30));
    final lastQuarter = now.subtract(const Duration(days: 90));
    final lastYear = now.subtract(const Duration(days: 365));

    return {
      'This Month': _calculateFilteredRevenue(payments, lastMonth),
      'This Quarter': _calculateFilteredRevenue(payments, lastQuarter),
      'This Year': _calculateFilteredRevenue(payments, lastYear),
    };
  }

  List<Map<String, dynamic>> _getRecentActivity(
    List<Patient> patients,
    List<Test> tests,
    List<Appointment> appointments,
    List<Payment> payments,
  ) {
    final activities = <Map<String, dynamic>>[];

    // Add recent patients
    final recentPatients = patients
        .where((p) => p.createdAt != null && p.createdAt!.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .take(3);
    
    for (final patient in recentPatients) {
      activities.add({
        'title': 'New Patient Registered',
        'subtitle': patient.fullName,
        'time': _getTimeAgo(patient.createdAt!),
        'icon': Icons.person_add,
        'color': Colors.blue,
      });
    }

    // Add recent tests
    final recentTests = tests
        .where((t) => t.createdAt != null && t.createdAt!.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .take(3);
    
    for (final test in recentTests) {
      activities.add({
        'title': 'Test Completed',
        'subtitle': test.testName,
        'time': _getTimeAgo(test.createdAt!),
        'icon': Icons.science,
        'color': Colors.green,
      });
    }

    // Add recent appointments
    final recentAppointments = appointments
        .where((a) => a.appointmentDate.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .take(3);
    
    for (final appointment in recentAppointments) {
      activities.add({
        'title': 'Appointment Scheduled',
        'subtitle': appointment.testType,
        'time': _getTimeAgo(appointment.appointmentDate),
        'icon': Icons.calendar_today,
        'color': Colors.orange,
      });
    }

    // Sort by time and take top 10
    activities.sort((a, b) => b['time'].compareTo(a['time']));
    return activities.take(10).toList();
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
