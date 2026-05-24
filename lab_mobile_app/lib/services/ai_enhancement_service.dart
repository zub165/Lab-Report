import '../models/test.dart';
import '../models/patient.dart';
import '../models/report_data.dart';

// AI providers enum (moved outside class)
enum AIProvider { openai, google, azure, local }

class AIEnhancementService {
  static final AIEnhancementService _instance = AIEnhancementService._internal();
  factory AIEnhancementService() => _instance;
  AIEnhancementService._internal();

  // Get AI-powered test recommendations based on patient profile
  Future<List<Test>> getTestRecommendations(Patient patient) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final recommendations = <Test>[];
    
    final age = _calculateAge(patient.dateOfBirth);
    if (age >= 50) {
      recommendations.add(_createTest('Lipid Panel', 'Chemistry', 120.0, 'Recommended for patients 50+'));
    }
    
    if (patient.gender.toLowerCase() == 'female') {
      recommendations.add(_createTest('Thyroid Function Test', 'Endocrinology', 95.0, 'Common in women'));
    }
    
    recommendations.add(_createTest('Complete Blood Count', 'Hematology', 85.0, 'Routine health check'));
    
    return recommendations;
  }

  int _calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  Test _createTest(String name, String type, double price, String reason) {
    return Test(
      testId: 'ai_${DateTime.now().millisecondsSinceEpoch}_${name.replaceAll(' ', '_').toLowerCase()}',
      patientId: '',
      testName: name,
      testType: type,
      status: 'Recommended',
      orderedDate: DateTime.now(),
      orderedBy: 'AI Assistant',
      price: price,
      notes: reason,
      priority: 'Normal',
    );
  }

  // Analyze test results and provide interpretation
  static Future<TestInterpretation> interpretTestResults({
    required Test test,
    required Map<String, dynamic> results,
    required Patient patient,
    AIProvider provider = AIProvider.openai,
  }) async {
    try {
      // Mock AI interpretation - in real app, this would call actual AI APIs
      await Future.delayed(const Duration(milliseconds: 2000));
      
      String interpretation = _generateMockInterpretation(test, results, patient);
      List<String> recommendations = _generateMockRecommendations(test, results);
      RiskAssessment risk = _generateMockRiskAssessment(test, results, patient);
      
      return TestInterpretation(
        testId: test.testId ?? '',
        interpretation: interpretation,
        recommendations: recommendations,
        riskAssessment: risk,
        confidence: 0.85,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      print('Error interpreting test results: $e');
      return TestInterpretation.error(test.testId ?? '', e.toString());
    }
  }

  // Generate diagnostic suggestions based on symptoms and test results
  static Future<List<DiagnosticSuggestion>> generateDiagnosticSuggestions({
    required List<String> symptoms,
    required List<Test> testResults,
    required Patient patient,
    AIProvider provider = AIProvider.openai,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 3000));
      
      List<DiagnosticSuggestion> suggestions = [];
      
      // Mock diagnostic suggestions based on symptoms
      if (symptoms.any((s) => ['fever', 'fatigue', 'headache'].contains(s.toLowerCase()))) {
        suggestions.add(DiagnosticSuggestion(
          condition: 'Viral Infection',
          probability: 0.75,
          description: 'Based on symptoms and test results, a viral infection is likely.',
          recommendedTests: ['CBC_001', 'CRP_001'],
          treatment: 'Rest, hydration, symptomatic treatment',
        ));
      }
      
      if (symptoms.any((s) => ['chest pain', 'shortness of breath'].contains(s.toLowerCase()))) {
        suggestions.add(DiagnosticSuggestion(
          condition: 'Cardiac Evaluation Needed',
          probability: 0.60,
          description: 'Cardiac symptoms require further evaluation.',
          recommendedTests: ['CARDIAC_001', 'ECG'],
          treatment: 'Immediate cardiac workup recommended',
        ));
      }
      
      return suggestions;
    } catch (e) {
      print('Error generating diagnostic suggestions: $e');
      return [];
    }
  }

  // Perform trend analysis on patient's test history
  static Future<TrendAnalysis> analyzeTrends({
    required String patientId,
    required String testType,
    required List<Map<String, dynamic>> historicalResults,
    AIProvider provider = AIProvider.openai,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 2500));
      
      return TrendAnalysis(
        patientId: patientId,
        testType: testType,
        trend: _calculateTrend(historicalResults),
        significantChanges: _identifySignificantChanges(historicalResults),
        predictions: _generatePredictions(historicalResults),
        recommendations: _generateTrendRecommendations(historicalResults),
        analyzedAt: DateTime.now(),
      );
    } catch (e) {
      print('Error analyzing trends: $e');
      return TrendAnalysis.error(patientId, testType, e.toString());
    }
  }

  // Generate AI-enhanced reports
  static Future<ReportData> generateAIReport({
    required String patientId,
    required String testId,
    required Map<String, dynamic> testResults,
    required Patient patient,
    AIProvider provider = AIProvider.openai,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 4000));
      
      String title = 'AI-Enhanced Lab Report - ${patient.fullName}';
      String content = _generateReportContent(patient, testResults);
      
      return ReportData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: patientId,
        testId: testId,
        title: title,
        content: content,
        reportDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      print('Error generating AI report: $e');
      return ReportData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: patientId,
        testId: testId,
        title: 'Error Report',
        content: 'Error generating report: $e',
        reportDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  // Risk assessment for patients
  static Future<RiskAssessment> assessPatientRisk({
    required Patient patient,
    required List<Test> recentTests,
    required List<String> symptoms,
    AIProvider provider = AIProvider.openai,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 2000));
      
      return RiskAssessment(
        patientId: patient.patientId ?? '',
        overallRisk: _calculateOverallRisk(patient, recentTests, symptoms),
        riskFactors: _identifyRiskFactors(patient, recentTests, symptoms),
        recommendations: _generateRiskRecommendations(patient, recentTests, symptoms),
        assessedAt: DateTime.now(),
      );
    } catch (e) {
      print('Error assessing patient risk: $e');
      return RiskAssessment.error(patient.patientId ?? '', e.toString());
    }
  }

  // Predictive analytics for patient outcomes
  static Future<PredictionAnalysis> predictPatientOutcomes({
    required String patientId,
    required List<Test> testHistory,
    required List<String> symptoms,
    required int predictionDays,
    AIProvider provider = AIProvider.openai,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 3000));
      
      return PredictionAnalysis(
        patientId: patientId,
        predictions: _generateOutcomePredictions(testHistory, symptoms, predictionDays),
        confidence: 0.80,
        factors: _identifyPredictionFactors(testHistory, symptoms),
        recommendations: _generatePredictionRecommendations(testHistory, symptoms),
        predictedAt: DateTime.now(),
      );
    } catch (e) {
      print('Error predicting patient outcomes: $e');
      return PredictionAnalysis.error(patientId, e.toString());
    }
  }

  // Mock helper methods (in real app, these would use actual AI APIs)
  static String _generateMockInterpretation(Test test, Map<String, dynamic> results, Patient patient) {
    return '''
Test: ${test.testName}
Patient: ${patient.fullName}
Date: ${DateTime.now().toString().split(' ')[0]}

INTERPRETATION:
The test results show normal values within the expected range for a patient of this age and gender. 
All parameters are within normal limits, indicating good overall health status.

CLINICAL SIGNIFICANCE:
No immediate concerns identified. Continue routine monitoring as recommended by healthcare provider.
''';
  }

  static List<String> _generateMockRecommendations(Test test, Map<String, dynamic> results) {
    return [
      'Continue current treatment plan',
      'Schedule follow-up in 3 months',
      'Maintain healthy lifestyle habits',
      'Monitor for any new symptoms',
    ];
  }

  static RiskAssessment _generateMockRiskAssessment(Test test, Map<String, dynamic> results, Patient patient) {
    return RiskAssessment(
      patientId: patient.patientId ?? '',
      overallRisk: RiskLevel.low,
      riskFactors: ['Age-related factors'],
      recommendations: ['Regular monitoring recommended'],
      assessedAt: DateTime.now(),
    );
  }

  static String _generateReportContent(Patient patient, Map<String, dynamic> testResults) {
    return '''
AI-ENHANCED LABORATORY REPORT

Patient Information:
Name: ${patient.fullName}
Date of Birth: ${patient.dateOfBirth.toString().split(' ')[0]}
Gender: ${patient.gender}

Test Results:
${testResults.entries.map((e) => '${e.key}: ${e.value}').join('\n')}

AI Analysis:
The artificial intelligence analysis indicates normal test results with no significant abnormalities detected. 
The patient's values are within expected ranges for their demographic profile.

Recommendations:
1. Continue current health maintenance routine
2. Schedule routine follow-up as recommended
3. Maintain healthy lifestyle practices

This report was generated using AI-enhanced analysis for improved accuracy and clinical insights.
''';
  }

  static TrendDirection _calculateTrend(List<Map<String, dynamic>> historicalResults) {
    // Mock trend calculation
    return TrendDirection.stable;
  }

  static List<String> _identifySignificantChanges(List<Map<String, dynamic>> historicalResults) {
    return ['No significant changes detected'];
  }

  static List<String> _generatePredictions(List<Map<String, dynamic>> historicalResults) {
    return ['Values expected to remain stable'];
  }

  static List<String> _generateTrendRecommendations(List<Map<String, dynamic>> historicalResults) {
    return ['Continue current monitoring schedule'];
  }

  static RiskLevel _calculateOverallRisk(Patient patient, List<Test> recentTests, List<String> symptoms) {
    return RiskLevel.low;
  }

  static List<String> _identifyRiskFactors(Patient patient, List<Test> recentTests, List<String> symptoms) {
    return ['Age-related factors'];
  }

  static List<String> _generateRiskRecommendations(Patient patient, List<Test> recentTests, List<String> symptoms) {
    return ['Regular monitoring recommended'];
  }

  static List<OutcomePrediction> _generateOutcomePredictions(List<Test> testHistory, List<String> symptoms, int predictionDays) {
    return [
      OutcomePrediction(
        outcome: 'Stable Health',
        probability: 0.85,
        timeframe: predictionDays,
        description: 'Patient likely to maintain current health status',
      ),
    ];
  }

  static List<String> _identifyPredictionFactors(List<Test> testHistory, List<String> symptoms) {
    return ['Historical test stability', 'Current symptom profile'];
  }

  static List<String> _generatePredictionRecommendations(List<Test> testHistory, List<String> symptoms) {
    return ['Continue current treatment plan', 'Monitor for any changes'];
  }
}

// Supporting classes
class TestInterpretation {
  final String testId;
  final String interpretation;
  final List<String> recommendations;
  final RiskAssessment riskAssessment;
  final double confidence;
  final DateTime generatedAt;

  TestInterpretation({
    required this.testId,
    required this.interpretation,
    required this.recommendations,
    required this.riskAssessment,
    required this.confidence,
    required this.generatedAt,
  });

  static TestInterpretation error(String testId, String error) {
    return TestInterpretation(
      testId: testId,
      interpretation: 'Error generating interpretation: $error',
      recommendations: ['Contact support'],
      riskAssessment: RiskAssessment.error(testId, error),
      confidence: 0.0,
      generatedAt: DateTime.now(),
    );
  }
}

class DiagnosticSuggestion {
  final String condition;
  final double probability;
  final String description;
  final List<String> recommendedTests;
  final String treatment;

  DiagnosticSuggestion({
    required this.condition,
    required this.probability,
    required this.description,
    required this.recommendedTests,
    required this.treatment,
  });
}

class TrendAnalysis {
  final String patientId;
  final String testType;
  final TrendDirection trend;
  final List<String> significantChanges;
  final List<String> predictions;
  final List<String> recommendations;
  final DateTime analyzedAt;

  TrendAnalysis({
    required this.patientId,
    required this.testType,
    required this.trend,
    required this.significantChanges,
    required this.predictions,
    required this.recommendations,
    required this.analyzedAt,
  });

  static TrendAnalysis error(String patientId, String testType, String error) {
    return TrendAnalysis(
      patientId: patientId,
      testType: testType,
      trend: TrendDirection.unknown,
      significantChanges: ['Error in analysis'],
      predictions: ['Unable to predict'],
      recommendations: ['Contact support'],
      analyzedAt: DateTime.now(),
    );
  }
}

class RiskAssessment {
  final String patientId;
  final RiskLevel overallRisk;
  final List<String> riskFactors;
  final List<String> recommendations;
  final DateTime assessedAt;

  RiskAssessment({
    required this.patientId,
    required this.overallRisk,
    required this.riskFactors,
    required this.recommendations,
    required this.assessedAt,
  });

  static RiskAssessment error(String patientId, String error) {
    return RiskAssessment(
      patientId: patientId,
      overallRisk: RiskLevel.unknown,
      riskFactors: ['Error in assessment'],
      recommendations: ['Contact support'],
      assessedAt: DateTime.now(),
    );
  }
}

class PredictionAnalysis {
  final String patientId;
  final List<OutcomePrediction> predictions;
  final double confidence;
  final List<String> factors;
  final List<String> recommendations;
  final DateTime predictedAt;

  PredictionAnalysis({
    required this.patientId,
    required this.predictions,
    required this.confidence,
    required this.factors,
    required this.recommendations,
    required this.predictedAt,
  });

  static PredictionAnalysis error(String patientId, String error) {
    return PredictionAnalysis(
      patientId: patientId,
      predictions: [],
      confidence: 0.0,
      factors: ['Error in prediction'],
      recommendations: ['Contact support'],
      predictedAt: DateTime.now(),
    );
  }
}

class OutcomePrediction {
  final String outcome;
  final double probability;
  final int timeframe;
  final String description;

  OutcomePrediction({
    required this.outcome,
    required this.probability,
    required this.timeframe,
    required this.description,
  });
}

enum TrendDirection { increasing, decreasing, stable, unknown }
enum RiskLevel { low, moderate, high, critical, unknown }
