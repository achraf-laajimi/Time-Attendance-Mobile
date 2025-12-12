# Flutter Time Attendance App - iPhone Deployment Guide

This guide helps you deploy the Flutter Time Attendance app to Khaled's iPhone from any macbook.

## 📱 Target Device
- **Device**: Khaled's iPhone
- **Device ID**: `00008120-001A1C3436B8201E`
- **iOS Version**: 18.4.1
- **Bundle ID**: `com.benchehidak.timeattendance`

## 🚀 Quick Deployment (Existing Setup)

If Flutter is already set up on your macbook:

```bash
# Navigate to project directory
cd /path/to/timeAttendance-Mobile

# Run the deployment script
./deploy_to_iphone.sh
```

## 🍎 New macbook Setup

If setting up on a fresh macbook:

### Step 1: Environment Setup
```bash
# Run the setup script to install Flutter, CocoaPods, etc.
./setup_macos_flutter.sh
```

### Step 2: Clone Project
```bash
# Clone the project to your desired location
git clone <repository-url> timeAttendance-Mobile
cd timeAttendance-Mobile
```

### Step 3: Configure Apple Developer Account
1. Open Xcode
2. Go to Xcode → Preferences → Accounts
3. Add your Apple ID: `benchehidak@icloud.com`
4. Download certificates and provisioning profiles

### Step 4: Deploy
```bash
./deploy_to_iphone.sh
```

## 🔧 Manual Deployment Steps

If you prefer to run commands manually or need to troubleshoot:

### 1. Clean Previous Builds
```bash
flutter clean
rm -rf ios/Pods
rm -f ios/Podfile.lock
```

### 2. Update Dependencies
```bash
flutter pub get
```

### 3. Install CocoaPods
```bash
cd ios
pod install --repo-update
cd ..
```

### 4. Connect iPhone
- Connect Khaled's iPhone via cable or wireless
- Ensure device is unlocked and trusted
- Verify connection: `flutter devices`

### 5. Deploy
```bash
# Deploy to specific device
flutter run -d 00008120-001A1C3436B8201E --release

# Or deploy to any available iOS device
flutter run --release
```

## 📋 Prerequisites

### Software Requirements
- **macOS** (Intel or Apple Silicon)
- **Xcode** (latest version recommended)
- **Flutter SDK** (installed via Homebrew or manual)
- **CocoaPods** (`gem install cocoapods`)
- **Git** (for cloning repository)

### Apple Developer Account
- Account: `benchehidak@icloud.com`
- Team ID: `S8975RH936`
- Valid development certificate
- Provisioning profile for bundle ID `com.benchehidak.timeattendance`

### iPhone Setup
- **Developer Mode enabled**
- **Device trusted** in computer
- **Connected** (cable or wireless)
- **Unlocked** during deployment

## 🐛 Troubleshooting

### Common Issues and Solutions

#### 1. "Framework 'Pods_Runner' not found"
```bash
# Clean and reinstall CocoaPods
rm -rf ios/Pods ios/Podfile.lock
cd ios && pod install --repo-update && cd ..
```

#### 2. "No provisioning profile found"
- Open `ios/Runner.xcworkspace` in Xcode
- Select Runner target → Signing & Capabilities
- Choose correct Team and Bundle Identifier

#### 3. "Device not found"
```bash
# Check connected devices
flutter devices

# Enable wireless debugging (iOS 15+)
# Settings → Privacy & Security → Developer Mode → ON
```

#### 4. "Build failed"
```bash
# Run Flutter doctor to check setup
flutter doctor

# Clean everything and retry
flutter clean && flutter pub get
```

### Getting Help
1. Run `flutter doctor -v` for detailed diagnostics
2. Check Xcode logs in Window → Devices and Simulators
3. Verify Apple Developer certificate status

## 📁 Project Structure

```
timeAttendance-Mobile/
├── deploy_to_iphone.sh      # Main deployment script
├── setup_macos_flutter.sh   # macOS environment setup
├── DEPLOYMENT_README.md     # This file
├── ios/                     # iOS-specific files
│   ├── Runner.xcworkspace   # Open this in Xcode if needed
│   └── Podfile             # CocoaPods dependencies
├── lib/                     # Flutter app source code
└── pubspec.yaml            # Flutter dependencies
```

## 🎯 Success Indicators

When deployment is successful, you should see:
- ✅ App icon appears on Khaled's iPhone
- ✅ App launches without crashes
- ✅ All features work as expected
- ✅ No certificate or signing errors

## 🔄 Updates and Changes

When making changes to the app:
1. Make your code changes
2. Test locally if possible
3. Run `./deploy_to_iphone.sh` to deploy updated version
4. The script handles cleaning and rebuilding automatically

---

**Created**: May 25, 2025  
**Last Updated**: May 25, 2025  
**Tested on**: macOS with Khaled's iPhone (iOS 18.4.1)
