import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/patient_provider.dart';
import '../providers/test_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/report_provider.dart';
import '../models/patient.dart';
import '../models/report_data.dart';
import '../models/test.dart';
import '../utils/constants.dart';
import 'analytics_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      await Future.wait([
        Provider.of<PatientProvider>(context, listen: false).loadPatients(),
        Provider.of<TestProvider>(context, listen: false).loadTests(),
        Provider.of<AppointmentProvider>(context, listen: false).loadAppointments(),
        Provider.of<PaymentProvider>(context, listen: false).loadPayments(),
        Provider.of<ReportProvider>(context, listen: false).loadReports(),
      ]);
    } catch (e) {
      print('Error loading initial data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DashboardScreen(),
          PatientsScreen(),
          TestsScreen(),
          ReportsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Tests'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SAEED Laboratory Dashboard'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer4<PatientProvider, TestProvider, AppointmentProvider, PaymentProvider>(
        builder: (context, patientProvider, testProvider, appointmentProvider, paymentProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Patients',
                        patientProvider.patients.length.toString(),
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Tests',
                        testProvider.tests.length.toString(),
                        Icons.science,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Appointments',
                        appointmentProvider.appointments.length.toString(),
                        Icons.calendar_today,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Payments',
                        paymentProvider.payments.length.toString(),
                        Icons.payment,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildActivityBarChart(
                  context,
                  patientProvider.patients.length,
                  testProvider.tests.length,
                  appointmentProvider.appointments.length,
                  paymentProvider.payments.length,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        'Add Patient',
                        Icons.person_add,
                        Colors.blue,
                        () => _showComingSoon(context, 'Add Patient'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        'Add Test',
                        Icons.science,
                        Colors.green,
                        () => _showComingSoon(context, 'Add Test'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        'Schedule Appointment',
                        Icons.calendar_today,
                        Colors.orange,
                        () => _showComingSoon(context, 'Schedule Appointment'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        'Generate Report',
                        Icons.assessment,
                        Colors.purple,
                        () => _showComingSoon(context, 'Generate Report'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
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
    const labels = ['Patients', 'Tests', 'Appts', 'Payments'];

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

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PatientProvider>(
        builder: (context, patientProvider, child) {
          if (patientProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (patientProvider.patients.isEmpty) {
            return const Center(
              child: Text('No patients found. Add some patients to get started.'),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _simplePatientsGenderMiniChart(patientProvider.patients),
              ),
              Expanded(
                child: ListView.builder(
            itemCount: patientProvider.patients.length,
            itemBuilder: (context, index) {
              final patient = patientProvider.patients[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(patient.fullName),
                subtitle: Text('${patient.phone} • ${patient.email ?? 'No email'}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showComingSoon(context, 'Patient Details'),
              );
            },
          ),
        ),
      ],
    );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showComingSoon(context, 'Add Patient'),
        child: const Icon(Icons.add),
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

class TestsScreen extends StatelessWidget {
  const TestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tests'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TestProvider>(
        builder: (context, testProvider, child) {
          if (testProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (testProvider.tests.isEmpty) {
            return const Center(
              child: Text('No tests found. Add some tests to get started.'),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _simpleTestsStatusMiniChart(testProvider.tests),
              ),
              Expanded(
                child: ListView.builder(
            itemCount: testProvider.tests.length,
            itemBuilder: (context, index) {
              final test = testProvider.tests[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.science),
                ),
                title: Text(test.testName),
                subtitle: Text('${test.status} • \$${test.price.toStringAsFixed(2)}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showComingSoon(context, 'Test Details'),
              );
            },
          ),
        ),
      ],
    );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showComingSoon(context, 'Add Test'),
        child: const Icon(Icons.add),
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

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ReportProvider>(
        builder: (context, reportProvider, child) {
          if (reportProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reportProvider.reports.isEmpty) {
            return const Center(
              child: Text('No reports found. Generate some reports to get started.'),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _simpleReportsStatusMiniChart(reportProvider.reports),
              ),
              Expanded(
                child: ListView.builder(
            itemCount: reportProvider.reports.length,
            itemBuilder: (context, index) {
              final report = reportProvider.reports[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.assessment),
                ),
                title: Text(report.title ?? 'Untitled Report'),
                subtitle: Text('${report.patientId} • ${report.reportDate?.toString().split(' ')[0] ?? 'No date'}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showComingSoon(context, 'Report Details'),
              );
            },
          ),
        ),
      ],
    );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showComingSoon(context, 'Generate Report'),
        child: const Icon(Icons.add),
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

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection(
            'Laboratory',
            [
              _buildSettingsTile(
                'Laboratory Information',
                'Manage lab details and settings',
                Icons.business,
                () => _showComingSoon(context, 'Laboratory Information'),
              ),
              _buildSettingsTile(
                'User Management',
                'Manage system users',
                Icons.people,
                () => _showComingSoon(context, 'User Management'),
              ),
              _buildSettingsTile(
                'Analytics & charts',
                'Visual trends for patients, tests, and revenue',
                Icons.bar_chart,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnalyticsDashboardScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            'System',
            [
              _buildSettingsTile(
                'API Connection',
                'Test backend connectivity',
                Icons.cloud,
                () => _showComingSoon(context, 'API Connection'),
              ),
              _buildSettingsTile(
                'Database Management',
                'Manage local database',
                Icons.storage,
                () => _showComingSoon(context, 'Database Management'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            'Account',
            [
              _buildSettingsTile(
                'Profile',
                'View and edit profile',
                Icons.person,
                () => _showComingSoon(context, 'Profile'),
              ),
              _buildSettingsTile(
                'Logout',
                'Sign out of the application',
                Icons.logout,
                () => _showLogoutDialog(context),
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppConstants.primaryColor,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// --- Mini charts (simple shell; mirrors main home_screen tab charts) ---

Widget _simpleMiniBarChartCard({
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
                      reservedSize: 22,
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

Widget _simplePatientsGenderMiniChart(List<Patient> patients) {
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
  return _simpleMiniBarChartCard(
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

Widget _simpleTestsStatusMiniChart(List<Test> tests) {
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
  return _simpleMiniBarChartCard(
    title: 'Tests by status',
    subtitle: '${tests.length} tests',
    labels: labels,
    values: values,
    colors: palette,
  );
}

Widget _simpleReportsStatusMiniChart(List<ReportData> reports) {
  if (reports.isEmpty) return const SizedBox.shrink();
  var draft = 0;
  var pending = 0;
  var done = 0;
  var other = 0;
  for (final r in reports) {
    final s = (r.status ?? '').toLowerCase();
    if (s.contains('draft')) {
      draft++;
    } else if (s.contains('pending')) {
      pending++;
    } else if (s.contains('complete')) {
      done++;
    } else {
      other++;
    }
  }
  return _simpleMiniBarChartCard(
    title: 'Reports by status',
    subtitle: '${reports.length} reports',
    labels: const ['Draft', 'Pending', 'Done', 'Other'],
    values: [draft, pending, done, other],
    colors: const [
      Color(0xFF546E7A),
      Color(0xFFFB8C00),
      Color(0xFF43A047),
      Color(0xFF9E9E9E),
    ],
  );
}
