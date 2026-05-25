# SAEED Laboratory Mobile App

A Flutter mobile application for the Medical Laboratory Management System, providing a modern mobile interface for managing patients, tests, appointments, and generating reports.

## Features

### ✅ Implemented Features
- **Authentication System**: Secure login with token-based authentication
- **Modern UI/UX**: Material Design 3 with light/dark theme support
- **State Management**: Provider pattern for efficient state management
- **API Integration**: Full integration with the laboratory management backend
- **Responsive Design**: Works on various screen sizes and orientations
- **Splash Screen**: Animated splash screen with app branding

### 🚧 In Development
- **Dashboard**: Real-time statistics and overview
- **Patient Management**: Add, edit, view, and search patients
- **Test Management**: Create, update, and track laboratory tests
- **Report Generation**: Generate and view test reports
- **Appointment Scheduling**: Manage patient appointments
- **Payment Tracking**: Track payments and billing
- **Offline Support**: Cache data for offline access
- **Push Notifications**: Real-time notifications for test results

## Screenshots

*Screenshots will be added once the app is fully implemented*

## Getting Started

### Prerequisites

- **Flutter SDK**: Version 3.4.4 or higher
- **Dart SDK**: Version 3.8.1 or higher
- **Android Studio** or **VS Code** with Flutter extensions
- **iOS Development**: Xcode (for iOS builds)
- **Backend Server**: The laboratory management system backend must be running

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd lab_mobile_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   - Open `lib/utils/constants.dart`
   - Update `baseUrl` to point to your backend server
   ```dart
   static const String baseUrl = 'http://your-server-ip:3003/api';
   ```

4. **Run the app**
   ```bash
   # For Android
   flutter run
   
   # For iOS
   flutter run -d ios
   
   # For specific device
   flutter devices
   flutter run -d <device-id>
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── patient.dart         # Patient model
│   ├── test.dart           # Test model
│   └── test_result.dart    # Test result model
├── providers/               # State management
│   ├── auth_provider.dart   # Authentication state
│   ├── patient_provider.dart # Patient data management
│   ├── test_provider.dart   # Test data management
│   ├── appointment_provider.dart # Appointment management
│   └── payment_provider.dart # Payment management
├── screens/                 # UI screens
│   ├── splash_screen.dart   # Splash screen
│   ├── login_screen.dart    # Login screen
│   └── home_screen.dart     # Main navigation
├── services/                # API services
│   └── api_service.dart     # HTTP API client
├── utils/                   # Utilities
│   ├── constants.dart       # App constants
│   └── theme.dart          # App themes
└── widgets/                 # Reusable widgets
    └── (to be implemented)
```

## Dependencies

### Core Dependencies
- **flutter**: The Flutter framework
- **provider**: State management
- **http**: HTTP requests
- **shared_preferences**: Local storage
- **flutter_local_notifications**: Push notifications

### UI Dependencies
- **flutter_svg**: SVG support
- **cached_network_image**: Image caching
- **fl_chart**: Charts and graphs
- **flutter_spinkit**: Loading animations
- **shimmer**: Shimmer loading effects

### Utility Dependencies
- **intl**: Internationalization
- **qr_flutter**: QR code generation
- **pdf**: PDF generation
- **printing**: Print functionality
- **image_picker**: Image selection
- **permission_handler**: Permissions
- **connectivity_plus**: Network connectivity

## Configuration

### API Configuration
The app connects to the laboratory management backend API. Configure the API endpoint in `lib/utils/constants.dart`:

```dart
static const String baseUrl = 'http://localhost:3003/api';
```

### Theme Configuration
Customize the app theme in `lib/utils/theme.dart`:

```dart
// Primary colors
static const Color primaryColor = Color(0xFF2C3E50);
static const Color secondaryColor = Color(0xFF3498DB);
```

### Build Configuration

#### Android
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Compile SDK: 34

#### iOS
- Minimum iOS: 12.0
- Target iOS: 17.0

## Development

### Code Style
The project follows Flutter's official style guide and uses `flutter_lints` for code analysis.

### State Management
The app uses the Provider pattern for state management:
- **AuthProvider**: Manages authentication state
- **PatientProvider**: Manages patient data
- **TestProvider**: Manages test data
- **AppointmentProvider**: Manages appointments
- **PaymentProvider**: Manages payments

### API Integration
All API calls are handled through the `ApiService` class, which provides:
- Automatic token management
- Error handling
- Request/response logging
- Offline fallback

## Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter test integration_test/
```

## Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Desktop (Windows, macOS, Linux)

Flutter desktop targets are enabled for lab staff on computers.

### Prerequisites
- Flutter SDK with desktop support: `flutter doctor`
- **macOS**: Xcode 15+, macOS 10.15+
- **Windows**: Visual Studio 2022 with Desktop development with C++
- **Linux**: `clang`, `cmake`, `ninja-build`, `pkg-config`, GTK 3

### Build (with `.env`)
```bash
cd lab_mobile_app
cp .env.example .env   # fill API keys
chmod +x scripts/run_with_env.sh
./scripts/run_with_env.sh --build-desktop
```

### Output
| OS | Artifact |
|----|----------|
| **macOS** (on Mac) | `build/release-submission/desktop/SaeedLab-{version}-macos.zip` → **Saeed Lab.app** |
| **Linux** (on Linux) | `SaeedLab-{version}-linux-x64.tar.gz` |
| **Windows** (on Windows) | `SaeedLab-{version}-windows-x64.zip` |

Run on macOS: unzip, open **Saeed Lab.app** (System Settings → Privacy → allow if blocked).

**Note:** App Store / Google Play subscriptions are mobile-only. Desktop uses the same lab API, offline SQLite, and per-lab Stripe for patient payments.

## Deployment

### Google Play Store
1. Build the app bundle
2. Create a release in Google Play Console
3. Upload the AAB file
4. Configure store listing and release notes

### Apple App Store
1. Build the iOS app
2. Archive in Xcode
3. Upload to App Store Connect
4. Configure app metadata and screenshots

## Troubleshooting

### Common Issues

**Build Errors**
- Ensure Flutter SDK is up to date
- Run `flutter clean` and `flutter pub get`
- Check for dependency conflicts

**API Connection Issues**
- Verify backend server is running
- Check API endpoint configuration
- Ensure network connectivity

**iOS Build Issues**
- Update Xcode to latest version
- Check iOS deployment target
- Verify signing certificates

**Android Build Issues**
- Update Android SDK
- Check Gradle configuration
- Verify signing configuration

### Debug Mode
```bash
flutter run --debug
```

### Profile Mode
```bash
flutter run --profile
```

### Release Mode
```bash
flutter run --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support and questions:
1. Check the troubleshooting section
2. Review the API documentation
3. Check the backend server status
4. Contact the development team

---

**Note**: This mobile app is designed to work with the SAEED Laboratory Management System backend. Ensure the backend is properly configured and running before using the mobile app.
