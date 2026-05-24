# 🚀 Lab Management System - Complete Data Access Guide

## ✅ Database Successfully Deployed!

Your database has been successfully deployed to the backend with all 12 tables and comprehensive data management capabilities.

## 🌐 Access Your Data

### 1. **API Server Status**
- **Server**: Running on `http://localhost:8000`
- **Interactive Docs**: `http://localhost:8000/docs`
- **Health Check**: `http://localhost:8000/api/health`

### 2. **Default Login**
- **Username**: `admin`
- **Password**: `admin123`

## 📊 Complete Data Management Features

### 🔍 **PATIENT DATA MANAGEMENT**

#### View All Patients
```bash
GET http://localhost:8000/api/data/patients
```

#### Search & Filter Patients
```bash
# Search by name, phone, email
GET http://localhost:8000/api/data/patients?search=john

# Filter by gender
GET http://localhost:8000/api/data/patients?gender=Male

# Sort by name (A-Z)
GET http://localhost:8000/api/data/patients?sort_by=full_name&sort_order=asc

# Pagination
GET http://localhost:8000/api/data/patients?skip=0&limit=50
```

#### Patient CRUD Operations
```bash
# Create new patient
POST http://localhost:8000/api/data/patients
{
  "full_name": "John Doe",
  "date_of_birth": "1990-05-15",
  "gender": "Male",
  "phone": "+1234567890",
  "email": "john@example.com"
}

# Update patient
PUT http://localhost:8000/api/data/patients/P001
{
  "phone": "+1234567892",
  "email": "john.doe@example.com"
}

# Delete patient
DELETE http://localhost:8000/api/data/patients/P001
```

### 🧪 **TEST DATA MANAGEMENT**

#### View All Tests
```bash
GET http://localhost:8000/api/data/tests
```

#### Advanced Test Filtering
```bash
# Filter by status
GET http://localhost:8000/api/data/tests?status=Pending

# Filter by test type
GET http://localhost:8000/api/data/tests?test_type=Blood Test (CBC)

# Filter by priority
GET http://localhost:8000/api/data/tests?priority=Urgent

# Filter by patient
GET http://localhost:8000/api/data/tests?patient_id=P001

# Sort by date (newest first)
GET http://localhost:8000/api/data/tests?sort_by=ordered_date&sort_order=desc
```

#### Test CRUD Operations
```bash
# Create new test
POST http://localhost:8000/api/data/tests
{
  "patient_id": "P001",
  "test_type": "Blood Test (CBC)",
  "test_name": "Complete Blood Count",
  "price": 150.00,
  "priority": "Normal"
}

# Update test status
PATCH http://localhost:8000/api/data/tests/T001/status
{
  "status": "Completed"
}
```

### 📊 **TEST RESULTS MANAGEMENT**

#### View Test Results
```bash
GET http://localhost:8000/api/data/tests/T001/results
```

#### Add Test Results
```bash
POST http://localhost:8000/api/data/tests/T001/results
{
  "parameter": "Hemoglobin",
  "value": "14.5",
  "unit": "g/dL",
  "reference_range": "12.0-16.0",
  "is_abnormal": false
}
```

### 📅 **APPOINTMENT MANAGEMENT**

#### View All Appointments
```bash
GET http://localhost:8000/api/data/appointments
```

#### Filter Appointments
```bash
# Filter by date
GET http://localhost:8000/api/data/appointments?date=2024-01-15

# Filter by status
GET http://localhost:8000/api/data/appointments?status=Scheduled

# Filter by test type
GET http://localhost:8000/api/data/appointments?test_type=Blood Test

# Sort by date and time
GET http://localhost:8000/api/data/appointments?sort_by=appointment_date&sort_order=asc
```

#### Create Appointments
```bash
POST http://localhost:8000/api/data/appointments
{
  "patient_id": "P001",
  "appointment_date": "2024-01-15",
  "appointment_time": "10:00:00",
  "test_type": "Blood Test (CBC)",
  "doctor_name": "Dr. Smith"
}
```

### 💰 **PAYMENT MANAGEMENT**

#### View All Payments
```bash
GET http://localhost:8000/api/data/payments
```

#### Filter Payments
```bash
# Filter by status
GET http://localhost:8000/api/data/payments?status=Completed

# Filter by payment method
GET http://localhost:8000/api/data/payments?payment_method=Cash

# Sort by amount (highest first)
GET http://localhost:8000/api/data/payments?sort_by=amount&sort_order=desc
```

#### Create Payments
```bash
POST http://localhost:8000/api/data/payments
{
  "test_id": "T001",
  "amount": 150.00,
  "payment_method": "Cash",
  "transaction_id": "TXN123456"
}
```

## 🔬 **RESEARCH & ANALYTICS**

### System Statistics
```bash
GET http://localhost:8000/api/data/research/statistics
```
Returns:
- Total patients, tests, appointments, payments
- Completion rates and efficiency scores
- Revenue analytics
- Pending items

### Recent Activities
```bash
GET http://localhost:8000/api/data/research/activities?limit=20
```

### Advanced Search
```bash
# Search across all entities
GET http://localhost:8000/api/data/research/search?query=john

# Search specific entity type
GET http://localhost:8000/api/data/research/search?query=blood&entity_type=tests
```

### Data Export for Research
```bash
# Export patients data
GET http://localhost:8000/api/data/research/export?entity_type=patients&format=json

# Export tests with filters
GET http://localhost:8000/api/data/research/export?entity_type=tests&format=json&filters={"status":"Completed"}

# Export appointments for specific date
GET http://localhost:8000/api/data/research/export?entity_type=appointments&format=json&filters={"date":"2024-01-15"}
```

## 📱 **Mobile App Integration**

### Update Your Flutter App

1. **Update API Constants** in `lib/utils/constants.dart`:
```dart
class AppConstants {
  static const String baseUrl = 'http://localhost:8000/api';
  
  // New data management endpoints
  static const String dataPatientsEndpoint = '/data/patients';
  static const String dataTestsEndpoint = '/data/tests';
  static const String dataAppointmentsEndpoint = '/data/appointments';
  static const String dataPaymentsEndpoint = '/data/payments';
  static const String dataResearchEndpoint = '/data/research';
}
```

2. **Example API Calls** in your Flutter app:
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

## 🛠️ **Advanced Usage Examples**

### Complex Filtering
```bash
# Get urgent blood tests sorted by date
GET http://localhost:8000/api/data/tests?priority=Urgent&test_type=Blood Test&sort_by=ordered_date&sort_order=desc

# Get completed payments above $100
GET http://localhost:8000/api/data/payments?status=Completed&sort_by=amount&sort_order=desc
```

### Bulk Operations
```bash
# Get all pending tests for a patient
GET http://localhost:8000/api/data/tests?patient_id=P001&status=Pending

# Get all appointments for today
GET http://localhost:8000/api/data/appointments?date=2024-01-15
```

## 🔐 **Authentication**

All endpoints require authentication. Include the token in your requests:

```bash
# Get token first
curl -X POST "http://localhost:8000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'

# Use token in subsequent requests
curl -X GET "http://localhost:8000/api/data/patients" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## 📊 **Available Data Operations**

### ✅ **Create** - Add new records
- Patients, Tests, Appointments, Payments, Test Results

### ✅ **Read** - View and retrieve data
- All entities with filtering, sorting, and search
- Related data inclusion (tests with results, patients with appointments)

### ✅ **Update** - Modify existing records
- Patient information, test status, appointment details

### ✅ **Delete** - Remove records
- Patients, tests, appointments (with cascade protection)

### ✅ **Search** - Find specific data
- Text search across names, IDs, phone numbers
- Advanced search with multiple criteria

### ✅ **Sort** - Organize data
- Sort by any field (name, date, amount, status)
- Ascending and descending order

### ✅ **Filter** - Narrow down results
- Filter by status, type, date, priority
- Multiple filter combinations

### ✅ **Research** - Analyze data
- System statistics and analytics
- Data export for external analysis
- Activity tracking and reporting

## 🎯 **Quick Start Commands**

### Test the API
```bash
# 1. Check server status
curl http://localhost:8000/api/health

# 2. Get authentication token
curl -X POST "http://localhost:8000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'

# 3. Test patient endpoint
curl -X GET "http://localhost:8000/api/data/patients" \
  -H "Authorization: Bearer YOUR_TOKEN"

# 4. Test research statistics
curl -X GET "http://localhost:8000/api/data/research/statistics" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 🚀 **What You Can Do Now**

1. **Access all your data** through the comprehensive API
2. **Search and filter** any information you need
3. **Sort data** by any criteria
4. **Create, edit, copy, delete** records as needed
5. **Research and analyze** your data with advanced tools
6. **Export data** for external analysis
7. **Integrate with your mobile app** seamlessly

Your lab management system now has complete data access with all the operations you requested: **sort, edit, copy, delete, and research with multiple options!**

## 📞 **Need Help?**

- **Interactive API Docs**: `http://localhost:8000/docs`
- **Health Check**: `http://localhost:8000/api/health`
- **Complete Documentation**: Check the `API_USAGE_GUIDE.md` file

Your database is deployed and ready for full data management operations! 🎉
