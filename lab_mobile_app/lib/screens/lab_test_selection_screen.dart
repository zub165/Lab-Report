import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient.dart';
import '../services/lab_test_api_service.dart';
import '../services/simple_hybrid_storage_service.dart';
import '../providers/test_provider.dart';

class LabTestSelectionScreen extends StatefulWidget {
  final Patient? selectedPatient;

  const LabTestSelectionScreen({Key? key, this.selectedPatient}) : super(key: key);

  @override
  State<LabTestSelectionScreen> createState() => _LabTestSelectionScreenState();
}

class _LabTestSelectionScreenState extends State<LabTestSelectionScreen> {
  final LabTestApiService _labTestApi = LabTestApiService();
  final SimpleHybridStorageService _hybridStorage = SimpleHybridStorageService();
  final TextEditingController _searchController = TextEditingController();
  
  List<LabTest> _allTests = [];
  List<LabTest> _filteredTests = [];
  List<Patient> _patients = [];
  String _selectedCategory = 'All';
  String? _selectedPatientId;
  bool _isLoading = false;
  String _sortBy = 'name'; // name, price, category
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.selectedPatient?.patientId;
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final futures = await Future.wait([
        _labTestApi.getAllTests(),
        _hybridStorage.getPatients(),
      ]);

      setState(() {
        _allTests = futures[0] as List<LabTest>;
        _patients = futures[1] as List<Patient>;
        _filteredTests = _allTests;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error loading data: $e');
    }
  }

  void _applyFilters() {
    List<LabTest> filtered = _allTests;

    // Apply category filter
    if (_selectedCategory != 'All') {
      filtered = filtered.where((test) => test.category == _selectedCategory).toList();
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((test) => 
        test.name.toLowerCase().contains(query) ||
        test.description.toLowerCase().contains(query)
      ).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'price':
          comparison = a.price.compareTo(b.price);
          break;
        case 'category':
          comparison = a.category.compareTo(b.category);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    setState(() {
      _filteredTests = filtered;
    });
  }

  Future<void> _orderTest(LabTest labTest) async {
    if (_selectedPatientId == null) {
      _showErrorDialog('Please select a patient first');
      return;
    }

    final confirmed = await _showOrderConfirmationDialog(labTest);
    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final orderResult = await _labTestApi.orderTest(
        testCode: labTest.testCode,
        patientId: _selectedPatientId!,
        orderedBy: 'Mobile App',
        notes: 'Ordered from Lab Test Selection',
      );

      if (mounted) {
        await Provider.of<TestProvider>(context, listen: false).loadTests();
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        final orderId = orderResult['order_id'] ?? '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              orderId.toString().isNotEmpty
                  ? 'Ordered "${labTest.name}" — Order #$orderId'
                  : 'Test "${labTest.name}" ordered successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error ordering test: $e');
    }
  }

  Future<bool?> _showOrderConfirmationDialog(LabTest labTest) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Test Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Test: ${labTest.name}'),
            Text('Price: \$${labTest.price.toStringAsFixed(2)}'),
            Text('Turnaround: ${labTest.turnaroundTime}'),
            if (_selectedPatientId != null)
              Text('Patient: ${_patients.firstWhere((p) => p.patientId == _selectedPatientId).fullName}'),
            const SizedBox(height: 16),
            const Text('Are you sure you want to order this test?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Order Test'),
          ),
        ],
      ),
    );
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
        title: Text(
          _allTests.isEmpty
              ? 'Lab Test Selection'
              : 'Lab Tests (${_filteredTests.length}/${_allTests.length})',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          _buildPatientSelector(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildTestsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search tests...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => _applyFilters(),
          ),
          const SizedBox(height: 16),
          // Category filter (all SaeedLab categories)
          FutureBuilder<List<String>>(
            future: _labTestApi.getTestCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator();
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }

              final categories = ['All', ...snapshot.data!];
              if (!categories.contains(_selectedCategory)) {
                _selectedCategory = 'All';
              }
              return DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                  _applyFilters();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPatientSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedPatientId,
        decoration: const InputDecoration(
          labelText: 'Select Patient *',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.person),
        ),
        items: _patients.map((patient) {
          final key = patient.patientId ??
              (patient.id != null ? patient.id.toString() : null);
          return DropdownMenuItem(
            value: key,
            child: Text(patient.fullName),
          );
        }).where((item) => item.value != null && item.value!.isNotEmpty).toList(),
        onChanged: (value) {
          setState(() {
            _selectedPatientId = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a patient';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTestsList() {
    if (_filteredTests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tests found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTests.length,
      itemBuilder: (context, index) {
        final test = _filteredTests[index];
        return _buildTestCard(test);
      },
    );
  }

  Widget _buildTestCard(LabTest test) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        test.category,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${test.price.toStringAsFixed(2)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        test.turnaroundTime,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              test.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showTestDetails(test),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedPatientId != null ? () => _orderTest(test) : null,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedPatientId != null ? null : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTestDetails(LabTest test) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(test.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Category', test.category),
              _buildDetailRow('Price', '\$${test.price.toStringAsFixed(2)}'),
              _buildDetailRow('Turnaround', test.turnaroundTime),
              _buildDetailRow('Currency', test.currency),
              const SizedBox(height: 16),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(test.description),
              const SizedBox(height: 16),
              const Text(
                'Preparation Instructions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(test.preparationInstructions),
              const SizedBox(height: 16),
              const Text(
                'Test Parameters:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...test.parameters.map((param) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  '${param['name']}: ${param['normal_range']} ${param['unit']}',
                  style: const TextStyle(fontSize: 12),
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (_selectedPatientId != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _orderTest(test);
              },
              child: const Text('Order Test'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Tests'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Name'),
              value: 'name',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            RadioListTile<String>(
              title: const Text('Price'),
              value: 'price',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            RadioListTile<String>(
              title: const Text('Category'),
              value: 'category',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
                _applyFilters();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
              });
              Navigator.pop(context);
              _applyFilters();
            },
            child: Text(_sortAscending ? 'Ascending' : 'Descending'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
