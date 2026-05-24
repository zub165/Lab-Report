import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/patient_provider.dart';
import '../providers/test_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/report_provider.dart';
import '../providers/user_provider.dart';
import '../providers/language_provider.dart';
import '../utils/constants.dart';
import '../services/advanced_report_service.dart';
import 'dashboard_tab.dart';
import 'tests_tab.dart';
import 'patients_tab.dart';
import 'appointments_tab.dart';
import 'payments_tab.dart';
import 'reports_tab.dart';
import 'archive_tab.dart';
import 'lab_images_tab.dart';
import 'staff_tab.dart';
import 'settings_tab.dart';
import 'enhanced_add_patient_screen.dart';
import 'simple_add_test_screen.dart';
import 'appointment_scheduling_screen.dart';
import 'advanced_report_screen.dart';
import 'lab_test_selection_screen.dart';
import 'comprehensive_payment_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  int _currentIndex = 0;
  int _bottomNavIndex = 1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppConstants.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    AppConstants.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _refreshTabData(_currentIndex);
  }

  List<_LabNavItem> _navItems(LanguageProvider l) => [
        _LabNavItem(0, Icons.dashboard, l.getText('dashboard')),
        _LabNavItem(1, Icons.science, l.getText('lab_tests')),
        _LabNavItem(2, Icons.people, l.getText('patients')),
        _LabNavItem(3, Icons.calendar_today, l.getText('appointments')),
        _LabNavItem(4, Icons.payments, l.getText('payments')),
        _LabNavItem(5, Icons.assessment, l.getText('reports')),
        _LabNavItem(6, Icons.archive, l.getText('archive')),
        _LabNavItem(7, Icons.image, l.getText('images')),
        _LabNavItem(8, Icons.badge, l.getText('staff')),
        _LabNavItem(9, Icons.settings, l.getText('settings')),
      ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await Future.wait([
          Provider.of<PatientProvider>(context, listen: false).loadPatients(),
          Provider.of<TestProvider>(context, listen: false).loadTests(),
          Provider.of<AppointmentProvider>(context, listen: false).loadAppointments(),
          Provider.of<PaymentProvider>(context, listen: false).loadPayments(),
          Provider.of<UserProvider>(context, listen: false).loadUsers(),
        ]);
      } catch (e) {
        print('Error loading initial data: $e');
      }
    });
  }

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
      if (index <= 2) {
        _bottomNavIndex = index + 1;
      } else {
        _bottomNavIndex = 4;
      }
    });
    _scaffoldKey.currentState?.closeDrawer();
    _refreshTabData(index);
  }

  void _openDrawer() {
    setState(() => _bottomNavIndex = 0);
    _scaffoldKey.currentState?.openDrawer();
  }

  void _showMoreModules() {
    final l = context.read<LanguageProvider>();
    final nav = _navItems(l);
    setState(() => _bottomNavIndex = 4);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final bottomInset = MediaQuery.paddingOf(ctx).bottom;
        return ListView(
          padding: EdgeInsets.fromLTRB(0, 0, 0, bottomInset + 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                l.getText('more_modules'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...nav.skip(3).take(7).map((item) {
              return ListTile(
                leading: Icon(item.icon, color: AppConstants.primaryColor),
                title: Text(item.label, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: _currentIndex == item.index
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  _selectTab(item.index);
                },
              );
            }),
          ],
        );
      },
    );
  }

  Future<void> _refreshTabData(int index) async {
    if (!mounted) return;
    final ctx = context;
    switch (index) {
      case 0:
        await _refreshAll();
        break;
      case 1:
        await Provider.of<TestProvider>(ctx, listen: false).loadTests();
        break;
      case 2:
        await Provider.of<PatientProvider>(ctx, listen: false).loadPatients();
        break;
      case 3:
        await Provider.of<AppointmentProvider>(ctx, listen: false).loadAppointments();
        break;
      case 4:
        await Provider.of<PaymentProvider>(ctx, listen: false).loadPayments();
        break;
      case 5:
        await Provider.of<TestProvider>(ctx, listen: false).loadTests();
        await Provider.of<PatientProvider>(ctx, listen: false).loadPatients();
        break;
      case 6:
        break;
      case 8:
        await Provider.of<UserProvider>(ctx, listen: false).loadUsers();
        break;
      default:
        break;
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      Provider.of<PatientProvider>(context, listen: false).loadPatients(),
      Provider.of<TestProvider>(context, listen: false).loadTests(),
      Provider.of<AppointmentProvider>(context, listen: false).loadAppointments(),
      Provider.of<PaymentProvider>(context, listen: false).loadPayments(),
      Provider.of<ReportProvider>(context, listen: false).loadReports(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final navItems = _navItems(lang);
    final fab = _buildFab();
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.biotech, color: Colors.white, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      lang.getText('lab_management'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => Text(
                        auth.username ?? 'Staff',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: navItems.map((item) {
                  final selected = _currentIndex == item.index;
                  return ListTile(
                    leading: Icon(
                      item.icon,
                      color: selected ? AppConstants.primaryColor : null,
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        color: selected ? AppConstants.primaryColor : null,
                      ),
                    ),
                    selected: selected,
                    onTap: () => _selectTab(item.index),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(lang.getText('log_out')),
              onTap: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DashboardScreen(),
          TestsScreen(),
          PatientsScreen(),
          AppointmentsScreen(),
          PaymentsScreen(),
          ReportsScreen(),
          ArchiveScreen(),
          LabImagesScreen(),
          StaffScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              _openDrawer();
              break;
            case 1:
              _selectTab(0);
              break;
            case 2:
              _selectTab(1);
              break;
            case 3:
              _selectTab(2);
              break;
            case 4:
              _showMoreModules();
              break;
          }
        },
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.menu), label: lang.getText('menu')),
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard), label: lang.getText('home')),
          BottomNavigationBarItem(icon: const Icon(Icons.science), label: lang.getText('tests')),
          BottomNavigationBarItem(icon: const Icon(Icons.people), label: lang.getText('patients')),
          BottomNavigationBarItem(icon: const Icon(Icons.apps), label: lang.getText('more')),
        ],
      ),
      floatingActionButton: fab == null
          ? null
          : KeyedSubtree(
              key: ValueKey<int>(_currentIndex),
              child: fab,
            ),
    );
  }

  Widget? _buildFab() {
    const fabHero = 'home_main_fab';
    switch (_currentIndex) {
      case 0:
        return FloatingActionButton(
          heroTag: fabHero,
          onPressed: _refreshAll,
          tooltip: 'Refresh dashboard',
          child: const Icon(Icons.refresh),
        );
      case 1:
        return FloatingActionButton(
          heroTag: fabHero,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LabTestSelectionScreen()),
          ),
          tooltip: 'New test order',
          child: const Icon(Icons.add),
        );
      case 2:
        return FloatingActionButton(
          heroTag: fabHero,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EnhancedAddPatientScreen()),
          ),
          tooltip: 'Add patient',
          child: const Icon(Icons.person_add),
        );
      case 3:
        return FloatingActionButton(
          heroTag: fabHero,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AppointmentSchedulingScreen()),
          ),
          tooltip: 'New appointment',
          child: const Icon(Icons.add),
        );
      case 4:
        return FloatingActionButton(
          heroTag: fabHero,
          onPressed: () async {
            final done = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const ProcessPaymentScreen()),
            );
            if (done == true && context.mounted) {
              context.read<PaymentProvider>().loadPayments();
            }
          },
          tooltip: 'Cash / Card / Insurance payment',
          child: const Icon(Icons.payments),
        );
      case 5:
        return FloatingActionButton(
          heroTag: fabHero,
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdvancedReportScreen()),
            );
            if (context.mounted) {
              context.read<TestProvider>().loadTests();
            }
          },
          tooltip: 'Generate report',
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }
}

class _LabNavItem {
  final int index;
  final IconData icon;
  final String label;
  const _LabNavItem(this.index, this.icon, this.label);
}
