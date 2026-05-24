# API Connection Fix Guide

This guide explains the fixes implemented to resolve the localhost connection issue in your Flutter mobile app.

## Problem
When running the app on a device or emulator, `localhost` no longer points to your computer - it points to the device itself. This causes "SocketConnection refused" errors when trying to connect to your backend API.

## Solution Implemented

### 1. Dynamic Base URL Configuration

The app now automatically selects the correct base URL based on the platform and environment:

- **iOS Simulator**: `http://localhost:3003/api`
- **Android Emulator**: `http://10.0.2.2:3003/api`
- **Physical Devices**: `http://192.168.4.152:3003/api` (your backend server)
- **Production**: `https://api.yourdomain.com/api`

### 2. Network Security Configuration

#### Android
- Added `android:usesCleartextTraffic="true"` to `AndroidManifest.xml`
- Created `network_security_config.xml` to allow HTTP for development domains
- Allows cleartext traffic for: localhost, 10.0.2.2, 10.0.3.2, 192.168.4.152

#### iOS
- Added App Transport Security settings to `Info.plist`
- Allows arbitrary loads for development
- Can be configured for specific domains only

### 3. New Utility Classes

#### `ApiUtils` (`lib/utils/api_utils.dart`)
- Provides methods to get correct base URLs
- Includes connectivity testing
- Debugging utilities

#### `ApiTestScreen` (`lib/screens/api_test_screen.dart`)
- Visual interface to test API connectivity
- Shows current configuration
- Provides troubleshooting guide

## How to Use

### 1. For Physical Devices

1. Find your Mac's LAN IP address:
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1
   ```

2. Update the IP address in `lib/utils/constants.dart`:
   ```dart
   static String get baseUrlForPhysicalDevice {
     if (kReleaseMode) {
       return 'https://api.yourdomain.com/api';
     }
     return 'http://YOUR_ACTUAL_IP:3003/api'; // Replace with your IP
   }
   ```

3. Also update `lib/utils/api_utils.dart`:
   ```dart
   static String getMacLanIp() {
     return 'YOUR_ACTUAL_IP'; // Replace with your actual IP
   }
   ```

### 2. Backend Server Configuration

Make sure your backend server binds to `0.0.0.0` instead of `127.0.0.1`:

```javascript
// Node.js/Express example
app.listen(3003, '0.0.0.0', () => {
  console.log('API server running on 0.0.0.0:3003');
});
```

### 3. CORS Configuration

Add CORS support to your backend to allow requests from the app:

```javascript
const cors = require('cors');

app.use(cors({
  origin: [
    'http://localhost',
    'http://10.0.2.2',
    'http://192.168.4.152', // Your backend server IP
  ],
  credentials: true
}));
```

### 4. Testing the Connection

#### Using the API Test Screen
1. Navigate to the API Test Screen in your app
2. Tap "Run API Tests"
3. Review the results and follow the troubleshooting guide

#### Using Console Logs
The app now prints configuration information to the console:
```
=== API Configuration ===
Platform: android
Release Mode: false
Base URL: http://10.0.2.2:3003/api
Physical Device URL: http://192.168.4.152:3003/api
========================
```

### 5. Manual Testing

Test connectivity from the device:
```bash
# From device terminal or browser
curl http://192.168.4.152:3003/api/health
```

## Environment-Specific URLs

| Environment | Base URL | Notes |
|-------------|----------|-------|
| iOS Simulator | `http://localhost:3003/api` | Maps to Mac host |
| Android Emulator | `http://10.0.2.2:3003/api` | Standard Android emulator |
| Genymotion | `http://10.0.3.2:3003/api` | Different IP for Genymotion |
| Physical Device | `http://192.168.4.152:3003/api` | Same WiFi network required |
| Production | `https://api.yourdomain.com/api` | Use HTTPS |

## Troubleshooting

### Common Issues

1. **Connection Refused**
   - Ensure backend is running on port 3003
   - Verify backend binds to `0.0.0.0`
   - Check firewall settings

2. **CORS Errors**
   - Add CORS middleware to backend
   - Include all necessary origins

3. **Physical Device Can't Connect**
   - Verify device and Mac are on same WiFi
   - Update IP address in constants
   - Test with `curl` from device

4. **Android Emulator Issues**
   - Use `10.0.2.2` for standard emulator
   - Use `10.0.3.2` for Genymotion

### Debug Steps

1. Run the API Test Screen
2. Check console logs for configuration
3. Test with `curl` from device
4. Verify backend is accessible from Mac browser
5. Check network security configuration

## Production Considerations

Before releasing to production:

1. **Remove HTTP allowances**:
   - Set `android:usesCleartextTraffic="false"`
   - Remove `NSAllowsArbitraryLoads` from iOS
   - Use domain-specific exceptions only

2. **Use HTTPS**:
   - Update production URL to use HTTPS
   - Configure SSL certificates

3. **Security**:
   - Remove debugging code
   - Use proper CORS configuration
   - Implement proper authentication

## Files Modified

- `lib/utils/constants.dart` - Dynamic base URL configuration
- `lib/utils/api_utils.dart` - New utility class
- `lib/services/api_service.dart` - Enhanced with debugging
- `lib/screens/api_test_screen.dart` - New test screen
- `android/app/src/main/AndroidManifest.xml` - Network security
- `android/app/src/main/res/xml/network_security_config.xml` - New config file
- `ios/Runner/Info.plist` - App Transport Security

## Next Steps

1. Update the IP address in the constants files with your actual Mac LAN IP
2. Ensure your backend server is running and binding to `0.0.0.0:3003`
3. Test the connection using the API Test Screen
4. Verify all API endpoints work correctly
5. Remove debugging code before production release
