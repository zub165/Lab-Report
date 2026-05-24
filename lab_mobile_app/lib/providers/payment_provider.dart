import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../services/django_api_service.dart';
import '../utils/constants.dart';
import '../services/local_storage_service.dart';

class PaymentProvider extends ChangeNotifier {
  final DjangoApiService _apiService = DjangoApiService();
  
  List<Payment> _payments = [];
  Payment? _selectedPayment;
  bool _isLoading = false;
  String? _error;

  List<Payment> get payments => _payments;
  Payment? get selectedPayment => _selectedPayment;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered lists
  List<Payment> get completedPayments => _payments.where((payment) => payment.isCompleted).toList();
  List<Payment> get pendingPayments => _payments.where((payment) => payment.isPending).toList();
  List<Payment> get failedPayments => _payments.where((payment) => payment.isFailed).toList();
  List<Payment> get refundedPayments => _payments.where((payment) => payment.isRefunded).toList();
  List<Payment> get cancelledPayments => _payments.where((payment) => payment.isCancelled).toList();
  
  List<Payment> get todayPayments => _payments.where((payment) {
    final today = DateTime.now();
    return payment.paymentDate.year == today.year &&
           payment.paymentDate.month == today.month &&
           payment.paymentDate.day == today.day;
  }).toList();
  
  List<Payment> get pastPayments => _payments.where((payment) => payment.paymentDate.isBefore(DateTime.now())).toList();
  List<Payment> get futurePayments => _payments.where((payment) => payment.paymentDate.isAfter(DateTime.now())).toList();

  Future<void> loadPayments() async {
    try {
      _isLoading = true;
      _error = null;
      scheduleProviderNotify(this);

      print('🔄 Loading payments from backend API...');
      
      // Try to load from backend API first
      final payments = await _apiService.getPayments();
      _payments = payments;
      
      // Save to local storage as backup
      await LocalStorageService.savePayments(payments);
      
      print('✅ Loaded ${payments.length} payments from backend API');
      _error = null;
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      print('❌ Failed to load payments from API: $msg');

      // Fallback to local storage
      try {
        print('🔄 Loading payments from local storage...');
        final localPayments = await LocalStorageService.loadPayments();
        _payments = localPayments;
        print('✅ Loaded ${localPayments.length} payments from local storage');
        _error = localPayments.isEmpty
            ? 'Could not load payments: $msg'
            : 'Using cached data — $msg';
      } catch (localError) {
        print('❌ Failed to load from local storage: $localError');
        _payments = [];
        _error = 'Failed to load payments: $e';
      }
    } finally {
      _isLoading = false;
      scheduleProviderNotify(this);
    }
  }

  Future<bool> addPayment(Payment payment) async {
    try {
      _isLoading = true;
      scheduleProviderNotify(this);

      print('🔄 Adding payment to backend API...');
      
      // Try to add to backend API first
      final newPayment = await _apiService.createPayment(payment);
      
      // Add to local list
      _payments.add(newPayment);
      
      // Update local storage
      await LocalStorageService.savePayments(_payments);
      
      print('✅ Payment added successfully to backend');
      _error = null;
      return true;
    } catch (e) {
      print('❌ Failed to add payment to API: $e');
      
      // Fallback to local storage only
      try {
        // Generate a temporary ID for local storage
        final tempPayment = payment.copyWith(
          paymentId: 'LOCAL_${DateTime.now().millisecondsSinceEpoch}',
        );
        
        _payments.add(tempPayment);
        await LocalStorageService.savePayments(_payments);
        
        print('✅ Payment added to local storage only');
        _error = 'Saved locally - Backend unavailable';
        return true;
      } catch (localError) {
        print('❌ Failed to save locally: $localError');
        _error = 'Failed to add payment: $e';
        return false;
      }
    } finally {
      _isLoading = false;
      scheduleProviderNotify(this);
    }
  }

  Future<bool> updatePayment(Payment payment) async {
    try {
      _isLoading = true;
      scheduleProviderNotify(this);

      print('🔄 Updating payment in backend API...');
      
      // Try to update in backend API first
      final pid = int.tryParse(payment.paymentId ?? '');
      if (pid == null) throw Exception('Cannot sync local payment ID to backend');
      final updatedPayment = await _apiService.updatePayment(pid, payment);
      
      // Update in local list
      final index = _payments.indexWhere((p) => p.paymentId == payment.paymentId);
      if (index != -1) {
        _payments[index] = updatedPayment;
      }
      
      // Update local storage
      await LocalStorageService.savePayments(_payments);
      
      print('✅ Payment updated successfully in backend');
      _error = null;
      return true;
    } catch (e) {
      print('❌ Failed to update payment in API: $e');
      
      // Fallback to local storage only
      try {
        final index = _payments.indexWhere((p) => p.paymentId == payment.paymentId);
        if (index != -1) {
          _payments[index] = payment;
          await LocalStorageService.savePayments(_payments);
          
          print('✅ Payment updated in local storage only');
          _error = 'Updated locally - Backend unavailable';
          return true;
        }
        return false;
      } catch (localError) {
        print('❌ Failed to update locally: $localError');
        _error = 'Failed to update payment: $e';
        return false;
      }
    } finally {
      _isLoading = false;
      scheduleProviderNotify(this);
    }
  }

  Future<bool> updatePaymentStatus(String paymentId, String status) async {
    _isLoading = true;
    _error = null;
    scheduleProviderNotify(this);

    try {
      final pid = int.tryParse(paymentId) ?? 0;
      final updatedPayment = await _apiService.updatePaymentStatus(pid, status);
      final index = _payments.indexWhere((p) => p.paymentId == paymentId);
      if (index != -1) {
        _payments[index] = updatedPayment;
      }
      // Save to local storage
      await LocalStorageService.savePayments(_payments);
      _isLoading = false;
      scheduleProviderNotify(this);
      return true;
    } catch (e) {
      _error = e.toString();
      // If API fails, update local storage only
      final index = _payments.indexWhere((p) => p.paymentId == paymentId);
      if (index != -1) {
        final updatedPayment = _payments[index].copyWith(status: status);
        _payments[index] = updatedPayment;
        await LocalStorageService.updatePayment(updatedPayment);
      }
      _isLoading = false;
      scheduleProviderNotify(this);
      return true; // Return true since we saved locally
    }
  }

  Future<bool> deletePayment(String paymentId) async {
    try {
      _isLoading = true;
      scheduleProviderNotify(this);

      print('🔄 Deleting payment from backend API...');
      
      // Try to delete from backend API first
      final pid = int.tryParse(paymentId);
      if (pid != null) await _apiService.deletePayment(pid);
      
      // Remove from local list
      _payments.removeWhere((p) => p.paymentId == paymentId);
      
      // Update local storage
      await LocalStorageService.savePayments(_payments);
      
      print('✅ Payment deleted successfully from backend');
      _error = null;
      return true;
    } catch (e) {
      print('❌ Failed to delete payment from API: $e');
      
      // Fallback to local storage only
      try {
        _payments.removeWhere((p) => p.paymentId == paymentId);
        await LocalStorageService.savePayments(_payments);
        
        print('✅ Payment deleted from local storage only');
        _error = 'Deleted locally - Backend unavailable';
        return true;
      } catch (localError) {
        print('❌ Failed to delete locally: $localError');
        _error = 'Failed to delete payment: $e';
        return false;
      }
    } finally {
      _isLoading = false;
      scheduleProviderNotify(this);
    }
  }

  Future<Payment?> getPayment(int id) async {
    try {
      final payment = await _apiService.getPayment(id);
      _selectedPayment = payment;
      scheduleProviderNotify(this);
      return payment;
    } catch (e) {
      _error = e.toString();
      scheduleProviderNotify(this);
      return null;
    }
  }

  void selectPayment(Payment payment) {
    _selectedPayment = payment;
    scheduleProviderNotify(this);
  }

  void clearSelectedPayment() {
    _selectedPayment = null;
    scheduleProviderNotify(this);
  }

  void clearError() {
    _error = null;
    scheduleProviderNotify(this);
  }

  List<Payment> searchPayments(String query) {
    if (query.isEmpty) return _payments;
    
    return _payments.where((payment) =>
      payment.paymentId?.toLowerCase().contains(query.toLowerCase()) == true ||
      payment.patientName.toLowerCase().contains(query.toLowerCase()) ||
      payment.testType.toLowerCase().contains(query.toLowerCase()) ||
      payment.testName.toLowerCase().contains(query.toLowerCase()) ||
      payment.status.toLowerCase().contains(query.toLowerCase()) ||
      payment.paymentMethod.toLowerCase().contains(query.toLowerCase()) ||
      payment.transactionId?.toLowerCase().contains(query.toLowerCase()) == true ||
      payment.receiptNumber?.toLowerCase().contains(query.toLowerCase()) == true
    ).toList();
  }

  List<Payment> getPaymentsByStatus(String status) {
    return _payments.where((payment) => payment.status == status).toList();
  }

  List<Payment> getPaymentsByMethod(String method) {
    return _payments.where((payment) => payment.paymentMethod.toLowerCase() == method.toLowerCase()).toList();
  }

  List<Payment> getPaymentsByDate(DateTime date) {
    return _payments.where((payment) => 
      payment.paymentDate.year == date.year &&
      payment.paymentDate.month == date.month &&
      payment.paymentDate.day == date.day
    ).toList();
  }

  List<Payment> getPaymentsByDateRange(DateTime startDate, DateTime endDate) {
    return _payments.where((payment) {
      return payment.paymentDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             payment.paymentDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  List<Payment> getPaymentsByTest(String testId) {
    return _payments.where((payment) => payment.testId == testId).toList();
  }

  List<Payment> getPaymentsByPatient(String patientId) {
    return _payments.where((payment) => payment.patientId == patientId).toList();
  }

  double get totalRevenue {
    return _payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  double get todayRevenue {
    return todayPayments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  Map<String, int> getPaymentStatistics() {
    return {
      'total': _payments.length,
      'completed': completedPayments.length,
      'pending': pendingPayments.length,
      'failed': failedPayments.length,
      'refunded': refundedPayments.length,
      'cancelled': cancelledPayments.length,
      'today': todayPayments.length,
      'past': pastPayments.length,
      'future': futurePayments.length,
    };
  }

  Map<String, double> getPaymentMethodStatistics() {
    final methodStats = <String, double>{};
    for (final payment in _payments) {
      final method = payment.paymentMethod.toLowerCase();
      methodStats[method] = (methodStats[method] ?? 0.0) + payment.amount;
    }
    return methodStats;
  }

  // Sorting functions
  List<Payment> getPaymentsSortedByDate({bool ascending = true}) {
    final sortedPayments = List<Payment>.from(_payments);
    if (ascending) {
      sortedPayments.sort((a, b) => a.paymentDate.compareTo(b.paymentDate));
    } else {
      sortedPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    }
    return sortedPayments;
  }

  List<Payment> getPaymentsSortedByAmount({bool ascending = true}) {
    final sortedPayments = List<Payment>.from(_payments);
    if (ascending) {
      sortedPayments.sort((a, b) => a.amount.compareTo(b.amount));
    } else {
      sortedPayments.sort((a, b) => b.amount.compareTo(a.amount));
    }
    return sortedPayments;
  }

  List<Payment> getPaymentsSortedByPatientName({bool ascending = true}) {
    final sortedPayments = List<Payment>.from(_payments);
    if (ascending) {
      sortedPayments.sort((a, b) => a.patientName.compareTo(b.patientName));
    } else {
      sortedPayments.sort((a, b) => b.patientName.compareTo(a.patientName));
    }
    return sortedPayments;
  }

  List<Payment> getPaymentsSortedByStatus({bool ascending = true}) {
    final sortedPayments = List<Payment>.from(_payments);
    if (ascending) {
      sortedPayments.sort((a, b) => a.status.compareTo(b.status));
    } else {
      sortedPayments.sort((a, b) => b.status.compareTo(a.status));
    }
    return sortedPayments;
  }

  List<Payment> getPaymentsSortedByMethod({bool ascending = true}) {
    final sortedPayments = List<Payment>.from(_payments);
    if (ascending) {
      sortedPayments.sort((a, b) => a.paymentMethod.compareTo(b.paymentMethod));
    } else {
      sortedPayments.sort((a, b) => b.paymentMethod.compareTo(a.paymentMethod));
    }
    return sortedPayments;
  }
}
