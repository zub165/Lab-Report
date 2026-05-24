#!/bin/bash

echo "=== Finding Mac LAN IP Address ==="
echo ""

# Method 1: Using ifconfig
echo "Method 1 - Using ifconfig:"
ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -5
echo ""

# Method 2: Using ipconfig
echo "Method 2 - Using ipconfig:"
ipconfig getifaddr en0 2>/dev/null || echo "en0 not found"
ipconfig getifaddr en1 2>/dev/null || echo "en1 not found"
echo ""

# Method 3: Using networksetup
echo "Method 3 - Using networksetup:"
networksetup -getinfo "Wi-Fi" 2>/dev/null | grep "IP address" || echo "Wi-Fi not found"
networksetup -getinfo "Ethernet" 2>/dev/null | grep "IP address" || echo "Ethernet not found"
echo ""

echo "=== Instructions ==="
echo "1. Look for an IP address starting with 192.168.x.x or 10.0.x.x"
echo "2. Update the following files with your IP:"
echo "   - lib/utils/constants.dart (baseUrlForPhysicalDevice)"
echo "   - lib/utils/api_utils.dart (getMacLanIp method)"
echo "3. Make sure your device and Mac are on the same WiFi network"
echo "4. Test connectivity: curl http://YOUR_IP:3003/api/health"
echo ""
