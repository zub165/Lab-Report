import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../models/user_create_request.dart';
import '../models/user_update_request.dart';
import '../services/django_api_service.dart';
import '../utils/constants.dart';
import 'delete_account_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final DjangoApiService _api = DjangoApiService();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _labGroups = [];
  bool _isLoading = false;
  bool _canManageStaff = false;
  bool _isSuperuser = false;
  int? _currentUserId;
  String _currentUsername = '';
  String? _currentLabGroupName;
  String? _selectedGroupFilter;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileAndUsers();
    });
  }

  Future<void> _loadProfileAndUsers() async {
    try {
      final profile = await DjangoApiService().getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUserId = JsonParse.intOrNull(profile['id']);
          _currentUsername =
              profile['username']?.toString() ?? context.read<AuthProvider>().username ?? '';
          _canManageStaff = DjangoApiService.profileCanManageStaff(profile);
          _isSuperuser = profile['is_superuser'] == true;
          final lp = profile['lab_profile'];
          if (lp is Map) {
            final u = User.fromJson({'lab_profile': lp, 'id': profile['id']});
            _currentLabGroupName = u.labGroupName;
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _canManageStaff = false);
    }
    await _loadLabGroups();
    await _loadUsers();
  }

  Future<void> _loadLabGroups() async {
    try {
      final groups = await _api.getLabGroups();
      if (mounted) setState(() => _labGroups = groups);
    } catch (_) {
      if (mounted) setState(() => _labGroups = []);
    }
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<UserProvider>();
      await provider.loadUsers();
      setState(() {
        _users = provider.users.map(_userToRow).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error loading users: $e');
    }
  }

  Map<String, dynamic> _userToRow(User u) {
    return {
      'id': u.id,
      'user': u,
      'name': u.fullName.isNotEmpty ? u.fullName : u.username,
      'email': u.email,
      'role': u.roleDisplayName,
      'apiRole': u.role,
      'department': u.departmentFromProfile ?? '—',
      'labGroup': u.labGroupDisplay,
      'labGroupId': u.labGroupId,
      'status': u.isActive ? 'Active' : 'Inactive',
      'lastLogin': u.lastLogin?.toString().split(' ').first ?? '—',
    };
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_selectedGroupFilter == null || _selectedGroupFilter!.isEmpty) {
      return _users;
    }
    final branch = _labGroupMapByName(_selectedGroupFilter!);
    final branchId = branch?['id']?.toString();
    return _users.where((u) {
      if (branchId != null && branchId.isNotEmpty) {
        return u['labGroupId']?.toString() == branchId;
      }
      return u['labGroup']?.toString() == _selectedGroupFilter;
    }).toList();
  }

  String _branchBucketForUser(Map<String, dynamic> u) {
    final gid = u['labGroupId']?.toString();
    if (gid != null && gid.isNotEmpty) {
      for (final g in _labGroups) {
        if (g['id']?.toString() == gid) {
          return (g['name'] ?? g['id']).toString();
        }
      }
    }
    final label = u['labGroup']?.toString();
    if (label != null && label.isNotEmpty && label != 'Default lab group') {
      return label;
    }
    return 'Default lab group';
  }

  Map<String, List<Map<String, dynamic>>> get _usersByLabGroup {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final g in _labGroups) {
      final name = (g['name'] ?? g['id']).toString();
      map[name] = [];
    }
    for (final u in _filteredUsers) {
      final key = _branchBucketForUser(u);
      map.putIfAbsent(key, () => []).add(u);
    }
    return map;
  }

  Map<String, dynamic>? _labGroupMapByName(String name) {
    for (final g in _labGroups) {
      if ((g['name'] ?? '').toString() == name) return g;
    }
    return null;
  }

  Future<void> _editLabGroup(Map<String, dynamic> group) async {
    if (!_canManageStaff) return;
    final id = group['id']?.toString();
    if (id == null || id.isEmpty) {
      _showErrorDialog('Cannot edit — missing lab group id');
      return;
    }
    final nameController = TextEditingController(text: group['name']?.toString() ?? '');
    var isActive = group['is_active'] != false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit lab branch'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Branch name',
                  border: OutlineInputBorder(),
                ),
              ),
              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Inactive branches hide from registration'),
                value: isActive,
                onChanged: (v) => setDialogState(() => isActive = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (ok != true || nameController.text.trim().isEmpty) return;
    try {
      await _api.updateLabGroup(
        id: id,
        name: nameController.text.trim(),
        isActive: isActive,
      );
      await _loadLabGroups();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lab branch updated'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) _showErrorDialog('$e');
    }
  }

  Future<void> _deleteLabGroup(Map<String, dynamic> group) async {
    if (!_canManageStaff) return;
    final id = group['id']?.toString();
    final name = group['name']?.toString() ?? 'this branch';
    if (id == null || id.isEmpty) {
      _showErrorDialog('Cannot delete — missing lab group id');
      return;
    }
    final staffHere = _users.where((u) => u['labGroupId']?.toString() == id).length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete lab branch'),
        content: Text(
          staffHere > 0
              ? 'Delete "$name"? It has $staffHere staff — server may reject if not empty. '
                  '${_isSuperuser ? "" : "Only platform superuser can delete on some servers."}'
              : 'Delete "$name"? This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _api.deleteLabGroup(id);
      await _loadLabGroups();
      await _loadUsers();
      if (mounted) {
        setState(() {
          if (_selectedGroupFilter == name) _selectedGroupFilter = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lab branch deleted'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) _showErrorDialog('$e');
    }
  }

  Future<void> _addLabBranch() async {
    if (!_canManageStaff) return;
    final nameController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add lab branch'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Branch / location name',
            hintText: 'North Campus Lab',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Create')),
        ],
      ),
    );
    if (ok != true || nameController.text.trim().isEmpty) return;
    try {
      await _api.createLabGroup(name: nameController.text.trim());
      await _loadLabGroups();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lab branch created — assign staff to it when adding users')),
        );
      }
    } catch (e) {
      if (mounted) _showErrorDialog('$e');
    }
  }

  Future<void> _addUser({String? labGroupId}) async {
    if (!_canManageStaff) {
      _showErrorDialog(
        'Only admin can add staff.\n\n'
        'Log out → Login screen → tap “Sign in as Admin”\n'
        '(admin / admin123, user ID 1)',
      );
      return;
    }

    final request = await _showStaffFormDialog(
      title: 'Add staff account',
      initialLabGroupId: labGroupId,
    );
    if (request == null || !mounted) return;

    final provider = context.read<UserProvider>();
    final ok = await provider.createUser(request);
    if (!mounted) return;

    if (ok) {
      await _loadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Staff created — they can log in on the lab login screen.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final err = provider.error ?? 'Could not create staff account';
      _showErrorDialog(
        err.contains('Exception: ')
            ? err.replaceAll('Exception: ', '')
            : err,
      );
    }
  }

  Future<void> _editUser(Map<String, dynamic> user) async {
    final u = user['user'] as User?;
    if (u?.id == null) {
      _showErrorDialog('Cannot edit — missing server user id');
      return;
    }
    final result = await _showEditUserDialog(user);
    if (result == null || !mounted) return;

    final provider = context.read<UserProvider>();
    final ok = await provider.updateUser(
      u!.id!,
      UserUpdateRequest(
        email: result['email'] as String?,
        role: result['apiRole'] as String?,
        isActive: result['isActive'] as bool?,
        labGroupId: result['labGroupId'] as String?,
      ),
    );
    if (!mounted) return;
    if (ok) {
      await _loadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Staff updated'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showErrorDialog(provider.error ?? 'Update failed');
    }
  }

  Future<void> _moveUserToLabGroup(Map<String, dynamic> user) async {
    if (!_canManageStaff) return;
    final u = user['user'] as User?;
    if (u?.id == null) {
      _showErrorDialog('Cannot move — missing server user id');
      return;
    }
    if (_labGroups.length < 2) {
      _showErrorDialog(
        'Add at least two lab branches first (Add branch), then you can move staff between them.',
        title: 'Need another branch',
      );
      return;
    }

    final currentId = user['labGroupId'] as String?;
    final currentName = user['labGroup']?.toString() ?? 'Default lab group';
    String? targetId = _labGroups
        .where((g) => g['id']?.toString() != currentId)
        .map((g) => g['id']?.toString())
        .firstWhere((id) => id != null && id.isNotEmpty, orElse: () => null);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Move ${user['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'From: $currentName',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: targetId,
                decoration: const InputDecoration(
                  labelText: 'Move to lab branch',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.swap_horiz),
                ),
                items: _labGroups
                    .where((g) => g['id']?.toString() != currentId)
                    .map((g) => DropdownMenuItem(
                          value: g['id']?.toString(),
                          child: Text(g['name']?.toString() ?? '${g['id']}'),
                        ))
                    .toList(),
                onChanged: (v) => setDialogState(() => targetId = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Move')),
          ],
        ),
      ),
    );

    if (ok != true || targetId == null || targetId!.isEmpty || !mounted) return;

    final targetName = _labGroups
        .where((g) => g['id']?.toString() == targetId)
        .map((g) => g['name']?.toString())
        .firstWhere((n) => n != null && n.isNotEmpty, orElse: () => 'branch');

    final provider = context.read<UserProvider>();
    final moved = await provider.updateUser(
      u!.id!,
      UserUpdateRequest(labGroupId: targetId),
    );
    if (!mounted) return;
    if (moved) {
      await _loadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user['name']} moved to $targetName'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showErrorDialog(provider.error ?? 'Move failed');
    }
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final u = user['user'] as User?;
    if (u?.id == null) {
      _showErrorDialog('Cannot delete — missing server user id');
      return;
    }
    if (u!.id == _currentUserId) {
      _showErrorDialog('You cannot delete your own admin account while logged in.');
      return;
    }
    final confirmed = await _showDeleteConfirmationDialog(user['name']);
    if (confirmed != true || !mounted) return;

    final provider = context.read<UserProvider>();
    final ok = await provider.deleteUser(u!.id!);
    if (!mounted) return;
    if (ok) {
      await _loadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Staff account removed'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showErrorDialog(provider.error ?? 'Delete failed');
    }
  }

  Future<UserCreateRequest?> _showStaffFormDialog({
    required String title,
    String? initialLabGroupId,
  }) async {
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController(text: '03000000000');
    final passwordController = TextEditingController(text: StaffFormDefaults.suggestPassword());
    final usernameController = TextEditingController();
    final employeeIdController = TextEditingController(text: StaffFormDefaults.suggestEmployeeId());

    String selectedRole = 'lab_technician';
    String? selectedLabGroupId = initialLabGroupId ??
        (_labGroups.isNotEmpty
            ? (_labGroups.firstWhere(
                  (g) => g['name']?.toString() == _currentLabGroupName,
                  orElse: () => _labGroups.first,
                )['id']
                ?.toString())
            : null);
    String? dialogError;
    var showMore = false;

    void applyEmailDefaults(void Function(void Function()) setDialogState) {
      final email = emailController.text.trim();
      if (email.contains('@')) {
        usernameController.text = StaffFormDefaults.usernameFromEmail(email);
      }
      if (employeeIdController.text.trim().isEmpty ||
          employeeIdController.text.startsWith('EMP-')) {
        employeeIdController.text = StaffFormDefaults.suggestEmployeeId();
      }
      setDialogState(() {});
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: MediaQuery.of(ctx).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Fill 4 fields — we fill the rest automatically.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  if (dialogError != null) ...[
                    const SizedBox(height: 8),
                    Text(dialogError!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: fullNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Full name *',
                      hintText: 'Dr Ali Khan',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      hintText: 'ali@lab.com',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    onChanged: (_) => applyEmailDefaults(setDialogState),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    items: StaffRoles.options
                        .map((o) => DropdownMenuItem(value: o['value'], child: Text(o['label']!)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedRole = v ?? 'lab_technician'),
                  ),
                  if (_labGroups.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedLabGroupId,
                      decoration: const InputDecoration(
                        labelText: 'Lab branch (chain)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_tree),
                      ),
                      items: _labGroups
                          .map((g) => DropdownMenuItem(
                                value: g['id']?.toString(),
                                child: Text(g['name']?.toString() ?? '${g['id']}'),
                              ))
                          .toList(),
                      onChanged: (v) => setDialogState(() => selectedLabGroupId = v),
                    ),
                  ],
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ActionChip(
                        label: const Text('Suggested password'),
                        onPressed: () {
                          passwordController.text = StaffFormDefaults.suggestPassword();
                          setDialogState(() {});
                        },
                      ),
                      ActionChip(
                        label: const Text('New employee ID'),
                        onPressed: () {
                          employeeIdController.text = StaffFormDefaults.suggestEmployeeId();
                          setDialogState(() {});
                        },
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: const Text('More options', style: TextStyle(fontSize: 14)),
                    initiallyExpanded: showMore,
                    onExpansionChanged: (v) => setDialogState(() => showMore = v),
                    children: [
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Login password (min 8)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: employeeIdController,
                        decoration: const InputDecoration(
                          labelText: 'Employee ID',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final full = fullNameController.text.trim();
                final email = emailController.text.trim();
                final phone = phoneController.text.trim();
                final password = passwordController.text;
                var username = usernameController.text.trim();
                var empId = employeeIdController.text.trim();

                String? err;
                if (full.isEmpty) {
                  err = 'Enter full name (e.g. Dr Ali Khan).';
                } else if (!email.contains('@')) {
                  err = 'Enter a valid email.';
                } else if (phone.isEmpty) {
                  err = 'Enter phone number.';
                } else if (password.length < 8) {
                  err = 'Password must be at least 8 characters.';
                }

                if (err != null) {
                  setDialogState(() => dialogError = err);
                  return;
                }

                if (username.isEmpty) {
                  username = StaffFormDefaults.usernameFromEmail(email);
                }
                if (username.contains(' ')) {
                  setDialogState(() => dialogError = 'Username cannot contain spaces.');
                  return;
                }
                if (empId.isEmpty) {
                  empId = StaffFormDefaults.suggestEmployeeId();
                }

                usernameController.text = username;
                employeeIdController.text = empId;
                Navigator.pop(ctx, true);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result != true) return null;

    final names = StaffFormDefaults.splitFullName(fullNameController.text);
    final today = DateTime.now();
    final hireDate =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return UserCreateRequest(
      username: usernameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      firstName: names.first,
      lastName: names.last,
      employeeId: employeeIdController.text.trim(),
      role: StaffRoles.apiRoleForAny(selectedRole),
      department: 'Laboratory',
      phone: phoneController.text.trim(),
      address: 'Laboratory',
      hireDate: hireDate,
      labGroupId: selectedLabGroupId,
    );
  }

  Future<Map<String, dynamic>?> _showEditUserDialog(Map<String, dynamic> user) async {
    final emailController = TextEditingController(text: user['email']);
    bool isActive = user['status'] == 'Active';
    final apiRole = user['apiRole'] as String? ?? user['role'] as String?;
    String selectedRole = StaffRoles.apiRoleForAny(apiRole);
    String? selectedLabGroupId = user['labGroupId'] as String?;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Edit ${user['name']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: StaffRoles.apiRoleForAny(selectedRole),
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: StaffRoles.options
                      .map((o) => DropdownMenuItem(
                            value: o['value'],
                            child: Text(o['label']!),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedRole = v ?? 'lab_technician'),
                ),
                if (_labGroups.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedLabGroupId,
                    decoration: const InputDecoration(
                      labelText: 'Lab branch',
                      border: OutlineInputBorder(),
                    ),
                    items: _labGroups
                        .map((g) => DropdownMenuItem(
                              value: g['id']?.toString(),
                              child: Text(g['name']?.toString() ?? '${g['id']}'),
                            ))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedLabGroupId = v),
                  ),
                ],
                SwitchListTile(
                  title: const Text('Authorized / active'),
                  subtitle: const Text('Can sign in to the lab app'),
                  value: isActive,
                  onChanged: (v) => setDialogState(() => isActive = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return null;
    return {
      'email': emailController.text.trim(),
      'role': StaffRoles.labelForApiRole(selectedRole),
      'apiRole': StaffRoles.apiRoleForAny(selectedRole),
      'isActive': isActive,
      'labGroupId': selectedLabGroupId,
    };
  }

  void _showErrorDialog(String message, {String title = 'Error'}) {
    final text = message.replaceAll('Exception: ', '').trim();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(String userName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete $userName? This action cannot be undone.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff — Doctors & Lab Techs'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_remove),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DeleteAccountScreen(),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Lab chain (${_labGroups.length} branches · ${_users.length} staff)',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_canManageStaff)
                            FilledButton.icon(
                              onPressed: () => _addUser(),
                              icon: const Icon(Icons.person_add),
                              label: const Text('Quick add'),
                            ),
                          if (_canManageStaff)
                            OutlinedButton.icon(
                              onPressed: _addLabBranch,
                              icon: const Icon(Icons.add_business),
                              label: const Text('Add branch'),
                            ),
                        ],
                      ),
                      if (_labGroups.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('All branches'),
                                selected: _selectedGroupFilter == null,
                                onSelected: (_) => setState(() => _selectedGroupFilter = null),
                              ),
                              ..._labGroups.map((g) {
                                final name = g['name']?.toString() ?? '';
                                return Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: FilterChip(
                                    label: Text(name),
                                    selected: _selectedGroupFilter == name,
                                    onSelected: (_) => setState(() => _selectedGroupFilter = name),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                      if (_canManageStaff && _labGroups.length < 2)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Tip: tap Add branch to create a second location — then use ⋮ → Move to other branch on any staff card.',
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        _canManageStaff
                            ? 'Admin: $_currentUsername (ID ${_currentUserId ?? "—"})'
                                '${_currentLabGroupName != null ? " · ${_currentLabGroupName!}" : ""}'
                                ' — staff grouped by lab branch.'
                            : 'Not admin — log out and use “Sign in as Admin” on login.',
                        style: TextStyle(
                          fontSize: 12,
                          color: _canManageStaff ? Colors.green.shade800 : Colors.orange.shade900,
                        ),
                      ),
                      if (_canManageStaff && _labGroups.length < 2)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Tip: tap Add branch to create a second location — then ⋮ → Move to other branch on any staff card.',
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_users.isEmpty)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.badge_outlined,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text(
                              'No staff loaded',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap Add staff to create a Doctor, Lab Tech, or Receptionist account.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _loadUsers,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh from API'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                Expanded(
                  child: ListView(
                    children: [
                      if (_canManageStaff && _labGroups.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Text(
                            'Lab groups (branches)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        ..._labGroups.map((g) {
                          final name = g['name']?.toString() ?? 'Branch';
                          final id = g['id']?.toString();
                          final count = _users.where((u) => u['labGroupId'] == id).length;
                          final active = g['is_active'] != false;
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: Icon(
                                Icons.account_tree,
                                color: active ? AppConstants.primaryColor : Colors.grey,
                              ),
                              title: Text(name),
                              subtitle: Text(
                                active ? '$count staff · ID ${id ?? "—"}' : 'Inactive branch',
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _editLabGroup(g);
                                  } else if (value == 'delete') {
                                    _deleteLabGroup(g);
                                  } else if (value == 'add_staff' && id != null) {
                                    _addUser(labGroupId: id);
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                    value: 'add_staff',
                                    child: Row(
                                      children: [
                                        Icon(Icons.person_add),
                                        SizedBox(width: 8),
                                        Text('Add staff here'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        SizedBox(width: 8),
                                        Text('Edit branch'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete branch'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const Divider(height: 24),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Text(
                            'Staff by branch',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                      for (final entry in _usersByLabGroup.entries)
                        ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                            child: Row(
                              children: [
                                Icon(Icons.location_city,
                                    size: 20, color: AppConstants.primaryColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Chip(
                                  label: Text('${entry.value.length} staff'),
                                  visualDensity: VisualDensity.compact,
                                ),
                                if (_canManageStaff)
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, size: 20),
                                    onSelected: (value) {
                                      final g = _labGroupMapByName(entry.key);
                                      if (g == null) return;
                                      if (value == 'edit') {
                                        _editLabGroup(g);
                                      } else if (value == 'delete') {
                                        _deleteLabGroup(g);
                                      } else if (value == 'add_staff') {
                                        _addUser(labGroupId: g['id']?.toString());
                                      }
                                    },
                                    itemBuilder: (ctx) => const [
                                      PopupMenuItem(
                                        value: 'add_staff',
                                        child: Text('Add staff'),
                                      ),
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit branch'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete branch'),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          if (entry.value.isEmpty && _canManageStaff)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final g = _labGroupMapByName(entry.key);
                                  _addUser(labGroupId: g?['id']?.toString());
                                },
                                icon: const Icon(Icons.person_add),
                                label: Text('Add staff to ${entry.key}'),
                              ),
                            ),
                          ...entry.value.map((user) => Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: ListTile(
                                  isThreeLine: true,
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        user['status'] == 'Active' ? Colors.green : Colors.grey,
                                    child: Text(
                                      (user['name'] as String)[0],
                                      style: const TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(
                                    user['name'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${user['role']} • ${user['labGroup']}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Last login: ${user['lastLogin']}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  trailing: _canManageStaff
                                      ? PopupMenuButton<String>(
                                          onSelected: (value) {
                                            switch (value) {
                                              case 'edit':
                                                _editUser(user);
                                                break;
                                              case 'move':
                                                _moveUserToLabGroup(user);
                                                break;
                                              case 'delete':
                                                _deleteUser(user);
                                                break;
                                            }
                                          },
                                          itemBuilder: (context) => [
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
                                              value: 'move',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.swap_horiz),
                                                  SizedBox(width: 8),
                                                  Text('Move to other branch'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete, color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text('Delete'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : null,
                                ),
                              )),
                        ],
                      if (_users.isEmpty && _labGroups.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No lab branches or staff yet. Tap Add branch to start your chain.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}