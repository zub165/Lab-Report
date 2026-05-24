import '../models/lab_test.dart';

class OnlineLabApiService {
  // This would typically be a real API endpoint, but for this demo, we'll use mock data.
  // In a real application, you'd fetch from a medical API like LOINC, RxNorm, etc.
  // For now, we simulate an API call with a delay.

  Future<List<LabTest>> fetchLabTestsWithNormalValues() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // Return a simplified list of lab tests that will compile
    return [
      const LabTest(
        id: 'LT001',
        name: 'Complete Blood Count (CBC)',
        category: 'Hematology',
        description: 'A CBC is a blood test used to evaluate your overall health and detect a wide range of disorders.',
        normalRange: 'See parameters',
        unit: 'Various',
        price: 50.0,
        preparation: 'No special preparation required',
        collectionMethod: 'Blood',
        processingTime: '24 hours',
        parameters: [
          LabTestParameter(
            name: 'White Blood Cell Count',
            normalRange: '4,500-11,000 cells/μL',
            unit: 'cells/μL',
            criticalLow: '2,000',
            criticalHigh: '30,000',
          ),
          LabTestParameter(
            name: 'Red Blood Cell Count',
            normalRange: '4.2-5.9 million cells/μL',
            unit: 'million cells/μL',
            criticalLow: '2.0',
            criticalHigh: '6.5',
          ),
        ],
      ),
      const LabTest(
        id: 'LT002',
        name: 'Basic Metabolic Panel (BMP)',
        category: 'Chemistry',
        description: 'A BMP is a group of 7-8 tests that measure different substances in your blood.',
        normalRange: 'See parameters',
        unit: 'Various',
        price: 65.0,
        preparation: 'Fasting for 8-12 hours recommended',
        collectionMethod: 'Blood',
        processingTime: '24 hours',
        parameters: [
          LabTestParameter(
            name: 'Glucose',
            normalRange: '70-99 mg/dL',
            unit: 'mg/dL',
            criticalLow: '40',
            criticalHigh: '450',
          ),
          LabTestParameter(
            name: 'Sodium',
            normalRange: '135-145 mEq/L',
            unit: 'mEq/L',
            criticalLow: '120',
            criticalHigh: '160',
          ),
        ],
      ),
    ];
  }

  /// Extract normal ranges from text description
  List<LabTestParameter> _extractNormalRanges(String description) {
    // Return a default parameter for now
    return [
      const LabTestParameter(
        name: 'General',
        normalRange: 'See reference ranges',
        unit: 'Various',
        criticalLow: 'N/A',
        criticalHigh: 'N/A',
      ),
    ];
  }

  /// Extract units from description
  String _extractUnits(String description) {
    // Extract units from description
    if (description.toLowerCase().contains('mg/dl')) return 'mg/dL';
    if (description.toLowerCase().contains('meq/l')) return 'mEq/L';
    if (description.toLowerCase().contains('u/l')) return 'U/L';
    if (description.toLowerCase().contains('pg/ml')) return 'pg/mL';
    return 'Various';
  }

  /// Extract specimen type from description
  String _extractSpecimenType(String description) {
    if (description.toLowerCase().contains('blood')) return 'Blood';
    if (description.toLowerCase().contains('urine')) return 'Urine';
    if (description.toLowerCase().contains('saliva')) return 'Saliva';
    return 'Blood';
  }

  /// Extract preparation instructions from description
  String _extractPreparationInstructions(String description) {
    if (description.toLowerCase().contains('fasting')) return 'Fasting required';
    if (description.toLowerCase().contains('no preparation')) return 'No special preparation required';
    return 'Follow standard preparation guidelines';
  }

  /// Extract clinical significance
  String _extractClinicalSignificance(String description) {
    return 'Please consult with your healthcare provider for interpretation of results.';
  }

  /// Categorize test based on name
  String _categorizeTest(String testName) {
    final name = testName.toLowerCase();
    if (name.contains('blood') || name.contains('cbc') || name.contains('hemoglobin')) {
      return 'Hematology';
    } else if (name.contains('glucose') || name.contains('cholesterol') || name.contains('metabolic')) {
      return 'Chemistry';
    } else if (name.contains('thyroid') || name.contains('hormone')) {
      return 'Endocrinology';
    } else if (name.contains('liver') || name.contains('alt') || name.contains('ast')) {
      return 'Gastroenterology';
    } else if (name.contains('heart') || name.contains('cardiac') || name.contains('lipid')) {
      return 'Cardiology';
    } else {
      return 'General';
    }
  }
}