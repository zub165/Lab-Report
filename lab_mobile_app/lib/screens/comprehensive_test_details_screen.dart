import 'package:flutter/material.dart';
import '../services/django_api_service.dart';
import '../utils/constants.dart';

class ComprehensiveTestDetailsScreen extends StatefulWidget {
  final String testId;
  final String testName;

  const ComprehensiveTestDetailsScreen({
    Key? key,
    required this.testId,
    required this.testName,
  }) : super(key: key);

  @override
  State<ComprehensiveTestDetailsScreen> createState() => _ComprehensiveTestDetailsScreenState();
}

class _ComprehensiveTestDetailsScreenState extends State<ComprehensiveTestDetailsScreen> {
  final _apiService = DjangoApiService();
  
  Map<String, dynamic>? _comprehensiveData;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadComprehensiveData();
  }

  Future<void> _loadComprehensiveData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final data = await _apiService.getTestComprehensiveData(widget.testId);
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
        title: Text(widget.testName),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTestInfoCard(),
                      const SizedBox(height: 16),
                      _buildPatientInfoCard(),
                      const SizedBox(height: 16),
                      _buildAppointmentInfoCard(),
                      const SizedBox(height: 16),
                      _buildPaymentInfoCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTestInfoCard() {
    if (_comprehensiveData == null) return const SizedBox.shrink();

    final test = _comprehensiveData!['test'] as Map<String, dynamic>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science, color: AppConstants.primaryColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Test Information',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                _getStatusChip(test['status']),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Test Name', test['test_name'] ?? 'N/A'),
            _buildInfoRow('Test Type', test['test_type'] ?? 'N/A'),
            _buildInfoRow('Status', test['status'] ?? 'N/A'),
            _buildInfoRow('Price', '\$${test['price']?.toStringAsFixed(2) ?? '0.00'}'),
            _buildInfoRow('Ordered Date', _formatDate(test['ordered_date'])),
            if (test['completed_date'] != null)
              _buildInfoRow('Completed Date', _formatDate(test['completed_date'])),
            if (test['notes'] != null)
              _buildInfoRow('Notes', test['notes']),
            if (test['results'] != null)
              _buildInfoRow('Results', test['results']),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    if (_comprehensiveData == null) return const SizedBox.shrink();

    final patient = _comprehensiveData!['patient'] as Map<String, dynamic>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: AppConstants.primaryColor, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Patient Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', patient['full_name'] ?? 'N/A'),
            _buildInfoRow('Phone', patient['phone'] ?? 'N/A'),
            _buildInfoRow('Email', patient['email'] ?? 'N/A'),
            _buildInfoRow('Blood Type', patient['blood_type'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentInfoCard() {
    if (_comprehensiveData == null) return const SizedBox.shrink();

    final appointment = _comprehensiveData!['appointment'] as Map<String, dynamic>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: AppConstants.primaryColor, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Appointment Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Date', _formatDate(appointment['date'])),
            _buildInfoRow('Status', appointment['status'] ?? 'N/A'),
            _buildInfoRow('Location', appointment['location'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    if (_comprehensiveData == null) return const SizedBox.shrink();

    final payment = _comprehensiveData!['payment'] as Map<String, dynamic>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.payment, color: AppConstants.primaryColor, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Payment Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Amount', '\$${payment['amount']?.toStringAsFixed(2) ?? '0.00'}'),
            _buildInfoRow('Status', payment['status'] ?? 'N/A'),
            _buildInfoRow('Method', payment['payment_method'] ?? 'N/A'),
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

  Widget _getStatusChip(String? status) {
    Color color;
    switch (status?.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status ?? 'Unknown',
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
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
}
