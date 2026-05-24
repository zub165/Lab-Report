# 🚀 Django Lab Management Backend Setup Guide

## 📋 **PREREQUISITES**

Before setting up the Django backend, ensure you have:

- Python 3.8+ installed
- pip (Python package manager)
- MySQL or PostgreSQL database (optional, SQLite works for development)
- Git (for version control)

## 🔧 **STEP 1: BACKEND DEPLOYMENT**

### Option A: Local Development Setup

1. **Create Django Project Directory:**
```bash
mkdir django_lab_management
cd django_lab_management
```

2. **Set up Virtual Environment:**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install Dependencies:**
```bash
pip install django==4.2.7
pip install djangorestframework==3.14.0
pip install djangorestframework-simplejwt==5.3.0
pip install django-cors-headers==4.3.1
pip install mysqlclient==2.2.0  # For MySQL
# OR
pip install psycopg2-binary==2.9.7  # For PostgreSQL
```

4. **Create Django Project:**
```bash
django-admin startproject hospital_finder_django
cd hospital_finder_django
python manage.py startapp lab_management
```

### Option B: Server Deployment

1. **Upload your Django project to the server**
2. **Install dependencies on the server**
3. **Configure database settings**
4. **Run migrations and create superuser**

## 🗄️ **STEP 2: DATABASE CONFIGURATION**

### For MySQL (Recommended for Production):

```python
# settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'lab_management_db',
        'USER': 'your_db_user',
        'PASSWORD': 'your_db_password',
        'HOST': 'localhost',
        'PORT': '3306',
    }
}
```

### For SQLite (Development):

```python
# settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}
```

## ⚙️ **STEP 3: DJANGO SETTINGS CONFIGURATION**

Create or update `settings.py`:

```python
import os
from datetime import timedelta

# ... existing settings ...

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'rest_framework_simplejwt',
    'corsheaders',
    'lab_management',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# JWT Configuration
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(hours=24),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': 'your-secret-key-here',
    'VERIFYING_KEY': None,
    'AUTH_HEADER_TYPES': ('Bearer',),
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
}

# REST Framework Configuration
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
}

# CORS Configuration
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://localhost:8080",
    "http://127.0.0.1:8080",
    # Add your Flutter app's origin
]

CORS_ALLOW_CREDENTIALS = True

# Security Settings
SECRET_KEY = 'your-secret-key-here'
DEBUG = False  # Set to False in production
ALLOWED_HOSTS = ['208.109.215.53', 'localhost', '127.0.0.1']

# Static Files
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

# Media Files
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')
```

## 🗃️ **STEP 4: CREATE MODELS**

Create `lab_management/models.py`:

```python
from django.db import models
from django.contrib.auth.models import User

class Patient(models.Model):
    patient_id = models.CharField(max_length=50, unique=True)
    full_name = models.CharField(max_length=200)
    date_of_birth = models.DateField()
    gender = models.CharField(max_length=10)
    phone = models.CharField(max_length=20)
    email = models.EmailField(blank=True, null=True)
    address = models.TextField(blank=True, null=True)
    blood_type = models.CharField(max_length=5, blank=True, null=True)
    medical_history = models.TextField(blank=True, null=True)
    insurance_info = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.full_name

class LabTest(models.Model):
    test_id = models.CharField(max_length=50, unique=True)
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    test_name = models.CharField(max_length=200)
    test_type = models.CharField(max_length=100)
    status = models.CharField(max_length=20, default='Pending')
    ordered_date = models.DateTimeField()
    completed_date = models.DateTimeField(null=True, blank=True)
    ordered_by = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    notes = models.TextField(blank=True, null=True)
    priority = models.CharField(max_length=20, default='Normal')
    test_results = models.JSONField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.test_name} - {self.patient.full_name}"

class Appointment(models.Model):
    appointment_id = models.CharField(max_length=50, unique=True)
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    appointment_type = models.CharField(max_length=100)
    scheduled_date = models.DateTimeField()
    duration_minutes = models.IntegerField(default=30)
    status = models.CharField(max_length=20, default='Scheduled')
    location = models.CharField(max_length=200)
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.patient.full_name} - {self.appointment_type}"

class Payment(models.Model):
    payment_id = models.CharField(max_length=50, unique=True)
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    test = models.ForeignKey(LabTest, on_delete=models.CASCADE, null=True, blank=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    payment_method = models.CharField(max_length=50)
    payment_date = models.DateTimeField()
    status = models.CharField(max_length=20, default='Pending')
    transaction_id = models.CharField(max_length=100, blank=True, null=True)
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.patient.full_name} - ${self.amount}"

class Report(models.Model):
    report_id = models.CharField(max_length=50, unique=True)
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    test = models.ForeignKey(LabTest, on_delete=models.CASCADE, null=True, blank=True)
    title = models.CharField(max_length=200)
    content = models.TextField()
    report_type = models.CharField(max_length=50)
    status = models.CharField(max_length=20, default='Draft')
    report_date = models.DateTimeField()
    authorized_by = models.CharField(max_length=100)
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.title} - {self.patient.full_name}"
```

## 🔗 **STEP 5: CREATE SERIALIZERS**

Create `lab_management/serializers.py`:

```python
from rest_framework import serializers
from .models import Patient, LabTest, Appointment, Payment, Report

class PatientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Patient
        fields = '__all__'

class LabTestSerializer(serializers.ModelSerializer):
    patient_name = serializers.CharField(source='patient.full_name', read_only=True)
    
    class Meta:
        model = LabTest
        fields = '__all__'

class AppointmentSerializer(serializers.ModelSerializer):
    patient_name = serializers.CharField(source='patient.full_name', read_only=True)
    
    class Meta:
        model = Appointment
        fields = '__all__'

class PaymentSerializer(serializers.ModelSerializer):
    patient_name = serializers.CharField(source='patient.full_name', read_only=True)
    test_name = serializers.CharField(source='test.test_name', read_only=True)
    
    class Meta:
        model = Payment
        fields = '__all__'

class ReportSerializer(serializers.ModelSerializer):
    patient_name = serializers.CharField(source='patient.full_name', read_only=True)
    test_name = serializers.CharField(source='test.test_name', read_only=True)
    
    class Meta:
        model = Report
        fields = '__all__'
```

## 🎯 **STEP 6: CREATE VIEWS**

Create `lab_management/views.py`:

```python
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Patient, LabTest, Appointment, Payment, Report
from .serializers import (
    PatientSerializer, LabTestSerializer, AppointmentSerializer,
    PaymentSerializer, ReportSerializer
)

class PatientViewSet(viewsets.ModelViewSet):
    queryset = Patient.objects.all()
    serializer_class = PatientSerializer
    permission_classes = [IsAuthenticated]

    @action(detail=True, methods=['get'])
    def comprehensive(self, request, pk=None):
        patient = self.get_object()
        tests = LabTest.objects.filter(patient=patient)
        appointments = Appointment.objects.filter(patient=patient)
        payments = Payment.objects.filter(patient=patient)
        
        data = {
            'patient': PatientSerializer(patient).data,
            'tests': LabTestSerializer(tests, many=True).data,
            'appointments': AppointmentSerializer(appointments, many=True).data,
            'payments': PaymentSerializer(payments, many=True).data,
        }
        return Response(data)

class LabTestViewSet(viewsets.ModelViewSet):
    queryset = LabTest.objects.all()
    serializer_class = LabTestSerializer
    permission_classes = [IsAuthenticated]

class AppointmentViewSet(viewsets.ModelViewSet):
    queryset = Appointment.objects.all()
    serializer_class = AppointmentSerializer
    permission_classes = [IsAuthenticated]

class PaymentViewSet(viewsets.ModelViewSet):
    queryset = Payment.objects.all()
    serializer_class = PaymentSerializer
    permission_classes = [IsAuthenticated]

class ReportViewSet(viewsets.ModelViewSet):
    queryset = Report.objects.all()
    serializer_class = ReportSerializer
    permission_classes = [IsAuthenticated]

# Health check endpoint
from django.http import JsonResponse

def health_check(request):
    return JsonResponse({
        'status': 'healthy',
        'message': 'Django Lab Management System is running',
        'version': '1.0.0'
    })
```

## 🛣️ **STEP 7: CONFIGURE URLS**

Create `lab_management/urls.py`:

```python
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from . import views

router = DefaultRouter()
router.register(r'patients', views.PatientViewSet)
router.register(r'tests', views.LabTestViewSet)
router.register(r'appointments', views.AppointmentViewSet)
router.register(r'payments', views.PaymentViewSet)
router.register(r'reports', views.ReportViewSet)

urlpatterns = [
    path('auth/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('health/', views.health_check, name='health_check'),
    path('', include(router.urls)),
]
```

Update main `urls.py`:

```python
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('lab/', include('lab_management.urls')),
]
```

## 🗄️ **STEP 8: RUN MIGRATIONS**

```bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
```

## 🚀 **STEP 9: START THE SERVER**

```bash
python manage.py runserver 0.0.0.0:3015
```

## 🧪 **STEP 10: TEST THE CONNECTION**

Run the test script:

```bash
dart test_django_backend_connection.dart
```

## 🔧 **STEP 11: FLUTTER APP INTEGRATION**

Your Flutter app is already configured to connect to:
- **Base URL**: `http://208.109.215.53:3015/lab`
- **Authentication**: JWT tokens via `/auth/token/`
- **All endpoints**: Already configured in `AppConstants`

## 📱 **STEP 12: TEST FLUTTER APP**

Run your Flutter app:

```bash
flutter run -d emulator-5554
```

The app should now successfully connect to your Django backend!

## 🎯 **EXPECTED RESULTS**

After setup, you should see:
- ✅ Health check returns 200 OK
- ✅ Authentication returns JWT tokens
- ✅ All API endpoints return data
- ✅ Flutter app connects without 403 errors
- ✅ All CRUD operations work properly

## 🆘 **TROUBLESHOOTING**

### Common Issues:

1. **Port 3015 not accessible**: Check firewall settings
2. **Database connection failed**: Verify database credentials
3. **CORS errors**: Update CORS_ALLOWED_ORIGINS
4. **JWT token errors**: Check SECRET_KEY configuration

### Debug Commands:

```bash
# Check if server is running
netstat -tulpn | grep 3015

# Test database connection
python manage.py dbshell

# Check Django logs
python manage.py runserver --verbosity=2
```

## 🎉 **SUCCESS!**

Once everything is set up, your Flutter lab management app will have full backend support with:
- ✅ User authentication
- ✅ Patient management
- ✅ Lab test management
- ✅ Appointment scheduling
- ✅ Payment processing
- ✅ Report generation
- ✅ Real-time data sync

The 403 authentication errors will be resolved, and all features will work seamlessly!
