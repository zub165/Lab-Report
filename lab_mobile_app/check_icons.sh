#!/bin/bash

echo "🔍 Checking Android Icon Structure..."
echo "=================================="

# Check Android icons
android_path="android/app/src/main/res"
if [ -d "$android_path" ]; then
    echo "✅ Android res directory exists"
    
    # Check mipmap directories
    for density in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
        icon_file="$android_path/mipmap-$density/ic_launcher.png"
        if [ -f "$icon_file" ]; then
            echo "✅ $icon_file exists"
        else
            echo "❌ $icon_file missing"
        fi
    done
    
    # Check adaptive icon
    adaptive_file="$android_path/mipmap-anydpi-v26/ic_launcher.xml"
    if [ -f "$adaptive_file" ]; then
        echo "✅ $adaptive_file exists"
    else
        echo "❌ $adaptive_file missing"
    fi
else
    echo "❌ Android res directory not found"
fi

echo ""
echo "🍎 Checking iOS Icon Structure..."
echo "================================"

# Check iOS icons
ios_path="ios/Runner/Assets.xcassets/AppIcon.appiconset"
if [ -d "$ios_path" ]; then
    echo "✅ iOS AppIcon.appiconset directory exists"
    
    # Check key iOS icon files
    ios_icons=(
        "Icon-App-20x20@1x.png"
        "Icon-App-29x29@1x.png"
        "Icon-App-40x40@1x.png"
        "Icon-App-60x60@2x.png"
        "Icon-App-76x76@1x.png"
        "Icon-App-1024x1024@1x.png"
        "Contents.json"
    )
    
    for icon in "${ios_icons[@]}"; do
        icon_file="$ios_path/$icon"
        if [ -f "$icon_file" ]; then
            echo "✅ $icon exists"
        else
            echo "❌ $icon missing"
        fi
    done
else
    echo "❌ iOS AppIcon.appiconset directory not found"
fi

echo ""
echo "📋 Next Steps:"
echo "1. Generate icons from your Lab Management image"
echo "2. Replace the existing icon files"
echo "3. Test the app to verify icons appear correctly"
echo "4. Rebuild AAB/IPA files with new icons"
