import '../models/patient.dart';
import '../models/test.dart';
import '../models/test_result.dart';

class ReportTemplatesService {
  static final ReportTemplatesService _instance = ReportTemplatesService._internal();
  factory ReportTemplatesService() => _instance;
  ReportTemplatesService._internal();

  // Modern Report Template
  String generateModernReport({
    required Patient patient,
    required Test test,
    required List<TestResult> testResults,
    required String laboratoryName,
    required String laboratoryAddress,
    required String laboratoryPhone,
    required String laboratoryEmail,
    required String directorName,
    required String licenseNumber,
  }) {
    final reportDate = DateTime.now();
    final reportNumber = 'RPT-${reportDate.millisecondsSinceEpoch.toString().substring(8)}';
    
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Laboratory Report - $laboratoryName</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; background: #f8f9fa; }
        .container { max-width: 800px; margin: 0 auto; background: white; box-shadow: 0 0 20px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; }
        .header h1 { font-size: 2.5em; margin-bottom: 10px; font-weight: 300; }
        .header p { font-size: 1.1em; opacity: 0.9; }
        .patient-info { padding: 30px; background: #f8f9fa; border-bottom: 1px solid #e9ecef; }
        .patient-info h2 { color: #495057; margin-bottom: 20px; font-size: 1.5em; }
        .info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 15px; }
        .info-item { background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .info-label { font-weight: 600; color: #6c757d; font-size: 0.9em; text-transform: uppercase; letter-spacing: 0.5px; }
        .info-value { color: #212529; font-size: 1.1em; margin-top: 5px; }
        .test-results { padding: 30px; }
        .test-results h2 { color: #495057; margin-bottom: 20px; font-size: 1.5em; }
        .results-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .results-table th { background: #495057; color: white; padding: 15px; text-align: left; font-weight: 600; }
        .results-table td { padding: 15px; border-bottom: 1px solid #e9ecef; }
        .results-table tr:hover { background: #f8f9fa; }
        .normal { color: #28a745; font-weight: 600; }
        .abnormal { color: #dc3545; font-weight: 600; }
        .critical { color: #dc3545; font-weight: 700; background: #f8d7da; padding: 2px 6px; border-radius: 4px; }
        .footer { padding: 30px; background: #495057; color: white; text-align: center; }
        .footer p { margin-bottom: 10px; }
        .signature-section { margin-top: 30px; padding: 20px; background: #f8f9fa; border-radius: 8px; }
        .signature-line { border-bottom: 1px solid #6c757d; width: 200px; margin: 20px 0 5px 0; }
        .report-number { background: #e9ecef; padding: 10px; border-radius: 4px; font-family: monospace; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>$laboratoryName</h1>
            <p>$laboratoryAddress</p>
            <p>Phone: $laboratoryPhone | Email: $laboratoryEmail</p>
            <p>License: $licenseNumber</p>
        </div>
        
        <div class="patient-info">
            <h2>Patient Information</h2>
            <div class="info-grid">
                <div class="info-item">
                    <div class="info-label">Patient Name</div>
                    <div class="info-value">${patient.fullName}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Date of Birth</div>
                    <div class="info-value">${patient.dateOfBirth.day}/${patient.dateOfBirth.month}/${patient.dateOfBirth.year}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Gender</div>
                    <div class="info-value">${patient.gender}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Phone</div>
                    <div class="info-value">${patient.phone}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Test Name</div>
                    <div class="info-value">${test.testName}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Report Date</div>
                    <div class="info-value">${reportDate.day}/${reportDate.month}/${reportDate.year}</div>
                </div>
            </div>
            <div class="report-number">Report Number: $reportNumber</div>
        </div>
        
        <div class="test-results">
            <h2>Test Results</h2>
            <table class="results-table">
                <thead>
                    <tr>
                        <th>Parameter</th>
                        <th>Result</th>
                        <th>Unit</th>
                        <th>Normal Range</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    ${testResults.map((result) => '''
                    <tr>
                        <td>${result.parameter}</td>
                        <td>${result.value}</td>
                        <td>${result.unit ?? 'N/A'}</td>
                        <td>${result.referenceRange ?? 'N/A'}</td>
                        <td class="${result.isAbnormal ? 'abnormal' : 'normal'}">
                            ${result.isAbnormal ? 'ABNORMAL' : 'NORMAL'}
                        </td>
                    </tr>
                    ''').join('')}
                </tbody>
            </table>
        </div>
        
        <div class="signature-section">
            <p><strong>Authorized by:</strong> $directorName, MD</p>
            <div class="signature-line"></div>
            <p>Director, $laboratoryName</p>
            <p>Date: ${reportDate.day}/${reportDate.month}/${reportDate.year}</p>
        </div>
        
        <div class="footer">
            <p><strong>$laboratoryName</strong></p>
            <p>$laboratoryAddress</p>
            <p>Phone: $laboratoryPhone | Email: $laboratoryEmail</p>
            <p>This report is confidential and intended for the patient and their healthcare provider only.</p>
        </div>
    </div>
</body>
</html>
    ''';
  }

  // Quest Style Report Template
  String generateQuestStyleReport({
    required Patient patient,
    required Test test,
    required List<TestResult> testResults,
    required String laboratoryName,
    required String laboratoryAddress,
    required String laboratoryPhone,
    required String laboratoryEmail,
    required String directorName,
    required String licenseNumber,
  }) {
    final reportDate = DateTime.now();
    final reportNumber = 'QST-${reportDate.millisecondsSinceEpoch.toString().substring(8)}';
    
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Laboratory Report - $laboratoryName</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; line-height: 1.4; color: #000; background: #fff; }
        .container { max-width: 800px; margin: 0 auto; background: white; }
        .header { background: #003366; color: white; padding: 20px; text-align: center; border-bottom: 3px solid #ff6600; }
        .header h1 { font-size: 2em; margin-bottom: 5px; font-weight: bold; }
        .header p { font-size: 1em; }
        .patient-section { padding: 20px; background: #f0f0f0; border-bottom: 2px solid #003366; }
        .patient-section h2 { color: #003366; margin-bottom: 15px; font-size: 1.3em; text-transform: uppercase; }
        .patient-details { display: flex; flex-wrap: wrap; gap: 20px; }
        .patient-detail { flex: 1; min-width: 200px; }
        .patient-detail strong { color: #003366; }
        .test-section { padding: 20px; }
        .test-section h2 { color: #003366; margin-bottom: 15px; font-size: 1.3em; text-transform: uppercase; }
        .results-table { width: 100%; border-collapse: collapse; border: 2px solid #003366; }
        .results-table th { background: #003366; color: white; padding: 12px; text-align: left; font-weight: bold; }
        .results-table td { padding: 10px; border: 1px solid #ccc; }
        .results-table tr:nth-child(even) { background: #f9f9f9; }
        .normal { color: #006600; font-weight: bold; }
        .abnormal { color: #cc0000; font-weight: bold; }
        .critical { color: #cc0000; font-weight: bold; background: #ffcccc; }
        .footer { padding: 20px; background: #003366; color: white; text-align: center; }
        .signature { margin-top: 30px; padding: 15px; background: #f0f0f0; border: 1px solid #ccc; }
        .signature-line { border-bottom: 1px solid #000; width: 250px; margin: 10px 0; }
        .report-info { background: #e6f3ff; padding: 10px; margin-bottom: 20px; border-left: 4px solid #003366; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>$laboratoryName</h1>
            <p>$laboratoryAddress</p>
            <p>Phone: $laboratoryPhone | Email: $laboratoryEmail</p>
            <p>License: $licenseNumber</p>
        </div>
        
        <div class="patient-section">
            <h2>Patient Information</h2>
            <div class="patient-details">
                <div class="patient-detail">
                    <strong>Name:</strong> ${patient.fullName}<br>
                    <strong>DOB:</strong> ${patient.dateOfBirth.day}/${patient.dateOfBirth.month}/${patient.dateOfBirth.year}<br>
                    <strong>Gender:</strong> ${patient.gender}
                </div>
                <div class="patient-detail">
                    <strong>Phone:</strong> ${patient.phone}<br>
                    <strong>Test:</strong> ${test.testName}<br>
                    <strong>Date:</strong> ${reportDate.day}/${reportDate.month}/${reportDate.year}
                </div>
            </div>
            <div class="report-info">
                <strong>Report Number:</strong> $reportNumber
            </div>
        </div>
        
        <div class="test-section">
            <h2>Laboratory Results</h2>
            <table class="results-table">
                <thead>
                    <tr>
                        <th>Test Parameter</th>
                        <th>Result</th>
                        <th>Reference Range</th>
                        <th>Unit</th>
                        <th>Flag</th>
                    </tr>
                </thead>
                <tbody>
                    ${testResults.map((result) => '''
                    <tr>
                        <td>${result.parameter}</td>
                        <td>${result.value}</td>
                        <td>${result.referenceRange ?? 'N/A'}</td>
                        <td>${result.unit ?? 'N/A'}</td>
                        <td class="${result.isAbnormal ? 'abnormal' : 'normal'}">
                            ${result.isAbnormal ? 'H' : 'N'}
                        </td>
                    </tr>
                    ''').join('')}
                </tbody>
            </table>
        </div>
        
        <div class="signature">
            <p><strong>Authorized by:</strong> $directorName, MD</p>
            <div class="signature-line"></div>
            <p>Director, $laboratoryName</p>
            <p>Date: ${reportDate.day}/${reportDate.month}/${reportDate.year}</p>
        </div>
        
        <div class="footer">
            <p><strong>$laboratoryName</strong></p>
            <p>$laboratoryAddress | Phone: $laboratoryPhone</p>
            <p>This report is confidential and intended for authorized personnel only.</p>
        </div>
    </div>
</body>
</html>
    ''';
  }

  // Custom Report Template
  String generateCustomReport({
    required Patient patient,
    required Test test,
    required List<TestResult> testResults,
    required String laboratoryName,
    required String laboratoryAddress,
    required String laboratoryPhone,
    required String laboratoryEmail,
    required String directorName,
    required String licenseNumber,
    String? customHeader,
    String? customFooter,
    String? customStyling,
  }) {
    final reportDate = DateTime.now();
    final reportNumber = 'CST-${reportDate.millisecondsSinceEpoch.toString().substring(8)}';
    
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Custom Laboratory Report - $laboratoryName</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Times New Roman', serif; line-height: 1.5; color: #000; background: #fff; }
        .container { max-width: 800px; margin: 0 auto; background: white; }
        .header { background: #2c3e50; color: white; padding: 25px; text-align: center; }
        .header h1 { font-size: 2.2em; margin-bottom: 10px; font-weight: bold; }
        .header p { font-size: 1em; }
        .custom-header { background: #ecf0f1; padding: 15px; text-align: center; font-style: italic; color: #7f8c8d; }
        .patient-info { padding: 25px; background: #fff; border: 2px solid #bdc3c7; }
        .patient-info h2 { color: #2c3e50; margin-bottom: 20px; font-size: 1.4em; text-decoration: underline; }
        .info-row { display: flex; margin-bottom: 10px; padding: 5px 0; }
        .info-label { width: 150px; font-weight: bold; color: #34495e; }
        .info-value { flex: 1; color: #2c3e50; }
        .test-results { padding: 25px; }
        .test-results h2 { color: #2c3e50; margin-bottom: 20px; font-size: 1.4em; text-decoration: underline; }
        .results-table { width: 100%; border-collapse: collapse; border: 2px solid #34495e; }
        .results-table th { background: #34495e; color: white; padding: 12px; text-align: left; font-weight: bold; }
        .results-table td { padding: 10px; border: 1px solid #bdc3c7; }
        .results-table tr:nth-child(odd) { background: #f8f9fa; }
        .normal { color: #27ae60; font-weight: bold; }
        .abnormal { color: #e74c3c; font-weight: bold; }
        .critical { color: #e74c3c; font-weight: bold; background: #fadbd8; }
        .footer { padding: 25px; background: #2c3e50; color: white; text-align: center; }
        .signature-section { margin-top: 30px; padding: 20px; background: #ecf0f1; border: 1px solid #bdc3c7; }
        .signature-line { border-bottom: 2px solid #34495e; width: 300px; margin: 15px 0; }
        .custom-footer { background: #ecf0f1; padding: 15px; text-align: center; font-style: italic; color: #7f8c8d; }
        .report-number { background: #34495e; color: white; padding: 8px; text-align: center; font-weight: bold; }
        ${customStyling ?? ''}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>$laboratoryName</h1>
            <p>$laboratoryAddress</p>
            <p>Phone: $laboratoryPhone | Email: $laboratoryEmail</p>
            <p>License: $licenseNumber</p>
        </div>
        
        ${customHeader != null ? '<div class="custom-header">$customHeader</div>' : ''}
        
        <div class="patient-info">
            <h2>Patient Details</h2>
            <div class="info-row">
                <div class="info-label">Patient Name:</div>
                <div class="info-value">${patient.fullName}</div>
            </div>
            <div class="info-row">
                <div class="info-label">Date of Birth:</div>
                <div class="info-value">${patient.dateOfBirth.day}/${patient.dateOfBirth.month}/${patient.dateOfBirth.year}</div>
            </div>
            <div class="info-row">
                <div class="info-label">Gender:</div>
                <div class="info-value">${patient.gender}</div>
            </div>
            <div class="info-row">
                <div class="info-label">Phone Number:</div>
                <div class="info-value">${patient.phone}</div>
            </div>
            <div class="info-row">
                <div class="info-label">Test Ordered:</div>
                <div class="info-value">${test.testName}</div>
            </div>
            <div class="info-row">
                <div class="info-label">Report Date:</div>
                <div class="info-value">${reportDate.day}/${reportDate.month}/${reportDate.year}</div>
            </div>
        </div>
        
        <div class="report-number">Report Number: $reportNumber</div>
        
        <div class="test-results">
            <h2>Laboratory Test Results</h2>
            <table class="results-table">
                <thead>
                    <tr>
                        <th>Parameter</th>
                        <th>Result Value</th>
                        <th>Normal Range</th>
                        <th>Unit</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    ${testResults.map((result) => '''
                    <tr>
                        <td>${result.parameter}</td>
                        <td>${result.value}</td>
                        <td>${result.referenceRange ?? 'N/A'}</td>
                        <td>${result.unit ?? 'N/A'}</td>
                        <td class="${result.isAbnormal ? 'abnormal' : 'normal'}">
                            ${result.isAbnormal ? 'ABNORMAL' : 'NORMAL'}
                        </td>
                    </tr>
                    ''').join('')}
                </tbody>
            </table>
        </div>
        
        <div class="signature-section">
            <p><strong>Authorized by:</strong> $directorName, MD</p>
            <div class="signature-line"></div>
            <p>Medical Director, $laboratoryName</p>
            <p>Date: ${reportDate.day}/${reportDate.month}/${reportDate.year}</p>
            <p>License Number: $licenseNumber</p>
        </div>
        
        ${customFooter != null ? '<div class="custom-footer">$customFooter</div>' : ''}
        
        <div class="footer">
            <p><strong>$laboratoryName</strong></p>
            <p>$laboratoryAddress</p>
            <p>Phone: $laboratoryPhone | Email: $laboratoryEmail</p>
            <p>This report is confidential and intended for the patient and their healthcare provider only.</p>
        </div>
    </div>
</body>
</html>
    ''';
  }

  // Get all available report templates
  List<Map<String, String>> getAvailableTemplates() {
    return [
      {
        'id': 'modern',
        'name': 'Modern Report',
        'description': 'Clean, modern design with gradient headers and card-based layout',
        'preview': 'Modern styling with blue gradient header and clean typography'
      },
      {
        'id': 'quest',
        'name': 'Quest Style Report',
        'description': 'Traditional laboratory report format similar to Quest Diagnostics',
        'preview': 'Classic lab report format with blue header and orange accent'
      },
      {
        'id': 'custom',
        'name': 'Custom Report',
        'description': 'Fully customizable report with custom headers, footers, and styling',
        'preview': 'Customizable template with serif fonts and traditional layout'
      }
    ];
  }
}
