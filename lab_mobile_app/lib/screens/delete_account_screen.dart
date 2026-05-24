import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/django_api_service.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmTextController = TextEditingController();
  bool _isLoading = false;
  bool _isConfirmed = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
        backgroundColor: AppConstants.errorColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppConstants.errorColor.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppConstants.errorColor,
                      size: 32,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Permanent Account Deletion',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.errorColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'This action cannot be undone. All your data will be permanently deleted.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // What will be deleted
              const Text(
                'What will be deleted:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildDeletionItem('Personal Information', 'Name, email, phone, address'),
              _buildDeletionItem('Medical Records', 'All patient data and test results'),
              _buildDeletionItem('Appointments', 'Scheduled and completed appointments'),
              _buildDeletionItem('Reports', 'All generated lab reports'),
              _buildDeletionItem('Payment History', 'Transaction records and billing info'),
              _buildDeletionItem('User Account', 'Login credentials and profile data'),

              const SizedBox(height: 32),

              // Password confirmation
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter your password to confirm',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Confirmation text
              TextFormField(
                controller: _confirmTextController,
                decoration: const InputDecoration(
                  labelText: 'Type "DELETE MY ACCOUNT" to confirm',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),
                validator: (value) {
                  if (value != 'DELETE MY ACCOUNT') {
                    return 'Please type exactly: DELETE MY ACCOUNT';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _isConfirmed = value == 'DELETE MY ACCOUNT';
                  });
                },
              ),

              const SizedBox(height: 32),

              // Alternative options
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppConstants.infoColor.withOpacity(0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppConstants.infoColor,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Alternative Options',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.infoColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Contact support at zub165@yahoo.com for data export\n'
                      '• Temporarily deactivate your account instead\n'
                      '• Request specific data deletion without full account deletion',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Delete button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isConfirmed && !_isLoading ? _deleteAccount : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.errorColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Deleting Account...'),
                          ],
                        )
                      : const Text(
                          'DELETE MY ACCOUNT PERMANENTLY',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeletionItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(
            Icons.delete_outline,
            color: AppConstants.errorColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show final confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'Are you absolutely sure you want to delete your account? This action is irreversible and all your data will be permanently lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            child: const Text('Yes, Delete Forever'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    final apiService = DjangoApiService();
    try {
      final success = await apiService.deleteCurrentUserAccount(
        _passwordController.text,
      );

      if (success && mounted) {
        // Clear local data
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logout();

        // Show success message and navigate to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to login screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppConstants.errorColor,
            duration: const Duration(seconds: 6),
          ),
        );
        if (msg.contains('Request Account Deletion')) {
          final submit = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Submit deletion request?'),
              content: const Text(
                'The server cannot delete your account immediately. '
                'You can submit a deletion request to the lab instead.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Submit request'),
                ),
              ],
            ),
          );
          if (submit == true && mounted) {
            try {
              final result = await apiService.requestAccountDeletion(
                reason: 'Requested from Delete Account screen',
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message),
                    backgroundColor: result.isSuccess ? Colors.green : Colors.orange,
                  ),
                );
              }
            } catch (reqErr) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(reqErr.toString().replaceAll('Exception: ', '')),
                    backgroundColor: AppConstants.errorColor,
                  ),
                );
              }
            }
          }
        }
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
