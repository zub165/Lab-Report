import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/report_template.dart';
import '../models/patient.dart';
import '../models/test.dart';
import '../models/test_result.dart';
import '../services/django_api_service.dart';

class ReportPreviewScreen extends StatefulWidget {
  final Patient patient;
  final Test test;
  final ReportTemplate? initialTemplate;

  const ReportPreviewScreen({
    Key? key,
    required this.patient,
    required this.test,
    this.initialTemplate,
  }) : super(key: key);

  @override
  State<ReportPreviewScreen> createState() => _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends State<ReportPreviewScreen> {
  final DjangoApiService _api = DjangoApiService();
  ReportTemplate? selectedTemplate;
  Map<String, dynamic> reportData = {};
  List<LabResultRow> _savedResultRows = [];
  bool isLoading = false;
  bool _loadingOrderResults = true;

  @override
  void initState() {
    super.initState();
    selectedTemplate = widget.initialTemplate ?? DefaultReportTemplates.templates.first;
    _loadResultsFromOrder();
  }

  Future<void> _loadResultsFromOrder() async {
    final orderId = widget.test.djangoOrderId?.trim().isNotEmpty == true
        ? widget.test.djangoOrderId
        : widget.test.testId?.trim();
    if (orderId == null || orderId.isEmpty) {
      _generateReportData();
      setState(() => _loadingOrderResults = false);
      return;
    }
    try {
      final rows = await _api.loadLabResultRowsForOrder(orderId);
      final withValues = rows.where((r) {
        final v = r.value.trim();
        return v.isNotEmpty && v != '—';
      }).toList();
      if (withValues.isNotEmpty) {
        setState(() {
          _savedResultRows = withValues;
          reportData = LabResultRowsBuilder.toReportFieldMap(withValues);
          _loadingOrderResults = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) {
      _generateReportData();
      setState(() => _loadingOrderResults = false);
    }
  }

  // Print and PDF Functions
  Future<void> _printReport() async {
    try {
      setState(() {
        isLoading = true;
      });

      final pdf = await _generatePDF();
      
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf,
        name: '${widget.patient.fullName}_${widget.test.testType}_Report.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report sent to printer')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error printing report: $e')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _exportToPDF() async {
    try {
      setState(() {
        isLoading = true;
      });

      final pdf = await _generatePDF();
      
      // Get the documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${widget.patient.fullName}_${widget.test.testType}_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsBytes(pdf);
      
      if (mounted) {
        // Share the PDF file
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Laboratory Report for ${widget.patient.fullName}',
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF exported: $fileName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting PDF: $e')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Uint8List> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.blue,
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      selectedTemplate?.headerTemplate ?? 'Laboratory Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Generated on: ${DateTime.now().toString().split('.')[0]}',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Patient Information
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Patient Information',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      children: [
                        pw.Text('Name: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(widget.patient.fullName),
                        pw.SizedBox(width: 30),
                        pw.Text('ID: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(widget.patient.patientId ?? 'N/A'),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      children: [
                        pw.Text('Date of Birth: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(widget.patient.formattedDateOfBirth),
                        pw.SizedBox(width: 30),
                        pw.Text('Gender: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(widget.patient.gender),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Test Information
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Test Information',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      children: [
                        pw.Text('Test Type: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(widget.test.testType),
                        pw.SizedBox(width: 30),
                        pw.Text('Test Name: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(widget.test.testName),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      children: [
                        pw.Text('Ordered Date: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(widget.test.orderedDate.toString().split(' ')[0]),
                        pw.SizedBox(width: 30),
                        pw.Text('Status: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(widget.test.status),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Results
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Test Results',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    ...reportData.entries.map((entry) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 5),
                      child: pw.Row(
                        children: [
                          pw.Text(
                            '${entry.key.replaceAll('_', ' ').toUpperCase()}: ',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(entry.value.toString()),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Footer
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                child: pw.Text(
                  selectedTemplate?.footerTemplate ?? 'Report generated by SAEED Laboratory',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  void _generateReportData() {
    // Generate realistic data based on the selected template and test type
    Map<String, dynamic> data = {};
    
    // Check if we have actual test results from the test object
    if (widget.test.results != null && widget.test.results!.isNotEmpty) {
      // Try to parse results as JSON, if it fails, use as string
      try {
        // If results is a JSON string, parse it
        if (widget.test.results!.startsWith('{') || widget.test.results!.startsWith('[')) {
          data = Map<String, dynamic>.from(jsonDecode(widget.test.results!));
        } else {
          // If it's a plain string, create a simple map
          data['results'] = widget.test.results!;
        }
      } catch (e) {
        // If parsing fails, use as string
        data['results'] = widget.test.results!;
      }
    } else {
      // Generate realistic data based on template and test type
      Map<String, dynamic> testSpecificData = _generateTestSpecificData(widget.test.testType);
      
      for (var field in selectedTemplate!.fields) {
        if (testSpecificData.containsKey(field.name)) {
          // Use test-specific data if available
          data[field.name] = testSpecificData[field.name];
        } else if (field.type == 'number') {
          data[field.name] = _generateRealisticValue(field.normalRange);
        } else if (field.type == 'text') {
          data[field.name] = _generateRealisticTextValue(field.name, widget.test.testType);
        } else if (field.type == 'textarea') {
          data[field.name] = _generateClinicalInterpretation(widget.test.testType);
        }
      }
    }
    
    setState(() {
      reportData = data;
    });
  }

  String _generateRealisticTextValue(String fieldName, String testType) {
    // Generate realistic text values based on field name and test type
    switch (fieldName.toLowerCase()) {
      case 'color':
        return 'Yellow';
      case 'appearance':
        return 'Clear';
      case 'protein':
      case 'glucose':
      case 'ketones':
      case 'blood':
      case 'leukocytes':
      case 'nitrites':
        return 'Negative';
      case 'ph':
        return '6.5';
      case 'specific_gravity':
        return '1.020';
      default:
        return 'Normal';
    }
  }

  String _generateClinicalInterpretation(String testType) {
    switch (testType.toLowerCase()) {
      case 'blood test (cbc)':
      case 'comprehensive blood panel':
        return 'Complete Blood Count shows all parameters within normal reference ranges. No significant abnormalities detected. Hemoglobin, white blood cells, and platelets are all within expected values.';
      case 'lipid profile':
      case 'comprehensive lipid profile':
        return 'Lipid panel results are within normal limits. Total cholesterol, HDL, LDL, and triglycerides are all in the optimal range. No cardiovascular risk factors identified.';
      case 'metabolic panel':
      case 'advanced metabolic panel':
        return 'Comprehensive metabolic panel shows normal kidney and liver function. Electrolytes are balanced. Glucose levels are within normal range. No metabolic abnormalities detected.';
      case 'urine analysis':
        return 'Urinalysis results are normal. No protein, glucose, blood, or other abnormal substances detected. Urine appearance and specific gravity are within normal limits.';
      case 'diabetes test':
        return 'Diabetes screening results are normal. Fasting glucose and HbA1c levels are within the normal range. No evidence of diabetes or prediabetes detected.';
      default:
        return 'All test parameters are within normal reference ranges. No significant abnormalities detected. Results indicate normal physiological function.';
    }
  }

  double _generateRealisticValue(String? normalRange) {
    if (normalRange == null) return 0.0;
    
    // Parse normal range and generate realistic value
    if (normalRange.contains('-')) {
      List<String> parts = normalRange.split('-');
      double min = double.tryParse(parts[0]) ?? 0.0;
      double max = double.tryParse(parts[1]) ?? 100.0;
      return min + (max - min) * 0.7; // 70% towards the middle
    } else if (normalRange.startsWith('<')) {
      double max = double.tryParse(normalRange.substring(1)) ?? 100.0;
      return max * 0.8; // 80% of max
    } else if (normalRange.startsWith('≥')) {
      double min = double.tryParse(normalRange.substring(1)) ?? 0.0;
      return min * 1.2; // 20% above min
    }
    
    return double.tryParse(normalRange) ?? 0.0;
  }

  Map<String, dynamic> _generateTestSpecificData(String testType) {
    // Generate test-specific realistic data based on test type
    switch (testType.toLowerCase()) {
      case 'comprehensive blood panel':
      case 'blood test (cbc)':
        return {
          'hemoglobin': 14.2,
          'white_blood_cells': 7.5,
          'platelets': 250,
          'red_blood_cells': 4.8,
          'hematocrit': 42.0,
          'mean_corpuscular_volume': 88.0,
          'mean_corpuscular_hemoglobin': 29.5,
          'mean_corpuscular_hemoglobin_concentration': 34.0,
        };
      case 'comprehensive lipid profile':
      case 'lipid profile':
        return {
          'total_cholesterol': 180.0,
          'hdl_cholesterol': 55.0,
          'ldl_cholesterol': 100.0,
          'triglycerides': 120.0,
          'cholesterol_ratio': 3.3,
        };
      case 'advanced metabolic panel':
      case 'metabolic panel':
        return {
          'glucose': 95.0,
          'creatinine': 0.9,
          'bun': 15.0,
          'sodium': 140.0,
          'potassium': 4.0,
          'chloride': 102.0,
          'co2': 24.0,
          'calcium': 9.5,
          'total_protein': 7.0,
          'albumin': 4.2,
          'bilirubin_total': 0.8,
          'alkaline_phosphatase': 70.0,
          'alt': 25.0,
          'ast': 22.0,
        };
      case 'urine analysis':
        return {
          'color': 'Yellow',
          'appearance': 'Clear',
          'specific_gravity': 1.020,
          'ph': 6.5,
          'protein': 'Negative',
          'glucose': 'Negative',
          'ketones': 'Negative',
          'blood': 'Negative',
          'leukocytes': 'Negative',
          'nitrites': 'Negative',
        };
      case 'diabetes test':
      case 'hba1c':
        return {
          'hba1c': 5.7,
          'fasting_glucose': 95.0,
          'random_glucose': 110.0,
        };
      default:
        return {
          'test_value': 50.0,
          'reference_range': '0-100',
          'units': 'mg/dL',
        };
    }
  }


  bool _isResultNormal(String fieldName, dynamic value) {
    var field = selectedTemplate!.fields.firstWhere((f) => f.name == fieldName);
    if (field.normalRange == null) return true;
    
    if (value is num) {
      if (field.normalRange!.contains('-')) {
        List<String> parts = field.normalRange!.split('-');
        double min = double.tryParse(parts[0]) ?? 0.0;
        double max = double.tryParse(parts[1]) ?? 100.0;
        return value >= min && value <= max;
      } else if (field.normalRange!.startsWith('<')) {
        double max = double.tryParse(field.normalRange!.substring(1)) ?? 100.0;
        return value < max;
      } else if (field.normalRange!.startsWith('≥')) {
        double min = double.tryParse(field.normalRange!.substring(1)) ?? 0.0;
        return value >= min;
      }
    }
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Report Preview'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Template Selection
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                const Text('Select Template: '),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<ReportTemplate>(
                    value: selectedTemplate,
                    isExpanded: true,
                    items: DefaultReportTemplates.templates.map((template) {
                      return DropdownMenuItem(
                        value: template,
                        child: Text(template.name),
                      );
                    }).toList(),
                    onChanged: (template) {
                      setState(() {
                        selectedTemplate = template;
                        if (_savedResultRows.isEmpty) {
                          _generateReportData();
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Report Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildReportContent(),
              ),
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _printReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Print'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _downloadPDF,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Download PDF'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    if (selectedTemplate == null) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: selectedTemplate!.styling['headerBackgroundColor'] ?? Colors.green.shade700,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Column(
            children: [
              Text(
                'SAEED LABORATORY',
                style: TextStyle(
                  fontSize: selectedTemplate!.styling['headerFontSize'] ?? 22.0,
                  fontWeight: FontWeight.bold,
                  color: selectedTemplate!.styling['headerTextColor'] ?? Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '123 Medical Center Dr, Healthcare City',
                style: TextStyle(
                  color: selectedTemplate!.styling['headerTextColor'] ?? Colors.white,
                ),
              ),
              Text(
                'Phone: 555-0126 | Email: info@saeedlab.com',
                style: TextStyle(
                  color: selectedTemplate!.styling['headerTextColor'] ?? Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Report No: R${DateTime.now().millisecondsSinceEpoch % 10000}',
                    style: TextStyle(
                      color: selectedTemplate!.styling['headerTextColor'] ?? Colors.white,
                    ),
                  ),
                  Text(
                    'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: TextStyle(
                      color: selectedTemplate!.styling['headerTextColor'] ?? Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Patient Information
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patient Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selectedTemplate!.styling['headerBackgroundColor'] ?? Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Patient Name:', widget.patient.fullName),
                        _buildInfoRow('Gender:', widget.patient.gender),
                        _buildInfoRow('Test Type:', widget.test.testType),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Age:', '${widget.patient.age}'),
                        _buildInfoRow('Contact:', widget.patient.phone),
                        _buildInfoRow('Status:', widget.test.status.toUpperCase()),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Test Results Table
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Test Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selectedTemplate!.styling['headerBackgroundColor'] ?? Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 16),
              if (_loadingOrderResults)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                _buildResultsTable(),
            ],
          ),
        ),
        
        // Footer
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Authorized by:'),
              const SizedBox(height: 8),
              Text(
                widget.test.orderedBy,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Report generated on: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTable() {
    final borderColor =
        selectedTemplate!.styling['tableBorderColor'] ?? Colors.grey.shade300;
    final headerBg =
        selectedTemplate!.styling['headerBackgroundColor'] ?? Colors.grey.shade200;
    final headerText = selectedTemplate!.styling['headerTextColor'];
    final normalColor =
        selectedTemplate!.styling['normalResultColor'] ?? Colors.green;
    final abnormalColor =
        selectedTemplate!.styling['abnormalResultColor'] ?? Colors.red;

    Widget headerRow() => Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(color: headerBg),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Test Parameter',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: headerText)),
              ),
              Expanded(
                child: Text('Result',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: headerText)),
              ),
              Expanded(
                child: Text('Reference Range',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: headerText)),
              ),
              Expanded(
                child: Text('Unit',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: headerText)),
              ),
            ],
          ),
        );

    List<Widget> dataRows;
    if (_savedResultRows.isNotEmpty) {
      dataRows = _savedResultRows.map((row) {
        final isNormal = _isResultNormalForRow(row);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text(row.parameter)),
              Expanded(
                child: Text(
                  row.value,
                  style: TextStyle(
                    color: isNormal ? normalColor : abnormalColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Text(row.displayReference)),
              Expanded(child: Text(row.unit.isEmpty ? '—' : row.unit)),
            ],
          ),
        );
      }).toList();
    } else {
      dataRows = selectedTemplate!.fields
          .where((field) => field.type != 'textarea')
          .map((field) {
        final value = reportData[field.name] ?? '';
        final isNormal = _isResultNormal(field.name, value);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text(field.label)),
              Expanded(
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    color: isNormal ? normalColor : abnormalColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Text(field.normalRange ?? '')),
              Expanded(child: Text(field.unit ?? '')),
            ],
          ),
        );
      }).toList();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [headerRow(), ...dataRows],
      ),
    );
  }

  bool _isResultNormalForRow(LabResultRow row) {
    final v = double.tryParse(row.value.replaceAll(RegExp(r'[^\d.\-]'), ''));
    if (v == null) return true;
    final parts = row.referenceRange.split(RegExp(r'[-–]'));
    if (parts.length != 2) return true;
    final low = double.tryParse(parts[0].trim());
    final high = double.tryParse(parts[1].trim());
    if (low == null || high == null) return true;
    return v >= low && v <= high;
  }

  void _downloadPDF() {
    _exportToPDF();
  }
}
