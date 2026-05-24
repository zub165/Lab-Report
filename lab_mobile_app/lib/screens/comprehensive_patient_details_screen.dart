import 'package:flutter/material.dart';
import '../services/django_api_service.dart';
import '../utils/constants.dart';
import '../utils/lab_currency.dart';
import 'comprehensive_payment_details_screen.dart';

class ComprehensivePatientDetailsScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const ComprehensivePatientDetailsScreen({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  State<ComprehensivePatientDetailsScreen> createState() => _ComprehensivePatientDetailsScreenState();
}

class _ComprehensivePatientDetailsScreenState extends State<ComprehensivePatientDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _apiService = DjangoApiService();
  
  Map<String, dynamic>? _comprehensiveData;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadComprehensiveData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadComprehensiveData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final data = await _apiService.getPatientComprehensiveData(widget.patientId);
      setState(() {
        _comprehensiveData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patientName),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Profile'),
            Tab(icon: Icon(Icons.science), text: 'Tests'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Appointments'),
            Tab(icon: Icon(Icons.payment), text: 'Payments'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadComprehensiveData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadComprehensiveData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTab(),
                    _buildTestsTab(),
                    _buildAppointmentsTab(),
                    _buildPaymentsTab(),
                  ],
                ),
    );
  }

  Widget _buildProfileTab() {
    if (_comprehensiveData == null) return const Center(child: Text('No data available'));

    final patient = _comprehensiveData!['patient'] as Map<String, dynamic>;
    final summary = _comprehensiveData!['summary'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientInfoCard(patient),
          const SizedBox(height: 16),
          _buildSummaryCards(summary),
        ],
      ),
    );
  }

  Widget _buildTestsTab() {
    if (_comprehensiveData == null) return const Center(child: Text('No data available'));

    final tests = _comprehensiveData!['tests'] as List<dynamic>;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index] as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(test['status']),
              child: const Icon(
                Icons.science,
                color: Colors.white,
              ),
            ),
            title: Text(test['test_name'] ?? 'Unknown Test'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${test['test_type'] ?? 'N/A'}'),
                Text('Status: ${test['status'] ?? 'N/A'}'),
                Text(
                  'Price: ${LabCurrency.formatWithSymbol(double.tryParse(test['price']?.toString() ?? '0') ?? 0)}',
                ),
                if (test['ordered_date'] != null)
                  Text('Ordered: ${_formatDate(test['ordered_date'])}'),
                if (test['completed_date'] != null)
                  Text('Completed: ${_formatDate(test['completed_date'])}'),
              ],
            ),
            trailing: _getStatusIcon(test['status']),
            onTap: () {
              // Navigate to test details
              _showTestDetails(test);
            },
          ),
        );
      },
    );
  }

  Widget _buildAppointmentsTab() {
    if (_comprehensiveData == null) return const Center(child: Text('No data available'));

    final appointments = _comprehensiveData!['appointments'] as List<dynamic>;

    if (appointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No appointments scheduled'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index] as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getAppointmentStatusColor(appointment['status']),
              child: const Icon(
                Icons.calendar_today,
                color: Colors.white,
              ),
            ),
            title: Text(appointment['test_type'] ?? 'Unknown Test'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${_formatDate(appointment['date'])}'),
                Text('Time: ${appointment['time'] ?? 'N/A'}'),
                Text('Location: ${appointment['location'] ?? 'N/A'}'),
                Text('Status: ${appointment['status'] ?? 'N/A'}'),
              ],
            ),
            trailing: _getAppointmentStatusIcon(appointment['status']),
            onTap: () {
              _showAppointmentDetails(appointment);
            },
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    if (_comprehensiveData == null) return const Center(child: Text('No data available'));

    final payments = _comprehensiveData!['payments'] as List<dynamic>;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: FilledButton.icon(
            onPressed: () async {
              final done = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => ProcessPaymentScreen(
                    filterPatientId: widget.patientId,
                    filterPatientName: widget.patientName,
                  ),
                ),
              );
              if (done == true) _loadComprehensiveData();
            },
            icon: const Icon(Icons.add_card),
            label: Text('Record charge (${LabCurrency.code})'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
          ),
        ),
        Expanded(
          child: payments.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No payments yet — tap Record charge'),
                    ],
                  ),
                )
              : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index] as Map<String, dynamic>;
        final amt = double.tryParse(payment['amount']?.toString() ?? '0') ?? 0;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getPaymentStatusColor(payment['status']),
              child: const Icon(
                Icons.payment,
                color: Colors.white,
              ),
            ),
            title: Text(LabCurrency.formatWithSymbol(amt)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Method: ${payment['payment_method'] ?? 'N/A'}'),
                Text('Status: ${payment['status'] ?? 'N/A'}'),
                Text('Date: ${_formatDate(payment['created_at'])}'),
              ],
            ),
            trailing: _getPaymentStatusIcon(payment['status']),
            onTap: () {
              _showPaymentDetails(payment);
            },
          ),
        );
      },
    ),
        ),
      ],
    );
  }

  Widget _buildPatientInfoCard(Map<String, dynamic> patient) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Full Name', patient['full_name'] ?? 'N/A'),
            _buildInfoRow('Date of Birth', _formatDate(patient['date_of_birth'])),
            _buildInfoRow('Gender', patient['gender'] ?? 'N/A'),
            _buildInfoRow('Phone', patient['phone'] ?? 'N/A'),
            _buildInfoRow('Email', patient['email'] ?? 'N/A'),
            _buildInfoRow('Address', patient['address'] ?? 'N/A'),
            _buildInfoRow('Blood Type', patient['blood_type'] ?? 'N/A'),
            _buildInfoRow('Insurance', patient['insurance_info'] ?? 'N/A'),
            _buildInfoRow('Medical History', patient['medical_history'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> summary) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Tests',
            '${summary['total_tests'] ?? 0}',
            '${summary['completed_tests'] ?? 0} completed',
            Icons.science,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Appointments',
            '${summary['total_appointments'] ?? 0}',
            '${summary['upcoming_appointments'] ?? 0} upcoming',
            Icons.calendar_today,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Payments',
            LabCurrency.formatWithSymbol(
              double.tryParse(summary['total_payments']?.toString() ?? '0') ?? 0,
              decimals: 0,
            ),
            '${LabCurrency.formatWithSymbol(double.tryParse(summary['paid_amount']?.toString() ?? '0') ?? 0, decimals: 0)} paid',
            Icons.payment,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
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
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
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

  Color _getAppointmentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'pending':
        return const Icon(Icons.schedule, color: Colors.orange);
      case 'cancelled':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.help, color: Colors.grey);
    }
  }

  Widget _getAppointmentStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'scheduled':
        return const Icon(Icons.schedule, color: Colors.blue);
      case 'completed':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'cancelled':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.help, color: Colors.grey);
    }
  }

  Widget _getPaymentStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'pending':
        return const Icon(Icons.schedule, color: Colors.orange);
      case 'failed':
        return const Icon(Icons.error, color: Colors.red);
      default:
        return const Icon(Icons.help, color: Colors.grey);
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  void _showTestDetails(Map<String, dynamic> test) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(test['test_name'] ?? 'Test Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Type', test['test_type'] ?? 'N/A'),
            _buildInfoRow('Status', test['status'] ?? 'N/A'),
            _buildInfoRow('Price', '\$${test['price']?.toStringAsFixed(2) ?? '0.00'}'),
            _buildInfoRow('Ordered', _formatDate(test['ordered_date'])),
            if (test['completed_date'] != null)
              _buildInfoRow('Completed', _formatDate(test['completed_date'])),
            if (test['results'] != null)
              _buildInfoRow('Results', test['results']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appointment['test_type'] ?? 'Appointment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Date', _formatDate(appointment['date'])),
            _buildInfoRow('Time', appointment['time'] ?? 'N/A'),
            _buildInfoRow('Location', appointment['location'] ?? 'N/A'),
            _buildInfoRow('Status', appointment['status'] ?? 'N/A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              'Amount',
              LabCurrency.formatWithSymbol(
                double.tryParse(payment['amount']?.toString() ?? '0') ?? 0,
              ),
            ),
            _buildInfoRow('Method', payment['payment_method'] ?? 'N/A'),
            _buildInfoRow('Status', payment['status'] ?? 'N/A'),
            _buildInfoRow('Date', _formatDate(payment['created_at'])),
            if (payment['transaction_id'] != null)
              _buildInfoRow('Transaction ID', payment['transaction_id']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
