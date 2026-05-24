import '../models/test.dart';
import 'django_api_service.dart';

class LabTestApiService {
  final DjangoApiService _api = DjangoApiService();
  
  // Mock data for demonstration - replace with actual API calls
  static final List<Map<String, dynamic>> _availableTests = [
    {
      'id': 'cbc_001',
      'name': 'Complete Blood Count (CBC)',
      'category': 'Hematology',
      'description': 'Complete blood count with differential',
      'price': 25.00,
      'currency': 'USD',
      'turnaround_time': 'Same Day',
      'preparation_instructions': 'No special preparation required',
      'normal_values': {
        'WBC': '4.5-11.0 K/µL',
        'RBC': '4.2-5.4 M/µL',
        'Hemoglobin': '12.0-16.0 g/dL',
        'Hematocrit': '36-46 %',
        'Platelets': '150-450 K/µL'
      },
      'parameters': [
        {'name': 'White Blood Cells', 'unit': 'K/µL', 'normal_range': '4.5-11.0'},
        {'name': 'Red Blood Cells', 'unit': 'M/µL', 'normal_range': '4.2-5.4'},
        {'name': 'Hemoglobin', 'unit': 'g/dL', 'normal_range': '12.0-16.0'},
        {'name': 'Hematocrit', 'unit': '%', 'normal_range': '36-46'},
        {'name': 'Platelets', 'unit': 'K/µL', 'normal_range': '150-450'}
      ]
    },
    {
      'id': 'cbc_diff_001',
      'name': 'CBC with Differential',
      'category': 'Hematology',
      'description': 'Complete blood count with 5-part differential',
      'price': 35.00,
      'currency': 'USD',
      'turnaround_time': 'Same Day',
      'preparation_instructions': 'No special preparation required',
      'normal_values': {
        'WBC': '4.5-11.0 K/µL',
        'RBC': '4.2-5.4 M/µL',
        'Hemoglobin': '12.0-16.0 g/dL',
        'Hematocrit': '36-46 %',
        'Platelets': '150-450 K/µL',
        'Neutrophils': '40-70%',
        'Lymphocytes': '20-40%',
        'Monocytes': '2-8%',
        'Eosinophils': '1-4%',
        'Basophils': '0.5-1%'
      },
      'parameters': [
        {'name': 'White Blood Cells', 'unit': 'K/µL', 'normal_range': '4.5-11.0'},
        {'name': 'Red Blood Cells', 'unit': 'M/µL', 'normal_range': '4.2-5.4'},
        {'name': 'Hemoglobin', 'unit': 'g/dL', 'normal_range': '12.0-16.0'},
        {'name': 'Hematocrit', 'unit': '%', 'normal_range': '36-46'},
        {'name': 'Platelets', 'unit': 'K/µL', 'normal_range': '150-450'},
        {'name': 'Neutrophils', 'unit': '%', 'normal_range': '40-70'},
        {'name': 'Lymphocytes', 'unit': '%', 'normal_range': '20-40'},
        {'name': 'Monocytes', 'unit': '%', 'normal_range': '2-8'},
        {'name': 'Eosinophils', 'unit': '%', 'normal_range': '1-4'},
        {'name': 'Basophils', 'unit': '%', 'normal_range': '0.5-1'}
      ]
    },
    {
      'id': 'lipid_001',
      'name': 'Lipid Panel',
      'category': 'Chemistry',
      'description': 'Comprehensive lipid profile including cholesterol and triglycerides',
      'price': 45.00,
      'currency': 'USD',
      'turnaround_time': '1-2 Days',
      'preparation_instructions': 'Fasting required for 12 hours',
      'normal_values': {
        'Total Cholesterol': '<200 mg/dL',
        'HDL Cholesterol': '≥40 mg/dL',
        'LDL Cholesterol': '<100 mg/dL',
        'Triglycerides': '<150 mg/dL',
        'Non-HDL Cholesterol': '<130 mg/dL'
      },
      'parameters': [
        {'name': 'Total Cholesterol', 'unit': 'mg/dL', 'normal_range': '<200'},
        {'name': 'HDL Cholesterol', 'unit': 'mg/dL', 'normal_range': '≥40'},
        {'name': 'LDL Cholesterol', 'unit': 'mg/dL', 'normal_range': '<100'},
        {'name': 'Triglycerides', 'unit': 'mg/dL', 'normal_range': '<150'},
        {'name': 'Non-HDL Cholesterol', 'unit': 'mg/dL', 'normal_range': '<130'}
      ]
    },
    {
      'id': 'metabolic_001',
      'name': 'Basic Metabolic Panel',
      'category': 'Chemistry',
      'description': 'Basic metabolic panel including glucose, electrolytes, and kidney function',
      'price': 30.00,
      'currency': 'USD',
      'turnaround_time': 'Same Day',
      'preparation_instructions': 'Fasting recommended for 8 hours',
      'normal_values': {
        'Glucose': '70-99 mg/dL',
        'BUN': '7-20 mg/dL',
        'Creatinine': '0.7-1.3 mg/dL',
        'Sodium': '135-145 mEq/L',
        'Potassium': '3.5-5.0 mEq/L',
        'Chloride': '96-106 mEq/L',
        'CO2': '22-28 mEq/L',
        'Calcium': '8.5-10.5 mg/dL'
      },
      'parameters': [
        {'name': 'Glucose', 'unit': 'mg/dL', 'normal_range': '70-99'},
        {'name': 'BUN', 'unit': 'mg/dL', 'normal_range': '7-20'},
        {'name': 'Creatinine', 'unit': 'mg/dL', 'normal_range': '0.7-1.3'},
        {'name': 'Sodium', 'unit': 'mEq/L', 'normal_range': '135-145'},
        {'name': 'Potassium', 'unit': 'mEq/L', 'normal_range': '3.5-5.0'},
        {'name': 'Chloride', 'unit': 'mEq/L', 'normal_range': '96-106'},
        {'name': 'CO2', 'unit': 'mEq/L', 'normal_range': '22-28'},
        {'name': 'Calcium', 'unit': 'mg/dL', 'normal_range': '8.5-10.5'}
      ]
    },
    {
      'id': 'thyroid_001',
      'name': 'Thyroid Function Panel',
      'category': 'Endocrinology',
      'description': 'Comprehensive thyroid function assessment',
      'price': 65.00,
      'currency': 'USD',
      'turnaround_time': '1-2 Days',
      'preparation_instructions': 'No special preparation required',
      'normal_values': {
        'TSH': '0.4-4.0 mIU/L',
        'Free T4': '0.8-1.8 ng/dL',
        'Free T3': '2.3-4.2 pg/mL',
        'Reverse T3': '9.2-24.1 ng/dL'
      },
      'parameters': [
        {'name': 'TSH', 'unit': 'mIU/L', 'normal_range': '0.4-4.0'},
        {'name': 'Free T4', 'unit': 'ng/dL', 'normal_range': '0.8-1.8'},
        {'name': 'Free T3', 'unit': 'pg/mL', 'normal_range': '2.3-4.2'},
        {'name': 'Reverse T3', 'unit': 'ng/dL', 'normal_range': '9.2-24.1'}
      ]
    },
    {
      'id': 'liver_001',
      'name': 'Liver Function Panel',
      'category': 'Chemistry',
      'description': 'Comprehensive liver function assessment',
      'price': 40.00,
      'currency': 'USD',
      'turnaround_time': 'Same Day',
      'preparation_instructions': 'No special preparation required',
      'normal_values': {
        'ALT': '7-56 U/L',
        'AST': '10-40 U/L',
        'ALP': '44-147 U/L',
        'Total Bilirubin': '0.3-1.2 mg/dL',
        'Direct Bilirubin': '0.0-0.3 mg/dL',
        'Albumin': '3.5-5.0 g/dL',
        'Total Protein': '6.3-8.2 g/dL'
      },
      'parameters': [
        {'name': 'ALT', 'unit': 'U/L', 'normal_range': '7-56'},
        {'name': 'AST', 'unit': 'U/L', 'normal_range': '10-40'},
        {'name': 'ALP', 'unit': 'U/L', 'normal_range': '44-147'},
        {'name': 'Total Bilirubin', 'unit': 'mg/dL', 'normal_range': '0.3-1.2'},
        {'name': 'Direct Bilirubin', 'unit': 'mg/dL', 'normal_range': '0.0-0.3'},
        {'name': 'Albumin', 'unit': 'g/dL', 'normal_range': '3.5-5.0'},
        {'name': 'Total Protein', 'unit': 'g/dL', 'normal_range': '6.3-8.2'}
      ]
    },
    {
      'id': 'urine_001',
      'name': 'Urinalysis',
      'category': 'Urinalysis',
      'description': 'Complete urinalysis with microscopic examination',
      'price': 20.00,
      'currency': 'USD',
      'turnaround_time': 'Same Day',
      'preparation_instructions': 'Clean catch midstream urine sample',
      'normal_values': {
        'Appearance': 'Clear',
        'Color': 'Yellow',
        'Specific Gravity': '1.005-1.030',
        'pH': '4.5-8.0',
        'Protein': 'Negative',
        'Glucose': 'Negative',
        'Ketones': 'Negative',
        'Blood': 'Negative',
        'Nitrites': 'Negative',
        'Leukocyte Esterase': 'Negative'
      },
      'parameters': [
        {'name': 'Appearance', 'unit': '', 'normal_range': 'Clear'},
        {'name': 'Color', 'unit': '', 'normal_range': 'Yellow'},
        {'name': 'Specific Gravity', 'unit': '', 'normal_range': '1.005-1.030'},
        {'name': 'pH', 'unit': '', 'normal_range': '4.5-8.0'},
        {'name': 'Protein', 'unit': '', 'normal_range': 'Negative'},
        {'name': 'Glucose', 'unit': '', 'normal_range': 'Negative'},
        {'name': 'Ketones', 'unit': '', 'normal_range': 'Negative'},
        {'name': 'Blood', 'unit': '', 'normal_range': 'Negative'},
        {'name': 'Nitrites', 'unit': '', 'normal_range': 'Negative'},
        {'name': 'Leukocyte Esterase', 'unit': '', 'normal_range': 'Negative'}
      ]
    }
  ];

  static String _formatTurnaround(dynamic value) {
    if (value == null) return '24 hours';
    if (value is int) {
      if (value <= 1) return 'Same Day';
      if (value == 2) return '1-2 Days';
      return '$value Days';
    }
    final s = value.toString().trim();
    return s.isEmpty ? '24 hours' : s;
  }

  /// Maps Django `/lab/tests/` rows (same as SaeedLab Test Types table).
  static LabTest fromCatalogApi(Map<String, dynamic> json) {
    final normalRange = json['normal_range']?.toString();
    final code = json['test_code']?.toString() ?? '';
    return LabTest(
      id: json['id']?.toString() ?? code,
      testCode: code.isNotEmpty ? code : (json['id']?.toString() ?? ''),
      name: json['test_name']?.toString() ?? '',
      category: json['category_name']?.toString() ?? 'General',
      description: json['description']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      currency: 'USD',
      turnaroundTime: _formatTurnaround(json['turnaround_time']),
      preparationInstructions:
          json['preparation_instructions']?.toString() ??
              'Follow standard preparation guidelines',
      normalValues: normalRange != null && normalRange.isNotEmpty
          ? {'Reference': normalRange}
          : const {},
      parameters: const [],
    );
  }

  // Full catalog from https://api.mywaitime.com/lab/tests/ (61+ tests on SaeedLab)
  Future<List<LabTest>> getAllTests() async {
    try {
      final catalog = await _api.getLabTestCatalog();
      final tests = catalog.map(fromCatalogApi).where((t) => t.name.isNotEmpty).toList();
      tests.sort((a, b) => a.name.compareTo(b.name));
      if (tests.isNotEmpty) {
        print('✅ Loaded ${tests.length} lab tests from SaeedLab API');
        return tests;
      }
    } catch (e) {
      print('Lab catalog API failed, using bundled reference list: $e');
    }
    return _availableTests.map((testData) => LabTest.fromJson(testData)).toList();
  }

  // Get tests by category
  Future<List<LabTest>> getTestsByCategory(String category) async {
    try {
      final allTests = await getAllTests();
      return allTests.where((test) => test.category.toLowerCase() == category.toLowerCase()).toList();
    } catch (e) {
      throw Exception('Failed to load tests by category: $e');
    }
  }

  // Search tests by name or description
  Future<List<LabTest>> searchTests(String query) async {
    try {
      final allTests = await getAllTests();
      return allTests.where((test) => 
        test.name.toLowerCase().contains(query.toLowerCase()) ||
        test.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      throw Exception('Failed to search tests: $e');
    }
  }

  // Get test by ID
  Future<LabTest?> getTestById(String testId) async {
    try {
      final allTests = await getAllTests();
      return allTests.firstWhere((test) => test.id == testId);
    } catch (e) {
      return null;
    }
  }

  // Categories from `/lab/test-categories/` (Hematology, Chemistry, …)
  Future<List<String>> getTestCategories() async {
    try {
      final names = await _api.getLabTestCategoryNames();
      if (names.isNotEmpty) {
        names.sort();
        return names;
      }
    } catch (e) {
      print('Category API failed, deriving from tests: $e');
    }
    final allTests = await getAllTests();
    final derived = allTests.map((t) => t.category).toSet().toList();
    derived.sort();
    return derived;
  }

  // Order via SaeedLab API: POST /lab/test-orders/
  Future<Map<String, dynamic>> orderTest({
    required String testCode,
    required String patientId,
    required String orderedBy,
    String? notes,
    String priority = 'routine',
  }) async {
    final p = priority.toLowerCase();
    final priorityApi = p == 'stat'
        ? 'stat'
        : (p == 'urgent' ? 'urgent' : 'routine');
    final order = await _api.createTestOrderForPatient(
      patientId: patientId,
      testCodes: [testCode],
      priority: priorityApi,
      clinicalNotes: notes ?? 'Ordered from mobile app by $orderedBy',
    );
    return {
      'order_id': order.testId,
      'test_code': testCode,
      'patient_id': patientId,
      'status': order.status,
      'message': 'Test order created on server',
    };
  }

  // Update test order
  Future<Map<String, dynamic>> updateTestOrder({
    required String orderId,
    String? priority,
    String? notes,
    String? status,
  }) async {
    try {
      // In a real implementation, this would make an API call to update the order
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API delay
      
      return {
        'order_id': orderId,
        'updated_at': DateTime.now().toIso8601String(),
        'priority': priority,
        'notes': notes,
        'status': status,
        'message': 'Order updated successfully'
      };
    } catch (e) {
      throw Exception('Failed to update test order: $e');
    }
  }

  // Cancel test order
  Future<Map<String, dynamic>> cancelTestOrder(String orderId) async {
    try {
      // In a real implementation, this would make an API call to cancel the order
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API delay
      
      return {
        'order_id': orderId,
        'cancelled_at': DateTime.now().toIso8601String(),
        'status': 'Cancelled',
        'message': 'Order cancelled successfully'
      };
    } catch (e) {
      throw Exception('Failed to cancel test order: $e');
    }
  }

  // Get order status
  Future<Map<String, dynamic>> getOrderStatus(String orderId) async {
    try {
      // In a real implementation, this would make an API call to get order status
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate API delay
      
      return {
        'order_id': orderId,
        'status': 'Pending',
        'progress': 25,
        'last_updated': DateTime.now().toIso8601String(),
        'estimated_completion': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get order status: $e');
    }
  }

  // Calculate estimated completion time
  String _calculateEstimatedCompletion(String turnaroundTime) {
    final now = DateTime.now();
    switch (turnaroundTime.toLowerCase()) {
      case 'same day':
        return now.add(const Duration(hours: 4)).toIso8601String();
      case '1-2 days':
        return now.add(const Duration(days: 1)).toIso8601String();
      case '2-3 days':
        return now.add(const Duration(days: 2)).toIso8601String();
      case '1 week':
        return now.add(const Duration(days: 7)).toIso8601String();
      default:
        return now.add(const Duration(hours: 24)).toIso8601String();
    }
  }

  // Convert LabTest to Test model for internal use
  Test convertToTest(LabTest labTest, String patientId, String orderedBy) {
    return Test(
      testId: labTest.id,
      patientId: patientId,
      testName: labTest.name,
      testType: labTest.name,
      status: 'Pending',
      orderedDate: DateTime.now(),
      orderedBy: orderedBy,
      price: labTest.price,
      notes: labTest.description,
    );
  }
}

class LabTest {
  final String id;
  /// SaeedLab POST /test-orders/ expects `test_items: [{ test_code }]`.
  final String testCode;
  final String name;
  final String category;
  final String description;
  final double price;
  final String currency;
  final String turnaroundTime;
  final String preparationInstructions;
  final Map<String, String> normalValues;
  final List<Map<String, String>> parameters;

  LabTest({
    required this.id,
    String? testCode,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.currency,
    required this.turnaroundTime,
    required this.preparationInstructions,
    required this.normalValues,
    required this.parameters,
  }) : testCode = testCode ?? id;

  factory LabTest.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final code = json['test_code']?.toString() ?? id;
    return LabTest(
      id: id,
      testCode: code,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse((json['price'] ?? 0.0).toString()) ?? 0.0,
      currency: json['currency'] ?? 'USD',
      turnaroundTime: json['turnaround_time'] ?? '',
      preparationInstructions: json['preparation_instructions'] ?? '',
      normalValues: Map<String, String>.from(json['normal_values'] ?? {}),
      parameters: List<Map<String, String>>.from(
        (json['parameters'] ?? []).map((param) => Map<String, String>.from(param))
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'currency': currency,
      'turnaround_time': turnaroundTime,
      'preparation_instructions': preparationInstructions,
      'normal_values': normalValues,
      'parameters': parameters,
    };
  }
}
