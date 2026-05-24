import 'package:flutter/material.dart';
import '../services/django_api_service.dart';
import '../models/user_create_request.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _positionController = TextEditingController();
  final _employeeIdController = TextEditingController();
  
  final DjangoApiService _api = DjangoApiService();

  String? _selectedRole;
  String? _username;
  int? _userId;
  bool _isSuperuser = false;
  bool _profileFromApi = false;
  String? _selectedDepartment;
  bool _isLoading = false;
  bool _isEditing = false;

  final List<String> _roles = [
    'Administrator',
    'Doctor',
    'Lab Technician',
    'Receptionist',
    'Manager',
  ];

  final List<String> _departments = [
    'General',
    'Hematology',
    'Pathology',
    'Microbiology',
    'Biochemistry',
    'Immunology',
    'Administration',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _api.getCurrentUser();
      final first = profile['first_name']?.toString() ?? '';
      final last = profile['last_name']?.toString() ?? '';
      var name = '$first $last'.trim();
      if (name.isEmpty) {
        name = profile['username']?.toString() ?? '';
      }
      _username = profile['username']?.toString();
      _userId = JsonParse.intOrNull(profile['id']);
      _isSuperuser = profile['is_superuser'] == true;
      _emailController.text = profile['email']?.toString() ?? '';
      _nameController.text = name;

      final labUser = profile['lab_user'];
      if (labUser is Map) {
        final lu = Map<String, dynamic>.from(labUser);
        _phoneController.text = lu['phone']?.toString() ?? '';
        _departmentController.text = lu['department']?.toString() ?? '';
        _positionController.text = lu['role']?.toString() ?? '';
        _employeeIdController.text = lu['employee_id']?.toString() ?? '';
        final role = lu['role']?.toString();
        if (role != null && _roles.contains(role)) {
          _selectedRole = role;
        } else if (role != null) {
          _selectedRole = StaffRoles.labelForApiRole(role);
        }
        final dept = lu['department']?.toString();
        if (dept != null && _departments.contains(dept)) {
          _selectedDepartment = dept;
        } else if (dept != null && dept.isNotEmpty) {
          _selectedDepartment = dept;
        }
      }
      _profileFromApi = true;
    } catch (e) {
      _profileFromApi = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not load profile from API: ${e.toString().replaceAll('Exception: ', '')}. Log in and retry.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final role = StaffRoles.apiRoleForLabel(_selectedRole ?? 'Lab Technician');
      await _api.ensureMyLabProfile(
        employeeId: _employeeIdController.text.trim().isEmpty
            ? 'EMP-${_username ?? 'user'}'
            : _employeeIdController.text.trim(),
        role: role,
        department: _selectedDepartment ?? _departmentController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved to SaeedLab API'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadProfileData();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error saving profile: $e');
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
    });
    _loadProfileData(); // Reset to original values
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
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
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
                    _buildProfileHeader(),
                    const SizedBox(height: 20),
                    _buildPersonalInfoSection(),
                    const SizedBox(height: 20),
                    _buildProfessionalInfoSection(),
                    const SizedBox(height: 20),
                    _buildAccountInfoSection(),
                    if (_isEditing) ...[
                      const SizedBox(height: 30),
                      _buildActionButtons(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                _nameController.text.isNotEmpty ? _nameController.text[0] : 'U',
                style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nameController.text,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _positionController.text,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  Text(
                    _selectedDepartment ?? 'General',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
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
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email address';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Professional Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _employeeIdController,
              decoration: const InputDecoration(
                labelText: 'Employee ID *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your employee ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _positionController,
              decoration: const InputDecoration(
                labelText: 'Position *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your position';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.admin_panel_settings),
              ),
              items: _roles.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: _isEditing ? (value) {
                setState(() {
                  _selectedRole = value;
                });
              } : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your role';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              decoration: const InputDecoration(
                labelText: 'Department *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              items: _departments.map((dept) {
                return DropdownMenuItem(
                  value: dept,
                  child: Text(dept),
                );
              }).toList(),
              onChanged: _isEditing ? (value) {
                setState(() {
                  _selectedDepartment = value;
                });
              } : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your department';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New password (min 8)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm new password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    final current = currentController.text;
    final newPw = newController.text;
    if (newPw.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be at least 8 characters')),
      );
      return;
    }
    if (newPw != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _api.changePassword(current, newPw);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildAccountInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('User ID', _userId?.toString() ?? '—'),
            _buildInfoRow('Username', _username ?? '—'),
            if (_isSuperuser) _buildInfoRow('Access', 'Django superuser'),
            _buildInfoRow('API', LabApiConfig.resolvedBaseUrl),
            _buildInfoRow('Profile source', _profileFromApi ? 'SaeedLab API' : 'Not loaded'),
            _buildInfoRow('Role', _selectedRole ?? _positionController.text),
            _buildInfoRow('Status', _profileFromApi ? 'Synced' : 'Offline'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _showChangePasswordDialog,
                icon: const Icon(Icons.lock_reset),
                label: const Text('Change password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _cancelEdit,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Saving...'),
                    ],
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }
}
