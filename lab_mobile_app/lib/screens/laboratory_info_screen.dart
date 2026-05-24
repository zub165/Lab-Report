import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/django_api_service.dart';
import '../services/store_subscription_service.dart';
import '../utils/constants.dart';
import '../utils/lab_currency.dart';

class LaboratoryInfoScreen extends StatefulWidget {
  const LaboratoryInfoScreen({Key? key}) : super(key: key);

  @override
  State<LaboratoryInfoScreen> createState() => _LaboratoryInfoScreenState();
}

class _LaboratoryInfoScreenState extends State<LaboratoryInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _licenseController = TextEditingController();
  final _directorController = TextEditingController();
  final _websiteController = TextEditingController();
  final _mainLocationController = TextEditingController();
  final _branch1Controller = TextEditingController();
  final _branch2Controller = TextEditingController();
  final _branch3Controller = TextEditingController();
  final _branch4Controller = TextEditingController();
  
  final DjangoApiService _api = DjangoApiService();
  final _stripePublishableController = TextEditingController();
  final _stripeSecretController = TextEditingController();
  bool _isLoading = false;
  bool _fromApi = false;
  bool _canManageStripe = false;
  bool _stripeSecretOnServer = false;
  String _displayCurrency = 'PKR';
  Map<String, dynamic>? _subscription;
  bool _subscriptionLoading = false;
  String? _labGroupLabel;
  ProductDetails? _storeProduct;
  bool _storeBillingAvailable = false;
  final StoreSubscriptionService _storeSub = StoreSubscriptionService.instance;

  @override
  void initState() {
    super.initState();
    _storeSub.onPurchaseMessage = _onStorePurchaseMessage;
    _loadLaboratoryInfo();
  }

  @override
  void dispose() {
    _storeSub.onPurchaseMessage = null;
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _licenseController.dispose();
    _directorController.dispose();
    _websiteController.dispose();
    _mainLocationController.dispose();
    _branch1Controller.dispose();
    _branch2Controller.dispose();
    _branch3Controller.dispose();
    _branch4Controller.dispose();
    _stripePublishableController.dispose();
    _stripeSecretController.dispose();
    super.dispose();
  }

  Future<void> _loadLaboratoryInfo() async {
    setState(() => _isLoading = true);
    try {
      try {
        final profile = await _api.getCurrentUser();
        _canManageStripe = DjangoApiService.profileCanManageStaff(profile);
      } catch (_) {
        _canManageStripe = false;
      }

      await _api.syncLabGroupScopeFromProfile();
      _labGroupLabel = LabGroupScope.groupName;

      final s = await _api.getLabUiSettings();
      _nameController.text = s['lab_name']?.toString() ?? '';
      _addressController.text = s['lab_address']?.toString() ?? '';
      _phoneController.text = s['lab_phone']?.toString() ?? '';
      _emailController.text = s['lab_email']?.toString() ?? '';
      _directorController.text = s['authorized_doctor']?.toString() ?? '';
      if (_mainLocationController.text.isEmpty && _addressController.text.isNotEmpty) {
        _mainLocationController.text =
            '${_nameController.text} — ${_addressController.text}';
      }
      final cur = s['display_currency']?.toString().trim().toUpperCase();
      if (cur != null && cur.isNotEmpty) {
        _displayCurrency = cur;
        LabCurrency.setCode(cur);
      }
      final pk = StripeConfig.publishableFromSettings(s);
      _stripePublishableController.text = pk ?? '';
      _stripeSecretOnServer = StripeConfig.secretConfiguredInSettings(s);
      _stripeSecretController.clear();
      await StripeConfig.applyLabSettings(s);
      await DjangoApiService.applyStripePublishableToSdk();
      _fromApi = true;
      await _loadSubscriptionStatus();
    } catch (e) {
      _fromApi = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Load from API failed: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSubscriptionStatus() async {
    if (!_canManageStripe) return;
    setState(() => _subscriptionLoading = true);
    try {
      await _api.syncLabGroupScopeFromProfile();
      _labGroupLabel = LabGroupScope.groupName;
      _subscription = await _storeSub.loadLocalStatus();
      if (!kIsWeb) {
        _storeBillingAvailable = await _storeSub.isStoreAvailable;
        _storeProduct = await _storeSub.loadStoreProduct();
      }
    } catch (e) {
      _subscription = {
        'status': 'unknown',
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    } finally {
      if (mounted) setState(() => _subscriptionLoading = false);
    }
  }

  void _onStorePurchaseMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
    if (!isError) {
      _loadSubscriptionStatus();
    }
  }

  Future<void> _subscribeLabPlan() async {
    if (kIsWeb) {
      _showErrorDialog('Subscribe on iPhone or Android using App Store or Google Play.');
      return;
    }
    setState(() => _subscriptionLoading = true);
    try {
      final started = await _storeSub.subscribeViaStore();
      if (!started && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not start store purchase')),
        );
      }
    } catch (e) {
      if (mounted) _showErrorDialog('$e');
    } finally {
      if (mounted) setState(() => _subscriptionLoading = false);
    }
  }

  Future<void> _restoreStoreSubscription() async {
    setState(() => _subscriptionLoading = true);
    try {
      await _storeSub.restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restore requested — checking purchases…')),
        );
      }
      await Future<void>.delayed(const Duration(seconds: 2));
      await _loadSubscriptionStatus();
    } catch (e) {
      if (mounted) _showErrorDialog('$e');
    } finally {
      if (mounted) setState(() => _subscriptionLoading = false);
    }
  }

  Future<void> _openSubscriptionPortal() async {
    setState(() => _subscriptionLoading = true);
    try {
      final manageUrl = defaultTargetPlatform == TargetPlatform.iOS
          ? LabSubscriptionConfig.appleManageSubscriptionsUrl
          : LabSubscriptionConfig.googleManageSubscriptionsUrl;
      final uri = Uri.parse(manageUrl);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not open subscription settings');
      }
    } catch (e) {
      if (mounted) _showErrorDialog('$e');
    } finally {
      if (mounted) setState(() => _subscriptionLoading = false);
    }
  }

  Future<void> _saveLaboratoryInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final payload = <String, dynamic>{
        'lab_name': _nameController.text.trim(),
        'lab_address': _addressController.text.trim(),
        'lab_phone': _phoneController.text.trim(),
        'lab_email': _emailController.text.trim(),
        'authorized_doctor': _directorController.text.trim(),
        'lab_technician': _directorController.text.trim().isEmpty
            ? 'Lab Staff'
            : _directorController.text.trim(),
        'display_currency': _displayCurrency,
      };
      if (LabGroupScope.groupId != 'default') {
        payload['lab_group_id'] = LabGroupScope.groupId;
      }
      if (_canManageStripe) {
        payload.addAll(
          StripeConfig.labSettingsPayload(
            publishableKey: _stripePublishableController.text,
            secretKey: _stripeSecretController.text,
          ),
        );
      }
      final saved = await _api.updateLabUiSettings(payload);

      LabCurrency.setCode(_displayCurrency);
      if (_canManageStripe) {
        await StripeConfig.applyLabSettings(saved);
        await DjangoApiService.applyStripePublishableToSdk();
        _stripeSecretController.clear();
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        final branch = _labGroupLabel ?? LabGroupScope.groupName;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _canManageStripe && StripeConfig.isConfigured
                  ? 'Saved for $branch — patient card payments use this lab’s Stripe'
                  : 'Saved — currency: $_displayCurrency',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _loadLaboratoryInfo();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error saving laboratory information: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratory Information'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _saveLaboratoryInfo,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoSection(),
                    const SizedBox(height: 20),
                    _buildContactInfoSection(),
                    const SizedBox(height: 20),
                    _buildLicenseInfoSection(),
                    const SizedBox(height: 20),
                    _buildCurrencySection(),
                    const SizedBox(height: 20),
                    if (_canManageStripe) ...[
                      _buildStripePatientPaymentsSection(),
                      const SizedBox(height: 20),
                      _buildSubscriptionSection(),
                      const SizedBox(height: 20),
                    ],
                    _buildLocationsSection(),
                    const SizedBox(height: 30),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSubscriptionSection() {
    final status = _subscription?['status']?.toString() ?? 'none';
    final isActive = LabSubscriptionConfig.isUnlockedStatus(status);
    final renewAt = _subscription?['renew_at'] ?? _subscription?['current_period_end'];
    final priceLabel = _storeSub.storePriceLabel(_storeProduct);
    final storeName = defaultTargetPlatform == TargetPlatform.iOS
        ? 'App Store'
        : defaultTargetPlatform == TargetPlatform.android
            ? 'Google Play'
            : 'Store';
    return Card(
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lab subscription (platform)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Billed only through Apple App Store or Google Play ($priceLabel). '
              'No Django or Stripe subscription — cancel anytime in your store account.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade800, height: 1.4),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isActive ? Icons.verified : Icons.workspace_premium_outlined,
                color: isActive ? Colors.green : Colors.orange,
              ),
              title: Text(LabSubscriptionConfig.planLabel),
              subtitle: Text(
                isActive
                    ? 'Active — $priceLabel'
                    : '$priceLabel — ${status == 'none' ? 'Not subscribed' : status}',
              ),
              trailing: _subscriptionLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
            if (_storeBillingAvailable)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Billed via $storeName · Product ID: ${LabSubscriptionConfig.storeProductId}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ),
            if (renewAt != null && isActive)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Renews: $renewAt',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
            Row(
              children: [
                if (!isActive)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _subscriptionLoading ? null : _subscribeLabPlan,
                      icon: const Icon(Icons.payment),
                      label: Text(
                        _storeBillingAvailable
                            ? 'Subscribe via $storeName'
                            : 'Subscribe $priceLabel',
                      ),
                    ),
                  ),
                if (isActive) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _subscriptionLoading ? null : _openSubscriptionPortal,
                      icon: const Icon(Icons.manage_accounts),
                      label: Text('Manage in $storeName'),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh status',
                    onPressed: _subscriptionLoading ? null : _loadSubscriptionStatus,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ],
            ),
            if (!kIsWeb && _storeBillingAvailable) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _subscriptionLoading ? null : _restoreStoreSubscription,
                  child: const Text('Restore purchases'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStripePatientPaymentsSection() {
    final branch = _labGroupLabel ?? LabGroupScope.groupName;
    return Card(
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payments, color: Colors.indigo.shade800),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Patient payments — Stripe (this lab branch)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Lab branch: $branch',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade900,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Each lab group uses its own Stripe account. When you charge a patient for a '
              'test order (Payments → Credit/Debit Card), money goes to this branch’s Stripe — '
              'not shared with other branches in your chain.',
              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.45),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Saeed Lab branch A and branch B each save separate pk_/sk_ keys here\n'
              '• Staff at that branch use card payments after keys are saved\n'
              '• Secret key stays on the server only (Django creates PaymentIntents)',
              style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _stripePublishableController,
              decoration: const InputDecoration(
                labelText: 'Stripe publishable key (pk_live_… or pk_test_…)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
                filled: true,
                fillColor: Colors.white,
              ),
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _stripeSecretController,
              decoration: InputDecoration(
                labelText: 'Stripe secret key (sk_live_… — server only)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                filled: true,
                fillColor: Colors.white,
                helperText: _stripeSecretOnServer
                    ? 'Secret already stored for $branch. Leave blank to keep it.'
                    : 'Required so patients can pay by card for lab tests.',
                helperMaxLines: 3,
              ),
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
            ),
            if (StripeConfig.isConfigured)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Ready for patient card payments · '
                        '${StripeConfig.maskedKey(StripeConfig.publishableKey)}',
                        style: TextStyle(fontSize: 11, color: Colors.green.shade900),
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Add keys and tap Save (top right) before using Credit/Debit Card on test orders.',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySection() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Display currency',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'All charges and payments show in this currency (PKR, USD, EUR, …). '
              'Same setting as SaeedLab web Settings.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: LabCurrency.supported.any((e) => e['code'] == _displayCurrency)
                  ? _displayCurrency
                  : 'PKR',
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_exchange),
              ),
              items: LabCurrency.supported
                  .map((e) => DropdownMenuItem(
                        value: e['code'],
                        child: Text(e['label']!),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _displayCurrency = v);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Laboratory Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter laboratory name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _directorController,
              decoration: const InputDecoration(
                labelText: 'Director Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter director name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.web),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter email address';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'License Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _licenseController,
              decoration: const InputDecoration(
                labelText: 'License Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.verified),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter license number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Laboratory Locations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mainLocationController,
              decoration: const InputDecoration(
                labelText: 'Main Location *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
                hintText: 'Main laboratory address',
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter main location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _branch1Controller,
              decoration: const InputDecoration(
                labelText: 'Branch 1',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
                hintText: 'First branch location',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _branch2Controller,
              decoration: const InputDecoration(
                labelText: 'Branch 2',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
                hintText: 'Second branch location',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _branch3Controller,
              decoration: const InputDecoration(
                labelText: 'Branch 3',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
                hintText: 'Third branch location',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _branch4Controller,
              decoration: const InputDecoration(
                labelText: 'Branch 4',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
                hintText: 'Fourth branch location',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveLaboratoryInfo,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        child: _isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Saving...'),
                ],
              )
            : const Text(
                'Save Laboratory Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
