import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/test.dart';
import '../models/patient.dart';
import '../providers/test_provider.dart';
import '../providers/patient_provider.dart';
import '../services/online_test_database_service.dart';
import '../services/ai_enhancement_service.dart';
import '../services/django_api_service.dart';
import '../utils/constants.dart';

class EnhancedAddTestScreen extends StatefulWidget {
  const EnhancedAddTestScreen({super.key});

  @override
  State<EnhancedAddTestScreen> createState() => _EnhancedAddTestScreenState();
}

class _EnhancedAddTestScreenState extends State<EnhancedAddTestScreen> {
  final _searchController = TextEditingController();
  final _notesController = TextEditingController();
  final _priorityController = TextEditingController();

  String _selectedCategory = 'All';
  String _selectedPatientId = '';
  String _selectedTestId = '';
  String _selectedStatus = 'Pending';
  String _selectedPriority = 'Normal';
  DateTime _selectedOrderDate = DateTime.now();
  bool _isLoading = false;
  bool _isSearching = false;

  List<Test> _availableTests = [];
  List<Patient> _patients = [];
  List<Test> _filteredTests = [];
  List<Test> _aiRecommendedTests = [];
  Test? _selectedTest;
  
  final _aiService = AIEnhancementService();
  final _apiService = DjangoApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Load patients and available tests
      final patientProvider = Provider.of<PatientProvider>(context, listen: false);
      await patientProvider.loadPatients();
      
      _patients = patientProvider.patients;
      _availableTests = await OnlineTestDatabaseService.fetchTestsFromAPI();
      _filteredTests = _availableTests;

      if (_patients.isNotEmpty) {
        _selectedPatientId = _patients.first.patientId ?? '';
        await _getAIRecommendations();
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getAIRecommendations() async {
    if (_selectedPatientId.isEmpty) return;
    
    try {
      final patient = _patients.firstWhere(
        (p) => p.patientId == _selectedPatientId,
        orElse: () => _patients.isNotEmpty ? _patients.first : Patient(
          patientId: '',
          fullName: 'Unknown',
          dateOfBirth: DateTime.now(),
          gender: 'Unknown',
          phone: '',
        ),
      );
      final recommendations = await _aiService.getTestRecommendations(patient);
      _aiRecommendedTests = recommendations;
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error getting AI recommendations: $e');
    }
  }

  void _onPatientChanged(String? patientId) {
    setState(() {
      _selectedPatientId = patientId ?? '';
      _selectedTestId = '';
      _selectedTest = null;
    });
    
    if (patientId != null) {
      _getAIRecommendations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Test'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveTest,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildSearchAndFilterSection(),
                  if (_aiRecommendedTests.isNotEmpty) _buildAIRecommendationsSection(),
                  _buildTestSelectionSection(),
                  _buildTestDetailsSection(),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Tests',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterTests();
                        },
                      ),
              ),
              onChanged: (value) {
                _filterTests();
              },
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: ['All', ...OnlineTestDatabaseService.getTestCategories()]
                      .map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                    _filterTests();
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedPatientId,
                  decoration: const InputDecoration(
                    labelText: 'Patient *',
                    border: OutlineInputBorder(),
                  ),
                  items: _patients.map((patient) {
                    return DropdownMenuItem(
                      value: patient.patientId,
                      child: Text(patient.fullName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPatientId = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a patient';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIRecommendationsSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Text(
                  'AI Recommended Tests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Based on patient profile and medical history, our AI suggests these tests:',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            ..._aiRecommendedTests.take(3).map((test) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple[100],
                child: Icon(Icons.science, color: Colors.purple[600]),
              ),
              title: Text(test.testName),
              subtitle: Text('${test.testType} • \$${test.price.toStringAsFixed(2)}'),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _selectedTestId = test.testId ?? '';
                    _selectedTest = test;
                  });
                },
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSelectionSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Available Tests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _filteredTests.isEmpty
                ? const Center(
                    child: Text('No tests found. Try adjusting your search criteria.'),
                  )
                : ListView.builder(
                    itemCount: _filteredTests.length,
                    itemBuilder: (context, index) {
                      final test = _filteredTests[index];
                      final isSelected = _selectedTestId == test.testId;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        color: isSelected ? AppConstants.primaryColor.withOpacity(0.1) : null,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected 
                                ? AppConstants.primaryColor 
                                : Colors.grey[300],
                            child: Icon(
                              _getTestIcon(test.testType),
                              color: isSelected ? Colors.white : Colors.grey[600],
                            ),
                          ),
                          title: Text(
                            test.testName,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Type: ${test.testType}'),
                              Text('Price: \$${test.price.toStringAsFixed(2)}'),
                              if (test.notes != null)
                                Text(
                                  test.notes!,
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '\$${test.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const Text(
                                'Same Day',
                                style: TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              _selectedTestId = test.testId ?? '';
                              _selectedTest = test;
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestDetailsSection() {
    if (_selectedTest == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Pending', 'In Progress', 'Completed', 'Cancelled']
                      .map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Low', 'Normal', 'High', 'Urgent']
                      .map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _selectOrderDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Order Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  '${_selectedOrderDate.day}/${_selectedOrderDate.month}/${_selectedOrderDate.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
                hintText: 'Additional notes or special instructions',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildTestInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestInfoCard() {
    if (_selectedTest == null) return const SizedBox.shrink();

    final normalRanges = OnlineTestDatabaseService.getNormalRanges(_selectedTest!.testId ?? '');
    final turnaroundTime = OnlineTestDatabaseService.getTurnaroundTimes()[_selectedTest!.testId ?? ''] ?? 'Same Day';

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Information',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Test: ${_selectedTest!.testName}'),
            Text('Type: ${_selectedTest!.testType}'),
            Text('Price: \$${_selectedTest!.price.toStringAsFixed(2)}'),
            Text('Turnaround: $turnaroundTime'),
            if (normalRanges.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Normal Ranges:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...normalRanges.entries.map((entry) {
                final range = entry.value;
                return Text(
                  '${entry.key}: ${range['min']}-${range['max']} ${range['unit']}',
                  style: const TextStyle(fontSize: 12),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Order Test'),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTestIcon(String testType) {
    switch (testType.toLowerCase()) {
      case 'hematology':
        return Icons.bloodtype;
      case 'chemistry':
        return Icons.science;
      case 'urinalysis':
        return Icons.water_drop;
      case 'endocrinology':
        return Icons.psychology;
      case 'cardiology':
        return Icons.favorite;
      case 'infectious disease':
        return Icons.bug_report;
      default:
        return Icons.medical_services;
    }
  }

  void _filterTests() {
    setState(() {
      _isSearching = true;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 300), () {
      String query = _searchController.text.toLowerCase();
      
      List<Test> filtered = _availableTests.where((test) {
        bool matchesCategory = _selectedCategory == 'All' || test.testType == _selectedCategory;
        bool matchesSearch = query.isEmpty ||
            test.testName.toLowerCase().contains(query) ||
            test.testType.toLowerCase().contains(query) ||
            (test.notes?.toLowerCase().contains(query) ?? false);
        
        return matchesCategory && matchesSearch;
      }).toList();

      setState(() {
        _filteredTests = filtered;
        _isSearching = false;
      });
    });
  }

  Future<void> _selectOrderDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedOrderDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedOrderDate) {
      setState(() {
        _selectedOrderDate = picked;
      });
    }
  }

  Future<void> _saveTest() async {
    if (_selectedTest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a test')),
      );
      return;
    }

    if (_selectedPatientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final test = Test(
        testId: DateTime.now().millisecondsSinceEpoch.toString(),
        testType: _selectedTest!.testType,
        testName: _selectedTest!.testName,
        patientId: _selectedPatientId,
        price: _selectedTest!.price,
        orderedBy: 'System', // In real app, this would be the current user
        orderedDate: _selectedOrderDate,
        status: _selectedStatus,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await Provider.of<TestProvider>(context, listen: false).addTest(test);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test ordered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ordering test: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
