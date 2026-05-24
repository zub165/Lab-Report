import 'package:flutter/material.dart';
import '../services/lab_test_database_service.dart' as local_service;
import '../services/online_lab_api_service.dart';
import '../models/lab_test.dart';

class LabTestsCatalogScreen extends StatefulWidget {
  const LabTestsCatalogScreen({Key? key}) : super(key: key);

  @override
  State<LabTestsCatalogScreen> createState() => _LabTestsCatalogScreenState();
}

class _LabTestsCatalogScreenState extends State<LabTestsCatalogScreen> {
  final local_service.LabTestDatabaseService _labTestService = local_service.LabTestDatabaseService();
  final OnlineLabApiService _onlineApiService = OnlineLabApiService();
  List<LabTest> _allTests = [];
  List<LabTest> _filteredTests = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _useOnlineData = true;

  @override
  void initState() {
    super.initState();
    _loadLabTests();
  }

  Future<void> _loadLabTests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<LabTest> tests;
      
        if (_useOnlineData) {
          // Try to load from online API first
          tests = await _onlineApiService.fetchLabTestsWithNormalValues();
          if (tests.isEmpty) {
            // Fallback to local data if online fails
            tests = _labTestService.getAllLabTests().map((test) => LabTest(
              id: test.id,
              name: test.name,
              category: test.category,
              description: test.description,
              normalRange: test.normalRange,
              unit: test.unit,
              price: test.price,
              preparation: test.preparation,
              collectionMethod: test.collectionMethod,
              processingTime: test.processingTime,
              parameters: test.parameters.map((p) => LabTestParameter(
                name: p.name,
                normalRange: p.normalRange,
                unit: p.unit,
                criticalLow: p.criticalLow,
                criticalHigh: p.criticalHigh,
              )).toList(),
            )).toList();
          }
        } else {
          // Use local data only
          tests = _labTestService.getAllLabTests().map((test) => LabTest(
            id: test.id,
            name: test.name,
            category: test.category,
            description: test.description,
            normalRange: test.normalRange,
            unit: test.unit,
            price: test.price,
            preparation: test.preparation,
            collectionMethod: test.collectionMethod,
            processingTime: test.processingTime,
            parameters: test.parameters.map((p) => LabTestParameter(
              name: p.name,
              normalRange: p.normalRange,
              unit: p.unit,
              criticalLow: p.criticalLow,
              criticalHigh: p.criticalHigh,
            )).toList(),
          )).toList();
        }
      
      setState(() {
        _allTests = tests;
        _filteredTests = tests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error loading lab tests: $e');
    }
  }

  void _filterTests() {
    setState(() {
      _filteredTests = _allTests.where((test) {
        final matchesCategory = _selectedCategory == 'All' || test.category == _selectedCategory;
        final matchesSearch = _searchQuery.isEmpty || 
            test.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            test.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            test.description.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
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
        title: const Text('Lab Tests Catalog'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_useOnlineData ? Icons.cloud_done : Icons.cloud_off),
            onPressed: () {
              setState(() {
                _useOnlineData = !_useOnlineData;
              });
              _loadLabTests();
            },
            tooltip: _useOnlineData ? 'Using Online Data' : 'Using Local Data',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLabTests,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchAndFilterSection(),
                _buildStatsSection(),
                Expanded(
                  child: _buildTestsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search lab tests...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _filterTests();
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('All'),
                const SizedBox(width: 8),
                ..._allTests.map((test) => test.category).toSet().map((category) => 
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildCategoryChip(category),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = category;
        });
        _filterTests();
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildStatsSection() {
    final categories = _allTests.map((test) => test.category).toSet().toList();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Tests',
                  _allTests.length.toString(),
                  Icons.science,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Categories',
                  categories.length.toString(),
                  Icons.category,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Filtered',
                  _filteredTests.length.toString(),
                  Icons.filter_list,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _useOnlineData ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _useOnlineData ? Colors.green : Colors.orange,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _useOnlineData ? Icons.cloud_done : Icons.cloud_off,
                  size: 16,
                  color: _useOnlineData ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  _useOnlineData ? 'Online Data Source' : 'Local Data Source',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _useOnlineData ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestsList() {
    if (_filteredTests.isEmpty) {
      return const Center(
        child: Text(
          'No lab tests found matching your criteria.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
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
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(test.category),
          child: Text(
            test.category[0],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          test.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(test.category),
            Text(
              test.description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.green[700]),
                Text(
                  '\$${test.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.blue[700]),
                Text(
                  test.processingTime,
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTestInfoRow('Preparation', test.preparation),
                _buildTestInfoRow('Collection Method', test.collectionMethod),
                _buildTestInfoRow('Processing Time', test.processingTime),
                const SizedBox(height: 16),
                const Text(
                  'Test Parameters & Normal Ranges:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...test.parameters.map((param) => _buildParameterCard(param)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestInfoRow(String label, String value) {
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

  Widget _buildParameterCard(LabTestParameter param) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    param.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    param.unit,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Normal Range: ${param.normalRange}',
                        style: const TextStyle(color: Colors.green),
                      ),
                      if (param.criticalLow.isNotEmpty)
                        Text(
                          'Critical Low: ${param.criticalLow}',
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      if (param.criticalHigh.isNotEmpty)
                        Text(
                          'Critical High: ${param.criticalHigh}',
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'hematology':
        return Colors.red;
      case 'biochemistry':
        return Colors.blue;
      case 'endocrinology':
        return Colors.purple;
      case 'cardiology':
        return Colors.orange;
      case 'urinalysis':
        return Colors.green;
      case 'nutrition':
        return Colors.teal;
      case 'pathology':
        return Colors.brown;
      case 'microbiology':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}
