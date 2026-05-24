# Lab Mobile App - Complete System Documentation

## Overview

This document provides a comprehensive guide to the Lab Management System, including the data structure, database schema, backend services, and integration with the mobile app.

## Table of Contents

1. [System Architecture](#system-architecture)
2. [Data Structure](#data-structure)
3. [Database Schema](#database-schema)
4. [Backend Services](#backend-services)
5. [API Integration](#api-integration)
6. [Mobile App Integration](#mobile-app-integration)
7. [Setup Instructions](#setup-instructions)
8. [Usage Examples](#usage-examples)

## System Architecture

The Lab Management System consists of:

- **Frontend**: Flutter mobile application
- **Backend**: FastAPI Python server
- **Database**: SQLite with comprehensive schema
- **Services**: Business logic layer for all operations

### Data Flow

```
Mobile App → API Service → Lab Service → Database
     ↑                                        ↓
     ←─────────── Response Data ←─────────────
```

## Data Structure

### Core Entities

#### 1. Patients
- **Purpose**: Store patient information
- **Key Fields**: patient_id, full_name, date_of_birth, gender, phone, email
- **Relationships**: One-to-many with Tests, Appointments

#### 2. Tests
- **Purpose**: Laboratory test orders and results
- **Key Fields**: test_id, patient_id, test_type, test_name, status, priority
- **Relationships**: Many-to-one with Patient, One-to-many with TestResults, Payments, Reports

#### 3. Test Results
- **Purpose**: Individual test parameters and values
- **Key Fields**: result_id, test_id, parameter, value, unit, reference_range
- **Relationships**: Many-to-one with Test

#### 4. Appointments
- **Purpose**: Patient appointment scheduling
- **Key Fields**: appointment_id, patient_id, appointment_date, appointment_time, test_type
- **Relationships**: Many-to-one with Patient

#### 5. Payments
- **Purpose**: Payment tracking for tests
- **Key Fields**: payment_id, test_id, amount, payment_method, status
- **Relationships**: Many-to-one with Test

#### 6. Reports
- **Purpose**: Generated test reports with templates
- **Key Fields**: report_id, test_id, template_id, field_values (JSON)
- **Relationships**: Many-to-one with Test, ReportTemplate

#### 7. Report Templates
- **Purpose**: Define report structure and fields
- **Key Fields**: template_id, name, test_type, header_template, footer_template
- **Relationships**: One-to-many with ReportFields, Reports

#### 8. Users
- **Purpose**: System user management
- **Key Fields**: user_id, username, email, full_name, role
- **Relationships**: One-to-many with AuditLogs, Notifications

#### 9. Settings
- **Purpose**: System configuration
- **Key Fields**: setting_key, setting_value, setting_type

#### 10. Audit Logs
- **Purpose**: Track system activities
- **Key Fields**: log_id, user_id, action, table_name, record_id

#### 11. Notifications
- **Purpose**: User notifications
- **Key Fields**: notification_id, user_id, title, message, type

## Database Schema

### Key Features

1. **Foreign Key Constraints**: Ensures data integrity
2. **Indexes**: Optimized for common queries
3. **Triggers**: Automatic timestamp updates
4. **Views**: Predefined complex queries
5. **Default Data**: Pre-populated templates and settings

### Schema Highlights

```sql
-- Example of relationship structure
CREATE TABLE tests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    test_id VARCHAR(20) UNIQUE NOT NULL,
    patient_id VARCHAR(20) NOT NULL,
    test_type VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE
);
```

### Views for Common Queries

1. **test_summary**: Combines test and patient information
2. **payment_summary**: Combines payment and test information
3. **appointment_summary**: Combines appointment and patient information

## Backend Services

### LabService Class

The `LabService` class provides comprehensive business logic for all operations:

#### Patient Management
```python
# Create patient
patient = lab_service.create_patient({
    'full_name': 'John Doe',
    'date_of_birth': '1990-05-15',
    'gender': 'Male',
    'phone': '+1234567890',
    'email': 'john@example.com'
})

# Get patients with search
patients = lab_service.get_patients(search='John')

# Update patient
updated_patient = lab_service.update_patient('P001', {
    'phone': '+1234567891'
})
```

#### Test Management
```python
# Create test
test = lab_service.create_test({
    'patient_id': 'P001',
    'test_type': 'Blood Test (CBC)',
    'test_name': 'Complete Blood Count',
    'price': 150.00,
    'priority': 'Normal'
})

# Update test status
lab_service.update_test_status('T001', 'Completed')

# Get tests by status
pending_tests = lab_service.get_tests(status='Pending')
```

#### Test Results Management
```python
# Create test result
result = lab_service.create_test_result({
    'test_id': 'T001',
    'parameter': 'Hemoglobin',
    'value': '14.5',
    'unit': 'g/dL',
    'reference_range': '12.0-16.0',
    'is_abnormal': False
})

# Get test results
results = lab_service.get_test_results('T001')
```

#### Report Management
```python
# Create report
report = lab_service.create_report({
    'test_id': 'T001',
    'template_id': 'TEMP001',
    'patient_name': 'John Doe',
    'test_type': 'Blood Test (CBC)',
    'test_date': '2024-01-01',
    'field_values': {
        'hemoglobin': '14.5',
        'wbc': '7500',
        'rbc': '4.8'
    }
})
```

#### Statistics and Analytics
```python
# Get dashboard statistics
stats = lab_service.get_dashboard_stats()
# Returns: {
#     'total_patients': 150,
#     'total_tests': 500,
#     'pending_tests': 25,
#     'completed_tests': 450,
#     'total_revenue': 75000.00
# }

# Get recent activities
activities = lab_service.get_recent_activities(limit=10)
```

## API Integration

### RESTful Endpoints

The backend provides RESTful APIs for all operations:

#### Patients
- `GET /api/patients` - List patients
- `GET /api/patients/{patient_id}` - Get patient details
- `POST /api/patients` - Create patient
- `PUT /api/patients/{patient_id}` - Update patient
- `DELETE /api/patients/{patient_id}` - Delete patient

#### Tests
- `GET /api/tests` - List tests
- `GET /api/tests/{test_id}` - Get test details
- `POST /api/tests` - Create test
- `PUT /api/tests/{test_id}` - Update test
- `PATCH /api/tests/{test_id}/status` - Update test status

#### Test Results
- `GET /api/tests/{test_id}/results` - Get test results
- `POST /api/tests/{test_id}/results` - Add test result
- `PUT /api/results/{result_id}` - Update test result

#### Appointments
- `GET /api/appointments` - List appointments
- `POST /api/appointments` - Create appointment
- `PATCH /api/appointments/{appointment_id}/status` - Update status

#### Payments
- `GET /api/payments` - List payments
- `POST /api/payments` - Create payment
- `PATCH /api/payments/{payment_id}/status` - Update status

#### Reports
- `GET /api/reports` - List reports
- `GET /api/reports/{report_id}` - Get report details
- `POST /api/reports` - Create report
- `PUT /api/reports/{report_id}` - Update report

### Response Format

All API responses follow a consistent format:

```json
{
    "success": true,
    "data": {
        // Response data
    },
    "message": "Operation completed successfully"
}
```

## Mobile App Integration

### API Service Updates

The mobile app's `ApiService` class has been updated to work with the new backend structure:

#### Key Changes

1. **Consistent Data Format**: All responses use the same structure
2. **Error Handling**: Improved error handling with specific error messages
3. **Authentication**: JWT token-based authentication
4. **Real-time Updates**: WebSocket support for real-time notifications

#### Example Usage

```dart
// Get patients
List<Patient> patients = await apiService.getPatients();

// Create patient
Patient newPatient = await apiService.createPatient(Patient(
    fullName: 'John Doe',
    dateOfBirth: DateTime(1990, 5, 15),
    gender: 'Male',
    contactNumber: '+1234567890',
    email: 'john@example.com'
));

// Get test results
List<TestResult> results = await apiService.getTestResults('T001');

// Create report
ReportData report = await apiService.createReport(ReportData(
    testId: 1,
    templateId: 1,
    patientName: 'John Doe',
    testType: 'Blood Test (CBC)',
    testDate: DateTime.now(),
    fieldValues: {
        'hemoglobin': '14.5',
        'wbc': '7500'
    }
));
```

## Setup Instructions

### 1. Database Setup

```bash
# Navigate to backend directory
cd backend

# Initialize database with new schema
python init_db.py

# The script will:
# - Create all tables
# - Insert default data
# - Create indexes and triggers
# - Set up default admin user
```

### 2. Backend Setup

```bash
# Install dependencies
pip install -r requirements.txt

# Start the server
python main.py

# Server will run on http://localhost:8000
```

### 3. Mobile App Setup

```bash
# Navigate to app directory
cd lib

# Update API constants in utils/constants.dart
# Set the correct backend URL

# Run the app
flutter run
```

### 4. Default Credentials

- **Username**: admin
- **Password**: admin123

## Usage Examples

### Complete Workflow Example

#### 1. Patient Registration
```python
# Backend
patient_data = {
    'full_name': 'John Doe',
    'date_of_birth': '1990-05-15',
    'gender': 'Male',
    'phone': '+1234567890',
    'email': 'john@example.com'
}
patient = lab_service.create_patient(patient_data)
```

#### 2. Test Order
```python
# Backend
test_data = {
    'patient_id': patient.patient_id,
    'test_type': 'Blood Test (CBC)',
    'test_name': 'Complete Blood Count',
    'price': 150.00,
    'priority': 'Normal'
}
test = lab_service.create_test(test_data)
```

#### 3. Appointment Scheduling
```python
# Backend
appointment_data = {
    'patient_id': patient.patient_id,
    'appointment_date': '2024-01-15',
    'appointment_time': '10:00:00',
    'test_type': 'Blood Test (CBC)',
    'doctor_name': 'Dr. Smith'
}
appointment = lab_service.create_appointment(appointment_data)
```

#### 4. Test Results Entry
```python
# Backend
results_data = [
    {
        'test_id': test.test_id,
        'parameter': 'Hemoglobin',
        'value': '14.5',
        'unit': 'g/dL',
        'reference_range': '12.0-16.0'
    },
    {
        'test_id': test.test_id,
        'parameter': 'WBC',
        'value': '7500',
        'unit': 'cells/μL',
        'reference_range': '4500-11000'
    }
]

for result_data in results_data:
    lab_service.create_test_result(result_data)
```

#### 5. Report Generation
```python
# Backend
report_data = {
    'test_id': test.test_id,
    'template_id': 'TEMP001',  # CBC template
    'patient_name': patient.full_name,
    'test_type': test.test_type,
    'test_date': test.ordered_date.strftime('%Y-%m-%d'),
    'field_values': {
        'hemoglobin': '14.5',
        'wbc': '7500',
        'rbc': '4.8',
        'platelets': '250000'
    },
    'doctor_name': 'Dr. Smith',
    'technician_name': 'Tech Johnson'
}
report = lab_service.create_report(report_data)
```

#### 6. Payment Processing
```python
# Backend
payment_data = {
    'test_id': test.test_id,
    'amount': test.price,
    'payment_method': 'Cash',
    'transaction_id': 'TXN123456'
}
payment = lab_service.create_payment(payment_data)
```

### Mobile App Integration Example

```dart
// Flutter app
class LabApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<List<Patient>>(
        future: ApiService().getPatients(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return PatientListScreen(patients: snapshot.data!);
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
```

## Benefits of New System

### 1. **Data Integrity**
- Foreign key constraints prevent orphaned records
- Consistent data validation
- Audit logging for all changes

### 2. **Scalability**
- Optimized database indexes
- Efficient query patterns
- Modular service architecture

### 3. **Maintainability**
- Clear separation of concerns
- Comprehensive documentation
- Consistent coding patterns

### 4. **User Experience**
- Real-time updates
- Comprehensive search functionality
- Rich reporting capabilities

### 5. **Business Intelligence**
- Dashboard statistics
- Activity tracking
- Financial reporting

## Conclusion

This comprehensive lab management system provides a robust foundation for managing laboratory operations. The structured approach ensures data consistency, provides excellent user experience, and supports business growth through detailed analytics and reporting capabilities.

The system is designed to be easily extensible, allowing for future enhancements such as:
- Integration with external laboratory equipment
- Advanced reporting and analytics
- Multi-location support
- Patient portal integration
- Insurance claim processing
