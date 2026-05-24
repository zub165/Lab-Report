import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/patient.dart';
import '../models/test.dart';
import 'django_api_service.dart';

import '../utils/constants.dart';

class SimpleHybridStorageService {
  static final SimpleHybridStorageService _instance = SimpleHybridStorageService._internal();
  factory SimpleHybridStorageService() => _instance;
  SimpleHybridStorageService._internal();

  Database? _database;
  final DjangoApiService _apiService = DjangoApiService();
  bool _isBackendAvailable = false;
  String _dbScope = '';

  // Initialize the hybrid storage
  Future<void> initialize() async {
    await LabGroupScope.loadCachedScope();
    await _initDatabase();
    await _checkBackendAvailability();
  }

  /// Re-open SQLite when admin logs into a different lab group on this device.
  Future<void> ensureLabGroupScope() async {
    await LabGroupScope.loadCachedScope();
    final scope = LabGroupScope.storageSuffix;
    if (_database != null && _dbScope == scope) return;
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    _dbScope = scope;
    await _initDatabase();
  }

  // Initialize SQLite database for local storage
  Future<void> _initDatabase() async {
    // Skip database initialization on web platform
    if (kIsWeb) {
      print('⚠️ Skipping database initialization on web platform');
      return;
    }
    
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, LabGroupScope.sqliteFileName);
    _dbScope = LabGroupScope.storageSuffix;

    _database = await openDatabase(
      path,
      version: 3, // Increment version to force recreation
      onCreate: (db, version) async {
        // Create patients table
        await db.execute('''
          CREATE TABLE patients (
            id TEXT PRIMARY KEY,
            full_name TEXT NOT NULL,
            date_of_birth TEXT,
            gender TEXT,
            phone TEXT,
            email TEXT,
            address TEXT,
            blood_type TEXT,
            medical_history TEXT,
            created_at TEXT,
            updated_at TEXT,
            synced_to_backend INTEGER DEFAULT 0,
            backend_id TEXT
          )
        ''');

        // Create tests table
        await db.execute('''
          CREATE TABLE tests (
            id TEXT PRIMARY KEY,
            patient_id TEXT NOT NULL,
            test_name TEXT NOT NULL,
            test_type TEXT NOT NULL,
            status TEXT DEFAULT 'Pending',
            ordered_date TEXT NOT NULL,
            completed_date TEXT,
            ordered_by TEXT,
            price REAL,
            notes TEXT,
            test_results TEXT,
            priority TEXT DEFAULT 'Normal',
            created_at TEXT,
            updated_at TEXT,
            synced_to_backend INTEGER DEFAULT 0,
            backend_id TEXT
          )
        ''');

        print('✅ Simple local database initialized successfully');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('🔄 Upgrading database from version $oldVersion to $newVersion');
        
        // Drop existing tables and recreate with correct schema
        await db.execute('DROP TABLE IF EXISTS tests');
        await db.execute('DROP TABLE IF EXISTS patients');
        
        // Recreate patients table
        await db.execute('''
          CREATE TABLE patients (
            id TEXT PRIMARY KEY,
            full_name TEXT NOT NULL,
            date_of_birth TEXT,
            gender TEXT,
            phone TEXT,
            email TEXT,
            address TEXT,
            blood_type TEXT,
            medical_history TEXT,
            created_at TEXT,
            updated_at TEXT,
            synced_to_backend INTEGER DEFAULT 0,
            backend_id TEXT
          )
        ''');

        // Recreate tests table with correct schema
        await db.execute('''
          CREATE TABLE tests (
            id TEXT PRIMARY KEY,
            patient_id TEXT NOT NULL,
            test_name TEXT NOT NULL,
            test_type TEXT NOT NULL,
            status TEXT DEFAULT 'Pending',
            ordered_date TEXT NOT NULL,
            completed_date TEXT,
            ordered_by TEXT,
            price REAL,
            notes TEXT,
            test_results TEXT,
            priority TEXT DEFAULT 'Normal',
            created_at TEXT,
            updated_at TEXT,
            synced_to_backend INTEGER DEFAULT 0,
            backend_id TEXT
          )
        ''');

        print('✅ Database upgraded successfully with new schema');
      },
    );
  }

  // Check if backend is available
  Future<void> _checkBackendAvailability() async {
    try {
      _isBackendAvailable = await _apiService.testBackendConnection();
      print('🌐 Backend availability: $_isBackendAvailable');
    } catch (e) {
      _isBackendAvailable = false;
      print('❌ Backend not available: $e');
    }
  }

  // ============================================================================
  // DEMO DATA FOR WEB PLATFORM
  // ============================================================================
  
  List<Patient> _getDemoPatients() {
    return [
      Patient(
        patientId: 'P001',
        fullName: 'John Doe',
        dateOfBirth: DateTime(1985, 5, 15),
        gender: 'Male',
        phone: '+1-555-0123',
        email: 'john.doe@email.com',
        address: '123 Main St, City, State',
        bloodType: 'O+',
        medicalHistory: 'No known allergies',
        insuranceInfo: 'Blue Cross Blue Shield',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        syncedToBackend: true,
      ),
      Patient(
        patientId: 'P002',
        fullName: 'Jane Smith',
        dateOfBirth: DateTime(1990, 8, 22),
        gender: 'Female',
        phone: '+1-555-0456',
        email: 'jane.smith@email.com',
        address: '456 Oak Ave, City, State',
        bloodType: 'A+',
        medicalHistory: 'Allergic to penicillin',
        insuranceInfo: 'Aetna',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
        syncedToBackend: true,
      ),
    ];
  }

  // ============================================================================
  // PATIENT MANAGEMENT
  // ============================================================================

  // Get all patients (local first, then sync from backend)
  Future<List<Patient>> getPatients() async {
    if (_isBackendAvailable || kIsWeb) {
      try {
        return await _apiService.getPatients();
      } catch (e) {
        print('⚠️ API patients failed, using local cache: $e');
      }
    }
    if (kIsWeb) return [];
    return _getLocalPatients();
  }

  // Add new patient (local first, then sync to backend)
  Future<Patient> addPatient(Patient patient) async {
    // Add to local storage immediately
    await _addLocalPatient(patient);
    print('✅ Patient added to local storage: ${patient.fullName}');

    // Try to sync to backend if available
    if (_isBackendAvailable) {
      try {
        final syncedPatient = await _apiService.createPatient(patient);
        if (patient.patientId != null && syncedPatient.patientId != null) {
          await _updateLocalPatientSyncStatus(patient.patientId!, syncedPatient.patientId!);
        }
        print('✅ Patient synced to backend: ${patient.fullName}');
        return syncedPatient;
      } catch (e) {
        print('⚠️ Backend sync failed, will retry later: $e');
        // Mark as pending sync
        if (patient.patientId != null) {
          await _markPatientForSync(patient.patientId!);
        }
      }
    } else {
      // Mark as pending sync when backend becomes available
      if (patient.patientId != null) {
        await _markPatientForSync(patient.patientId!);
      }
    }

    return patient;
  }

  // Update patient (local first, then sync to backend)
  Future<Patient> updatePatient(Patient patient) async {
    // Update local storage immediately
    await _updateLocalPatient(patient);
    print('✅ Patient updated in local storage: ${patient.fullName}');

    // Try to sync to backend if available
    if (_isBackendAvailable) {
      try {
        final syncedPatient = await _apiService.updatePatient(int.tryParse(patient.patientId ?? '') ?? 0, patient);
        print('✅ Patient update synced to backend: ${patient.fullName}');
        return syncedPatient;
      } catch (e) {
        print('⚠️ Backend sync failed, will retry later: $e');
        if (patient.patientId != null) {
          await _markPatientForSync(patient.patientId!);
        }
      }
    } else {
      if (patient.patientId != null) {
        await _markPatientForSync(patient.patientId!);
      }
    }

    return patient;
  }

  // Delete patient (local first, then sync to backend)
  Future<void> deletePatient(String patientId) async {
    // Delete from local storage immediately
    await _deleteLocalPatient(patientId);
    print('✅ Patient deleted from local storage: $patientId');

    // Try to sync to backend if available
    if (_isBackendAvailable) {
      try {
        await _apiService.deletePatient(int.tryParse(patientId) ?? 0);
        print('✅ Patient deletion synced to backend: $patientId');
      } catch (e) {
        print('⚠️ Backend sync failed, will retry later: $e');
        // Keep record for later sync
        await _markPatientForSync(patientId);
      }
    } else {
      await _markPatientForSync(patientId);
    }
  }

  // Force sync all data
  Future<void> forceSyncAll() async {
    await _checkBackendAvailability();
    await _syncPendingPatients();
  }

  // ============================================================================
  // LOCAL STORAGE METHODS
  // ============================================================================

  Future<List<Patient>> _getLocalPatients() async {
    final List<Map<String, dynamic>> maps = await _database!.query('patients');
    return List.generate(maps.length, (i) => Patient.fromLocalJson(maps[i]));
  }

  Future<void> _addLocalPatient(Patient patient) async {
    await _database!.insert('patients', patient.toLocalJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _updateLocalPatient(Patient patient) async {
    await _database!.update('patients', patient.toLocalJson(), where: 'id = ?', whereArgs: [patient.patientId]);
  }

  Future<void> _deleteLocalPatient(String patientId) async {
    await _database!.delete('patients', where: 'id = ?', whereArgs: [patientId]);
  }

  Future<void> _markPatientForSync(String patientId) async {
    await _database!.update('patients', {'synced_to_backend': 0}, where: 'id = ?', whereArgs: [patientId]);
  }

  Future<void> _updateLocalPatientSyncStatus(String localId, String backendId) async {
    await _database!.update('patients', {'synced_to_backend': 1, 'backend_id': backendId}, where: 'id = ?', whereArgs: [localId]);
  }

  // ============================================================================
  // MERGE METHODS
  // ============================================================================

  Future<void> _mergePatients(List<Patient> local, List<Patient> backend) async {
    // Simple merge - add backend patients that don't exist locally
    for (final backendPatient in backend) {
      final existsLocally = local.any((p) => p.patientId == backendPatient.patientId);
      if (!existsLocally) {
        try {
          await _addLocalPatient(backendPatient);
        } catch (e) {
          // If insertion fails due to constraint, skip this patient
          print('⚠️ Skipped duplicate patient: ${backendPatient.patientId}');
        }
      }
    }
  }

  // ============================================================================
  // SYNC METHODS
  // ============================================================================

  Future<void> _syncPendingPatients() async {
    if (!_isBackendAvailable) return;

    print('🔄 Syncing pending patients to backend...');
    
    try {
      final pendingPatients = await _database!.query('patients', where: 'synced_to_backend = ?', whereArgs: [0]);
      for (final patientMap in pendingPatients) {
        try {
          final patient = Patient.fromLocalJson(patientMap);
          final syncedPatient = await _apiService.createPatient(patient);
          if (patient.patientId != null && syncedPatient.patientId != null) {
            await _updateLocalPatientSyncStatus(patient.patientId!, syncedPatient.patientId!);
          }
        } catch (e) {
          print('Failed to sync patient ${patientMap['id']}: $e');
        }
      }
      
      print('✅ Pending patients synced successfully');
    } catch (e) {
      print('❌ Error syncing pending patients: $e');
    }
  }

  // Test management methods
  Future<List<Test>> getTests() async {
    try {
      if (_database == null) {
        await _initDatabase();
      }

      final List<Map<String, dynamic>> maps = await _database!.query('tests');
      return List.generate(maps.length, (i) {
        return Test.fromLocalJson(maps[i]);
      });
    } catch (e) {
      print('❌ Error getting tests from local storage: $e');
      return [];
    }
  }

  Future<void> addTest(Test test) async {
    try {
      if (_database == null) {
        await _initDatabase();
      }

      await _database!.insert(
        'tests',
        test.toLocalJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('✅ Test added to local storage: ${test.testType}');
    } catch (e) {
      print('❌ Error adding test to local storage: $e');
      rethrow;
    }
  }

  Future<void> updateTest(Test test) async {
    try {
      if (_database == null) {
        await _initDatabase();
      }

      await _database!.update(
        'tests',
        test.toLocalJson(),
        where: 'test_id = ?',
        whereArgs: [test.testId],
      );

      print('✅ Test updated in local storage: ${test.testType}');
    } catch (e) {
      print('❌ Error updating test in local storage: $e');
      rethrow;
    }
  }

  Future<void> deleteTest(String testId) async {
    try {
      if (_database == null) {
        await _initDatabase();
      }

      await _database!.delete(
        'tests',
        where: 'test_id = ?',
        whereArgs: [testId],
      );

      print('✅ Test deleted from local storage: $testId');
    } catch (e) {
      print('❌ Error deleting test from local storage: $e');
      rethrow;
    }
  }
}

