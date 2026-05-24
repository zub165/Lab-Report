import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/patient.dart';
import '../providers/patient_provider.dart';
import '../providers/test_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/payment_provider.dart';
import '../utils/constants.dart';
import '../utils/media_permissions.dart';

class EnhancedAddPatientScreen extends StatefulWidget {
  const EnhancedAddPatientScreen({super.key});

  @override
  State<EnhancedAddPatientScreen> createState() => _EnhancedAddPatientScreenState();
}

class _EnhancedAddPatientScreenState extends State<EnhancedAddPatientScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _insuranceNumberController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();

  DateTime? _selectedDateOfBirth;
  String _selectedGender = 'Male';
  String _selectedBloodType = 'O+';
  String _selectedMaritalStatus = 'Single';
  String _selectedInsuranceProvider = AppConstants.globalInsuranceProviders.first;
  File? _selectedImage;
  bool _isLoading = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _maritalStatuses = ['Single', 'Married', 'Divorced', 'Widowed'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _insuranceNumberController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Patient'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _savePatient,
          ),
        ],
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
                    _buildPhotoSection(),
                    const SizedBox(height: 24),
                    _buildPersonalInfoSection(),
                    const SizedBox(height: 24),
                    _buildContactInfoSection(),
                    const SizedBox(height: 24),
                    _buildMedicalInfoSection(),
                    const SizedBox(height: 24),
                    _buildInsuranceInfoSection(),
                    const SizedBox(height: 24),
                    _buildEmergencyContactSection(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPhotoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Patient Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 2),
                  color: Colors.grey[100],
                ),
                child: _selectedImage != null
                    ? ClipOval(
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Add Photo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                GestureDetector(
                  onTap: _selectDateOfBirth,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _selectedDateOfBirth != null
                          ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                          : 'Select Date',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender *',
                    border: OutlineInputBorder(),
                  ),
                  items: _genders.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedBloodType,
                  decoration: const InputDecoration(
                    labelText: 'Blood Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _bloodTypes.map((bloodType) {
                    return DropdownMenuItem(
                      value: bloodType,
                      child: Text(bloodType),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBloodType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedMaritalStatus,
                  decoration: const InputDecoration(
                    labelText: 'Marital Status',
                    border: OutlineInputBorder(),
                  ),
                  items: _maritalStatuses.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMaritalStatus = value!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medical Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _medicalHistoryController,
              decoration: const InputDecoration(
                labelText: 'Medical History',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services),
                hintText: 'Previous illnesses, surgeries, etc.',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _allergiesController,
              decoration: const InputDecoration(
                labelText: 'Allergies',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.warning),
                hintText: 'Known allergies to medications, foods, etc.',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _medicationsController,
              decoration: const InputDecoration(
                labelText: 'Current Medications',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
                hintText: 'Current medications and dosages',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Insurance Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedInsuranceProvider,
              decoration: const InputDecoration(
                labelText: 'Insurance Provider',
                border: OutlineInputBorder(),
              ),
              items: AppConstants.globalInsuranceProviders.map((provider) {
                return DropdownMenuItem(
                  value: provider,
                  child: Text(provider),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedInsuranceProvider = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _insuranceNumberController,
              decoration: const InputDecoration(
                labelText: 'Policy / Member ID (international)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.policy),
                hintText: 'e.g. member ID, group number, country',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Health insurance only — lab payments (Cash / Card) are under Payments → Process Payment.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Contact',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emergencyContactController,
              decoration: const InputDecoration(
                labelText: 'Emergency Contact Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.emergency),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emergencyPhoneController,
              decoration: const InputDecoration(
                labelText: 'Emergency Contact Phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _savePatient,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Save Patient'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    if (!mounted) return;
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from library'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
    if (source == null || !mounted) return;
    await _pickImageFromSource(source);
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      if (!await ensureImageSourcePermission(source)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission is required to take photos'),
            ),
          );
        }
        return;
      }
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        requestFullMetadata: false,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (!mounted) return;
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message?.isNotEmpty == true
                ? e.message!
                : 'Could not open the camera or photo library.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick image: $e')),
      );
    }
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final policy = _insuranceNumberController.text.trim();
      final insuranceInfo = _selectedInsuranceProvider == 'None / Self-pay'
          ? null
          : policy.isEmpty
              ? _selectedInsuranceProvider
              : '$_selectedInsuranceProvider · $policy';

      final patient = Patient(
        patientId: DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: _nameController.text,
        dateOfBirth: _selectedDateOfBirth!,
        gender: _selectedGender,
        phone: _phoneController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        emergencyContact: _emergencyContactController.text.trim().isNotEmpty
            ? '${_emergencyContactController.text.trim()}'
            : null,
        bloodType: _selectedBloodType,
        medicalHistory: _medicalHistoryController.text.isNotEmpty ? _medicalHistoryController.text : null,
        insuranceInfo: insuranceInfo,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await Provider.of<PatientProvider>(context, listen: false).addPatient(patient);

      // Refresh all providers to ensure data sync across tabs
      if (mounted) {
        Provider.of<TestProvider>(context, listen: false).loadTests();
        Provider.of<AppointmentProvider>(context, listen: false).loadAppointments();
        Provider.of<PaymentProvider>(context, listen: false).loadPayments();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient added successfully! All tabs refreshed.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding patient: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
