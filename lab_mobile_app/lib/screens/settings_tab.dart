import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/tab_helpers.dart';
import 'laboratory_info_screen.dart';
import 'user_management_screen.dart';
import 'appointment_scheduling_screen.dart';
import 'advanced_report_screen.dart';
import 'analytics_dashboard_screen.dart';
import 'api_connection_screen.dart';
import 'database_excel_screen.dart';
import 'theme_selection_screen.dart';
import 'language_selection_screen.dart';
import 'profile_screen.dart';
import 'delete_account_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().getText;
    return Scaffold(
      appBar: AppBar(
        title: Text(t('settings')),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
          _buildSettingsSection(
            context,
            t('section_laboratory'),
            [
              _buildSettingsTile(
                context,
                t('laboratory_information'),
                'Currency, patient Stripe (per lab branch), app subscription, lab details',
                Icons.business,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LaboratoryInfoScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                context,
                t('user_management'),
                t('manage_users'),
                Icons.people,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserManagementScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                context,
                t('schedule_appointment'),
                t('schedule_new_appointments'),
                Icons.calendar_today,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppointmentSchedulingScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                context,
                t('generate_report'),
                t('generate_new_reports'),
                Icons.assessment,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdvancedReportScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                context,
                t('analytics_charts'),
                t('analytics_subtitle'),
                Icons.bar_chart,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnalyticsDashboardScreen(),
                  ),
                ),
              ),
                        ],
                      ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            t('section_system'),
            [
              _buildSettingsTile(
                context,
                t('api_connection'),
                t('test_backend'),
                Icons.cloud,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ApiConnectionScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                context,
                t('database_management'),
                t('manage_local_db'),
                Icons.storage,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DatabaseExcelScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                context,
                t('theme_selection'),
                t('choose_theme'),
                Icons.palette,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThemeSelectionScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                context,
                t('language_selection'),
                t('choose_language'),
                Icons.language,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageSelectionScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            t('section_account'),
            [
              _buildSettingsTile(
                context,
                t('privacy_policy'),
                t('privacy_subtitle'),
                Icons.privacy_tip,
                () => Navigator.pushNamed(context, '/privacy'),
              ),
              _buildSettingsTile(
                context,
                t('terms_of_service'),
                t('terms_subtitle'),
                Icons.description,
                () => Navigator.pushNamed(context, '/terms'),
              ),
              _buildSettingsTile(
                context,
                t('profile'),
                t('profile_subtitle'),
                Icons.person,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                context,
                t('delete_account'),
                t('delete_account_subtitle'),
                Icons.person_remove,
                () => _showDeleteAccountDialog(context),
                isDestructive: true,
              ),
              _buildSettingsTile(
                context,
                t('request_deletion'),
                t('request_deletion_subtitle'),
                Icons.delete_forever,
                () => runAccountDeletionRequest(context),
                isDestructive: true,
              ),
              _buildSettingsTile(
                context,
                t('export_my_data'),
                t('export_subtitle'),
                Icons.download,
                () => runLabDataExport(context),
              ),
              _buildSettingsTile(
                context,
                t('logout'),
                t('logout_subtitle'),
                Icons.logout,
                () => _showLogoutDialog(context),
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, String title, List<Widget> children) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
                    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppConstants.primaryColor,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
        content: Text('$feature functionality - Coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'You can delete your account and all associated data. This action is permanent and cannot be undone.\n\n'
          'Would you like to proceed to the account deletion screen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeleteAccountScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}
