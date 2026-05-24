# Lab Management System - API Usage Guide

## 🚀 Quick Start

### 1. Start the Backend Server
```bash
cd backend
python3 main.py
```

### 2. Access the API
- **API Base URL**: `http://localhost:8000`
- **Interactive Docs**: `http://localhost:8000/docs`
- **Default Admin**: `admin` / `admin123`

## 📋 Authentication

All data management endpoints require authentication. First, get a token:

```bash
# Login to get access token
curl -X POST "http://localhost:8000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123"
  }'
```

Use the returned token in the `Authorization: Bearer <token>` header for all requests.

## 🔍 PATIENT MANAGEMENT

### Get All Patients
```bash
curl -X GET "http://localhost:8000/api/data/patients" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Patients with Advanced Filtering
```bash
# Search by name, phone, or email
curl -X GET "http://localhost:8000/api/data/patients?search=john" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Filter by gender
curl -X GET "http://localhost:8000/api/data/patients?gender=Male" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Sort by name (ascending)
curl -X GET "http://localhost:8000/api/data/patients?sort_by=full_name&sort_order=asc" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Pagination
curl -X GET "http://localhost:8000/api/data/patients?skip=0&limit=50" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Single Patient with Related Data
```bash
# Basic patient info
curl -X GET "http://localhost:8000/api/data/patients/P001" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Include tests and appointments
curl -X GET "http://localhost:8000/api/data/patients/P001?include_tests=true&include_appointments=true" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Create New Patient
```bash
curl -X POST "http://localhost:8000/api/data/patients" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "John Doe",
    "date_of_birth": "1990-05-15",
    "gender": "Male",
    "phone": "+1234567890",
    "email": "john@example.com",
    "address": "123 Main St, City",
    "emergency_contact": "+1234567891",
    "medical_history": "Diabetes, Hypertension",
    "blood_type": "A+",
    "insurance_info": "Blue Cross, Policy#123"
  }'
```

### Update Patient
```bash
curl -X PUT "http://localhost:8000/api/data/patients/P001" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+1234567892",
    "email": "john.doe@example.com",
    "address": "456 Oak Ave, City"
  }'
```

### Delete Patient
```bash
curl -X DELETE "http://localhost:8000/api/data/patients/P001" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 🧪 TEST MANAGEMENT

### Get All Tests
```bash
curl -X GET "http://localhost:8000/api/data/tests" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Tests with Filtering
```bash
# Filter by status
curl -X GET "http://localhost:8000/api/data/tests?status=Pending" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Filter by test type
curl -X GET "http://localhost:8000/api/data/tests?test_type=Blood Test (CBC)" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Filter by priority
curl -X GET "http://localhost:8000/api/data/tests?priority=Urgent" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Filter by patient
curl -X GET "http://localhost:8000/api/data/tests?patient_id=P001" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Sort by date (newest first)
curl -X GET "http://localhost:8000/api/data/tests?sort_by=ordered_date&sort_order=desc" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Single Test with Results
```bash
# Include test results
curl -X GET "http://localhost:8000/api/data/tests/T001?include_results=true" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Include payments
curl -X GET "http://localhost:8000/api/data/tests/T001?include_payments=true" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Create New Test
```bash
curl -X POST "http://localhost:8000/api/data/tests" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "patient_id": "P001",
    "test_type": "Blood Test (CBC)",
    "test_name": "Complete Blood Count",
    "description": "Complete blood count test",
    "price": 150.00,
    "priority": "Normal",
    "ordered_by": "Dr. Smith"
  }'
```

### Update Test Status
```bash
curl -X PATCH "http://localhost:8000/api/data/tests/T001/status" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "Completed"
  }'
```

## 📊 TEST RESULTS MANAGEMENT

### Get Test Results
```bash
curl -X GET "http://localhost:8000/api/data/tests/T001/results" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Add Test Result
```bash
curl -X POST "http://localhost:8000/api/data/tests/T001/results" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "parameter": "Hemoglobin",
    "value": "14.5",
    "unit": "g/dL",
    "reference_range": "12.0-16.0",
    "is_abnormal": false,
    "notes": "Normal value"
  }'
```

## 📅 APPOINTMENT MANAGEMENT

### Get All Appointments
```bash
curl -X GET "http://localhost:8000/api/data/appointments" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Appointments with Filtering
```bash
# Filter by date
curl -X GET "http://localhost:8000/api/data/appointments?date=2024-01-15" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Filter by status
curl -X GET "http://localhost:8000/api/data/appointments?status=Scheduled" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Filter by test type
curl -X GET "http://localhost:8000/api/data/appointments?test_type=Blood Test" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Sort by date and time
curl -X GET "http://localhost:8000/api/data/appointments?sort_by=appointment_date&sort_order=asc" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Create New Appointment
```bash
curl -X POST "http://localhost:8000/api/data/appointments" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "patient_id": "P001",
    "appointment_date": "2024-01-15",
    "appointment_time": "10:00:00",
    "test_type": "Blood Test (CBC)",
    "doctor_name": "Dr. Smith",
    "notes": "Fasting required"
  }'
```

## 💰 PAYMENT MANAGEMENT

### Get All Payments
```bash
curl -X GET "http://localhost:8000/api/data/payments" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Payments with Filtering
```bash
# Filter by status
curl -X GET "http://localhost:8000/api/data/payments?status=Completed" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Filter by payment method
curl -X GET "http://localhost:8000/api/data/payments?payment_method=Cash" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Sort by amount (highest first)
curl -X GET "http://localhost:8000/api/data/payments?sort_by=amount&sort_order=desc" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Create New Payment
```bash
curl -X POST "http://localhost:8000/api/data/payments" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "test_id": "T001",
    "amount": 150.00,
    "payment_method": "Cash",
    "transaction_id": "TXN123456",
    "notes": "Payment received"
  }'
```

## 🔬 RESEARCH AND ANALYTICS

### Get System Statistics
```bash
curl -X GET "http://localhost:8000/api/data/research/statistics" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Response includes:
- Total patients, tests, appointments, payments
- Completion rates and efficiency scores
- Revenue analytics
- Pending items

### Get Recent Activities
```bash
curl -X GET "http://localhost:8000/api/data/research/activities?limit=20" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Advanced Search
```bash
# Search across all entities
curl -X GET "http://localhost:8000/api/data/research/search?query=john" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Search specific entity type
curl -X GET "http://localhost:8000/api/data/research/search?query=blood&entity_type=tests" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Export Data for Research
```bash
# Export patients data
curl -X GET "http://localhost:8000/api/data/research/export?entity_type=patients&format=json" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Export tests with filters
curl -X GET "http://localhost:8000/api/data/research/export?entity_type=tests&format=json&filters={\"status\":\"Completed\"}" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Export appointments for specific date
curl -X GET "http://localhost:8000/api/data/research/export?entity_type=appointments&format=json&filters={\"date\":\"2024-01-15\"}" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 📱 Mobile App Integration

### Update API Constants
In your Flutter app, update `lib/utils/constants.dart`:

```dart
class AppConstants {
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Data management endpoints
  static const String dataPatientsEndpoint = '/data/patients';
  static const String dataTestsEndpoint = '/data/tests';
  static const String dataAppointmentsEndpoint = '/data/appointments';
  static const String dataPaymentsEndpoint = '/data/payments';
  static const String dataResearchEndpoint = '/data/research';
}
```

### Example API Calls in Flutter

```dart
// Get patients with search
Future<List<Patient>> searchPatients(String query) async {
  final response = await _get('${AppConstants.dataPatientsEndpoint}?search=$query');
  // Process response...
}

// Create new test
Future<Test> createTest(Test test) async {
  final response = await _post(AppConstants.dataTestsEndpoint, test.toApiJson());
  // Process response...
}

// Get test with results
Future<Test> getTestWithResults(String testId) async {
  final response = await _get('${AppConstants.dataTestsEndpoint}/$testId?include_results=true');
  // Process response...
}

// Get research statistics
Future<Map<String, dynamic>> getResearchStats() async {
  final response = await _get('${AppConstants.dataResearchEndpoint}/statistics');
  // Process response...
}
```

## 🛠️ Advanced Usage Examples

### Complex Filtering and Sorting
```bash
# Get urgent blood tests for male patients, sorted by date
curl -X GET "http://localhost:8000/api/data/tests?priority=Urgent&test_type=Blood Test&sort_by=ordered_date&sort_order=desc" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Get completed payments above $100, sorted by amount
curl -X GET "http://localhost:8000/api/data/payments?status=Completed&sort_by=amount&sort_order=desc" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Bulk Operations
```bash
# Get all pending tests for a specific patient
curl -X GET "http://localhost:8000/api/data/tests?patient_id=P001&status=Pending" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Get all appointments for today
curl -X GET "http://localhost:8000/api/data/appointments?date=$(date +%Y-%m-%d)" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Research Queries
```bash
# Export all completed tests for analysis
curl -X GET "http://localhost:8000/api/data/research/export?entity_type=tests&format=json&filters={\"status\":\"Completed\"}" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Get efficiency statistics
curl -X GET "http://localhost:8000/api/data/research/statistics" \
  -H "Authorization: Bearer YOUR_TOKEN" | jq '.completion_rate, .efficiency_score'
```

## 🔧 Error Handling

All endpoints return consistent error responses:

```json
{
  "detail": "Error message here"
}
```

Common HTTP status codes:
- `200`: Success
- `201`: Created
- `400`: Bad Request
- `401`: Unauthorized
- `404`: Not Found
- `500`: Internal Server Error

## 📊 Response Format

All successful responses follow this format:

```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {
    // Response data here
  }
}
```

## 🚀 Next Steps

1. **Test the endpoints** using the interactive docs at `http://localhost:8000/docs`
2. **Integrate with your mobile app** using the provided examples
3. **Set up monitoring** for production use
4. **Customize filters and sorting** based on your specific needs
5. **Use the research endpoints** for data analysis and reporting

The API now provides comprehensive data management capabilities with full CRUD operations, advanced filtering, sorting, search, and research functionality for your lab management system!
