import 'package:flutter/material.dart';
import '../models/report_template.dart';
import '../models/report_data.dart';
import '../services/django_api_service.dart';
import '../utils/null_safety_extensions.dart';

class ReportProvider extends ChangeNotifier {
  final DjangoApiService _apiService = DjangoApiService();
  
  List<ReportTemplate> _templates = [];
  List<ReportData> _reports = [];
  ReportTemplate? _selectedTemplate;
  ReportData? _selectedReport;
  bool _isLoading = false;
  String? _error;

  List<ReportTemplate> get templates => _templates;
  List<ReportData> get reports => _reports;
  ReportTemplate? get selectedTemplate => _selectedTemplate;
  ReportData? get selectedReport => _selectedReport;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered lists
  List<ReportTemplate> get activeTemplates => _templates;
  List<ReportData> get completedReports => _reports.where((report) => report.status == 'completed').toList();
  List<ReportData> get draftReports => _reports.where((report) => report.status == 'draft').toList();
  List<ReportData> get pendingReports => _reports.where((report) => report.status == 'pending').toList();

  Future<void> loadTemplates() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final templates = await _apiService.getReportTemplates();
      _templates = templates;
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _templates = [];
      
      // Initialize with Quest Lab templates when backend fails
      _templates = DefaultReportTemplates.templates;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReports() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final reports = await _apiService.getReports();
      _reports = reports;
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _reports = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTemplate(ReportTemplate template) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newTemplate = await _apiService.createReportTemplate(template);
      _templates.add(newTemplate);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTemplate(String id, ReportTemplate template) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedTemplate = await _apiService.updateReportTemplate(id, template);
      final index = _templates.indexWhere((t) => t.id == id);
      if (index != -1) {
        _templates[index] = updatedTemplate;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTemplate(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteReportTemplate(id);
      _templates.removeWhere((template) => template.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createReport(ReportData report) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newReport = await _apiService.createReport(report);
      _reports.add(newReport);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateReport(String id, ReportData report) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedReport = await _apiService.updateReport(id, report);
      final index = _reports.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reports[index] = updatedReport;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReport(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteReport(id);
      _reports.removeWhere((report) => report.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> exportReportToPdf(String reportId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final pdfUrl = await _apiService.exportReportToPdf(reportId);
      _isLoading = false;
      notifyListeners();
      return pdfUrl;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> printReport(String reportId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.printReport(reportId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void selectTemplate(ReportTemplate template) {
    _selectedTemplate = template;
    notifyListeners();
  }

  void selectReport(ReportData report) {
    _selectedReport = report;
    notifyListeners();
  }

  void clearSelectedTemplate() {
    _selectedTemplate = null;
    notifyListeners();
  }

  void clearSelectedReport() {
    _selectedReport = null;
    notifyListeners();
  }

  ReportTemplate? getTemplateById(String id) {
    try {
      return _templates.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }

  ReportData? getReportById(String id) {
    try {
      return _reports.firstWhere((report) => report.id == id.toString());
    } catch (e) {
      return null;
    }
  }

  List<ReportTemplate> searchTemplates(String query) {
    if (query.isEmpty) return _templates;
    
    return _templates.where((template) {
      return template.name.toLowerCase().contains(query.toLowerCase()) ||
             template.testType.toLowerCase().contains(query.toLowerCase()) ||
             template.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<ReportData> searchReports(String query) {
    if (query.isEmpty) return _reports;
    
    return _reports.where((report) {
      final q = query.toLowerCase();
      return report.patientId.containsIgnoreCase(q) ||
             report.templateId.containsIgnoreCase(q) ||
             report.authorizedBy.containsIgnoreCase(q) ||
             report.title.containsIgnoreCase(q);
    }).toList();
  }

  List<ReportData> getReportsByStatus(String status) {
    return _reports.where((report) => report.status == status).toList();
  }

  List<ReportData> getReportsByTestType(String testType) {
    return _reports.where((report) => report.templateId == testType).toList();
  }

  List<ReportData> getReportsByDateRange(DateTime startDate, DateTime endDate) {
    return _reports.where((report) {
      return report.reportDate.isAfterOrFalse(startDate.subtract(const Duration(days: 1))) &&
             report.reportDate.isBeforeOrFalse(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Initialize with demo reports if none exist
  void initializeDemoReports() {
    if (_reports.isEmpty) {
      _reports = [
        ReportData(
          id: '1',
          patientId: '1',
          testId: '1',
          templateId: 'standard_report',
          results: {
            'hemoglobin': '14.2',
            'wbc': '7500',
            'rbc': '4.8',
            'platelets': '250000',
            'hematocrit': '42',
            'mcv': '88',
            'mch': '29',
            'mchc': '34',
            'comments': 'All values within normal range.',
          },
          reportDate: DateTime.now().subtract(const Duration(days: 1)),
          status: 'completed',
          notes: 'All values within normal range.',
          authorizedBy: 'Dr. John Smith',
        ),
        ReportData(
          id: '2',
          patientId: '2',
          testId: '2',
          templateId: 'urine_analysis',
          results: {
            'color': 'Yellow',
            'appearance': 'Clear',
            'ph': '6.5',
            'specific_gravity': '1.020',
            'protein': 'Negative',
            'glucose': 'Negative',
            'ketones': 'Negative',
            'blood': 'Negative',
            'leukocytes': 'Negative',
            'nitrites': 'Negative',
            'comments': 'Normal urine analysis results.',
          },
          reportDate: DateTime.now(),
          status: 'completed',
          notes: 'Normal urine analysis results.',
          authorizedBy: 'Dr. John Smith',
        ),
      ];
      notifyListeners();
    }
  }
}
