
class LabTestDatabaseService {
  static final LabTestDatabaseService _instance = LabTestDatabaseService._internal();
  factory LabTestDatabaseService() => _instance;
  LabTestDatabaseService._internal();

  // Comprehensive lab test database with normal ranges
  static const List<LabTest> _labTests = [
    // Blood Tests
    LabTest(
      id: 'cbc_001',
      name: 'Complete Blood Count (CBC)',
      category: 'Hematology',
      description: 'Complete blood count with differential',
      normalRange: 'See individual parameters',
      unit: 'Various',
      price: 25.0,
      preparation: 'No special preparation required',
      collectionMethod: 'Venous blood',
      processingTime: 'Same day',
      parameters: [
        LabTestParameter(
          name: 'White Blood Cell Count (WBC)',
          normalRange: '4,500-11,000',
          unit: 'cells/μL',
          criticalLow: '<2,000',
          criticalHigh: '>30,000',
        ),
        LabTestParameter(
          name: 'Red Blood Cell Count (RBC)',
          normalRange: '4.5-5.9',
          unit: 'million cells/μL',
          criticalLow: '<3.0',
          criticalHigh: '>7.0',
        ),
        LabTestParameter(
          name: 'Hemoglobin (Hgb)',
          normalRange: '13.8-17.2',
          unit: 'g/dL',
          criticalLow: '<8.0',
          criticalHigh: '>20.0',
        ),
        LabTestParameter(
          name: 'Hematocrit (Hct)',
          normalRange: '40.7-50.3',
          unit: '%',
          criticalLow: '<24.0',
          criticalHigh: '>60.0',
        ),
        LabTestParameter(
          name: 'Platelet Count',
          normalRange: '150,000-450,000',
          unit: 'cells/μL',
          criticalLow: '<50,000',
          criticalHigh: '>1,000,000',
        ),
      ],
    ),
    
    LabTest(
      id: 'lipid_001',
      name: 'Lipid Profile',
      category: 'Biochemistry',
      description: 'Complete lipid panel including cholesterol and triglycerides',
      normalRange: 'See individual parameters',
      unit: 'mg/dL',
      price: 35.0,
      preparation: 'Fasting 12-14 hours',
      collectionMethod: 'Venous blood',
      processingTime: 'Same day',
      parameters: [
        LabTestParameter(
          name: 'Total Cholesterol',
          normalRange: '<200',
          unit: 'mg/dL',
          criticalLow: '<100',
          criticalHigh: '>300',
        ),
        LabTestParameter(
          name: 'LDL Cholesterol',
          normalRange: '<100',
          unit: 'mg/dL',
          criticalLow: '<70',
          criticalHigh: '>190',
        ),
        LabTestParameter(
          name: 'HDL Cholesterol',
          normalRange: '>40',
          unit: 'mg/dL',
          criticalLow: '<20',
          criticalHigh: '>100',
        ),
        LabTestParameter(
          name: 'Triglycerides',
          normalRange: '<150',
          unit: 'mg/dL',
          criticalLow: '<50',
          criticalHigh: '>500',
        ),
      ],
    ),

    LabTest(
      id: 'liver_001',
      name: 'Liver Function Test (LFT)',
      category: 'Biochemistry',
      description: 'Comprehensive liver function panel',
      normalRange: 'See individual parameters',
      unit: 'Various',
      price: 40.0,
      preparation: 'No special preparation required',
      collectionMethod: 'Venous blood',
      processingTime: 'Same day',
      parameters: [
        LabTestParameter(
          name: 'ALT (Alanine Aminotransferase)',
          normalRange: '7-56',
          unit: 'U/L',
          criticalLow: '<5',
          criticalHigh: '>200',
        ),
        LabTestParameter(
          name: 'AST (Aspartate Aminotransferase)',
          normalRange: '10-40',
          unit: 'U/L',
          criticalLow: '<5',
          criticalHigh: '>200',
        ),
        LabTestParameter(
          name: 'Alkaline Phosphatase (ALP)',
          normalRange: '44-147',
          unit: 'U/L',
          criticalLow: '<30',
          criticalHigh: '>500',
        ),
        LabTestParameter(
          name: 'Total Bilirubin',
          normalRange: '0.3-1.2',
          unit: 'mg/dL',
          criticalLow: '<0.1',
          criticalHigh: '>5.0',
        ),
        LabTestParameter(
          name: 'Direct Bilirubin',
          normalRange: '0.0-0.3',
          unit: 'mg/dL',
          criticalLow: '<0.0',
          criticalHigh: '>2.0',
        ),
        LabTestParameter(
          name: 'Total Protein',
          normalRange: '6.3-8.2',
          unit: 'g/dL',
          criticalLow: '<5.0',
          criticalHigh: '>10.0',
        ),
        LabTestParameter(
          name: 'Albumin',
          normalRange: '3.5-5.0',
          unit: 'g/dL',
          criticalLow: '<2.5',
          criticalHigh: '>6.0',
        ),
      ],
    ),

    LabTest(
      id: 'kidney_001',
      name: 'Kidney Function Test (KFT)',
      category: 'Biochemistry',
      description: 'Comprehensive kidney function panel',
      normalRange: 'See individual parameters',
      unit: 'Various',
      price: 30.0,
      preparation: 'No special preparation required',
      collectionMethod: 'Venous blood',
      processingTime: 'Same day',
      parameters: [
        LabTestParameter(
          name: 'Creatinine',
          normalRange: '0.6-1.2',
          unit: 'mg/dL',
          criticalLow: '<0.3',
          criticalHigh: '>3.0',
        ),
        LabTestParameter(
          name: 'Blood Urea Nitrogen (BUN)',
          normalRange: '7-20',
          unit: 'mg/dL',
          criticalLow: '<5',
          criticalHigh: '>50',
        ),
        LabTestParameter(
          name: 'eGFR (estimated)',
          normalRange: '>60',
          unit: 'mL/min/1.73m²',
          criticalLow: '<30',
          criticalHigh: '>150',
        ),
        LabTestParameter(
          name: 'Uric Acid',
          normalRange: '3.5-7.0',
          unit: 'mg/dL',
          criticalLow: '<2.0',
          criticalHigh: '>12.0',
        ),
      ],
    ),

    LabTest(
      id: 'thyroid_001',
      name: 'Thyroid Function Test (TFT)',
      category: 'Endocrinology',
      description: 'Complete thyroid function panel',
      normalRange: 'See individual parameters',
      unit: 'Various',
      price: 45.0,
      preparation: 'No special preparation required',
      collectionMethod: 'Venous blood',
      processingTime: 'Same day',
      parameters: [
        LabTestParameter(
          name: 'TSH (Thyroid Stimulating Hormone)',
          normalRange: '0.4-4.0',
          unit: 'mIU/L',
          criticalLow: '<0.1',
          criticalHigh: '>10.0',
        ),
        LabTestParameter(
          name: 'Free T4 (Free Thyroxine)',
          normalRange: '0.8-1.8',
          unit: 'ng/dL',
          criticalLow: '<0.5',
          criticalHigh: '>3.0',
        ),
        LabTestParameter(
          name: 'Free T3 (Free Triiodothyronine)',
          normalRange: '2.3-4.2',
          unit: 'pg/mL',
          criticalLow: '<1.5',
          criticalHigh: '>6.0',
        ),
        LabTestParameter(
          name: 'Total T4 (Total Thyroxine)',
          normalRange: '4.5-12.0',
          unit: 'μg/dL',
          criticalLow: '<3.0',
          criticalHigh: '>15.0',
        ),
      ],
    ),

    LabTest(
      id: 'diabetes_001',
      name: 'Diabetes Screening Panel',
      category: 'Endocrinology',
      description: 'Comprehensive diabetes screening and monitoring',
      normalRange: 'See individual parameters',
      unit: 'Various',
      price: 25.0,
      preparation: 'Fasting 8-12 hours for glucose',
      collectionMethod: 'Venous blood',
      processingTime: 'Same day',
      parameters: [
        LabTestParameter(
          name: 'Fasting Blood Glucose',
          normalRange: '70-100',
          unit: 'mg/dL',
          criticalLow: '<50',
          criticalHigh: '>200',
        ),
        LabTestParameter(
          name: 'Random Blood Glucose',
          normalRange: '<140',
          unit: 'mg/dL',
          criticalLow: '<70',
          criticalHigh: '>300',
        ),
        LabTestParameter(
          name: 'HbA1c (Glycated Hemoglobin)',
          normalRange: '<5.7',
          unit: '%',
          criticalLow: '<4.0',
          criticalHigh: '>12.0',
        ),
        LabTestParameter(
          name: 'Insulin (Fasting)',
          normalRange: '2.6-24.9',
          unit: 'μIU/mL',
          criticalLow: '<1.0',
          criticalHigh: '>50.0',
        ),
      ],
    ),

    LabTest(
      id: 'cardiac_001',
      name: 'Cardiac Markers',
      category: 'Cardiology',
      description: 'Cardiac enzyme and protein markers',
      normalRange: 'See individual parameters',
      unit: 'Various',
      price: 50.0,
      preparation: 'No special preparation required',
      collectionMethod: 'Venous blood',
      processingTime: 'Same day',
      parameters: [
        LabTestParameter(
          name: 'Troponin I',
          normalRange: '<0.04',
          unit: 'ng/mL',
          criticalLow: '<0.01',
          criticalHigh: '>0.5',
        ),
        LabTestParameter(
          name: 'CK-MB (Creatine Kinase-MB)',
          normalRange: '<6.3',
          unit: 'ng/mL',
          criticalLow: '<1.0',
          criticalHigh: '>25.0',
        ),
        LabTestParameter(
          name: 'BNP (Brain Natriuretic Peptide)',
          normalRange: '<100',
          unit: 'pg/mL',
          criticalLow: '<10',
          criticalHigh: '>1000',
        ),
        LabTestParameter(
          name: 'Myoglobin',
          normalRange: '17-106',
          unit: 'ng/mL',
          criticalLow: '<10',
          criticalHigh: '>500',
        ),
      ],
    ),

    LabTest(
      id: 'urine_001',
      name: 'Urine Analysis (Complete)',
      category: 'Urinalysis',
      description: 'Complete urinalysis with microscopic examination',
      normalRange: 'See individual parameters',
      unit: 'Various',
      price: 20.0,
      preparation: 'Clean catch midstream urine',
      collectionMethod: 'Urine collection',
      processingTime: 'Same day',
      parameters: [
        LabTestParameter(
          name: 'Specific Gravity',
          normalRange: '1.005-1.030',
          unit: 'g/mL',
          criticalLow: '<1.002',
          criticalHigh: '>1.035',
        ),
        LabTestParameter(
          name: 'pH',
          normalRange: '4.6-8.0',
          unit: 'pH units',
          criticalLow: '<4.0',
          criticalHigh: '>9.0',
        ),
        LabTestParameter(
          name: 'Protein',
          normalRange: 'Negative',
          unit: 'mg/dL',
          criticalLow: 'Negative',
          criticalHigh: '>300',
        ),
        LabTestParameter(
          name: 'Glucose',
          normalRange: 'Negative',
          unit: 'mg/dL',
          criticalLow: 'Negative',
          criticalHigh: '>1000',
        ),
        LabTestParameter(
          name: 'Ketones',
          normalRange: 'Negative',
          unit: 'mg/dL',
          criticalLow: 'Negative',
          criticalHigh: '>80',
        ),
        LabTestParameter(
          name: 'Blood',
          normalRange: 'Negative',
          unit: 'RBC/HPF',
          criticalLow: 'Negative',
          criticalHigh: '>50',
        ),
        LabTestParameter(
          name: 'Leukocytes',
          normalRange: '0-5',
          unit: 'WBC/HPF',
          criticalLow: '0',
          criticalHigh: '>50',
        ),
      ],
    ),

    LabTest(
      id: 'coagulation_001',
      name: 'Coagulation Profile',
      category: 'Hematology',
      description: 'Complete coagulation studies',
      normalRange: 'See individual parameters',
      unit: 'Various',
      price: 35.0,
      preparation: 'No special preparation required',
      collectionMethod: 'Venous blood (citrated)',
      processingTime: 'Same day',
      parameters: [
        LabTestParameter(
          name: 'PT (Prothrombin Time)',
          normalRange: '11-13',
          unit: 'seconds',
          criticalLow: '<8',
          criticalHigh: '>20',
        ),
        LabTestParameter(
          name: 'INR (International Normalized Ratio)',
          normalRange: '0.8-1.1',
          unit: 'ratio',
          criticalLow: '<0.5',
          criticalHigh: '>5.0',
        ),
        LabTestParameter(
          name: 'aPTT (Activated Partial Thromboplastin Time)',
          normalRange: '25-35',
          unit: 'seconds',
          criticalLow: '<20',
          criticalHigh: '>60',
        ),
        LabTestParameter(
          name: 'Fibrinogen',
          normalRange: '200-400',
          unit: 'mg/dL',
          criticalLow: '<100',
          criticalHigh: '>800',
        ),
        LabTestParameter(
          name: 'D-Dimer',
          normalRange: '<0.5',
          unit: 'μg/mL',
          criticalLow: '<0.2',
          criticalHigh: '>2.0',
        ),
      ],
    ),

    LabTest(
      id: 'vitamin_001',
      name: 'Vitamin Panel',
      category: 'Nutrition',
      description: 'Essential vitamins and minerals',
      normalRange: 'See individual parameters',
      unit: 'Various',
      price: 60.0,
      preparation: 'No special preparation required',
      collectionMethod: 'Venous blood',
      processingTime: '2-3 days',
      parameters: [
        LabTestParameter(
          name: 'Vitamin D (25-OH)',
          normalRange: '30-100',
          unit: 'ng/mL',
          criticalLow: '<20',
          criticalHigh: '>150',
        ),
        LabTestParameter(
          name: 'Vitamin B12',
          normalRange: '200-900',
          unit: 'pg/mL',
          criticalLow: '<150',
          criticalHigh: '>1500',
        ),
        LabTestParameter(
          name: 'Folate (Folic Acid)',
          normalRange: '>3.0',
          unit: 'ng/mL',
          criticalLow: '<2.0',
          criticalHigh: '>20.0',
        ),
        LabTestParameter(
          name: 'Vitamin C',
          normalRange: '0.6-2.0',
          unit: 'mg/dL',
          criticalLow: '<0.2',
          criticalHigh: '>3.0',
        ),
      ],
    ),

    LabTest(
      id: 'hormone_001',
      name: 'Hormone Panel',
      category: 'Endocrinology',
      description: 'Comprehensive hormone analysis',
      normalRange: 'See individual parameters',
      unit: 'Various',
      price: 55.0,
      preparation: 'Fasting 8-12 hours',
      collectionMethod: 'Venous blood',
      processingTime: '2-3 days',
      parameters: [
        LabTestParameter(
          name: 'Cortisol (Morning)',
          normalRange: '6.2-19.4',
          unit: 'μg/dL',
          criticalLow: '<3.0',
          criticalHigh: '>30.0',
        ),
        LabTestParameter(
          name: 'Testosterone (Male)',
          normalRange: '300-1000',
          unit: 'ng/dL',
          criticalLow: '<200',
          criticalHigh: '>1500',
        ),
        LabTestParameter(
          name: 'Estradiol (Female)',
          normalRange: '30-400',
          unit: 'pg/mL',
          criticalLow: '<10',
          criticalHigh: '>800',
        ),
        LabTestParameter(
          name: 'Progesterone (Female)',
          normalRange: '0.1-25',
          unit: 'ng/mL',
          criticalLow: '<0.1',
          criticalHigh: '>50',
        ),
        LabTestParameter(
          name: 'FSH (Follicle Stimulating Hormone)',
          normalRange: '1.5-12.4',
          unit: 'mIU/mL',
          criticalLow: '<0.5',
          criticalHigh: '>50',
        ),
        LabTestParameter(
          name: 'LH (Luteinizing Hormone)',
          normalRange: '1.7-8.6',
          unit: 'mIU/mL',
          criticalLow: '<0.5',
          criticalHigh: '>50',
        ),
      ],
    ),
  ];

  // Get all lab tests
  List<LabTest> getAllLabTests() {
    return List.from(_labTests);
  }

  // Get lab tests by category
  List<LabTest> getLabTestsByCategory(String category) {
    return _labTests.where((test) => test.category.toLowerCase() == category.toLowerCase()).toList();
  }

  // Search lab tests
  List<LabTest> searchLabTests(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _labTests.where((test) =>
        test.name.toLowerCase().contains(lowercaseQuery) ||
        test.category.toLowerCase().contains(lowercaseQuery) ||
        test.description.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  // Get lab test by ID
  LabTest? getLabTestById(String id) {
    try {
      return _labTests.firstWhere((test) => test.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get all categories
  List<String> getAllCategories() {
    return _labTests.map((test) => test.category).toSet().toList()..sort();
  }

  // Get normal range for a specific parameter
  String? getNormalRange(String testId, String parameterName) {
    final test = getLabTestById(testId);
    if (test == null) return null;
    
    final parameter = test.parameters.firstWhere(
      (param) => param.name.toLowerCase() == parameterName.toLowerCase(),
      orElse: () => const LabTestParameter(name: '', normalRange: '', unit: '', criticalLow: '', criticalHigh: ''),
    );
    
    return parameter.normalRange.isNotEmpty ? parameter.normalRange : null;
  }

  // Check if a value is within normal range
  bool isValueNormal(String testId, String parameterName, double value) {
    final test = getLabTestById(testId);
    if (test == null) return false;
    
    final parameter = test.parameters.firstWhere(
      (param) => param.name.toLowerCase() == parameterName.toLowerCase(),
      orElse: () => const LabTestParameter(name: '', normalRange: '', unit: '', criticalLow: '', criticalHigh: ''),
    );
    
    if (parameter.normalRange.isEmpty) return false;
    
    // Parse normal range (assuming format like "4.5-5.9" or "<200")
    if (parameter.normalRange.contains('-')) {
      final parts = parameter.normalRange.split('-');
      if (parts.length == 2) {
        final min = double.tryParse(parts[0].trim());
        final max = double.tryParse(parts[1].trim());
        if (min != null && max != null) {
          return value >= min && value <= max;
        }
      }
    } else if (parameter.normalRange.startsWith('<')) {
      final max = double.tryParse(parameter.normalRange.substring(1).trim());
      if (max != null) {
        return value < max;
      }
    } else if (parameter.normalRange.startsWith('>')) {
      final min = double.tryParse(parameter.normalRange.substring(1).trim());
      if (min != null) {
        return value > min;
      }
    }
    
    return false;
  }
}

// Lab Test Model
class LabTest {
  final String id;
  final String name;
  final String category;
  final String description;
  final String normalRange;
  final String unit;
  final double price;
  final String preparation;
  final String collectionMethod;
  final String processingTime;
  final List<LabTestParameter> parameters;

  const LabTest({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.normalRange,
    required this.unit,
    required this.price,
    required this.preparation,
    required this.collectionMethod,
    required this.processingTime,
    required this.parameters,
  });
}

// Lab Test Parameter Model
class LabTestParameter {
  final String name;
  final String normalRange;
  final String unit;
  final String criticalLow;
  final String criticalHigh;

  const LabTestParameter({
    required this.name,
    required this.normalRange,
    required this.unit,
    required this.criticalLow,
    required this.criticalHigh,
  });
}
