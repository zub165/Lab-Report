
class LabReferenceService {
  static final LabReferenceService _instance = LabReferenceService._internal();
  factory LabReferenceService() => _instance;
  LabReferenceService._internal();

  // Online lab reference data sources
  final Map<String, String> _referenceSources = {
    'mayo_clinic': 'https://www.mayoclinic.org/',
    'labcorp': 'https://www.labcorp.com/',
    'quest_diagnostics': 'https://www.questdiagnostics.com/',
    'medline_plus': 'https://medlineplus.gov/',
    'webmd': 'https://www.webmd.com/',
  };

  // Comprehensive lab reference ranges
  final Map<String, LabReferenceRange> _referenceRanges = {
    'CBC': LabReferenceRange(
      testName: 'Complete Blood Count',
      parameters: {
        'WBC': {'normal': '4.5-11.0', 'unit': 'K/μL', 'critical_low': '<2.0', 'critical_high': '>30.0'},
        'RBC': {'normal': '4.5-5.9', 'unit': 'M/μL', 'critical_low': '<3.0', 'critical_high': '>6.5'},
        'Hemoglobin': {'normal': '13.8-17.2', 'unit': 'g/dL', 'critical_low': '<8.0', 'critical_high': '>20.0'},
        'Hematocrit': {'normal': '40.7-50.3', 'unit': '%', 'critical_low': '<25.0', 'critical_high': '>60.0'},
        'Platelets': {'normal': '150-450', 'unit': 'K/μL', 'critical_low': '<50', 'critical_high': '>1000'},
        'MCV': {'normal': '80-100', 'unit': 'fL', 'critical_low': '<70', 'critical_high': '>110'},
        'MCH': {'normal': '27-33', 'unit': 'pg', 'critical_low': '<20', 'critical_high': '>40'},
        'MCHC': {'normal': '32-36', 'unit': 'g/dL', 'critical_low': '<28', 'critical_high': '>40'},
      },
      ageGroups: {
        'adult': '18-65 years',
        'pediatric': '0-17 years',
        'geriatric': '65+ years',
      },
      notes: 'Values may vary slightly between laboratories',
    ),
    'BMP': LabReferenceRange(
      testName: 'Basic Metabolic Panel',
      parameters: {
        'Glucose': {'normal': '70-100', 'unit': 'mg/dL', 'critical_low': '<40', 'critical_high': '>400'},
        'BUN': {'normal': '7-20', 'unit': 'mg/dL', 'critical_low': '<5', 'critical_high': '>50'},
        'Creatinine': {'normal': '0.6-1.2', 'unit': 'mg/dL', 'critical_low': '<0.3', 'critical_high': '>3.0'},
        'Sodium': {'normal': '136-145', 'unit': 'mEq/L', 'critical_low': '<120', 'critical_high': '>160'},
        'Potassium': {'normal': '3.5-5.0', 'unit': 'mEq/L', 'critical_low': '<2.5', 'critical_high': '>6.5'},
        'Chloride': {'normal': '98-107', 'unit': 'mEq/L', 'critical_low': '<80', 'critical_high': '>120'},
        'CO2': {'normal': '22-28', 'unit': 'mEq/L', 'critical_low': '<15', 'critical_high': '>40'},
        'Calcium': {'normal': '8.5-10.5', 'unit': 'mg/dL', 'critical_low': '<7.0', 'critical_high': '>12.0'},
      },
      ageGroups: {
        'adult': '18-65 years',
        'pediatric': '0-17 years',
        'geriatric': '65+ years',
      },
      notes: 'Fasting required for glucose measurement',
    ),
    'Lipid_Panel': LabReferenceRange(
      testName: 'Lipid Panel',
      parameters: {
        'Total Cholesterol': {'normal': '<200', 'unit': 'mg/dL', 'critical_low': '<100', 'critical_high': '>300'},
        'LDL Cholesterol': {'normal': '<100', 'unit': 'mg/dL', 'critical_low': '<50', 'critical_high': '>190'},
        'HDL Cholesterol': {'normal': '>40', 'unit': 'mg/dL', 'critical_low': '<20', 'critical_high': '>100'},
        'Triglycerides': {'normal': '<150', 'unit': 'mg/dL', 'critical_low': '<50', 'critical_high': '>500'},
        'VLDL Cholesterol': {'normal': '<30', 'unit': 'mg/dL', 'critical_low': '<10', 'critical_high': '>60'},
      },
      ageGroups: {
        'adult': '18-65 years',
        'pediatric': '0-17 years',
        'geriatric': '65+ years',
      },
      notes: 'Fasting 12-14 hours required for accurate results',
    ),
    'Thyroid_Panel': LabReferenceRange(
      testName: 'Thyroid Function Panel',
      parameters: {
        'TSH': {'normal': '0.4-4.0', 'unit': 'mIU/L', 'critical_low': '<0.1', 'critical_high': '>10.0'},
        'Free T4': {'normal': '0.8-1.8', 'unit': 'ng/dL', 'critical_low': '<0.4', 'critical_high': '>3.0'},
        'Free T3': {'normal': '2.3-4.2', 'unit': 'pg/mL', 'critical_low': '<1.5', 'critical_high': '>6.0'},
        'Total T4': {'normal': '5.0-12.0', 'unit': 'μg/dL', 'critical_low': '<2.0', 'critical_high': '>20.0'},
        'Total T3': {'normal': '80-200', 'unit': 'ng/dL', 'critical_low': '<50', 'critical_high': '>300'},
      },
      ageGroups: {
        'adult': '18-65 years',
        'pediatric': '0-17 years',
        'geriatric': '65+ years',
      },
      notes: 'TSH is the most sensitive indicator of thyroid function',
    ),
    'Liver_Panel': LabReferenceRange(
      testName: 'Liver Function Panel',
      parameters: {
        'ALT': {'normal': '7-56', 'unit': 'U/L', 'critical_low': '<5', 'critical_high': '>200'},
        'AST': {'normal': '10-40', 'unit': 'U/L', 'critical_low': '<5', 'critical_high': '>200'},
        'ALP': {'normal': '44-147', 'unit': 'U/L', 'critical_low': '<30', 'critical_high': '>300'},
        'Total Bilirubin': {'normal': '0.3-1.2', 'unit': 'mg/dL', 'critical_low': '<0.1', 'critical_high': '>5.0'},
        'Direct Bilirubin': {'normal': '0.0-0.3', 'unit': 'mg/dL', 'critical_low': '<0.0', 'critical_high': '>2.0'},
        'Albumin': {'normal': '3.5-5.0', 'unit': 'g/dL', 'critical_low': '<2.0', 'critical_high': '>6.0'},
        'Total Protein': {'normal': '6.0-8.3', 'unit': 'g/dL', 'critical_low': '<4.0', 'critical_high': '>10.0'},
      },
      ageGroups: {
        'adult': '18-65 years',
        'pediatric': '0-17 years',
        'geriatric': '65+ years',
      },
      notes: 'Values may be elevated in certain conditions',
    ),
  };

  // Get reference ranges for a specific test
  LabReferenceRange? getReferenceRange(String testType) {
    return _referenceRanges[testType];
  }

  // Get all available test types
  List<String> getAvailableTestTypes() {
    return _referenceRanges.keys.toList();
  }

  // Get parameter reference for a specific test and parameter
  Map<String, String>? getParameterReference(String testType, String parameter) {
    final test = _referenceRanges[testType];
    return test?.parameters[parameter];
  }

  // Check if a value is within normal range
  bool isValueNormal(String testType, String parameter, double value) {
    final paramRef = getParameterReference(testType, parameter);
    if (paramRef == null) return false;
    
    final normalRange = paramRef['normal'];
    if (normalRange == null) return false;
    
    return _isValueInRange(value, normalRange);
  }

  // Check if a value is critical
  bool isValueCritical(String testType, String parameter, double value) {
    final paramRef = getParameterReference(testType, parameter);
    if (paramRef == null) return false;
    
    final criticalLow = paramRef['critical_low'];
    final criticalHigh = paramRef['critical_high'];
    
    if (criticalLow != null && value < _parseValue(criticalLow)) return true;
    if (criticalHigh != null && value > _parseValue(criticalHigh)) return true;
    
    return false;
  }

  // Get interpretation of a value
  String getValueInterpretation(String testType, String parameter, double value) {
    if (isValueCritical(testType, parameter, value)) {
      return 'CRITICAL - Immediate attention required';
    } else if (isValueNormal(testType, parameter, value)) {
      return 'Normal';
    } else {
      return 'Abnormal - Follow up recommended';
    }
  }

  // Get color for value status
  String getValueStatusColor(String testType, String parameter, double value) {
    if (isValueCritical(testType, parameter, value)) {
      return 'red';
    } else if (isValueNormal(testType, parameter, value)) {
      return 'green';
    } else {
      return 'orange';
    }
  }

  // Helper method to check if value is in range
  bool _isValueInRange(double value, String range) {
    if (range.contains('-')) {
      final parts = range.split('-');
      if (parts.length == 2) {
        final low = _parseValue(parts[0]);
        final high = _parseValue(parts[1]);
        return value >= low && value <= high;
      }
    } else if (range.startsWith('<')) {
      return value < _parseValue(range.substring(1));
    } else if (range.startsWith('>')) {
      return value > _parseValue(range.substring(1));
    }
    return false;
  }

  // Helper method to parse value from string
  double _parseValue(String value) {
    return double.tryParse(value.replaceAll(RegExp(r'[<>]'), '')) ?? 0.0;
  }

  // Get online reference links
  Map<String, String> getReferenceLinks() {
    return Map.from(_referenceSources);
  }

  // Search for test information online (mock implementation)
  Future<Map<String, dynamic>> searchOnlineReference(String testName) async {
    // In a real implementation, this would make HTTP requests to medical databases
    await Future.delayed(const Duration(milliseconds: 1000));
    
    return {
      'test_name': testName,
      'description': 'Comprehensive laboratory test for diagnostic purposes',
      'preparation': 'Follow standard fasting guidelines if required',
      'turnaround_time': '1-2 business days',
      'references': _referenceSources,
      'last_updated': DateTime.now().toIso8601String(),
    };
  }
}

class LabReferenceRange {
  final String testName;
  final Map<String, Map<String, String>> parameters;
  final Map<String, String> ageGroups;
  final String notes;

  LabReferenceRange({
    required this.testName,
    required this.parameters,
    required this.ageGroups,
    required this.notes,
  });
}
