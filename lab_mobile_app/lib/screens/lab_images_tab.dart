import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/test_provider.dart';
import '../providers/language_provider.dart';
import '../models/test.dart';
import '../services/django_api_service.dart';
import '../utils/constants.dart';
import '../utils/lab_order_images.dart';
import '../utils/media_permissions.dart';

class LabImagesScreen extends StatefulWidget {
  const LabImagesScreen({super.key});

  @override
  State<LabImagesScreen> createState() => _LabImagesScreenState();
}

class _LabImagesScreenState extends State<LabImagesScreen> {
  final _orderIdController = TextEditingController();
  final _urlController = TextEditingController();
  final _labelController = TextEditingController();
  final DjangoApiService _api = DjangoApiService();
  final ImagePicker _picker = ImagePicker();

  Test? _order;
  /// Django UUID used for API calls (dropdown value / save).
  String? _selectedApiOrderId;
  List<OrderImageLink> _imageLinks = [];
  String _otherNotes = '';
  bool _loading = false;
  bool _saving = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<TestProvider>().tests.isEmpty) {
        context.read<TestProvider>().loadTests();
      }
    });
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    _urlController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  String? _apiOrderId(Test? t) {
    if (t == null) return null;
    final django = t.djangoOrderId?.trim();
    if (django != null && django.isNotEmpty) return django;
    return t.testId?.trim();
  }

  /// Human-readable label: ORD000038 — Sarah Williams (not UUID).
  String _orderDisplayLabel(Test t) {
    final ord = t.testId?.trim();
    final name = (t.patientName ?? t.testName).trim();
    if (ord != null && ord.isNotEmpty && !ord.contains('-')) {
      return name.isEmpty ? ord : '$ord — $name';
    }
    return name.isEmpty ? (ord ?? 'Order') : '$name';
  }

  void _setOrderFieldDisplay(Test t) {
    _selectedApiOrderId = _apiOrderId(t);
    _orderIdController.text = _orderDisplayLabel(t);
  }

  String _resolveApiOrderId(String input, List<Test> tests) {
    final q = input.trim();
    if (q.isEmpty) return q;
    for (final t in tests) {
      final apiId = _apiOrderId(t);
      if (apiId == null) continue;
      if (apiId == q || t.testId?.trim() == q) return apiId;
      if (_orderDisplayLabel(t) == q) return apiId;
    }
    return q;
  }

  void _applyOrder(Test order) {
    final parsed = parseClinicalNotesForImages(order.notes);
    setState(() {
      _order = order;
      _imageLinks = List<OrderImageLink>.from(parsed.imageLinks);
      _otherNotes = parsed.otherText;
    });
  }

  Future<void> _loadOrder([String? idOverride]) async {
    final tests = context.read<TestProvider>().tests;
    final raw = (idOverride ?? _selectedApiOrderId ?? _orderIdController.text).trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter or select a test order')),
      );
      return;
    }
    final id = _resolveApiOrderId(raw, tests);
    setState(() => _loading = true);
    try {
      final order = await _api.getTestOrder(id);
      _setOrderFieldDisplay(order);
      _applyOrder(order);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load order: $e')),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveImages() async {
    final tests = context.read<TestProvider>().tests;
    final id = _apiOrderId(_order) ??
        _selectedApiOrderId ??
        _resolveApiOrderId(_orderIdController.text.trim(), tests);
    if (id.isEmpty || _order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Load an order first')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final payload = buildClinicalNotesWithImageLinks(
        _order!.notes,
        _imageLinks,
      );
      final updated = await _api.updateTestOrderClinicalNotes(id, payload);
      _applyOrder(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved image links')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  void _addLinkFromFields() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    setState(() {
      _imageLinks = [
        ..._imageLinks,
        OrderImageLink(url: url, label: _labelController.text.trim()),
      ];
      _urlController.clear();
      _labelController.clear();
    });
  }

  Future<void> _pickAndUpload({required ImageSource source}) async {
    final tests = context.read<TestProvider>().tests;
    final id = _apiOrderId(_order) ??
        _selectedApiOrderId ??
        _resolveApiOrderId(_orderIdController.text.trim(), tests);
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Load an order before uploading')),
      );
      return;
    }
    if (!await ensureImageSourcePermission(source)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required to take photos')),
        );
      }
      return;
    }
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      final url = await _api.uploadLabFile(File(picked.path));
      setState(() {
        _imageLinks = [
          ..._imageLinks,
          OrderImageLink(url: url, label: picked.name),
        ];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload complete — tap Save to persist')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
    if (mounted) setState(() => _uploading = false);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tests = context.watch<TestProvider>().tests;
    final busy = _loading || _saving || _uploading;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('images')),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_order != null)
            IconButton(
              tooltip: 'Save',
              onPressed: busy ? null : _saveImages,
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (tests.isNotEmpty) ...[
              Builder(
                builder: (context) {
                  final orderOptions = tests.take(50).map((t) {
                    final apiId = _apiOrderId(t) ?? '';
                    if (apiId.isEmpty) return null;
                    return (id: apiId, label: _orderDisplayLabel(t));
                  }).whereType<({String id, String label})>().toList();

                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Recent test orders',
                      border: OutlineInputBorder(),
                    ),
                    items: orderOptions
                        .map(
                          (o) => DropdownMenuItem(
                            value: o.id,
                            child: Text(
                              o.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    selectedItemBuilder: (context) => orderOptions
                        .map(
                          (o) => Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              o.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    value: _selectedApiOrderId != null &&
                            orderOptions.any((o) => o.id == _selectedApiOrderId)
                        ? _selectedApiOrderId
                        : null,
                    onChanged: busy
                        ? null
                        : (v) {
                            if (v == null) return;
                            for (final t in tests) {
                              if (_apiOrderId(t) == v) {
                                _setOrderFieldDisplay(t);
                                break;
                              }
                            }
                            _loadOrder(v);
                          },
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _orderIdController,
              decoration: const InputDecoration(
                labelText: 'Order',
                hintText: 'ORD000038 — Patient name (or pick above)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.assignment_ind_outlined),
              ),
              enabled: !busy,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: busy ? null : () => _loadOrder(),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Load order images / notes'),
            ),
            if (_order != null) ...[
              const SizedBox(height: 16),
              Text(
                _orderDisplayLabel(_order!),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_otherNotes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_otherNotes, style: TextStyle(color: Colors.grey[700])),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: busy
                          ? null
                          : () => _pickAndUpload(source: ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: busy
                          ? null
                          : () => _pickAndUpload(source: ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                ],
              ),
              if (_uploading)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
                enabled: !busy,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Label (optional)',
                  border: OutlineInputBorder(),
                ),
                enabled: !busy,
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: busy ? null : _addLinkFromFields,
                child: const Text('Add link'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => setState(() => _imageLinks = []),
                    child: const Text('Clear all links'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: busy ? null : _saveImages,
                    child: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
              if (_imageLinks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No image links on this order yet. Upload or add a URL, then Save.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else ...[
                const SizedBox(height: 8),
                ...List.generate(_imageLinks.length, (i) {
                  final link = _imageLinks[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        link.label.isNotEmpty ? link.label : 'Image ${i + 1}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        link.url,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () => _openUrl(link.url),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: busy
                                ? null
                                : () => setState(() {
                                      _imageLinks =
                                          List<OrderImageLink>.from(_imageLinks)
                                        ..removeAt(i);
                                    }),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: _imageLinks
                      .where((l) => isLikelyImageUrl(l.url))
                      .length,
                  itemBuilder: (context, index) {
                    final link = _imageLinks
                        .where((l) => isLikelyImageUrl(l.url))
                        .elementAt(index);
                    return GestureDetector(
                      onTap: () => _openUrl(link.url),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: link.url,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (_, __, ___) => ColoredBox(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
