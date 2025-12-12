#!/bin/bash

# Flutter Development Environment Setup for macOS
# Run this script on a new macbook to set up everything needed for Flutter iOS development

set -e  # Exit on any error

echo "🍎 Setting up Flutter development environment for macOS..."
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Homebrew is installed
if ! command_exists brew; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "✅ Homebrew already installed"
fi

# Update Homebrew
echo "🔄 Updating Homebrew..."
brew update

# Install Flutter via Homebrew
if ! command_exists flutter; then
    echo "🎯 Installing Flutter..."
    brew install --cask flutter
else
    echo "✅ Flutter already installed"
fi

# Install CocoaPods
if ! command_exists pod; then
    echo "🍫 Installing CocoaPods..."
    sudo gem install cocoapods
else
    echo "✅ CocoaPods already installed"
fi

# Check if Xcode is installed
if ! command_exists xcodebuild; then
    echo "⚠️  Xcode not found. Please install Xcode from the App Store."
    echo "   After installing Xcode:"
    echo "   1. Open Xcode and accept the license"
    echo "   2. Install additional components when prompted"
    echo "   3. Run: sudo xcode-select --install"
    echo ""
    open "https://apps.apple.com/us/app/xcode/id497799835"
    exit 1
else
    echo "✅ Xcode command line tools found"
fi

# Accept Xcode license
echo "📋 Ensuring Xcode license is accepted..."
sudo xcodebuild -license accept 2>/dev/null || true

# Run Flutter doctor to check setup
echo "🏥 Running Flutter doctor..."
flutter doctor

echo ""
echo "🎉 Setup completed!"
echo ""
echo "📋 Next steps:"
echo "   1. Clone your Flutter project"
echo "   2. Connect Khaled's iPhone"
echo "   3. Run the deploy_to_iphone.sh script"
echo ""
echo "💡 Additional setup you might need:"
echo "   - Configure Apple Developer account in Xcode"
echo "   - Enable Developer Mode on the iPhone"
echo "   - Trust the development certificate on the device"
echo ""
