import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/patient.dart';
import '../models/test.dart';
import '../models/appointment.dart';
import '../models/payment.dart';
import '../models/user.dart';

/// Privacy or Terms loaded for Account settings.
class LegalDocumentResult {
  final String title;
  final String body;
  final String sourceLabel;
  final Map<String, dynamic> labSettings;

  const LegalDocumentResult({
    required this.title,
    required this.body,
    required this.sourceLabel,
    this.labSettings = const {},
  });
}

/// Result of Settings → Request Account Deletion.
class AccountDeletionRequestResult {
  final String requestId;
  final bool savedLocally;
  final bool apiAccepted;
  final bool emailOpened;
  final String message;

  const AccountDeletionRequestResult({
    required this.requestId,
    required this.savedLocally,
    required this.apiAccepted,
    required this.emailOpened,
    required this.message,
  });

  bool get isSuccess => savedLocally || apiAccepted;
}

/// Result of a full lab data export (Settings → Request Data Export).
class DataExportResult {
  final List<String> filePaths;
  final int patientCount;
  final int testCount;
  final int appointmentCount;
  final int paymentCount;
  final int userCount;

  const DataExportResult({
    required this.filePaths,
    required this.patientCount,
    required this.testCount,
    required this.appointmentCount,
    required this.paymentCount,
    required this.userCount,
  });

  String get summary =>
      '$patientCount patients, $testCount tests, $appointmentCount appointments, '
      '$paymentCount payments';
}

class DataExportUtils {
  /// Export data to Excel format
  static Future<String> exportToExcel({
    required List<Patient> patients,
    required List<Test> tests,
    required List<Appointment> appointments,
    required List<Payment> payments,
    required List<User> users,
    bool shareAfterWrite = true,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'lab_data_$timestamp.csv';
      final file = File('${directory.path}/$fileName');
      
      final csvContent = _generateCSVContent(
        patients: patients,
        tests: tests,
        appointments: appointments,
        payments: payments,
        users: users,
      );
      
      await file.writeAsString(csvContent);

      if (shareAfterWrite) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'SAEED Laboratory Data Export',
        );
      }

      return file.path;
    } catch (e) {
      throw Exception('Failed to export to Excel: $e');
    }
  }

  /// Generate CSV content for Excel
  static String _generateCSVContent({
    required List<Patient> patients,
    required List<Test> tests,
    required List<Appointment> appointments,
    required List<Payment> payments,
    required List<User> users,
  }) {
    final buffer = StringBuffer();
    
    // Add timestamp
    buffer.writeln('SAEED Laboratory Data Export');
    buffer.writeln('Generated on: ${DateTime.now().toString()}');
    buffer.writeln();
    
    // Patients Sheet
    buffer.writeln('=== PATIENTS ===');
    buffer.writeln('ID,Full Name,Email,Phone,Date of Birth,Gender,Address,Medical History,Created At');
    for (final patient in patients) {
      buffer.writeln('${patient.id},"${patient.fullName}","${patient.email}","${patient.phone}","${patient.dateOfBirth}","${patient.gender}","${patient.address}","${patient.medicalHistory}","${patient.createdAt}"');
    }
    buffer.writeln();
    
    // Tests Sheet
    buffer.writeln('=== TESTS ===');
    buffer.writeln('ID,Test Name,Description,Price,Test Type,Status,Patient ID,Ordered Date,Created At');
    for (final test in tests) {
      buffer.writeln('${test.id},"${test.testName}","${test.description}","${test.price}","${test.testType}","${test.status}","${test.patientId}","${test.orderedDate}","${test.createdAt}"');
    }
    buffer.writeln();
    
    // Appointments Sheet
    buffer.writeln('=== APPOINTMENTS ===');
    buffer.writeln('ID,Patient ID,Patient Name,Test Type,Test Name,Appointment Date,Status,Notes,Created At');
    for (final appointment in appointments) {
      buffer.writeln('${appointment.appointmentId},${appointment.patientId},"${appointment.patientName}","${appointment.testType}","${appointment.testName}","${appointment.appointmentDate}","${appointment.status}","${appointment.notes}","${appointment.createdAt}"');
    }
    buffer.writeln();
    
    // Payments Sheet
    buffer.writeln('=== PAYMENTS ===');
    buffer.writeln('ID,Test ID,Patient ID,Patient Name,Test Type,Test Name,Amount,Payment Method,Status,Transaction ID,Payment Date,Created At');
    for (final payment in payments) {
      buffer.writeln('${payment.paymentId},${payment.testId},${payment.patientId},"${payment.patientName}","${payment.testType}","${payment.testName}","${payment.amount}","${payment.paymentMethod}","${payment.status}","${payment.transactionId}","${payment.paymentDate}","${payment.createdAt}"');
    }
    buffer.writeln();
    
    // Users Sheet
    buffer.writeln('=== USERS ===');
    buffer.writeln('ID,Username,Email,Role,Is Active,Created At');
    for (final user in users) {
      buffer.writeln('${user.id},"${user.username}","${user.email}","${user.role}","${user.isActive}","${user.createdAt}"');
    }
    
    return buffer.toString();
  }

  /// Export data to PDF format
  static Future<String> exportToPDF({
    required List<Patient> patients,
    required List<Test> tests,
    required List<Appointment> appointments,
    required List<Payment> payments,
    required List<User> users,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'lab_report_$timestamp.txt';
      final file = File('${directory.path}/$fileName');
      
      final pdfContent = _generatePDFContent(
        patients: patients,
        tests: tests,
        appointments: appointments,
        payments: payments,
        users: users,
      );
      
      await file.writeAsString(pdfContent);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'SAEED Laboratory Report',
      );
      
      return file.path;
    } catch (e) {
      throw Exception('Failed to export to PDF: $e');
    }
  }

  /// Generate PDF content
  static String _generatePDFContent({
    required List<Patient> patients,
    required List<Test> tests,
    required List<Appointment> appointments,
    required List<Payment> payments,
    required List<User> users,
  }) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('=' * 80);
    buffer.writeln('SAEED LABORATORY MANAGEMENT SYSTEM');
    buffer.writeln('DATA EXPORT REPORT');
    buffer.writeln('=' * 80);
    buffer.writeln('Generated on: ${DateTime.now().toString()}');
    buffer.writeln('Total Records: ${patients.length + tests.length + appointments.length + payments.length + users.length}');
    buffer.writeln();
    
    // Summary
    buffer.writeln('SUMMARY:');
    buffer.writeln('- Patients: ${patients.length}');
    buffer.writeln('- Tests: ${tests.length}');
    buffer.writeln('- Appointments: ${appointments.length}');
    buffer.writeln('- Payments: ${payments.length}');
    buffer.writeln('- Users: ${users.length}');
    buffer.writeln();
    
    // Patients Section
    buffer.writeln('PATIENTS (${patients.length} records):');
    buffer.writeln('-' * 80);
    for (final patient in patients) {
      buffer.writeln('ID: ${patient.id}');
      buffer.writeln('Name: ${patient.fullName}');
      buffer.writeln('Email: ${patient.email}');
      buffer.writeln('Phone: ${patient.phone}');
      buffer.writeln('Date of Birth: ${patient.dateOfBirth}');
      buffer.writeln('Gender: ${patient.gender}');
      buffer.writeln('Address: ${patient.address}');
      buffer.writeln('Medical History: ${patient.medicalHistory}');
      buffer.writeln('Created: ${patient.createdAt}');
      buffer.writeln();
    }
    
    // Tests Section
    buffer.writeln('TESTS (${tests.length} records):');
    buffer.writeln('-' * 80);
    for (final test in tests) {
      buffer.writeln('ID: ${test.id}');
      buffer.writeln('Name: ${test.testName}');
      buffer.writeln('Description: ${test.description}');
      buffer.writeln('Price: \$${test.price}');
      buffer.writeln('Type: ${test.testType}');
      buffer.writeln('Status: ${test.status}');
      buffer.writeln('Patient ID: ${test.patientId}');
      buffer.writeln('Created: ${test.createdAt}');
      buffer.writeln();
    }
    
    // Appointments Section
    buffer.writeln('APPOINTMENTS (${appointments.length} records):');
    buffer.writeln('-' * 80);
    for (final appointment in appointments) {
      buffer.writeln('ID: ${appointment.appointmentId}');
      buffer.writeln('Patient ID: ${appointment.patientId}');
      buffer.writeln('Patient Name: ${appointment.patientName}');
      buffer.writeln('Test Type: ${appointment.testType}');
      buffer.writeln('Test Name: ${appointment.testName}');
      buffer.writeln('Date: ${appointment.appointmentDate}');
      buffer.writeln('Status: ${appointment.status}');
      buffer.writeln('Notes: ${appointment.notes}');
      buffer.writeln('Created: ${appointment.createdAt}');
      buffer.writeln();
    }
    
    // Payments Section
    buffer.writeln('PAYMENTS (${payments.length} records):');
    buffer.writeln('-' * 80);
    for (final payment in payments) {
      buffer.writeln('ID: ${payment.paymentId}');
      buffer.writeln('Test ID: ${payment.testId}');
      buffer.writeln('Patient ID: ${payment.patientId}');
      buffer.writeln('Patient Name: ${payment.patientName}');
      buffer.writeln('Test Type: ${payment.testType}');
      buffer.writeln('Test Name: ${payment.testName}');
      buffer.writeln('Amount: \$${payment.amount}');
      buffer.writeln('Method: ${payment.paymentMethod}');
      buffer.writeln('Status: ${payment.status}');
      buffer.writeln('Transaction ID: ${payment.transactionId}');
      buffer.writeln('Payment Date: ${payment.paymentDate}');
      buffer.writeln('Created: ${payment.createdAt}');
      buffer.writeln();
    }
    
    // Users Section
    buffer.writeln('USERS (${users.length} records):');
    buffer.writeln('-' * 80);
    for (final user in users) {
      buffer.writeln('ID: ${user.id}');
      buffer.writeln('Username: ${user.username}');
      buffer.writeln('Email: ${user.email}');
      buffer.writeln('Role: ${user.role}');
      buffer.writeln('Active: ${user.isActive}');
      buffer.writeln('Created: ${user.createdAt}');
      buffer.writeln();
    }
    
    // Footer
    buffer.writeln('=' * 80);
    buffer.writeln('End of Report');
    buffer.writeln('Generated by SAEED Laboratory Management System');
    buffer.writeln('=' * 80);
    
    return buffer.toString();
  }

  /// Export specific data type (alias for compatibility)
  static Future<String> exportSpecific({
    required String dataType,
    required List<dynamic> data,
  }) async {
    return exportSpecificData(dataType: dataType, data: data);
  }

  /// Export specific data type
  static Future<String> exportSpecificData({
    required String dataType,
    required List<dynamic> data,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${dataType.toLowerCase()}_$timestamp.csv';
      final file = File('${directory.path}/$fileName');
      
      final csvContent = _generateSpecificCSV(dataType, data);
      await file.writeAsString(csvContent);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'SAEED Laboratory - $dataType Export',
      );
      
      return file.path;
    } catch (e) {
      throw Exception('Failed to export $dataType: $e');
    }
  }

  /// Generate CSV for specific data type
  static String _generateSpecificCSV(String dataType, List<dynamic> data) {
    final buffer = StringBuffer();
    
    buffer.writeln('SAEED Laboratory - $dataType Export');
    buffer.writeln('Generated on: ${DateTime.now().toString()}');
    buffer.writeln('Total Records: ${data.length}');
    buffer.writeln();
    
    switch (dataType.toLowerCase()) {
      case 'patients':
        buffer.writeln('ID,Full Name,Email,Phone,Date of Birth,Gender,Address,Medical History,Created At');
        for (final patient in data) {
          buffer.writeln('${patient.id},"${patient.fullName}","${patient.email}","${patient.phone}","${patient.dateOfBirth}","${patient.gender}","${patient.address}","${patient.medicalHistory}","${patient.createdAt}"');
        }
        break;
      case 'tests':
        buffer.writeln('ID,Test Name,Description,Price,Test Type,Status,Patient ID,Ordered Date,Created At');
        for (final test in data) {
          buffer.writeln('${test.id},"${test.testName}","${test.description}","${test.price}","${test.testType}","${test.status}","${test.patientId}","${test.orderedDate}","${test.createdAt}"');
        }
        break;
      case 'appointments':
        buffer.writeln('ID,Patient ID,Patient Name,Test Type,Test Name,Appointment Date,Status,Notes,Created At');
        for (final appointment in data) {
          buffer.writeln('${appointment.appointmentId},${appointment.patientId},"${appointment.patientName}","${appointment.testType}","${appointment.testName}","${appointment.appointmentDate}","${appointment.status}","${appointment.notes}","${appointment.createdAt}"');
        }
        break;
      case 'payments':
        buffer.writeln('ID,Test ID,Patient ID,Patient Name,Test Type,Test Name,Amount,Payment Method,Status,Transaction ID,Payment Date,Created At');
        for (final payment in data) {
          buffer.writeln('${payment.paymentId},${payment.testId},${payment.patientId},"${payment.patientName}","${payment.testType}","${payment.testName}","${payment.amount}","${payment.paymentMethod}","${payment.status}","${payment.transactionId}","${payment.paymentDate}","${payment.createdAt}"');
        }
        break;
      case 'users':
        buffer.writeln('ID,Username,Email,Role,Is Active,Created At');
        for (final user in data) {
          buffer.writeln('${user.id},"${user.username}","${user.email}","${user.role}","${user.isActive}","${user.createdAt}"');
        }
        break;
    }
    
    return buffer.toString();
  }

  /// Get data statistics
  static Map<String, dynamic> getDataStatistics({
    required List<Patient> patients,
    required List<Test> tests,
    required List<Appointment> appointments,
    required List<Payment> payments,
    required List<User> users,
  }) {
    final totalRevenue = payments
        .where((p) => p.status == 'completed')
        .fold(0.0, (sum, payment) => sum + payment.amount);
    
    final pendingAppointments = appointments
        .where((a) => a.status == 'pending')
        .length;
    
    final completedAppointments = appointments
        .where((a) => a.status == 'completed')
        .length;
    
    return {
      'totalPatients': patients.length,
      'totalTests': tests.length,
      'totalAppointments': appointments.length,
      'totalPayments': payments.length,
      'totalUsers': users.length,
      'totalRevenue': totalRevenue,
      'pendingAppointments': pendingAppointments,
      'completedAppointments': completedAppointments,
      'averageTestPrice': tests.isNotEmpty 
          ? tests.fold(0.0, (sum, test) => sum + test.price) / tests.length 
          : 0.0,
    };
  }
}
