# 🔌 API Connection Setup Guide

## 🚨 **Current Issue: API Connection Errors**

Your app is currently configured to connect to `localhost:3003`, but you're trying to connect to Apple and Android APIs. Here's how to fix this:

## 🍎 **Apple App Store Connect API Setup**

### Step 1: Get API Credentials
1. **Go to App Store Connect**: https://appstoreconnect.apple.com
2. **Navigate to**: Users and Access → Keys
3. **Create API Key**:
   - Click "+" to create new key
   - Give it a name (e.g., "Lab Mobile App API")
   - Select permissions (Admin or App Manager)
   - Download the `.p8` file

### Step 2: Update Configuration
Replace the placeholder values in `lib/utils/constants.dart`:

```dart
// Apple App Store Connect API
static const String appStoreConnectApiKey = 'YOUR_ACTUAL_API_KEY';
static const String appStoreConnectIssuerId = 'YOUR_ACTUAL_ISSUER_ID';
static const String appStoreConnectKeyId = 'YOUR_ACTUAL_KEY_ID';
```

### Step 3: Update AppleApiService
In `lib/services/apple_api_service.dart`, replace the placeholder:

```dart
Future<String> _generateJWTToken() async {
  // Implement JWT token generation using your .p8 file
  // This requires the 'jose' package for JWT signing
  return 'YOUR_ACTUAL_JWT_TOKEN';
}
```

## 🤖 **Google Play Console API Setup**

### Step 1: Create Service Account
1. **Go to Google Cloud Console**: https://console.cloud.google.com
2. **Create Project** (if not exists)
3. **Enable Google Play Android Developer API**
4. **Create Service Account**:
   - Go to IAM & Admin → Service Accounts
   - Click "Create Service Account"
   - Download the JSON key file

### Step 2: Update Configuration
Replace the placeholder values in `lib/utils/constants.dart`:

```dart
// Google Play Console API
static const String googlePlayServiceAccountEmail = 'YOUR_ACTUAL_SERVICE_ACCOUNT_EMAIL';
static const String googlePlayPrivateKey = 'YOUR_ACTUAL_PRIVATE_KEY';
```

### Step 3: Update GooglePlayApiService
In `lib/services/google_play_api_service.dart`, replace the placeholder:

```dart
Future<String> _generateOAuth2Token() async {
  // Implement OAuth2 token generation using your service account
  // This requires the 'googleapis_auth' package
  return 'YOUR_ACTUAL_OAUTH2_TOKEN';
}
```

## 🔧 **Required Dependencies**

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  jose: ^0.3.2  # For JWT token generation
  googleapis_auth: ^1.4.1  # For Google OAuth2
  googleapis: ^11.0.0  # For Google APIs
```

## 🧪 **Testing API Connections**

### Option 1: Use Debug Tools
1. **Open the app**
2. **Go to Settings → Debug Tools**
3. **Click "Test All Store APIs"**

### Option 2: Command Line Testing
```bash
# Test Apple API
flutter run --debug
# Then use the debug tools in the app

# Test Google Play API
flutter run --debug
# Then use the debug tools in the app
```

## 📋 **Quick Setup Checklist**

### Apple App Store Connect:
- [ ] API Key created and downloaded
- [ ] Issuer ID copied
- [ ] Key ID copied
- [ ] Constants updated
- [ ] JWT token generation implemented

### Google Play Console:
- [ ] Service account created
- [ ] JSON key file downloaded
- [ ] API enabled
- [ ] Constants updated
- [ ] OAuth2 token generation implemented

### General:
- [ ] Dependencies added to pubspec.yaml
- [ ] `flutter pub get` run
- [ ] API connections tested
- [ ] Error handling implemented

## 🚨 **Common Issues & Solutions**

### Issue 1: "Invalid API Key"
**Solution**: Ensure you're using the correct API key format and it has the right permissions.

### Issue 2: "Authentication Failed"
**Solution**: Check that your JWT token/OAuth2 token is being generated correctly.

### Issue 3: "Permission Denied"
**Solution**: Verify that your service account has the necessary permissions in Google Play Console.

### Issue 4: "Network Error"
**Solution**: Check your internet connection and firewall settings.

## 🔄 **Alternative: Use Transporter/Xcode**

If API setup is complex, you can still submit using:

### Apple:
- **Transporter App**: Drag and drop your IPA file
- **Xcode**: Archive and upload directly

### Google Play:
- **Google Play Console**: Upload AAB file directly
- **Fastlane**: Automated deployment tool

## 📞 **Next Steps**

1. **Set up API credentials** (Apple & Google)
2. **Update configuration files**
3. **Test connections** using debug tools
4. **Implement proper error handling**
5. **Deploy your app** with working API connections

## 🎯 **Immediate Action Required**

To fix your current connection issues:

1. **Decide**: Do you want to use APIs or manual upload?
2. **If APIs**: Follow the setup guide above
3. **If Manual**: Use Transporter/Xcode for Apple, Play Console for Google
4. **Test**: Verify connections work before submission

Your app is ready for submission - you just need to choose your preferred method! 🚀
