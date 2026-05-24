import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/patient.dart';
import '../models/test.dart';

class AdvancedReportService {
  // Report template types
  static const String standardTemplate = 'standard';
  static const String modernTemplate = 'modern';
  static const String questStyleTemplate = 'quest';
  static const String customTemplate = 'custom';

  // Generate report based on template
  Future<Map<String, dynamic>> generateReport({
    required Patient patient,
    required List<Test> tests,
    required String templateType,
    String? customTitle,
    String? customHeader,
    String? customFooter,
  }) async {
    try {
      switch (templateType) {
        case standardTemplate:
        case modernTemplate:
          return _generateModernReport(patient, tests, title: 'Standard Report');
        case questStyleTemplate:
          return _generateQuestStyleReport(patient, tests);
        case customTemplate:
          return _generateCustomReport(patient, tests, customTitle, customHeader, customFooter);
        default:
          return _generateModernReport(patient, tests);
      }
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
  }

  // Modern report template
  Map<String, dynamic> _generateModernReport(
    Patient patient,
    List<Test> tests, {
    String title = 'SAEED Laboratory - Modern Report',
  }) {
    final reportData = {
      'template_type': 'modern',
      'title': title,
      'header': {
        'lab_name': 'SAEED Laboratory',
        'address': '123 Medical Center Dr, Healthcare City',
        'phone': '555-0126',
        'email': 'info@saeedlab.com',
        'logo_url': 'assets/icon/app_icon.png',
      },
      'patient_info': {
        'name': patient.fullName,
        'id': patient.patientId,
        'age': _calculateAge(patient.dateOfBirth),
        'gender': patient.gender,
        'phone': patient.phone,
        'email': patient.email,
        'address': patient.address,
      },
      'report_info': {
        'report_number': 'R${DateTime.now().millisecondsSinceEpoch % 10000}',
        'date': DateTime.now().toIso8601String(),
        'total_tests': tests.length,
        'completed_tests': tests.where((t) => t.status == 'Completed').length,
        'pending_tests': tests.where((t) => t.status == 'Pending').length,
      },
      'tests': tests.map((test) => {
        'name': test.testType,
        'status': test.status,
        'ordered_date': test.orderedDate.toIso8601String(),
        'completed_date': test.completedDate?.toIso8601String(),
        'price': test.price,
        'notes': test.notes,
        'results': test.testResults?.map((result) => {
          'parameter': result.parameter,
          'value': result.value,
          'unit': result.unit,
          'normal_range': result.referenceRange ?? 'N/A',
          'status': result.isAbnormal ? 'Abnormal' : 'Normal',
        }).toList(),
      }).toList(),
      'styling': {
        'primary_color': '#2196F3',
        'secondary_color': '#E3F2FD',
        'accent_color': '#1976D2',
        'font_family': 'Roboto',
        'header_style': 'bold',
        'table_style': 'modern',
      },
    };

    return reportData;
  }

  // Quest Style report template
  Map<String, dynamic> _generateQuestStyleReport(Patient patient, List<Test> tests) {
    final reportData = {
      'template_type': 'quest_style',
      'title': 'Quest Diagnostics - Laboratory Report',
      'header': {
        'lab_name': 'Quest Diagnostics',
        'subtitle': 'A Quest Diagnostics Company',
        'address': '123 Medical Center Dr, Healthcare City',
        'phone': '555-0126',
        'email': 'info@questdiagnostics.com',
        'logo_url': 'assets/icon/app_icon.png',
        'accreditation': 'CLIA Certified • CAP Accredited',
      },
      'patient_info': {
        'name': patient.fullName,
        'id': patient.patientId,
        'age': _calculateAge(patient.dateOfBirth),
        'gender': patient.gender,
        'phone': patient.phone,
        'email': patient.email,
        'address': patient.address,
        'date_of_birth': patient.dateOfBirth.toIso8601String(),
      },
      'report_info': {
        'report_number': 'Q${DateTime.now().millisecondsSinceEpoch % 10000}',
        'date': DateTime.now().toIso8601String(),
        'total_tests': tests.length,
        'completed_tests': tests.where((t) => t.status == 'Completed').length,
        'pending_tests': tests.where((t) => t.status == 'Pending').length,
        'turnaround_time': '24-48 hours',
      },
      'tests': tests.map((test) => {
        'name': test.testType,
        'status': test.status,
        'ordered_date': test.orderedDate.toIso8601String(),
        'completed_date': test.completedDate?.toIso8601String(),
        'price': test.price,
        'notes': test.notes,
        'results': test.testResults?.map((result) => {
          'parameter': result.parameter,
          'value': result.value,
          'unit': result.unit,
          'normal_range': result.referenceRange ?? 'N/A',
          'status': result.isAbnormal ? 'Abnormal' : 'Normal',
          'flag': _getResultFlag(result.value, result.referenceRange),
        }).toList(),
      }).toList(),
      'styling': {
        'primary_color': '#0066CC',
        'secondary_color': '#F0F8FF',
        'accent_color': '#004499',
        'font_family': 'Arial',
        'header_style': 'bold',
        'table_style': 'quest',
        'show_flags': true,
        'show_reference_ranges': true,
      },
    };

    return reportData;
  }

  // Custom report template
  Map<String, dynamic> _generateCustomReport(
    Patient patient,
    List<Test> tests,
    String? customTitle,
    String? customHeader,
    String? customFooter,
  ) {
    final reportData = {
      'template_type': 'custom',
      'title': customTitle ?? 'SAEED Laboratory - Custom Report',
      'header': {
        'lab_name': 'SAEED Laboratory',
        'custom_header': customHeader ?? 'Comprehensive Laboratory Analysis',
        'address': '123 Medical Center Dr, Healthcare City',
        'phone': '555-0126',
        'email': 'info@saeedlab.com',
        'logo_url': 'assets/icon/app_icon.png',
      },
      'patient_info': {
        'name': patient.fullName,
        'id': patient.patientId,
        'age': _calculateAge(patient.dateOfBirth),
        'gender': patient.gender,
        'phone': patient.phone,
        'email': patient.email,
        'address': patient.address,
        'blood_type': patient.bloodType,
        'emergency_contact': patient.emergencyContact,
      },
      'report_info': {
        'report_number': 'C${DateTime.now().millisecondsSinceEpoch % 10000}',
        'date': DateTime.now().toIso8601String(),
        'total_tests': tests.length,
        'completed_tests': tests.where((t) => t.status == 'Completed').length,
        'pending_tests': tests.where((t) => t.status == 'Pending').length,
        'custom_footer': customFooter ?? 'This report is confidential and intended for medical use only.',
      },
      'tests': tests.map((test) => {
        'name': test.testType,
        'status': test.status,
        'ordered_date': test.orderedDate.toIso8601String(),
        'completed_date': test.completedDate?.toIso8601String(),
        'price': test.price,
        'notes': test.notes,
        'results': test.testResults?.map((result) => {
          'parameter': result.parameter,
          'value': result.value,
          'unit': result.unit,
          'normal_range': result.referenceRange ?? 'N/A',
          'status': result.isAbnormal ? 'Abnormal' : 'Normal',
          'flag': _getResultFlag(result.value, result.referenceRange),
        }).toList(),
      }).toList(),
      'styling': {
        'primary_color': '#4CAF50',
        'secondary_color': '#E8F5E8',
        'accent_color': '#2E7D32',
        'font_family': 'Calibri',
        'header_style': 'bold',
        'table_style': 'custom',
        'show_flags': true,
        'show_reference_ranges': true,
        'custom_styling': true,
      },
    };

    return reportData;
  }

  // Export report to PDF
  Future<String> exportToPDF(Map<String, dynamic> reportData) async {
    try {
      // In a real implementation, this would use a PDF generation library like pdf package
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'report_${reportData['report_info']['report_number']}.pdf';
      final filePath = '${directory.path}/$fileName';
      
      // Mock PDF content - replace with actual PDF generation
      final pdfContent = _generatePDFContent(reportData);
      final file = File(filePath);
      await file.writeAsString(pdfContent);
      
      return filePath;
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }

  // Email report
  Future<void> emailReport(String filePath, String recipientEmail) async {
    try {
      // In a real implementation, this would use email functionality
      print('📧 Email report to $recipientEmail: $filePath');
      
      // Mock email sending
      await Future.delayed(const Duration(seconds: 1));
      print('✅ Report sent successfully');
    } catch (e) {
      throw Exception('Failed to email report: $e');
    }
  }

  // Share report
  Future<void> shareReport(String filePath) async {
    try {
      await Share.shareXFiles([XFile(filePath)], text: 'Laboratory Report');
    } catch (e) {
      throw Exception('Failed to share report: $e');
    }
  }

  // Generate PDF content (mock)
  String _generatePDFContent(Map<String, dynamic> reportData) {
    final buffer = StringBuffer();
    buffer.writeln('PDF Report Content');
    buffer.writeln('==================');
    buffer.writeln();
    buffer.writeln('Title: ${reportData['title']}');
    buffer.writeln('Report Number: ${reportData['report_info']['report_number']}');
    buffer.writeln('Date: ${reportData['report_info']['date']}');
    buffer.writeln();
    buffer.writeln('Patient Information:');
    buffer.writeln('Name: ${reportData['patient_info']['name']}');
    buffer.writeln('ID: ${reportData['patient_info']['id']}');
    buffer.writeln('Age: ${reportData['patient_info']['age']}');
    buffer.writeln('Gender: ${reportData['patient_info']['gender']}');
    buffer.writeln();
    buffer.writeln('Tests:');
    for (final test in reportData['tests']) {
      buffer.writeln('- ${test['name']}: ${test['status']}');
    }
    buffer.writeln();
    buffer.writeln('Generated by SAEED Laboratory System');
    
    return buffer.toString();
  }

  // Calculate age from date of birth
  int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // Get result flag based on value and normal range
  String _getResultFlag(String? value, String? normalRange) {
    if (value == null || normalRange == null) return '';
    
    // Simple flag logic - in real implementation, this would be more sophisticated
    if (normalRange.contains('<')) {
      final threshold = double.tryParse(normalRange.replaceAll('<', '').trim());
      if (threshold != null) {
        final testValue = double.tryParse(value);
        if (testValue != null) {
          return testValue > threshold ? 'H' : 'N';
        }
      }
    } else if (normalRange.contains('>')) {
      final threshold = double.tryParse(normalRange.replaceAll('>', '').trim());
      if (threshold != null) {
        final testValue = double.tryParse(value);
        if (testValue != null) {
          return testValue < threshold ? 'L' : 'N';
        }
      }
    }
    
    return 'N'; // Normal
  }

  // Get available report templates
  List<Map<String, dynamic>> getAvailableTemplates() {
    return [
      {
        'id': standardTemplate,
        'name': 'Standard Report',
        'description': 'Default SaeedLab layout (same as web)',
        'icon': 'standard',
        'preview_color': '#008080',
      },
      {
        'id': modernTemplate,
        'name': 'Modern Report',
        'description': 'Clean, modern design with blue color scheme',
        'icon': 'modern',
        'preview_color': '#2196F3',
      },
      {
        'id': questStyleTemplate,
        'name': 'Quest Style',
        'description': 'Professional Quest Diagnostics style report',
        'icon': 'quest',
        'preview_color': '#0066CC',
      },
      {
        'id': customTemplate,
        'name': 'Custom Report',
        'description': 'Fully customizable report template',
        'icon': 'custom',
        'preview_color': '#4CAF50',
      },
    ];
  }
}

/// Match test orders to patients when API uses numeric id vs patient_id string.
bool labPatientMatchesTest(Patient patient, Test test) {
  final keys = <String>{
    if (patient.id != null) patient.id.toString(),
    if (patient.patientId != null) patient.patientId.toString(),
  };
  return keys.contains(test.patientId);
}

String labPatientSelectionKey(Patient patient) {
  return patient.id?.toString() ?? patient.patientId?.toString() ?? '';
}
