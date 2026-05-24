import '../models/test.dart';

class OnlineTestDatabaseService {

  // Standard Laboratory Tests Database
  static final Map<String, List<Test>> _standardTests = {
    'Hematology': [
      Test(
        testId: 'CBC_001',
        patientId: 'template', // Template test, no specific patient
        testType: 'Hematology',
        testName: 'Complete Blood Count (CBC)',
        price: 25.00,
        orderedBy: 'System',
        orderedDate: DateTime.now(),
        status: 'Available',
        notes: 'Includes: WBC, RBC, Hemoglobin, Hematocrit, Platelets, Differential',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Test(
        testId: 'CBC_DIFF_002',
        patientId: 'template',
        testType: 'Hematology',
        testName: 'CBC with Differential',
        price: 35.00,
        orderedBy: 'System',
        orderedDate: DateTime.now(),
        status: 'Available',
        notes: 'Complete blood count with 5-part differential',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Test(
        testId: 'ESR_003',
        patientId: 'template',
        testType: 'Hematology',
        testName: 'Erythrocyte Sedimentation Rate (ESR)',
        price: 15.00,
        orderedBy: 'System',
        orderedDate: DateTime.now(),
        status: 'Available',
        notes: 'Measures inflammation in the body',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ],
    'Chemistry': [
      Test(
        testId: 'BMP_001',
        patientId: 'template',
        testType: 'Chemistry',
        testName: 'Basic Metabolic Panel (BMP)',
        price: 30.00,
        orderedBy: 'System',
        orderedDate: DateTime.now(),
        status: 'Available',
        notes: 'Glucose, BUN, Creatinine, Electrolytes (Na, K, Cl, CO2)',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Test(
        testId: 'CMP_002',
        patientId: 'template',
        testType: 'Chemistry',
        testName: 'Comprehensive Metabolic Panel (CMP)',
        price: 45.00,
        orderedBy: 'System',
        orderedDate: DateTime.now(),
        status: 'Available',
        notes: 'BMP + Liver function tests (ALT, AST, ALP, Bilirubin, Protein)',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Test(
        testId: 'RENAL_003',
        patientId: 'template',
        testType: 'Chemistry',
        testName: 'Renal Panel',
        price: 40.00,
        orderedBy: 'System',
        orderedDate: DateTime.now(),
        status: 'Available',
        notes: 'BUN, Creatinine, eGFR, Electrolytes, Phosphorus, Calcium',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Test(
        testId: 'LIVER_004',
        patientId: 'template',
        testType: 'Chemistry',
        testName: 'Liver Panel',
        price: 35.00,
        orderedBy: 'System',
        orderedDate: DateTime.now(),
        status: 'Available',
        notes: 'ALT, AST, ALP, Bilirubin (Total & Direct), Protein, Albumin',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Test(
        testId: 'LIPID_005',
        patientId: 'template',
        testType: 'Chemistry',
        testName: 'Lipid Panel',
        price: 25.00,
        orderedBy: 'System',
        orderedDate: DateTime.now(),
        status: 'Available',
        notes: 'Total Cholesterol, HDL, LDL, Triglycerides',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ],
    'Urinalysis': [
      Test(
        testId: 'UA_001',
        patientId: 'template',
        testType: 'Urinalysis',
        testName: 'Urinalysis',
        price: 20.00,
        orderedBy: 'System',
        orderedDate: DateTime.now(),
        status: 'Available',
        notes: 'Physical, chemical, and microscopic examination',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Test(
        testId: 'UA_MICRO_002',
        patientId: 'template',
        testType: 'Urinalysis',
        testName: 'Urinalysis with Microscopy',
        price: 30.00,
        orderedBy: 'System',
        orderedDate: DateTime.now(),
        status: 'Available',
        notes: 'Complete urinalysis with microscopic examination',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Test(
        testId: 'UA_CULTURE_003',
        patientId: 'template',
        testType: 'Urinalysis',
        testName: 'Urine Culture & Sensitivity',
        price: 50.00,
        orderedBy: 'System',
        orderedDate: DateTime.now(),
        status: 'Available',
        notes: 'Bacterial culture with antibiotic sensitivity testing',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ],
    'Endocrinology': [
      Test(
        testId: 'THYROID_001',
        patientId: 'template',
        testType: 'Endocrinology',
        testName: 'Thyroid Function Panel',
        price: 60.00,
        orderedBy: 'System',
        orderedDate: DateTime.now(),
        status: 'Available',
        notes: 'TSH, Free T4, Free T3',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Test(
        testId: 'DIABETES_002',
        patientId: 'template',
        testType: 'Endocrinology',
        testName: 'Diabetes Panel',
        price: 45.00,
        orderedBy: 'System',
        orderedDate: DateTime.now(),
        status: 'Available',
        notes: 'Glucose, HbA1c, Insulin, C-Peptide',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ],
    'Cardiology': [
      Test(
        testId: 'CARDIAC_001',
        patientId: 'template',
        testType: 'Cardiology',
        testName: 'Cardiac Markers',
        price: 55.00,
        orderedBy: 'System',
        orderedDate: DateTime.now(),
        status: 'Available',
        notes: 'Troponin I, CK-MB, BNP',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Test(
        testId: 'LIPID_ADV_002',
        patientId: 'template',
        testType: 'Cardiology',
        testName: 'Advanced Lipid Panel',
        price: 75.00,
        orderedBy: 'System',
        orderedDate: DateTime.now(),
        status: 'Available',
        notes: 'Extended lipid profile with particle size analysis',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ],
    'Infectious Disease': [
      Test(
        testId: 'CRP_001',
        patientId: 'template',
        testType: 'Infectious Disease',
        testName: 'C-Reactive Protein (CRP)',
        price: 25.00,
        orderedBy: 'System',
        orderedDate: DateTime.now(),
        status: 'Available',
        notes: 'Inflammation marker',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Test(
        testId: 'PROCALC_002',
        patientId: 'template',
        testType: 'Infectious Disease',
        testName: 'Procalcitonin',
        price: 40.00,
        orderedBy: 'System',
        orderedDate: DateTime.now(),
        status: 'Available',
        notes: 'Bacterial infection marker',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ],
  };

  // Get all available test categories
  static List<String> getTestCategories() {
    return _standardTests.keys.toList();
  }

  // Get tests by category
  static List<Test> getTestsByCategory(String category) {
    return _standardTests[category] ?? [];
  }

  // Get all available tests
  static List<Test> getAllTests() {
    List<Test> allTests = [];
    for (var tests in _standardTests.values) {
      allTests.addAll(tests);
    }
    return allTests;
  }

  // Search tests by name or type
  static List<Test> searchTests(String query) {
    if (query.isEmpty) return getAllTests();
    
    final lowercaseQuery = query.toLowerCase();
    List<Test> results = [];
    
    for (var tests in _standardTests.values) {
      for (Test test in tests) {
        if (test.testName.toLowerCase().contains(lowercaseQuery) ||
            test.testType.toLowerCase().contains(lowercaseQuery) ||
            test.notes?.toLowerCase().contains(lowercaseQuery) == true) {
          results.add(test);
        }
      }
    }
    
    return results;
  }

  // Get test by ID
  static Test? getTestById(String testId) {
    for (List<Test> tests in _standardTests.values) {
      for (Test test in tests) {
        if (test.testId == testId) {
          return test;
        }
      }
    }
    return null;
  }

  // Get normal ranges for a test (mock data - in real app, this would come from API)
  static Map<String, dynamic> getNormalRanges(String testId) {
    final normalRanges = {
      'CBC_001': {
        'WBC': {'min': 4.5, 'max': 11.0, 'unit': 'K/uL'},
        'RBC': {'min': 4.5, 'max': 5.9, 'unit': 'M/uL'},
        'Hemoglobin': {'min': 13.8, 'max': 17.2, 'unit': 'g/dL'},
        'Hematocrit': {'min': 40.7, 'max': 50.3, 'unit': '%'},
        'Platelets': {'min': 150, 'max': 450, 'unit': 'K/uL'},
      },
      'BMP_001': {
        'Glucose': {'min': 70, 'max': 100, 'unit': 'mg/dL'},
        'BUN': {'min': 7, 'max': 20, 'unit': 'mg/dL'},
        'Creatinine': {'min': 0.6, 'max': 1.2, 'unit': 'mg/dL'},
        'Sodium': {'min': 136, 'max': 145, 'unit': 'mEq/L'},
        'Potassium': {'min': 3.5, 'max': 5.0, 'unit': 'mEq/L'},
        'Chloride': {'min': 98, 'max': 107, 'unit': 'mEq/L'},
        'CO2': {'min': 22, 'max': 28, 'unit': 'mEq/L'},
      },
      'CMP_002': {
        'Glucose': {'min': 70, 'max': 100, 'unit': 'mg/dL'},
        'BUN': {'min': 7, 'max': 20, 'unit': 'mg/dL'},
        'Creatinine': {'min': 0.6, 'max': 1.2, 'unit': 'mg/dL'},
        'ALT': {'min': 7, 'max': 56, 'unit': 'U/L'},
        'AST': {'min': 10, 'max': 40, 'unit': 'U/L'},
        'ALP': {'min': 44, 'max': 147, 'unit': 'U/L'},
        'Total Bilirubin': {'min': 0.3, 'max': 1.2, 'unit': 'mg/dL'},
        'Total Protein': {'min': 6.3, 'max': 8.2, 'unit': 'g/dL'},
        'Albumin': {'min': 3.5, 'max': 5.0, 'unit': 'g/dL'},
      },
    };
    
    return normalRanges[testId] ?? {};
  }

  // Get turnaround times for tests
  static Map<String, String> getTurnaroundTimes() {
    return {
      'CBC_001': 'Same Day',
      'BMP_001': 'Same Day',
      'CMP_002': 'Same Day',
      'RENAL_003': 'Same Day',
      'LIVER_004': 'Same Day',
      'LIPID_005': 'Same Day',
      'UA_001': 'Same Day',
      'UA_MICRO_002': '1-2 Days',
      'UA_CULTURE_003': '2-3 Days',
      'THYROID_001': '1-2 Days',
      'DIABETES_002': '1-2 Days',
      'CARDIAC_001': 'Same Day',
      'LIPID_ADV_002': '3-5 Days',
      'PROCALC_002': '1-2 Days',
    };
  }

  // Fetch tests from online API (mock implementation)
  static Future<List<Test>> fetchTestsFromAPI() async {
    try {
      // In a real implementation, this would make an HTTP request
      // to an online test database API
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      return getAllTests();
    } catch (e) {
      print('Error fetching tests from API: $e');
      return getAllTests(); // Fallback to local data
    }
  }

  // Get test recommendations based on symptoms (AI-enhanced)
  static List<Test> getRecommendedTests(List<String> symptoms) {
    final recommendations = <Test>[];
    
    // Simple rule-based recommendations (in real app, this would use AI)
    if (symptoms.any((s) => ['fever', 'fatigue', 'weakness'].contains(s.toLowerCase()))) {
      recommendations.addAll(getTestsByCategory('Hematology'));
    }
    
    if (symptoms.any((s) => ['nausea', 'vomiting', 'abdominal pain'].contains(s.toLowerCase()))) {
      recommendations.addAll(getTestsByCategory('Chemistry'));
    }
    
    if (symptoms.any((s) => ['frequent urination', 'burning urination'].contains(s.toLowerCase()))) {
      recommendations.addAll(getTestsByCategory('Urinalysis'));
    }
    
    if (symptoms.any((s) => ['weight gain', 'weight loss', 'fatigue'].contains(s.toLowerCase()))) {
      recommendations.addAll(getTestsByCategory('Endocrinology'));
    }
    
    return recommendations;
  }
}
