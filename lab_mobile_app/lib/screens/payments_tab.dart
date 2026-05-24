import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';
import '../providers/language_provider.dart';
import '../utils/constants.dart';
import '../utils/lab_currency.dart';
import '../utils/tab_helpers.dart';
import 'comprehensive_payment_details_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().loadPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('payments')),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card),
            tooltip: 'Process payment (Cash / Card / Insurance)',
            onPressed: () async {
              final done = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const ProcessPaymentScreen()),
              );
              if (done == true && context.mounted) {
                context.read<PaymentProvider>().loadPayments();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PaymentProvider>().loadPayments(),
          ),
        ],
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.payments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null && provider.payments.isEmpty) {
            return apiTabPlaceholder(
              icon: Icons.cloud_off,
              title: context.tr('could_not_load_payments'),
              message: provider.error!,
              onRetry: () => provider.loadPayments(),
            );
          }
          if (provider.payments.isEmpty) {
            return apiTabPlaceholder(
              icon: Icons.payments_outlined,
              title: context.tr('no_payments'),
              message: context.tr('no_payments_hint'),
              onRetry: () => provider.loadPayments(),
            );
          }
          return RefreshIndicator(
            onRefresh: () => provider.loadPayments(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: provider.payments.length,
              itemBuilder: (context, index) {
                final p = provider.payments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    isThreeLine: true,
                    leading: Icon(
                      Icons.payments,
                      color: p.isCompleted ? Colors.green : Colors.orange,
                    ),
                    title: Text(
                      p.patientName ?? 'Payment #${p.paymentId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${p.testName ?? p.testType ?? 'Order'} · ${p.paymentMethod ?? '—'} · ${p.status}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        LabCurrency.formatWithSymbol(p.amount, decimals: 0),
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
