import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/django_api_service.dart';
import '../utils/constants.dart';
import '../utils/lab_currency.dart';
import '../widgets/sync_status_widget.dart';
import 'enhanced_add_patient_screen.dart';
import 'simple_add_test_screen.dart';
import 'appointment_scheduling_screen.dart';
import 'analytics_dashboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DjangoApiService _api = DjangoApiService();
  Map<String, dynamic>? _stats;
  Map<String, double>? _finance;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stats = await _api.getDashboardStatsNormalized();
      Map<String, double>? finance;
      try {
        finance = await _api.getFinancialSummary30d();
      } catch (_) {
        finance = {'received30d': 0, 'pendingDue30d': 0};
      }
      if (mounted) {
        setState(() {
          _stats = stats;
          _finance = finance;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('dashboard')),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDashboard),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadDashboard,
                            child: Text(context.tr('retry')),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SyncStatusWidget(),
                      if (_stats?['lastUpdated'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Updated ${_stats!['lastUpdated']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      const SizedBox(height: 16),
                      _dashboardMetricRow(
                        'Total Orders',
                        '${_stats!['totalOrders']}',
                        'Non-archived orders',
                        Icons.receipt_long,
                        const Color(0xFF667eea),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _dashboardMetricTile(
                              'Pending',
                              '${_stats!['pendingOrders']}',
                              '${_stats!['pendingOrders']} need attention',
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _dashboardMetricTile(
                              "Today's Appts",
                              '${_stats!['todayAppointments']}',
                              '${_stats!['todayAppointments']} scheduled today',
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _dashboardMetricRow(
                        'Completed Orders',
                        '${_stats!['completedOrders']}',
                        '${_stats!['inProgressOrders']} in progress • ${_stats!['completedOrders']} done',
                        Icons.check_circle,
                        Colors.green,
                      ),
                      const SizedBox(height: 16),
                      _dashboardMetricRow(
                        'Total Patients',
                        '${_stats!['totalPatients']}',
                        '${_stats!['recentPatients']} new (7 days)',
                        Icons.people,
                        Colors.indigo,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _financeCard(
                              'Received (30 Days)',
                              LabCurrency.formatWithSymbol(
                                (_finance?['received30d'] as num?) ?? 0,
                              ),
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _financeCard(
                              'Pending Due (30D)',
                              LabCurrency.formatWithSymbol(
                                (_finance?['pendingDue30d'] as num?) ?? 0,
                              ),
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ordersStatusChart(
                        (_stats!['pendingOrders'] as num).toInt(),
                        (_stats!['inProgressOrders'] as num).toInt(),
                        (_stats!['completedOrders'] as num).toInt(),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Quick Actions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _quickChip(context, 'Add Patient', Icons.person_add, () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const EnhancedAddPatientScreen()));
                          }),
                          _quickChip(context, 'New Test Order', Icons.science, () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const SimpleAddTestScreen()));
                          }),
                          _quickChip(context, 'Appointment', Icons.event, () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const AppointmentSchedulingScreen()));
                          }),
                          _quickChip(context, 'Analytics', Icons.insights, () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const AnalyticsDashboardScreen()));
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _dashboardMetricRow(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: color.withValues(alpha: 0.12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            value,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ),
    );
  }

  Widget _dashboardMetricTile(
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _financeCard(String title, String value, Color color) {
    return Card(
      color: color.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _ordersStatusChart(int pending, int inProgress, int completed) {
    final maxY = [pending, inProgress, completed].reduce((a, b) => a > b ? a : b);
    final maxVal = maxY <= 0 ? 4.0 : (maxY * 1.2).ceilToDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Orders by status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: maxVal,
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(toY: pending.toDouble(), color: Colors.orange, width: 28),
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(toY: inProgress.toDouble(), color: Colors.blue, width: 28),
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(toY: completed.toDouble(), color: Colors.green, width: 28),
                    ]),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          const labels = ['Pending', 'In prog.', 'Done'];
                          final i = v.toInt();
                          return Text(labels[i.clamp(0, 2)], style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickChip(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }

  Widget _buildActivityBarChart(
    BuildContext context,
    int patients,
    int tests,
    int appointments,
    int payments,
  ) {
    final values = [patients, tests, appointments, payments];
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final maxY = maxVal <= 0 ? 4.0 : (maxVal * 1.15).ceilToDouble();
    const colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];
    final labels = [
      context.tr('patients'),
      context.tr('tests'),
      context.tr('appts_short'),
      context.tr('payments'),
    ];

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap a bar for the exact count',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
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
                    horizontalInterval: maxY <= 8 ? 1 : null,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
                Text(
                  title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
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
