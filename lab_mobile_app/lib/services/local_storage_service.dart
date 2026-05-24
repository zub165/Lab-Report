import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient.dart';
import '../models/test.dart';
import '../models/appointment.dart';
import '../models/payment.dart';
import '../utils/constants.dart';

class LocalStorageService {
  static const String _patientsKey = 'local_patients';
  static const String _testsKey = 'local_tests';
  static const String _appointmentsKey = 'local_appointments';
  static const String _paymentsKey = 'local_payments';

  static Future<String> _scoped(String base) async {
    await LabGroupScope.loadCachedScope();
    return LabGroupScope.scopedPrefsKey(base);
  }

  // Save patients to local storage
  static Future<void> savePatients(List<Patient> patients) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _scoped(_patientsKey);
    final patientsJson = patients.map((patient) => patient.toJson()).toList();
    await prefs.setString(key, jsonEncode(patientsJson));
  }

  // Load patients from local storage
  static Future<List<Patient>> loadPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _scoped(_patientsKey);
    final patientsString = prefs.getString(key);
    if (patientsString != null) {
      final patientsJson = jsonDecode(patientsString) as List;
      return patientsJson.map((json) => Patient.fromJson(json)).toList();
    }
    return [];
  }

  // Save tests to local storage
  static Future<void> saveTests(List<Test> tests) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _scoped(_testsKey);
    final testsJson = tests.map((test) => test.toJson()).toList();
    await prefs.setString(key, jsonEncode(testsJson));
  }

  // Load tests from local storage
  static Future<List<Test>> loadTests() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _scoped(_testsKey);
    final testsString = prefs.getString(key);
    if (testsString != null) {
      final testsJson = jsonDecode(testsString) as List;
      return testsJson.map((json) => Test.fromJson(json)).toList();
    }
    return [];
  }

  // Add a single patient to local storage
  static Future<void> addPatient(Patient patient) async {
    final patients = await loadPatients();
    patients.add(patient);
    await savePatients(patients);
  }

  // Add a single test to local storage
  static Future<void> addTest(Test test) async {
    final tests = await loadTests();
    tests.add(test);
    await saveTests(tests);
  }

  // Update a patient in local storage
  static Future<void> updatePatient(Patient updatedPatient) async {
    final patients = await loadPatients();
    final index = patients.indexWhere((p) => p.patientId == updatedPatient.patientId);
    if (index != -1) {
      patients[index] = updatedPatient;
      await savePatients(patients);
    }
  }

  // Update a test in local storage
  static Future<void> updateTest(Test updatedTest) async {
    final tests = await loadTests();
    final index = tests.indexWhere((t) => t.testId == updatedTest.testId);
    if (index != -1) {
      tests[index] = updatedTest;
      await saveTests(tests);
    }
  }

  // Delete a patient from local storage
  static Future<void> deletePatient(String patientId) async {
    final patients = await loadPatients();
    patients.removeWhere((p) => p.patientId == patientId);
    await savePatients(patients);
  }

  // Delete a test from local storage
  static Future<void> deleteTest(String testId) async {
    final tests = await loadTests();
    tests.removeWhere((t) => t.testId == testId);
    await saveTests(tests);
  }

  // Appointments
  static Future<void> saveAppointments(List<Appointment> appointments) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _scoped(_appointmentsKey);
    final appointmentsJson = appointments.map((appointment) => appointment.toJson()).toList();
    await prefs.setString(key, jsonEncode(appointmentsJson));
  }

  // Load appointments from local storage
  static Future<List<Appointment>> loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _scoped(_appointmentsKey);
    final appointmentsString = prefs.getString(key);
    if (appointmentsString != null) {
      final appointmentsJson = jsonDecode(appointmentsString) as List;
      return appointmentsJson.map((json) => Appointment.fromJson(json)).toList();
    }
    return [];
  }

  // Add a single appointment to local storage
  static Future<void> addAppointment(Appointment appointment) async {
    final appointments = await loadAppointments();
    appointments.add(appointment);
    await saveAppointments(appointments);
  }

  // Update an appointment in local storage
  static Future<void> updateAppointment(Appointment updatedAppointment) async {
    final appointments = await loadAppointments();
    final index = appointments.indexWhere((apt) => apt.appointmentId == updatedAppointment.appointmentId);
    if (index != -1) {
      appointments[index] = updatedAppointment;
      await saveAppointments(appointments);
    }
  }

  // Delete an appointment from local storage
  static Future<void> deleteAppointment(String appointmentId) async {
    final appointments = await loadAppointments();
    appointments.removeWhere((apt) => apt.appointmentId == appointmentId);
    await saveAppointments(appointments);
  }

  // Payments
  static Future<void> savePayments(List<Payment> payments) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _scoped(_paymentsKey);
    final paymentsJson = payments.map((payment) => payment.toJson()).toList();
    await prefs.setString(key, jsonEncode(paymentsJson));
  }

  // Load payments from local storage
  static Future<List<Payment>> loadPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _scoped(_paymentsKey);
    final paymentsString = prefs.getString(key);
    if (paymentsString != null) {
      final paymentsJson = jsonDecode(paymentsString) as List;
      return paymentsJson.map((json) => Payment.fromJson(json)).toList();
    }
    return [];
  }

  // Add a single payment to local storage
  static Future<void> addPayment(Payment payment) async {
    final payments = await loadPayments();
    payments.add(payment);
    await savePayments(payments);
  }

  // Update a payment in local storage
  static Future<void> updatePayment(Payment updatedPayment) async {
    final payments = await loadPayments();
    final index = payments.indexWhere((p) => p.paymentId == updatedPayment.paymentId);
    if (index != -1) {
      payments[index] = updatedPayment;
      await savePayments(payments);
    }
  }

  // Delete a payment from local storage
  static Future<void> deletePayment(String paymentId) async {
    final payments = await loadPayments();
    payments.removeWhere((p) => p.paymentId == paymentId);
    await savePayments(payments);
  }

  /// Clears offline cache for the **active** lab group only.
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(await _scoped(_patientsKey));
    await prefs.remove(await _scoped(_testsKey));
    await prefs.remove(await _scoped(_appointmentsKey));
    await prefs.remove(await _scoped(_paymentsKey));
  }
}
