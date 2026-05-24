import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:provider/provider.dart';
import '../models/payment.dart';
import '../models/test.dart';
import '../providers/payment_provider.dart';
import '../providers/test_provider.dart';
import '../services/django_api_service.dart';
import '../utils/constants.dart';
import '../utils/lab_currency.dart';

class ComprehensivePaymentDetailsScreen extends StatefulWidget {
  final String paymentId;
  final String amount;

  const ComprehensivePaymentDetailsScreen({
    Key? key,
    required this.paymentId,
    required this.amount,
  }) : super(key: key);

  @override
  State<ComprehensivePaymentDetailsScreen> createState() => _ComprehensivePaymentDetailsScreenState();
}

class _ComprehensivePaymentDetailsScreenState extends State<ComprehensivePaymentDetailsScreen> {
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
      final data = await _apiService.getPaymentComprehensiveData(widget.paymentId);
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
        title: Text('\$${widget.amount}'),
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
                      _buildPaymentInfoCard(),
                      const SizedBox(height: 16),
                      _buildPatientInfoCard(),
                      const SizedBox(height: 16),
                      _buildTestInfoCard(),
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
                Expanded(
                  child: Text(
                    'Payment Information',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                _getStatusChip(payment['status']),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Amount', '\$${payment['amount']?.toStringAsFixed(2) ?? '0.00'}'),
            _buildInfoRow('Status', payment['status'] ?? 'N/A'),
            _buildInfoRow('Method', payment['payment_method'] ?? 'N/A'),
            _buildInfoRow('Date', _formatDate(payment['created_at'])),
            if (payment['transaction_id'] != null)
              _buildInfoRow('Transaction ID', payment['transaction_id']),
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
                Text(
                  'Test Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Test Name', test['test_name'] ?? 'N/A'),
            _buildInfoRow('Test Type', test['test_type'] ?? 'N/A'),
            _buildInfoRow('Price', '\$${test['price']?.toStringAsFixed(2) ?? '0.00'}'),
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
      case 'paid':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'failed':
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

/// Process Payment — Cash, Credit/Debit (Stripe), Insurance, Online (SaeedLab /payments/).
class ProcessPaymentScreen extends StatefulWidget {
  final String? filterPatientId;
  final String? filterPatientName;

  const ProcessPaymentScreen({
    super.key,
    this.filterPatientId,
    this.filterPatientName,
  });

  @override
  State<ProcessPaymentScreen> createState() => _ProcessPaymentScreenState();
}

class _PayableOrder {
  final Test order;
  final double due;
  _PayableOrder({required this.order, required this.due});
}

class _ProcessPaymentScreenState extends State<ProcessPaymentScreen> {
  final _api = DjangoApiService();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  List<_PayableOrder> _payable = [];
  String? _selectedOrderId;
  String _paymentMethod = 'cash';
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPayableOrders());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPayableOrders() async {
    setState(() => _loading = true);
    try {
      await Provider.of<TestProvider>(context, listen: false).loadTests();
      await Provider.of<PaymentProvider>(context, listen: false).loadPayments();
      final orders = Provider.of<TestProvider>(context, listen: false).tests;
      final payments = Provider.of<PaymentProvider>(context, listen: false).payments;

      final paidByOrder = <String, double>{};
      for (final p in payments) {
        if (p.status.toLowerCase() == 'completed') {
          final id = p.testId;
          paidByOrder[id] = (paidByOrder[id] ?? 0) + p.amount;
        }
      }

      final list = <_PayableOrder>[];
      for (final o in orders) {
        if (widget.filterPatientId != null &&
            o.patientId != widget.filterPatientId) {
          continue;
        }
        final orderId = o.testId ?? '';
        if (orderId.isEmpty) continue;
        final price = o.price;
        final paid = paidByOrder[orderId] ?? 0;
        final due = price - paid;
        if (due > 0.01) list.add(_PayableOrder(order: o, due: due));
      }
      _payable = list;
      if (_payable.isNotEmpty && _selectedOrderId == null) {
        _selectedOrderId = _payable.first.order.testId;
        _amountController.text = _payable.first.due.toStringAsFixed(2);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  _PayableOrder? get _selectedPayable {
    if (_selectedOrderId == null) return null;
    for (final p in _payable) {
      if (p.order.testId == _selectedOrderId) return p;
    }
    return null;
  }

  Future<bool> _createPendingStripePayment(double amount, String note) async {
    final payable = _selectedPayable;
    if (payable == null) return false;
    final o = payable.order;
    final payment = Payment(
      testId: o.testId ?? '',
      patientId: o.patientId ?? '',
      patientName: o.patientName ?? '',
      testType: o.testType,
      testName: o.testName,
      amount: amount,
      paymentMethod: 'card',
      status: 'pending_stripe',
      notes: note,
      paymentDate: DateTime.now(),
      createdAt: DateTime.now(),
    );
    return Provider.of<PaymentProvider>(context, listen: false).addPayment(payment);
  }

  Future<String?> _runStripeIfNeeded(double amount) async {
    if (_paymentMethod != 'card') return null;

    final payableOrder = _selectedPayable?.order;
    final testOrderRef = payableOrder?.djangoOrderId ??
        payableOrder?.testId ??
        _selectedOrderId ??
        '';
    if (testOrderRef.isEmpty) return null;

    Future<String?> offerPending(String reason) async {
      if (!mounted) return null;
      final go = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Card payment pending'),
          content: Text(
            '$reason\n\n'
            'Save as pending card payment (no PaymentSheet)? Staff can collect at desk or '
            'configure Stripe in Settings → Laboratory Information.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save pending')),
          ],
        ),
      );
      if (go != true) return null;
      final ok = await _createPendingStripePayment(
        amount,
        'Awaiting Stripe configuration',
      );
      return ok ? 'pending_stripe' : null;
    }

    if (!StripeConfig.isConfigured) {
      return offerPending('No publishable key (pk_test_ / pk_live_) in Settings.');
    }

    final intent = await _api.createStripePaymentIntent(
      amount: amount,
      currency: LabCurrency.stripeCode,
      testOrder: testOrderRef,
    );

    if (!intent.success) {
      if (intent.statusCode == 503) {
        return offerPending(intent.message ?? 'STRIPE_SECRET_KEY missing on server');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(intent.message ?? 'Could not start card payment'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      if (intent.statusCode == 401) return null;
      return offerPending(intent.message ?? 'create-intent failed');
    }

    final pk = (intent.publishableKey?.trim().isNotEmpty == true)
        ? intent.publishableKey!.trim()
        : StripeConfig.publishableKey;
    if (!pk.startsWith('pk_')) {
      return offerPending('No publishable key from server or Settings');
    }
    Stripe.publishableKey = pk;
    await Stripe.instance.applySettings();

    final secret = intent.clientSecret;
    if (secret == null || secret.isEmpty) {
      return offerPending('No client_secret from lab API');
    }

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: secret,
          merchantDisplayName: AppConstants.appName,
        ),
      );
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.error.localizedMessage ?? 'Stripe payment cancelled')),
        );
      }
      return null;
    }

    final piId = intent.paymentIntentId;
    if (piId != null && piId.isNotEmpty) {
      final confirmed = await _api.confirmStripePayment(piId);
      if (!confirmed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment taken — confirming on server failed; check Payments tab'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
    return piId ?? 'stripe_ok';
  }

  Future<void> _submitPayment() async {
    final payable = _selectedPayable;
    if (payable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a test order to pay')),
      );
      return;
    }
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final stripeTx = await _runStripeIfNeeded(amount);
      if (_paymentMethod == 'card' && stripeTx == null) {
        setState(() => _submitting = false);
        return;
      }

      if (_paymentMethod == 'card' &&
          (stripeTx == 'pending_stripe' ||
              (stripeTx != null && stripeTx.startsWith('pi_')))) {
        if (mounted) {
          await Provider.of<PaymentProvider>(context, listen: false).loadPayments();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                stripeTx == 'pending_stripe'
                    ? 'Card payment saved as pending_stripe'
                    : 'Card payment completed',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
        return;
      }

      final o = payable.order;
      final payment = Payment(
        testId: o.testId ?? '',
        patientId: o.patientId ?? '',
        patientName: o.patientName ?? '',
        testType: o.testType,
        testName: o.testName,
        amount: amount,
        paymentMethod: _paymentMethod,
        status: 'completed',
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        transactionId: stripeTx,
        paymentDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final ok = await Provider.of<PaymentProvider>(context, listen: false).addPayment(payment);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment recorded successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<PaymentProvider>(context, listen: false).error ??
                  'Payment failed',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.filterPatientName != null
              ? 'Charge — ${widget.filterPatientName}'
              : 'Record lab charge',
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Record a charge for a test order (${LabCurrency.code}). '
                        'Amounts use ${LabCurrency.symbol.trim()} from lab settings.',
                        style: const TextStyle(fontSize: 12, height: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Payment method',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...AppConstants.paymentMethodOptions.map((opt) {
                    final value = opt['value']!;
                    final selected = _paymentMethod == value;
                    IconData icon;
                    switch (opt['icon']) {
                      case 'credit_card':
                        icon = Icons.credit_card;
                        break;
                      case 'health_and_safety':
                        icon = Icons.health_and_safety;
                        break;
                      case 'account_balance':
                        icon = Icons.account_balance;
                        break;
                      default:
                        icon = Icons.payments;
                    }
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: selected
                          ? AppConstants.primaryColor.withValues(alpha: 0.08)
                          : null,
                      child: RadioListTile<String>(
                        value: value,
                        groupValue: _paymentMethod,
                        onChanged: _submitting
                            ? null
                            : (v) => setState(() => _paymentMethod = v!),
                        title: Text(
                          opt['label']!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        secondary: Icon(icon, color: AppConstants.primaryColor),
                      ),
                    );
                  }),
                  if (_paymentMethod == 'card') ...[
                    const SizedBox(height: 8),
                    ListTile(
                      leading: Icon(
                        StripeConfig.isConfigured ? Icons.check_circle : Icons.warning,
                        color: StripeConfig.isConfigured ? Colors.green : Colors.orange,
                      ),
                      title: Text(
                        StripeConfig.isConfigured
                            ? 'Stripe ready (this lab)'
                            : 'Lab admin: set Stripe in Settings → Laboratory Information',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _payable.isEmpty ? null : _selectedOrderId,
                    decoration: const InputDecoration(
                      labelText: 'Patient / Test order',
                      border: OutlineInputBorder(),
                    ),
                    selectedItemBuilder: (context) {
                      return _payable.map((p) {
                        final id = p.order.testId ?? '';
                        final name = p.order.patientName ?? 'Patient';
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '$name · $id · ${LabCurrency.formatWithSymbol(p.due)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList();
                    },
                    items: _payable.map((p) {
                      final id = p.order.testId ?? '';
                      final name = p.order.patientName ?? 'Patient';
                      final test = p.order.testName ?? 'Test';
                      return DropdownMenuItem(
                        value: id,
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '$test · $id',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                'Due ${LabCurrency.formatWithSymbol(p.due)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: _payable.isEmpty
                        ? null
                        : (v) {
                            setState(() {
                              _selectedOrderId = v;
                              final sel = _selectedPayable;
                              if (sel != null) {
                                _amountController.text = sel.due.toStringAsFixed(2);
                              }
                            });
                          },
                  ),
                  if (_payable.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'No unpaid test orders. Create a test order first.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount (${LabCurrency.code})',
                      border: const OutlineInputBorder(),
                      prefixText: LabCurrency.symbol,
                      helperText: _selectedPayable != null
                          ? 'Suggested due: ${LabCurrency.formatWithSymbol(_selectedPayable!.due)}'
                          : null,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _submitting || _payable.isEmpty ? null : _submitPayment,
                    icon: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check),
                    label: Text(_submitting ? 'Processing…' : 'Process Payment'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
