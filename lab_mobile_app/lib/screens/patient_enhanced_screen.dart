import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';
import '../providers/test_provider.dart';
import '../providers/appointment_provider.dart';
import '../models/patient.dart';

class PatientEnhancedScreen extends StatefulWidget {
  const PatientEnhancedScreen({super.key});

  @override
  State<PatientEnhancedScreen> createState() => _PatientEnhancedScreenState();
}

class _PatientEnhancedScreenState extends State<PatientEnhancedScreen> {
  String _searchQuery = '';
  // String _selectedFilter = 'all'; // For future use
  String _selectedSortBy = 'name';
  bool _sortAscending = true;
  final List<String> _selectedBloodTypes = [];
  final List<String> _selectedGenders = [];
  bool _showAnalytics = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Patient Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => setState(() => _showAnalytics = !_showAnalytics),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
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
                hintText: 'Search patients...',
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

          // Analytics Dashboard
          if (_showAnalytics)
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.blue.shade50,
              child: Consumer<PatientProvider>(
                builder: (context, patientProvider, child) {
                  final patients = patientProvider.patients;
                  final totalPatients = patients.length;
                  final malePatients = patients.where((p) => p.gender.toLowerCase() == 'male').length;
                  final femalePatients = patients.where((p) => p.gender.toLowerCase() == 'female').length;
                  final activePatients = patients.where((p) => p.createdAt != null && 
                      p.createdAt!.isAfter(DateTime.now().subtract(const Duration(days: 30)))).length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patient Analytics',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildAnalyticsCard(
                              'Total Patients',
                              totalPatients.toString(),
                              Icons.people,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildAnalyticsCard(
                              'Male',
                              malePatients.toString(),
                              Icons.male,
                              Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildAnalyticsCard(
                              'Female',
                              femalePatients.toString(),
                              Icons.female,
                              Colors.pink,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildAnalyticsCard(
                              'Active (30d)',
                              activePatients.toString(),
                              Icons.trending_up,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

          // Patients List
          Expanded(
            child: Consumer<PatientProvider>(
              builder: (context, patientProvider, child) {
                final filteredPatients = _getFilteredPatients(patientProvider);
                
                if (filteredPatients.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No patients found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredPatients.length,
                  itemBuilder: (context, index) {
                    final patient = filteredPatients[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: _getPatientStatusColor(patient),
                          child: Text(
                            patient.initials,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          patient.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${patient.patientId ?? 'N/A'}'),
                            Text('Age: ${patient.age} years | ${patient.gender}'),
                            if (patient.bloodType != null)
                              Text('Blood Type: ${patient.bloodType}'),
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
                                  Text('View Details'),
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
                              value: 'tests',
                              child: Row(
                                children: [
                                  Icon(Icons.science),
                                  SizedBox(width: 8),
                                  Text('View Tests'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'appointments',
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today),
                                  SizedBox(width: 8),
                                  Text('View Appointments'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'history',
                              child: Row(
                                children: [
                                  Icon(Icons.history),
                                  SizedBox(width: 8),
                                  Text('Medical History'),
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
                          onSelected: (value) => _handlePatientAction(value, patient),
                        ),
                        children: [
                          _buildPatientDetails(patient),
                        ],
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
        onPressed: _addNewPatient,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPatientDetails(Patient patient) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Information
          const Text(
            'Contact Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Phone', patient.phone),
          if (patient.email != null) _buildDetailRow('Email', patient.email!),
          if (patient.address != null) _buildDetailRow('Address', patient.address!),
          if (patient.emergencyContact != null) 
            _buildDetailRow('Emergency Contact', patient.emergencyContact!),
          
          const SizedBox(height: 16),
          
          // Medical Information
          const Text(
            'Medical Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (patient.bloodType != null) _buildDetailRow('Blood Type', patient.bloodType!),
          if (patient.medicalHistory != null) 
            _buildDetailRow('Medical History', patient.medicalHistory!),
          if (patient.insuranceInfo != null) 
            _buildDetailRow('Insurance', patient.insuranceInfo!),
          
          const SizedBox(height: 16),
          
          // Recent Activity
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Consumer2<TestProvider, AppointmentProvider>(
            builder: (context, testProvider, appointmentProvider, child) {
              final patientTests = testProvider.tests
                  .where((test) => test.patientId == patient.patientId)
                  .take(3)
                  .toList();
              
              final patientAppointments = appointmentProvider.appointments
                  .where((apt) => apt.patientId == patient.patientId)
                  .take(3)
                  .toList();

              return Column(
                children: [
                  if (patientTests.isNotEmpty) ...[
                    const Text('Recent Tests:', style: TextStyle(fontWeight: FontWeight.w500)),
                    ...patientTests.map((test) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Row(
                        children: [
                          Icon(
                            _getTestStatusIcon(test.status),
                            size: 16,
                            color: _getTestStatusColor(test.status),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${test.testName} - ${test.status}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                  if (patientAppointments.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('Recent Appointments:', style: TextStyle(fontWeight: FontWeight.w500)),
                    ...patientAppointments.map((apt) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Row(
                        children: [
                          Icon(
                            _getAppointmentStatusIcon(apt.status),
                            size: 16,
                            color: _getAppointmentStatusColor(apt.status),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${apt.testType} - ${apt.appointmentDate.toString().split(' ')[0]}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPatientStatusColor(Patient patient) {
    // Determine patient status based on recent activity
    if (patient.createdAt != null && 
        patient.createdAt!.isAfter(DateTime.now().subtract(const Duration(days: 7)))) {
      return Colors.green; // New patient
    } else if (patient.createdAt != null && 
               patient.createdAt!.isAfter(DateTime.now().subtract(const Duration(days: 30)))) {
      return Colors.blue; // Active patient
    } else {
      return Colors.grey; // Inactive patient
    }
  }

  IconData _getTestStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'in_progress':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getTestStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getAppointmentStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'scheduled':
        return Icons.schedule;
      case 'confirmed':
        return Icons.confirmation_number;
      case 'cancelled':
        return Icons.cancel;
      case 'no_show':
        return Icons.person_off;
      default:
        return Icons.help;
    }
  }

  Color _getAppointmentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'scheduled':
        return Colors.blue;
      case 'confirmed':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'no_show':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  List<Patient> _getFilteredPatients(PatientProvider patientProvider) {
    List<Patient> patients = patientProvider.patients;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      patients = patients.where((patient) {
        return patient.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (patient.patientId?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
               patient.phone.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (patient.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply blood type filter
    if (_selectedBloodTypes.isNotEmpty) {
      patients = patients.where((patient) {
        return patient.bloodType != null && _selectedBloodTypes.contains(patient.bloodType);
      }).toList();
    }

    // Apply gender filter
    if (_selectedGenders.isNotEmpty) {
      patients = patients.where((patient) {
        return _selectedGenders.contains(patient.gender.toLowerCase());
      }).toList();
    }

    // Sort patients
    patients.sort((a, b) {
      int comparison = 0;
      switch (_selectedSortBy) {
        case 'name':
          comparison = a.fullName.compareTo(b.fullName);
          break;
        case 'age':
          comparison = a.age.compareTo(b.age);
          break;
        case 'date':
          comparison = (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now());
          break;
        case 'id':
          comparison = (a.patientId ?? '').compareTo(b.patientId ?? '');
          break;
        default:
          comparison = 0;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return patients;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Patients'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Blood Type Filter
                const Text('Blood Type', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((bloodType) {
                    final isSelected = _selectedBloodTypes.contains(bloodType);
                    return FilterChip(
                      label: Text(bloodType),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedBloodTypes.add(bloodType);
                          } else {
                            _selectedBloodTypes.remove(bloodType);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Gender Filter
                const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: ['male', 'female'].map((gender) {
                    final isSelected = _selectedGenders.contains(gender);
                    return FilterChip(
                      label: Text(gender.toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedGenders.add(gender);
                          } else {
                            _selectedGenders.remove(gender);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedBloodTypes.clear();
                _selectedGenders.clear();
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
        title: const Text('Sort Patients'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Name'),
              value: 'name',
              groupValue: _selectedSortBy,
              onChanged: (value) {
                setState(() => _selectedSortBy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Age'),
              value: 'age',
              groupValue: _selectedSortBy,
              onChanged: (value) {
                setState(() => _selectedSortBy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Registration Date'),
              value: 'date',
              groupValue: _selectedSortBy,
              onChanged: (value) {
                setState(() => _selectedSortBy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Patient ID'),
              value: 'id',
              groupValue: _selectedSortBy,
              onChanged: (value) {
                setState(() => _selectedSortBy = value!);
                Navigator.pop(context);
              },
            ),
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

  void _handlePatientAction(String action, Patient patient) {
    switch (action) {
      case 'view':
        _viewPatientDetails(patient);
        break;
      case 'edit':
        _editPatient(patient);
        break;
      case 'tests':
        _viewPatientTests(patient);
        break;
      case 'appointments':
        _viewPatientAppointments(patient);
        break;
      case 'history':
        _viewMedicalHistory(patient);
        break;
      case 'delete':
        _deletePatient(patient);
        break;
    }
  }

  void _viewPatientDetails(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Patient Details: ${patient.fullName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Patient ID', patient.patientId ?? 'N/A'),
              _buildDetailRow('Full Name', patient.fullName),
              _buildDetailRow('Date of Birth', patient.formattedDateOfBirth),
              _buildDetailRow('Age', '${patient.age} years'),
              _buildDetailRow('Gender', patient.gender),
              _buildDetailRow('Phone', patient.phone),
              if (patient.email != null) _buildDetailRow('Email', patient.email!),
              if (patient.address != null) _buildDetailRow('Address', patient.address!),
              if (patient.emergencyContact != null) 
                _buildDetailRow('Emergency Contact', patient.emergencyContact!),
              if (patient.bloodType != null) _buildDetailRow('Blood Type', patient.bloodType!),
              if (patient.medicalHistory != null) 
                _buildDetailRow('Medical History', patient.medicalHistory!),
              if (patient.insuranceInfo != null) 
                _buildDetailRow('Insurance', patient.insuranceInfo!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editPatient(Patient patient) {
    // Implement patient editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Patient editing coming soon!')),
    );
  }

  void _viewPatientTests(Patient patient) {
    // Navigate to patient tests screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Patient tests view coming soon!')),
    );
  }

  void _viewPatientAppointments(Patient patient) {
    // Navigate to patient appointments screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Patient appointments view coming soon!')),
    );
  }

  void _viewMedicalHistory(Patient patient) {
    // Navigate to medical history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medical history view coming soon!')),
    );
  }

  void _deletePatient(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient'),
        content: Text('Are you sure you want to delete ${patient.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement patient deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Patient deleted successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addNewPatient() {
    // Navigate to add patient screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add patient functionality coming soon!')),
    );
  }
}
