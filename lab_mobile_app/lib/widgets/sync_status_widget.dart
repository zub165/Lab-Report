import 'package:flutter/material.dart';
import '../services/simple_hybrid_storage_service.dart';

class SyncStatusWidget extends StatefulWidget {
  const SyncStatusWidget({Key? key}) : super(key: key);

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  bool _isBackendAvailable = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBackendStatus();
    });
  }

  Future<void> _checkBackendStatus() async {
    if (mounted) {
      setState(() {
        _isBackendAvailable = true; // This would be set by the hybrid storage service
      });
    }
  }

  Future<void> _forceSync() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      final hybridStorage = SimpleHybridStorageService();
      await hybridStorage.forceSyncAll();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Data synced successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _isBackendAvailable ? Colors.green.shade50 : Colors.orange.shade50,
        border: Border.all(
          color: _isBackendAvailable ? Colors.green.shade200 : Colors.orange.shade200,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _isBackendAvailable ? Icons.cloud_done : Icons.cloud_off,
            color: _isBackendAvailable ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _isBackendAvailable 
                ? '🟢 Online - Data synced' 
                : '🟡 Offline - Local storage',
              style: TextStyle(
                fontSize: 12,
                color: _isBackendAvailable ? Colors.green.shade700 : Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_isBackendAvailable)
            IconButton(
              onPressed: _isSyncing ? null : _forceSync,
              icon: _isSyncing 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync, size: 16),
              tooltip: 'Force sync',
            ),
        ],
      ),
    );
  }
}
