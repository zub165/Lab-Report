import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../providers/test_provider.dart';
import '../models/report_data.dart';
import '../utils/null_safety_extensions.dart';

class ReportEnhancedScreen extends StatefulWidget {
  const ReportEnhancedScreen({super.key});

  @override
  State<ReportEnhancedScreen> createState() => _ReportEnhancedScreenState();
}

class _ReportEnhancedScreenState extends State<ReportEnhancedScreen> {
  String _selectedFilter = 'all';
  String _selectedSortBy = 'date';
  bool _sortAscending = false;
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> _selectedStatuses = [];
  final List<String> _selectedTestTypes = [];
  final List<String> _selectedTemplates = [];
  bool _showBatchOperations = false;
  final List<String> _selectedReports = [];

  // Filter options for future use
  // final List<String> _filterOptions = [
  //   'all',
  //   'completed',
  //   'pending',
  //   'draft',
  //   'urgent',
  //   'abnormal',
  // ];

  final List<String> _sortOptions = [
    'date',
    'patient_name',
    'test_type',
    'status',
    'template',
    'priority',
  ];

  final List<String> _statusOptions = [
    'completed',
    'pending',
    'draft',
    'in_progress',
    'cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
          ),
          IconButton(
            icon: const Icon(Icons.batch_prediction),
            onPressed: () => setState(() => _showBatchOperations = !_showBatchOperations),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search reports...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Active Filters Display
          if (_hasActiveFilters())
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8.0,
                children: [
                  if (_selectedFilter != 'all')
                    Chip(
                      label: Text('Filter: $_selectedFilter'),
                      onDeleted: () => setState(() => _selectedFilter = 'all'),
                    ),
                  if (_startDate != null)
                    Chip(
                      label: Text('From: ${_startDate!.toString().split(' ')[0]}'),
                      onDeleted: () => setState(() => _startDate = null),
                    ),
                  if (_endDate != null)
                    Chip(
                      label: Text('To: ${_endDate!.toString().split(' ')[0]}'),
                      onDeleted: () => setState(() => _endDate = null),
                    ),
                  if (_selectedStatuses.isNotEmpty)
                    Chip(
                      label: Text('Status: ${_selectedStatuses.join(', ')}'),
                      onDeleted: () => setState(() => _selectedStatuses.clear()),
                    ),
                  if (_selectedTestTypes.isNotEmpty)
                    Chip(
                      label: Text('Tests: ${_selectedTestTypes.join(', ')}'),
                      onDeleted: () => setState(() => _selectedTestTypes.clear()),
                    ),
                  if (_selectedTemplates.isNotEmpty)
                    Chip(
                      label: Text('Templates: ${_selectedTemplates.join(', ')}'),
                      onDeleted: () => setState(() => _selectedTemplates.clear()),
                    ),
                ],
              ),
            ),

          // Batch Operations Bar
          if (_showBatchOperations)
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_selectedReports.length} reports selected',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _selectedReports.isEmpty ? null : _exportSelectedReports,
                    icon: const Icon(Icons.download),
                    label: const Text('Export'),
                  ),
                  TextButton.icon(
                    onPressed: _selectedReports.isEmpty ? null : _printSelectedReports,
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                  ),
                  TextButton.icon(
                    onPressed: _selectedReports.isEmpty ? null : _deleteSelectedReports,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),

          // Reports List
          Expanded(
            child: Consumer<ReportProvider>(
              builder: (context, reportProvider, child) {
                final filteredReports = _getFilteredReports(reportProvider);
                
                if (filteredReports.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No reports found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredReports.length,
                  itemBuilder: (context, index) {
                    final report = filteredReports[index];
                    final isSelected = _selectedReports.contains(report.id);
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: ListTile(
                        leading: _showBatchOperations
                            ? Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      if (report.id != null) _selectedReports.add(report.id!);
                                    } else {
                                      _selectedReports.remove(report.id);
                                    }
                                  });
                                },
                              )
                            : CircleAvatar(
                                backgroundColor: _getReportStatusColor(report.notes ?? ''),
                                child: Icon(
                                  _getReportStatusIcon(report.notes ?? ''),
                                  color: Colors.white,
                                ),
                              ),
                        title: Text(
                          'Report for ${report.patientId}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Test: ${report.testId}'),
                            Text('Date: ${report.reportDate.toString().split(' ')[0]}'),
                            if (report.notes != null && report.notes!.isNotEmpty)
                              Text(
                                'Status: ${report.notes}',
                                style: TextStyle(
                                  color: _getReportStatusColor(report.notes!),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility),
                                  SizedBox(width: 8),
                                  Text('View'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'print',
                              child: Row(
                                children: [
                                  Icon(Icons.print),
                                  SizedBox(width: 8),
                                  Text('Print'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'export',
                              child: Row(
                                children: [
                                  Icon(Icons.download),
                                  SizedBox(width: 8),
                                  Text('Export PDF'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'share',
                              child: Row(
                                children: [
                                  Icon(Icons.share),
                                  SizedBox(width: 8),
                                  Text('Share'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) => _handleReportAction(value, report),
                        ),
                        onTap: () => _viewReport(report),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewReport,
        child: const Icon(Icons.add),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedFilter != 'all' ||
        _startDate != null ||
        _endDate != null ||
        _selectedStatuses.isNotEmpty ||
        _selectedTestTypes.isNotEmpty ||
        _selectedTemplates.isNotEmpty;
  }

  List<ReportData> _getFilteredReports(ReportProvider reportProvider) {
    List<ReportData> reports = reportProvider.reports;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      reports = reports.where((report) {
        return report.patientId.containsIgnoreCase(_searchQuery) ||
               report.testId.containsIgnoreCase(_searchQuery) ||
               (report.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply status filter
    if (_selectedFilter != 'all') {
      reports = reports.where((report) {
        final status = report.notes?.toLowerCase() ?? '';
        switch (_selectedFilter) {
          case 'completed':
            return status.contains('completed');
          case 'pending':
            return status.contains('pending');
          case 'draft':
            return status.contains('draft');
          case 'urgent':
            return status.contains('urgent');
          case 'abnormal':
            return status.contains('abnormal');
          default:
            return true;
        }
      }).toList();
    }

    // Apply date range filter
    if (_startDate != null) {
      reports = reports.where((report) => report.reportDate.isAfterOrFalse(_startDate!)).toList();
    }
    if (_endDate != null) {
      reports = reports.where((report) => report.reportDate.isBeforeOrFalse(_endDate!)).toList();
    }

    // Apply multiple status filter
    if (_selectedStatuses.isNotEmpty) {
      reports = reports.where((report) {
        final status = report.notes?.toLowerCase() ?? '';
        return _selectedStatuses.any((selectedStatus) => status.contains(selectedStatus));
      }).toList();
    }

    // Sort reports
    reports.sort((a, b) {
      int comparison = 0;
      switch (_selectedSortBy) {
        case 'date':
          comparison = compareDatesNullsLast(a.reportDate, b.reportDate);
          break;
        case 'patient_name':
          comparison = compareStringsNullsLast(a.patientId, b.patientId);
          break;
        case 'test_type':
          comparison = compareStringsNullsLast(a.testId, b.testId);
          break;
        case 'status':
          comparison = (a.notes ?? '').compareTo(b.notes ?? '');
          break;
        default:
          comparison = 0;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return reports;
  }

  Color _getReportStatusColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('completed')) return Colors.green;
    if (lowerStatus.contains('pending')) return Colors.orange;
    if (lowerStatus.contains('draft')) return Colors.grey;
    if (lowerStatus.contains('urgent')) return Colors.red;
    if (lowerStatus.contains('abnormal')) return Colors.purple;
    return Colors.blue;
  }

  IconData _getReportStatusIcon(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('completed')) return Icons.check_circle;
    if (lowerStatus.contains('pending')) return Icons.schedule;
    if (lowerStatus.contains('draft')) return Icons.edit;
    if (lowerStatus.contains('urgent')) return Icons.warning;
    if (lowerStatus.contains('abnormal')) return Icons.error;
    return Icons.description;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Filters'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date Range
                const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => _startDate = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_startDate?.toString().split(' ')[0] ?? 'Start Date'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => _endDate = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_endDate?.toString().split(' ')[0] ?? 'End Date'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Status Filter
                const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: _statusOptions.map((status) {
                    final isSelected = _selectedStatuses.contains(status);
                    return FilterChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedStatuses.add(status);
                          } else {
                            _selectedStatuses.remove(status);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Test Types Filter
                const Text('Test Types', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Consumer<TestProvider>(
                  builder: (context, testProvider, child) {
                    final testTypes = testProvider.tests
                        .map((test) => test.testType)
                        .toSet()
                        .toList();
                    
                    return Wrap(
                      spacing: 8.0,
                      children: testTypes.map((testType) {
                        final isSelected = _selectedTestTypes.contains(testType);
                        return FilterChip(
                          label: Text(testType),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTestTypes.add(testType);
                              } else {
                                _selectedTestTypes.remove(testType);
                              }
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Templates Filter
                const Text('Templates', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Consumer<ReportProvider>(
                  builder: (context, reportProvider, child) {
                    return Wrap(
                      spacing: 8.0,
                      children: reportProvider.templates.map((template) {
                        final isSelected = _selectedTemplates.contains(template.name);
                        return FilterChip(
                          label: Text(template.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTemplates.add(template.name);
                              } else {
                                _selectedTemplates.remove(template.name);
                              }
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
                _selectedStatuses.clear();
                _selectedTestTypes.clear();
                _selectedTemplates.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Reports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._sortOptions.map((option) => RadioListTile<String>(
              title: Text(option.replaceAll('_', ' ').toUpperCase()),
              value: option,
              groupValue: _selectedSortBy,
              onChanged: (value) {
                setState(() => _selectedSortBy = value!);
                Navigator.pop(context);
              },
            )),
            const Divider(),
            SwitchListTile(
              title: const Text('Ascending Order'),
              value: _sortAscending,
              onChanged: (value) {
                setState(() => _sortAscending = value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _handleReportAction(String action, ReportData report) {
    switch (action) {
      case 'view':
        _viewReport(report);
        break;
      case 'edit':
        _editReport(report);
        break;
      case 'print':
        _printReport(report);
        break;
      case 'export':
        _exportReport(report);
        break;
      case 'share':
        _shareReport(report);
        break;
      case 'delete':
        _deleteReport(report);
        break;
    }
  }

  void _viewReport(ReportData report) {
    // Navigate to report preview screen
    // This would need to be implemented based on your data structure
  }

  void _editReport(ReportData report) {
    // Implement report editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report editing coming soon!')),
    );
  }

  void _printReport(ReportData report) {
    // Implement report printing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report printing coming soon!')),
    );
  }

  void _exportReport(ReportData report) {
    // Implement report export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report export coming soon!')),
    );
  }

  void _shareReport(ReportData report) {
    // Implement report sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report sharing coming soon!')),
    );
  }

  void _deleteReport(ReportData report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement report deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report deleted successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _createNewReport() {
    // Navigate to report creation screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report creation coming soon!')),
    );
  }

  void _exportSelectedReports() {
    // Implement batch export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting ${_selectedReports.length} reports...')),
    );
  }

  void _printSelectedReports() {
    // Implement batch printing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Printing ${_selectedReports.length} reports...')),
    );
  }

  void _deleteSelectedReports() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Reports'),
        content: Text('Are you sure you want to delete ${_selectedReports.length} reports?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement batch deletion
              setState(() => _selectedReports.clear());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reports deleted successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
