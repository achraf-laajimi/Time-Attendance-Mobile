#!/bin/bash

# Flutter Time Attendance App - Deploy to Khaled's iPhone
# This script automates the complete deployment process including all necessary fixes
# 
# Prerequisites:
# - Xcode installed with iOS development tools
# - Flutter SDK installed and in PATH
# - CocoaPods installed (gem install cocoapods)
# - Apple Developer account configured
# - iPhone connected (wirelessly or via cable)

set -e  # Exit on any error

# Configuration
DEVICE_ID="00008120-001A1C3436B8201E"  # Khaled's iPhone
BUNDLE_ID="com.benchehidak.timeattendance"
PROJECT_DIR="$(dirname "$0")"
IOS_DIR="$PROJECT_DIR/ios"

echo "🚀 Starting Flutter Time Attendance App deployment to Khaled's iPhone..."
echo "📱 Target Device ID: $DEVICE_ID"
echo "📦 Bundle ID: $BUNDLE_ID"
echo "📁 Project Directory: $PROJECT_DIR"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "🔍 Checking prerequisites..."

if ! command_exists flutter; then
    echo "❌ Flutter not found in PATH. Please install Flutter and add it to your PATH."
    exit 1
fi

if ! command_exists pod; then
    echo "❌ CocoaPods not found. Installing..."
    sudo gem install cocoapods
fi

if ! command_exists xcodebuild; then
    echo "❌ Xcode command line tools not found. Please install Xcode."
    exit 1
fi

echo "✅ All prerequisites met"
echo ""

# Step 1: Clean previous builds
echo "🧹 Cleaning previous builds..."
cd "$PROJECT_DIR"
flutter clean
rm -rf "$IOS_DIR/Pods"
rm -f "$IOS_DIR/Podfile.lock"
rm -rf "$IOS_DIR/.symlinks"
rm -rf build/
echo "✅ Clean completed"
echo ""

# Step 2: Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get
echo "✅ Flutter dependencies updated"
echo ""

# Step 3: Verify and fix bundle identifier in project.pbxproj
echo "🔧 Verifying bundle identifier configuration..."
PBXPROJ_FILE="$IOS_DIR/Runner.xcodeproj/project.pbxproj"

if [ ! -f "$PBXPROJ_FILE" ]; then
    echo "❌ project.pbxproj file not found at $PBXPROJ_FILE"
    exit 1
fi

# Check current bundle identifier
CURRENT_BUNDLE_ID=$(grep -o 'PRODUCT_BUNDLE_IDENTIFIER = [^;]*' "$PBXPROJ_FILE" | head -1 | sed 's/PRODUCT_BUNDLE_IDENTIFIER = //' | tr -d '"')

if [ "$CURRENT_BUNDLE_ID" != "$BUNDLE_ID" ]; then
    echo "🔄 Updating bundle identifier from '$CURRENT_BUNDLE_ID' to '$BUNDLE_ID'..."
    
    # Create backup
    cp "$PBXPROJ_FILE" "$PBXPROJ_FILE.backup"
    
    # Replace all occurrences of the old bundle identifier with the new one
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.example\.inOut/PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID/g" "$PBXPROJ_FILE"
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = \"com\.example\.inOut\"/PRODUCT_BUNDLE_IDENTIFIER = \"$BUNDLE_ID\"/g" "$PBXPROJ_FILE"
    
    # Verify the change
    UPDATED_COUNT=$(grep -c "$BUNDLE_ID" "$PBXPROJ_FILE" || true)
    echo "✅ Bundle identifier updated in $UPDATED_COUNT locations"
else
    echo "✅ Bundle identifier already correct: $BUNDLE_ID"
fi
echo ""

# Step 4: Install CocoaPods dependencies
echo "🍫 Installing CocoaPods dependencies..."
cd "$IOS_DIR"
pod install --repo-update --verbose
cd "$PROJECT_DIR"
echo "✅ CocoaPods installation completed"
echo ""

# Step 5: Check for connected devices
echo "📱 Checking for connected devices..."
flutter devices

# Verify target device is available
if ! flutter devices | grep -q "$DEVICE_ID"; then
    echo "⚠️  Warning: Target device $DEVICE_ID not found in connected devices."
    echo "   Please ensure:"
    echo "   - iPhone is connected via cable or wireless"
    echo "   - Device is unlocked and trusted"
    echo "   - Developer mode is enabled on the device"
    echo ""
    echo "   Available devices:"
    flutter devices
    echo ""
    read -p "   Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Deployment cancelled"
        exit 1
    fi
fi
echo ""

# Step 6: Build and deploy to iPhone
echo "🏗️  Building and deploying to iPhone..."
echo "   This may take several minutes..."

if flutter devices | grep -q "$DEVICE_ID"; then
    # Deploy to specific device
    flutter run -d "$DEVICE_ID" --release
else
    # Deploy to any available iOS device
    echo "⚠️  Deploying to any available iOS device..."
    flutter run --release
fi

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Summary of actions performed:"
echo "   ✅ Cleaned previous builds and CocoaPods cache"
echo "   ✅ Updated Flutter dependencies"
echo "   ✅ Verified/fixed bundle identifier: $BUNDLE_ID"
echo "   ✅ Reinstalled CocoaPods dependencies"
echo "   ✅ Built and deployed app to iPhone"
echo ""
echo "💡 Tips for future deployments:"
echo "   - Keep this script in the project root"
echo "   - Ensure iPhone is connected and trusted before running"
echo "   - Run 'flutter doctor' if you encounter issues"
echo "   - Check Apple Developer certificate if signing fails"
echo ""
