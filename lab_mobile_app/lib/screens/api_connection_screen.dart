import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import '../config/api_env.dart';
import '../services/simple_hybrid_storage_service.dart';
import '../services/django_api_service.dart';
import '../utils/constants.dart';

class ApiConnectionScreen extends StatefulWidget {
  const ApiConnectionScreen({Key? key}) : super(key: key);

  @override
  State<ApiConnectionScreen> createState() => _ApiConnectionScreenState();
}

class _ApiConnectionScreenState extends State<ApiConnectionScreen> {
  final SimpleHybridStorageService _hybridStorage = SimpleHybridStorageService();
  final DjangoApiService _apiService = DjangoApiService();
  
  bool _isLoading = false;
  bool _backendConnected = false;
  bool _localDatabaseConnected = false;
  String _connectionStatus = 'Checking...';
  String _lastSyncTime = 'Never';
  int _localRecords = 0;
  int _pendingSyncRecords = 0;
  bool _canManageLabStripe = false;
  ApiProfile _apiProfile = ApiProfile.production;
  final _baseUrlController = TextEditingController();
  final _stripeKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiProfile = ApiEnvConfig.activeProfile;
    _baseUrlController.text = LabApiConfig.resolvedBaseUrl;
    _refreshStripeFieldFromConfig();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkConnections();
      if (_backendConnected) {
        try {
          final profile = await _apiService.getCurrentUser();
          _canManageLabStripe = DjangoApiService.profileCanManageStaff(profile);
          await _apiService.syncLabStripeConfig();
        } catch (_) {
          _canManageLabStripe = false;
        }
      } else {
        await StripeConfig.initialize();
      }
      if (mounted) {
        _refreshStripeFieldFromConfig();
        setState(() {});
      }
    });
  }

  void _refreshStripeFieldFromConfig() {
    if (_stripeKeyController.text.trim().isEmpty && StripeConfig.isConfigured) {
      _stripeKeyController.text = StripeConfig.publishableKey;
    }
  }

  void _loadStripeKeyFromEnv() {
    final key = StripeConfig.envPublishableKeyForEditor;
    if (!StripeConfig.hasEnvDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No STRIPE_PUBLISHABLE_KEY in .env. Add pk_live_… to lab_mobile_app/.env '
            'and run ./scripts/run_with_env.sh',
          ),
        ),
      );
      return;
    }
    setState(() => _stripeKeyController.text = key);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Loaded publishable key from .env — tap Save Stripe Key to store on device'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _stripeKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveLabApiSettings() async {
    try {
      final raw = _baseUrlController.text.trim();
      if (raw.isNotEmpty) {
        DjangoApiService.assertLabBase(raw);
        await ApiEnvConfig.saveCustomBaseUrl(raw);
      } else {
        await ApiEnvConfig.saveCustomBaseUrl(null);
      }
      await ApiEnvConfig.saveProfile(_apiProfile);
      await LabApiConfig.applyResolvedBase();
      final healthy = await _apiService.testBackendConnection();
      if (mounted) {
        setState(() => _backendConnected = healthy);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              healthy
                  ? 'Lab API OK — ${LabApiConfig.resolvedBaseUrl}'
                  : 'Health check failed for ${LabApiConfig.resolvedBaseUrl}',
            ),
            backgroundColor: healthy ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _tryBackupServer() async {
    setState(() => _isLoading = true);
    final ok = await _apiService.switchToBackupServer();
    if (mounted) {
      _baseUrlController.text = LabApiConfig.resolvedBaseUrl;
      setState(() {
        _isLoading = false;
        _backendConnected = ok;
        _apiProfile = ApiEnvConfig.activeProfile;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Using backup server: ${LabApiConfig.resolvedBaseUrl}'
                : 'Backup server unreachable',
          ),
          backgroundColor: ok ? Colors.orange : Colors.red,
        ),
      );
    }
  }

  Future<void> _usePrimaryServer() async {
    await _apiService.switchToPrimaryServer();
    if (mounted) {
      _baseUrlController.text = LabApiConfig.resolvedBaseUrl;
      setState(() => _apiProfile = ApiEnvConfig.activeProfile);
      await _checkConnections();
    }
  }

  Future<void> _saveStripeKey({bool toLabServer = false}) async {
    if (toLabServer && _canManageLabStripe) {
      try {
        final saved = await _apiService.updateLabUiSettings(
          StripeConfig.labSettingsPayload(
            publishableKey: _stripeKeyController.text,
          ),
        );
        await StripeConfig.applyLabSettings(saved);
        await DjangoApiService.applyStripePublishableToSdk();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Stripe publishable key saved for this lab (all staff)'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {});
        }
        return;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Save to lab failed: $e'), backgroundColor: Colors.red),
          );
        }
        return;
      }
    }

    await StripeConfig.savePublishableKey(_stripeKeyController.text);
    await DjangoApiService.applyStripePublishableToSdk();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            StripeConfig.isConfigured
                ? 'Stripe key saved on this device only (dev override)'
                : 'Stripe key cleared on this device',
          ),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
    }
  }

  Future<void> _checkConnections() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _localRecords = 0;
      _pendingSyncRecords = 0;
      // Check local database connection
      await _hybridStorage.initialize();
      _localDatabaseConnected = true;

      // Same Django API as https://zub165.github.io/SaeedLab/
      try {
        _backendConnected = await _apiService.testBackendConnection();
        if (_backendConnected) {
          _connectionStatus =
              'Connected to SaeedLab API (${LabApiConfig.resolvedBaseUrl})';
          try {
            final patients = await _apiService.getPatients();
            _localRecords = patients.length;
            _connectionStatus =
                'Connected — ${patients.length} patients from API';
          } catch (e) {
            final msg = e.toString();
            if (msg.contains('Authentication') || msg.contains('401')) {
              _connectionStatus =
                  'API online — log in to load patients and sync data';
            } else {
              _connectionStatus = 'API online — data load: $msg';
            }
            final patients = await _hybridStorage.getPatients();
            _localRecords = patients.length;
          }
        } else {
          _connectionStatus = 'SaeedLab API unreachable — local cache only';
        }
      } catch (e) {
        _backendConnected = false;
        _connectionStatus = 'Backend unavailable: $e';
      }

      if (_localRecords == 0) {
        try {
          final patients = await _hybridStorage.getPatients();
          _localRecords = patients.length;
        } catch (_) {}
      }
      _pendingSyncRecords = 0;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _localDatabaseConnected = false;
        _backendConnected = false;
        _connectionStatus = 'Connection Error: $e';
      });
    }
  }

  Future<void> _forceSync() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _hybridStorage.forceSyncAll();
      setState(() {
        _lastSyncTime = DateTime.now().toString().split('.')[0];
        _pendingSyncRecords = 0;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync completed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testBackendConnection() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final healthy = await _apiService.testBackendConnection();
      if (!healthy) {
        throw Exception('Health check failed — is ${LabApiConfig.resolvedBaseUrl} reachable?');
      }
      String detail = 'API server is online';
      try {
        final patients = await _apiService.getPatients();
        detail = 'Connected — ${patients.length} patients loaded';
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('Authentication') || msg.contains('401')) {
          detail = 'API online — log in from the home screen to sync data';
        } else {
          detail = 'API online — patient load: $msg';
        }
      }
      setState(() {
        _backendConnected = true;
        _connectionStatus = detail;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(detail), backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() {
        _backendConnected = false;
        _connectionStatus = 'Backend connection failed: $e';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Connection Status'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _checkConnections,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (LabApiConfig.isUsingBackupServer)
                    MaterialBanner(
                      content: Text(
                        'Using backup Lab API: ${LabApiConfig.resolvedBaseUrl}',
                      ),
                      leading: const Icon(Icons.warning_amber, color: Colors.orange),
                      actions: [
                        TextButton(onPressed: _usePrimaryServer, child: const Text('Primary')),
                      ],
                    ),
                  _buildLabApiCard(),
                  const SizedBox(height: 16),
                  _buildConnectionStatusCard(),
                  const SizedBox(height: 16),
                  _buildDatabaseStatusCard(),
                  const SizedBox(height: 16),
                  _buildSyncStatusCard(),
                  const SizedBox(height: 16),
                  _buildStripeCard(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildLabApiCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lab API (JWT) — not Hospital Finder',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Lab: ${ApiEnvConfig.production.labApiBase}/\n'
              'Do not use ${ApiEnvConfig.hospitalFinderApiBase}/ (no Lab JWT).',
              style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.35),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ApiProfile>(
              value: _apiProfile,
              decoration: const InputDecoration(
                labelText: 'API profile',
                border: OutlineInputBorder(),
              ),
              items: ApiProfile.values
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(ApiEnvConfig.envForProfile(p).label),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _apiProfile = v);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _baseUrlController,
              decoration: const InputDecoration(
                labelText: 'Lab API base URL',
                hintText: 'https://api.mywaitime.com/lab',
                border: OutlineInputBorder(),
                helperText: 'Must end with /lab — health: GET …/health/',
                helperMaxLines: 2,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(onPressed: _saveLabApiSettings, child: const Text('Save & health check')),
                OutlinedButton(onPressed: _tryBackupServer, child: const Text('Use backup server')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _backendConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: _backendConnected ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Backend Connection',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _connectionStatus,
                        style: TextStyle(
                          color: _backendConnected ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Status', _backendConnected ? 'Connected' : 'Disconnected'),
            _buildInfoRow('API', LabApiConfig.resolvedBaseUrl),
            _buildInfoRow('Web app', LabApiConfig.saeedLabWebUrl),
            _buildInfoRow('Type', _backendConnected ? 'Django (SaeedLab)' : 'Local cache only'),
            _buildInfoRow('Last Check', DateTime.now().toString().split('.')[0]),
          ],
        ),
      ),
    );
  }

  Widget _buildDatabaseStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _localDatabaseConnected ? Icons.storage : Icons.error,
                  color: _localDatabaseConnected ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Local Database',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _localDatabaseConnected ? 'Connected' : 'Error',
                        style: TextStyle(
                          color: _localDatabaseConnected ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Status', _localDatabaseConnected ? 'Connected' : 'Disconnected'),
            _buildInfoRow('Type', 'SQLite Local Database'),
            _buildInfoRow('Total Records', _localRecords.toString()),
            _buildInfoRow('Pending Sync', _pendingSyncRecords.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Synchronization Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Last Sync', _lastSyncTime),
            _buildInfoRow('Sync Mode', _backendConnected ? 'Auto Sync' : 'Manual Sync Only'),
            _buildInfoRow('Pending Records', _pendingSyncRecords.toString()),
            if (_pendingSyncRecords > 0)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[800], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have $_pendingSyncRecords records pending sync',
                        style: TextStyle(color: Colors.orange[800], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStripeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  StripeConfig.isConfigured ? Icons.credit_card : Icons.credit_card_off,
                  color: StripeConfig.isConfigured ? Colors.green : Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Stripe (Credit / Debit Card)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Each lab uses its own Stripe account. Lab admins: open '
              'Settings → Laboratory Information to set publishable + secret keys '
              'for everyone at your lab. Below is optional (this device / .env only).',
              style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 10),
            _buildInfoRow('.env / build', StripeConfig.envKeyPreview),
            _buildInfoRow('Active key', StripeConfig.maskedKey(StripeConfig.publishableKey)),
            _buildInfoRow('Source', StripeConfig.activeKeySource),
            if (StripeConfig.isFromEnvOnly)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Using STRIPE_PUBLISHABLE_KEY from .env. Save below to store on this device.',
                  style: TextStyle(fontSize: 11, color: Colors.green.shade700),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _stripeKeyController,
              decoration: const InputDecoration(
                labelText: 'Stripe Publishable Key',
                border: OutlineInputBorder(),
                hintText: 'pk_live_... or pk_test_...',
                helperText:
                    'Optional: set STRIPE_PUBLISHABLE_KEY in lab_mobile_app/.env',
                helperMaxLines: 2,
              ),
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 8),
            if (StripeConfig.hasEnvDefault)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _loadStripeKeyFromEnv,
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Load from .env'),
                ),
              ),
            const SizedBox(height: 4),
            if (_canManageLabStripe)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _saveStripeKey(toLabServer: true),
                  child: const Text('Save publishable key for this lab'),
                ),
              ),
            if (_canManageLabStripe) const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _saveStripeKey(toLabServer: false),
                child: const Text('Save on this device only (dev)'),
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _testBackendConnection,
            icon: const Icon(Icons.cloud),
            label: const Text('Test Backend Connection'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _forceSync,
            icon: const Icon(Icons.sync),
            label: const Text('Force Sync All Data'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _checkConnections,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Status'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
