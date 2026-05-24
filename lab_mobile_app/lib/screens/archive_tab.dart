import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/test_provider.dart';
import '../providers/language_provider.dart';
import '../models/test.dart';
import '../services/django_api_service.dart';
import '../utils/constants.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final DjangoApiService _api = DjangoApiService();
  List<Test> _archived = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _archived = await _api.getArchivedTestOrders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archive load failed: $e')),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('archive')),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _archived.isEmpty
              ? const Center(child: Text('No archived test orders.'))
              : ListView.builder(
                  itemCount: _archived.length,
                  itemBuilder: (context, index) {
                    final t = _archived[index];
                    return ListTile(
                      leading: const Icon(Icons.archive),
                      title: Text(t.testName, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${t.patientName ?? t.patientId} · ${t.status}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: SizedBox(
                        width: 72,
                        child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Restore', maxLines: 1, overflow: TextOverflow.ellipsis),
                        onPressed: () async {
                          try {
                            await _api.restoreTestOrder(t.testId!);
                            await _load();
                            if (context.mounted) {
                              context.read<TestProvider>().loadTests();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Restore failed: $e')),
                              );
                            }
                          }
                        },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
