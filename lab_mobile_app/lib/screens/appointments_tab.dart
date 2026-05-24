import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/language_provider.dart';
import '../utils/constants.dart';
import '../utils/tab_helpers.dart';
import 'comprehensive_appointment_details_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('appointments')),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<AppointmentProvider>().loadAppointments(),
          ),
        ],
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.appointments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null && provider.appointments.isEmpty) {
            return apiTabPlaceholder(
              icon: Icons.cloud_off,
              title: context.tr('could_not_load_appointments'),
              message: provider.error!,
              onRetry: () => provider.loadAppointments(),
            );
          }
          if (provider.appointments.isEmpty) {
            return apiTabPlaceholder(
              icon: Icons.event_busy,
              title: context.tr('no_appointments'),
              message: context.tr('no_appointments_hint'),
              onRetry: () => provider.loadAppointments(),
            );
          }
          return RefreshIndicator(
            onRefresh: () => provider.loadAppointments(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: provider.appointments.length,
              itemBuilder: (context, index) {
                final a = provider.appointments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.15),
                      child: const Icon(Icons.event, color: AppConstants.primaryColor),
                    ),
                    title: Text(
                      a.patientName ?? 'Patient #${a.patientId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${a.testType ?? 'Test'} · ${a.appointmentDate.toString().split(' ')[0]} · ${a.status}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 72),
                      child: Text(
                        a.appointmentTime ?? '',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ComprehensiveAppointmentDetailsScreen(
                          appointmentId: a.appointmentId ?? '',
                          appointmentType: a.testType,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
