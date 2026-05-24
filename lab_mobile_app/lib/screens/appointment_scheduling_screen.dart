import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient.dart';
import '../services/appointment_service.dart';
import '../services/simple_hybrid_storage_service.dart';
import '../providers/appointment_provider.dart';
import 'location_selection_screen.dart';

class AppointmentSchedulingScreen extends StatefulWidget {
  final Patient? selectedPatient;

  const AppointmentSchedulingScreen({Key? key, this.selectedPatient}) : super(key: key);

  @override
  State<AppointmentSchedulingScreen> createState() => _AppointmentSchedulingScreenState();
}

class _AppointmentSchedulingScreenState extends State<AppointmentSchedulingScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  final SimpleHybridStorageService _hybridStorage = SimpleHybridStorageService();
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  List<Patient> _patients = [];
  String? _selectedPatientId;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  String? _selectedType;
  String? _selectedLocation;
  bool _isLoading = false;
  List<String> _availableTimeSlots = [];

  final List<String> _appointmentTypes = [
    'General Consultation',
    'Blood Test',
    'X-Ray',
    'Ultrasound',
    'ECG',
    'Follow-up',
    'Emergency',
  ];

  final List<String> _locations = [
    'Main',
    'Downtown',
    'Medical',
    'Home',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.selectedPatient?.patientId;
    _loadPatients();
    _loadAvailableTimeSlots();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await _hybridStorage.getPatients();
      setState(() {
        _patients = patients;
      });
    } catch (e) {
      _showErrorDialog('Error loading patients: $e');
    }
  }

  Future<void> _loadAvailableTimeSlots() async {
    try {
      final slots = await _appointmentService.getAvailableTimeSlots(_selectedDate);
      setState(() {
        _availableTimeSlots = slots;
        if (slots.isNotEmpty && _selectedTime == null) {
          _selectedTime = slots.first;
        }
      });
    } catch (e) {
      _showErrorDialog('Error loading time slots: $e');
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _selectedTime = null;
      });
      _loadAvailableTimeSlots();
    }
  }

  Future<void> _scheduleAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatientId == null) {
      _showErrorDialog('Please select a patient');
      return;
    }
    if (_selectedTime == null) {
      _showErrorDialog('Please select a time slot');
      return;
    }
    if (_selectedType == null) {
      _showErrorDialog('Please select appointment type');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final patient = _patients.firstWhere((p) => p.patientId == _selectedPatientId);
      
      final appointment = await _appointmentService.createAppointment(
        patientId: _selectedPatientId!,
        patientName: patient.fullName,
        patientPhone: patient.phone,
        appointmentDate: _selectedDate,
        appointmentTime: _selectedTime!,
        appointmentType: _selectedType!,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        location: _selectedLocation ?? _locations.first,
      );

      // Update provider
      if (mounted) {
        Provider.of<AppointmentProvider>(context, listen: false).addAppointment(appointment);
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment scheduled successfully for ${patient.fullName}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error scheduling appointment: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Appointment'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPatientSelector(),
                    const SizedBox(height: 20),
                    _buildDateSelector(),
                    const SizedBox(height: 20),
                    _buildTimeSelector(),
                    const SizedBox(height: 20),
                    _buildTypeSelector(),
                    const SizedBox(height: 20),
                    _buildLocationSelector(),
                    const SizedBox(height: 20),
                    _buildNotesField(),
                    const SizedBox(height: 30),
                    _buildScheduleButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPatientSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Patient',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedPatientId,
              decoration: const InputDecoration(
                labelText: 'Patient *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              isExpanded: true,
              items: _patients.map((patient) {
                return DropdownMenuItem(
                  value: patient.patientId,
                  child: Text(
                    patient.fullName ?? 'Unknown',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPatientId = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a patient';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appointment Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Time Slots',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_availableTimeSlots.isEmpty)
              const Text(
                'No available time slots for selected date',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTimeSlots.map((time) {
                  final isSelected = _selectedTime == time;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTime = time;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                        ),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appointment Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              isExpanded: true,
              items: _appointmentTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select appointment type';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final selectedLocation = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationSelectionScreen(
                      currentLocation: _selectedLocation,
                      onLocationSelected: (location) {
                        setState(() {
                          _selectedLocation = location;
                        });
                      },
                    ),
                  ),
                );
                if (selectedLocation != null) {
                  setState(() {
                    _selectedLocation = selectedLocation;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedLocation ?? _locations.first,
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
                hintText: 'Any special requirements or notes...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _scheduleAppointment,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        child: const Text(
          'Schedule Appointment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
