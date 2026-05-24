# App Icon Setup Guide

## 📱 Android Icons

### Required Sizes:
- `mipmap-mdpi/ic_launcher.png` (48x48)
- `mipmap-hdpi/ic_launcher.png` (72x72)
- `mipmap-xhdpi/ic_launcher.png` (96x96)
- `mipmap-xxhdpi/ic_launcher.png` (144x144)
- `mipmap-xxxhdpi/ic_launcher.png` (192x192)

### Adaptive Icon (Android 8.0+):
- `mipmap-anydpi-v26/ic_launcher.xml`
- Foreground: 108x108 (transparent background)
- Background: 108x108 (solid color)

### File Locations:
```
android/app/src/main/res/
├── mipmap-mdpi/ic_launcher.png
├── mipmap-hdpi/ic_launcher.png
├── mipmap-xhdpi/ic_launcher.png
├── mipmap-xxhdpi/ic_launcher.png
├── mipmap-xxxhdpi/ic_launcher.png
└── mipmap-anydpi-v26/ic_launcher.xml
```

## 🍎 iOS Icons

### Required Sizes:
- `Icon-App-20x20@1x.png` (20x20)
- `Icon-App-20x20@2x.png` (40x40)
- `Icon-App-20x20@3x.png` (60x60)
- `Icon-App-29x29@1x.png` (29x29)
- `Icon-App-29x29@2x.png` (58x58)
- `Icon-App-29x29@3x.png` (87x87)
- `Icon-App-40x40@1x.png` (40x40)
- `Icon-App-40x40@2x.png` (80x80)
- `Icon-App-40x40@3x.png` (120x120)
- `Icon-App-60x60@2x.png` (120x120)
- `Icon-App-60x60@3x.png` (180x180)
- `Icon-App-76x76@1x.png` (76x76)
- `Icon-App-76x76@2x.png` (152x152)
- `Icon-App-83.5x83.5@2x.png` (167x167)
- `Icon-App-1024x1024@1x.png` (1024x1024)

### File Locations:
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── Icon-App-20x20@1x.png
├── Icon-App-20x20@2x.png
├── Icon-App-20x20@3x.png
├── Icon-App-29x29@1x.png
├── Icon-App-29x29@2x.png
├── Icon-App-29x29@3x.png
├── Icon-App-40x40@1x.png
├── Icon-App-40x40@2x.png
├── Icon-App-40x40@3x.png
├── Icon-App-60x60@2x.png
├── Icon-App-60x60@3x.png
├── Icon-App-76x76@1x.png
├── Icon-App-76x76@2x.png
├── Icon-App-83.5x83.5@2x.png
├── Icon-App-1024x1024@1x.png
└── Contents.json
```

## 🎨 Design Recommendations

### Based on Your Lab Management Image:
1. **Primary Element**: Laboratory flask with teal liquid
2. **Secondary Element**: Clipboard with checkmark
3. **Color Scheme**: 
   - Teal (#008080) - for liquid and clipboard clip
   - Blue (#0066CC) - for clipboard outline and checkmark
   - Dark Grey (#333333) - for text and outlines
   - White (#FFFFFF) - for background

### Icon Generation Tools:
1. **App Icon Generator**: https://appicon.co/
2. **MakeAppIcon**: https://makeappicon.com/
3. **Icon Kitchen**: https://icon.kitchen/

## 📋 Setup Steps:

1. **Generate Icons**: Use one of the online tools above
2. **Download Package**: Get the complete icon set
3. **Replace Files**: Copy new icons to the specified locations
4. **Test**: Run the app to verify icons appear correctly
5. **Rebuild**: Create new AAB/IPA files with updated icons

## ⚠️ Important Notes:

- **iOS Icons**: Must have solid background (no transparency)
- **Android Icons**: Can have transparent background
- **1024x1024**: Required for App Store submission
- **Test on Devices**: Verify icons look good on actual devices
