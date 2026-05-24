import 'package:flutter/foundation.dart';
import '../models/test.dart';
import '../services/django_api_service.dart';
import '../services/local_storage_service.dart';
import '../utils/constants.dart';

class TestProvider with ChangeNotifier {
  final DjangoApiService _apiService = DjangoApiService();
  
  List<Test> _tests = [];
  Test? _selectedTest;
  bool _isLoading = false;
  String? _error;

  List<Test> get tests => _tests;
  Test? get selectedTest => _selectedTest;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Test> get completedTests => _tests.where((test) => test.status.toLowerCase() == 'completed').toList();
  List<Test> get pendingTests => _tests.where((test) => test.status.toLowerCase() == 'pending').toList();
  List<Test> get inProgressTests => _tests.where((test) => test.status.toLowerCase() == 'in progress').toList();
  List<Test> get urgentTests => _tests.where((test) => test.status.toLowerCase() == 'urgent').toList();

  Future<void> loadTests() async {
    try {
      _isLoading = true;
      _error = null;
      scheduleProviderNotify(this);

      print('🔄 Loading tests from backend API...');
      
      // Try to load from backend API first
      final tests = await _apiService.getTests();
      _tests = tests;
      
      // Save to local storage as backup
      await LocalStorageService.saveTests(tests);
      
      print('✅ Loaded ${tests.length} tests from backend API');
      _error = null;
    } catch (e) {
      print('❌ Failed to load tests from API: $e');
      
      // Fallback to local storage
      try {
        print('🔄 Loading tests from local storage...');
        final localTests = await LocalStorageService.loadTests();
        _tests = localTests;
        print('✅ Loaded ${localTests.length} tests from local storage');
        _error = 'Using cached data - Backend unavailable';
      } catch (localError) {
        print('❌ Failed to load from local storage: $localError');
        _tests = [];
        _error = 'Failed to load tests: $e';
      }
    } finally {
      _isLoading = false;
      scheduleProviderNotify(this);
    }
  }

  Future<bool> addTest(Test test) async {
    try {
      _isLoading = true;
      scheduleProviderNotify(this);

      print('🔄 Adding test to backend API...');
      
      // Try to add to backend API first
      final newTest = await _apiService.createTest(test);
      
      // Add to local list
      _tests.add(newTest);
      
      // Update local storage
      await LocalStorageService.saveTests(_tests);
      
      print('✅ Test added successfully to backend');
      _error = null;
      return true;
    } catch (e) {
      print('❌ Failed to add test to API: $e');
      
      // Fallback to local storage only
      try {
        // Generate a temporary ID for local storage
        final tempTest = test.copyWith(
          testId: 'LOCAL_${DateTime.now().millisecondsSinceEpoch}',
        );
        
        _tests.add(tempTest);
        await LocalStorageService.saveTests(_tests);
        
        print('✅ Test added to local storage only');
        _error = 'Saved locally - Backend unavailable';
        return true;
      } catch (localError) {
        print('❌ Failed to save locally: $localError');
        _error = 'Failed to add test: $e';
        return false;
      }
    } finally {
      _isLoading = false;
      scheduleProviderNotify(this);
    }
  }

  Future<bool> updateTest(Test test) async {
    try {
      _isLoading = true;
      scheduleProviderNotify(this);

      print('🔄 Updating test in backend API...');
      
      // Try to update in backend API first
      final updatedTest = await _apiService.updateTest(test.testId!, test);
      
      // Update in local list
      final index = _tests.indexWhere((t) => t.testId == test.testId);
      if (index != -1) {
        _tests[index] = updatedTest;
      }
      
      // Update local storage
      await LocalStorageService.saveTests(_tests);
      
      print('✅ Test updated successfully in backend');
      _error = null;
      return true;
    } catch (e) {
      print('❌ Failed to update test in API: $e');
      
      // Fallback to local storage only
      try {
        final index = _tests.indexWhere((t) => t.testId == test.testId);
        if (index != -1) {
          _tests[index] = test;
          await LocalStorageService.saveTests(_tests);
          
          print('✅ Test updated in local storage only');
          _error = 'Updated locally - Backend unavailable';
          return true;
        }
        return false;
      } catch (localError) {
        print('❌ Failed to update locally: $localError');
        _error = 'Failed to update test: $e';
        return false;
      }
    } finally {
      _isLoading = false;
      scheduleProviderNotify(this);
    }
  }

  Future<bool> deleteTest(String testId) async {
    try {
      _isLoading = true;
      scheduleProviderNotify(this);

      print('🔄 Deleting test from backend API...');
      
      // Try to delete from backend API first
      await _apiService.deleteTest(testId);
      
      // Remove from local list
      _tests.removeWhere((t) => t.testId == testId);
      
      // Update local storage
      await LocalStorageService.saveTests(_tests);
      
      print('✅ Test deleted successfully from backend');
      _error = null;
      return true;
    } catch (e) {
      print('❌ Failed to delete test from API: $e');
      
      // Fallback to local storage only
      try {
        _tests.removeWhere((t) => t.testId == testId);
        await LocalStorageService.saveTests(_tests);
        
        print('✅ Test deleted from local storage only');
        _error = 'Deleted locally - Backend unavailable';
        return true;
      } catch (localError) {
        print('❌ Failed to delete locally: $localError');
        _error = 'Failed to delete test: $e';
        return false;
      }
    } finally {
      _isLoading = false;
      scheduleProviderNotify(this);
    }
  }

  Future<bool> updateTestStatus(String testId, String status) async {
    _isLoading = true;
    _error = null;
    scheduleProviderNotify(this);

    try {
      final updatedTest = await _apiService.updateTestStatus(testId, status);
      final index = _tests.indexWhere((t) => t.testId == testId);
      if (index != -1) {
        _tests[index] = updatedTest;
      }
      // Save to local storage
      await LocalStorageService.saveTests(_tests);
      _isLoading = false;
      scheduleProviderNotify(this);
      return true;
    } catch (e) {
      _error = e.toString();
      // If API fails, update local storage only
      final index = _tests.indexWhere((t) => t.testId == testId);
      if (index != -1) {
        final updatedTest = _tests[index].copyWith(status: status);
        _tests[index] = updatedTest;
        await LocalStorageService.updateTest(updatedTest);
      }
      _isLoading = false;
      scheduleProviderNotify(this);
      return true; // Return true since we saved locally
    }
  }

  void selectTest(Test test) {
    _selectedTest = test;
    scheduleProviderNotify(this);
  }

  void clearSelectedTest() {
    _selectedTest = null;
    scheduleProviderNotify(this);
  }

  void clearError() {
    _error = null;
    scheduleProviderNotify(this);
  }

  Map<String, int> getTestStatistics() {
    return {
      'total': _tests.length,
      'completed': completedTests.length,
      'pending': pendingTests.length,
      'inProgress': inProgressTests.length,
      'urgent': urgentTests.length,
    };
  }

  List<Test> searchTests(String query) {
    if (query.isEmpty) return _tests;
    
    return _tests.where((test) =>
      test.testType.toLowerCase().contains(query.toLowerCase()) ||
      test.patientName?.toLowerCase().contains(query.toLowerCase()) == true ||
      test.status.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  List<Test> getTestsByStatus(String status) {
    return _tests.where((test) => test.status.toLowerCase() == status.toLowerCase()).toList();
  }

  List<Test> getTestsByType(String testType) {
    return _tests.where((test) => test.testType.toLowerCase() == testType.toLowerCase()).toList();
  }

  List<Test> getTestsByDateRange(DateTime startDate, DateTime endDate) {
    return _tests.where((test) {
      return test.orderedDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             test.orderedDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  List<Test> getTestsByPatient(String patientId) {
    return _tests.where((test) => test.patientId == patientId).toList();
  }

  // Sorting functions
  List<Test> getTestsSortedByDate({bool ascending = true}) {
    print('getTestsSortedByDate called with ascending: $ascending, total tests: ${_tests.length}');
    final sortedTests = List<Test>.from(_tests);
    if (ascending) {
      sortedTests.sort((a, b) => a.orderedDate.compareTo(b.orderedDate));
    } else {
      sortedTests.sort((a, b) => b.orderedDate.compareTo(a.orderedDate));
    }
    print('Returning ${sortedTests.length} sorted tests');
    return sortedTests;
  }

  List<Test> getTestsSortedByName({bool ascending = true}) {
    final sortedTests = List<Test>.from(_tests);
    if (ascending) {
      sortedTests.sort((a, b) => a.testName.compareTo(b.testName));
    } else {
      sortedTests.sort((a, b) => b.testName.compareTo(a.testName));
    }
    return sortedTests;
  }

  List<Test> getTestsSortedByStatus({bool ascending = true}) {
    final sortedTests = List<Test>.from(_tests);
    if (ascending) {
      sortedTests.sort((a, b) => a.status.compareTo(b.status));
    } else {
      sortedTests.sort((a, b) => b.status.compareTo(a.status));
    }
    return sortedTests;
  }

  List<Test> getTestsSortedByPrice({bool ascending = true}) {
    final sortedTests = List<Test>.from(_tests);
    if (ascending) {
      sortedTests.sort((a, b) => a.price.compareTo(b.price));
    } else {
      sortedTests.sort((a, b) => b.price.compareTo(a.price));
    }
    return sortedTests;
  }

  List<Test> getTestsSortedByPatientName({bool ascending = true}) {
    final sortedTests = List<Test>.from(_tests);
    if (ascending) {
      sortedTests.sort((a, b) => (a.patientName ?? '').compareTo(b.patientName ?? ''));
    } else {
      sortedTests.sort((a, b) => (b.patientName ?? '').compareTo(a.patientName ?? ''));
    }
    return sortedTests;
  }
}
