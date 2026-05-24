import 'package:flutter/material.dart';
import '../services/simple_hybrid_storage_service.dart';
import '../models/patient.dart';
import '../models/test.dart';

class DatabaseExcelScreen extends StatefulWidget {
  const DatabaseExcelScreen({Key? key}) : super(key: key);

  @override
  State<DatabaseExcelScreen> createState() => _DatabaseExcelScreenState();
}

class _DatabaseExcelScreenState extends State<DatabaseExcelScreen> {
  final SimpleHybridStorageService _hybridStorage = SimpleHybridStorageService();
  
  List<Patient> _patients = [];
  List<Test> _tests = [];
  bool _isLoading = false;
  String _selectedTable = 'Patients';
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final patients = await _hybridStorage.getPatients();
      final tests = await _hybridStorage.getTests();
      
      setState(() {
        _patients = patients;
        _tests = tests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error loading data: $e');
    }
  }

  Future<void> _editRecord() async {
    if (_selectedIndex == -1) {
      _showErrorDialog('Please select a record to edit');
      return;
    }

    if (_selectedTable == 'Patients') {
      final patient = _patients[_selectedIndex];
      // Navigate to edit patient screen
      // This would be implemented based on your existing edit patient screen
      _showComingSoon('Edit Patient');
    } else if (_selectedTable == 'Tests') {
      final test = _tests[_selectedIndex];
      // Navigate to edit test screen
      // This would be implemented based on your existing edit test screen
      _showComingSoon('Edit Test');
    }
  }

  Future<void> _deleteRecord() async {
    if (_selectedIndex == -1) {
      _showErrorDialog('Please select a record to delete');
      return;
    }

    final confirmed = await _showDeleteConfirmationDialog();
    if (confirmed == true) {
      try {
        if (_selectedTable == 'Patients') {
          await _hybridStorage.deletePatient(_patients[_selectedIndex].patientId!);
          _patients.removeAt(_selectedIndex);
        } else if (_selectedTable == 'Tests') {
          await _hybridStorage.deleteTest(_tests[_selectedIndex].testId!);
          _tests.removeAt(_selectedIndex);
        }
        
        setState(() {
          _selectedIndex = -1;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        _showErrorDialog('Error deleting record: $e');
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this record? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature functionality - Coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildTableSelector(),
                _buildActionBar(),
                Expanded(
                  child: _selectedTable == 'Patients' ? _buildPatientsTable() : _buildTestsTable(),
                ),
              ],
            ),
    );
  }

  Widget _buildTableSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text('Table: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedTable,
              isExpanded: true,
              items: ['Patients', 'Tests'].map((String table) {
                return DropdownMenuItem<String>(
                  value: table,
                  child: Text(table),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTable = newValue!;
                  _selectedIndex = -1;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: _editRecord,
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedIndex == -1 ? Colors.grey : Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _deleteRecord,
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedIndex == -1 ? Colors.grey : Colors.red,
            ),
          ),
          const Spacer(),
          Text('$_selectedTable: ${_selectedTable == 'Patients' ? _patients.length : _tests.length} records'),
        ],
      ),
    );
  }

  Widget _buildPatientsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Gender')),
            DataColumn(label: Text('DOB')),
            DataColumn(label: Text('Address')),
            DataColumn(label: Text('Blood Type')),
            DataColumn(label: Text('Emergency Contact')),
            DataColumn(label: Text('Insurance Info')),
            DataColumn(label: Text('Created At')),
            DataColumn(label: Text('Synced')),
          ],
          rows: _patients.asMap().entries.map((entry) {
            final index = entry.key;
            final patient = entry.value;
            final isSelected = _selectedIndex == index;
            
            return DataRow(
              selected: isSelected,
              onSelectChanged: (bool? selected) {
                setState(() {
                  _selectedIndex = selected == true ? index : -1;
                });
              },
              cells: [
                DataCell(Text(patient.patientId ?? 'N/A')),
                DataCell(Text(patient.fullName)),
                DataCell(Text(patient.phone)),
                DataCell(Text(patient.email ?? 'N/A')),
                DataCell(Text(patient.gender)),
                DataCell(Text(patient.dateOfBirth.toString().split(' ')[0])),
                DataCell(Text(patient.address ?? 'N/A')),
                DataCell(Text(patient.bloodType ?? 'N/A')),
                DataCell(Text(patient.emergencyContact ?? 'N/A')),
                DataCell(Text(patient.insuranceInfo ?? 'N/A')),
                DataCell(Text(patient.createdAt.toString().split(' ')[0])),
                DataCell(Icon(
                  (patient.syncedToBackend ?? false) ? Icons.check : Icons.sync,
                  color: (patient.syncedToBackend ?? false) ? Colors.green : Colors.orange,
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTestsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Patient ID')),
            DataColumn(label: Text('Test Name')),
            DataColumn(label: Text('Test Type')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Priority')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Ordered Date')),
            DataColumn(label: Text('Completed Date')),
            DataColumn(label: Text('Ordered By')),
            DataColumn(label: Text('Notes')),
            DataColumn(label: Text('Created At')),
            DataColumn(label: Text('Synced')),
          ],
          rows: _tests.asMap().entries.map((entry) {
            final index = entry.key;
            final test = entry.value;
            final isSelected = _selectedIndex == index;
            
            return DataRow(
              selected: isSelected,
              onSelectChanged: (bool? selected) {
                setState(() {
                  _selectedIndex = selected == true ? index : -1;
                });
              },
              cells: [
                DataCell(Text(test.testId ?? 'N/A')),
                DataCell(Text(test.patientId)),
                DataCell(Text(test.testName)),
                DataCell(Text(test.testType)),
                DataCell(Text(test.status)),
                DataCell(Text(test.priority ?? 'N/A')),
                DataCell(Text('\$${test.price.toStringAsFixed(2)}')),
                DataCell(Text(test.orderedDate.toString().split(' ')[0])),
                DataCell(Text(test.completedDate?.toString().split(' ')[0] ?? 'N/A')),
                DataCell(Text(test.orderedBy ?? 'N/A')),
                DataCell(Text(test.notes ?? 'N/A')),
                DataCell(Text(test.createdAt.toString().split(' ')[0])),
                DataCell(Icon(
                  (test.syncedToBackend ?? false) ? Icons.check : Icons.sync,
                  color: (test.syncedToBackend ?? false) ? Colors.green : Colors.orange,
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
