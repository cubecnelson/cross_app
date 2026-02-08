#!/bin/bash
# android_setup.sh - Setup Android project and build configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

print_header "Android Project Setup for Cross App"

# Check if we're in the project root
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Are you in the project root?"
    exit 1
fi

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    print_error "Flutter not found. Please install Flutter first."
    print_info "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

print_info "Flutter Version:"
flutter --version

# Check Android directory
if [ -d "android" ]; then
    print_success "Android directory exists"
    print_info "Android project structure:"
    find android -maxdepth 2 -type f -name "*.gradle" -o -name "AndroidManifest.xml" | sort
else
    print_info "Android directory not found"
    print_info "Flutter can create it with: flutter create --platforms=android ."
    
    read -p "Create Android project? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_header "Creating Android project..."
        flutter create --platforms=android .
        print_success "Android project created"
    else
        print_error "Android project required for APK builds"
        print_info "You can create it manually later with: flutter create --platforms=android ."
        exit 1
    fi
fi

print_header "Android Build Configuration"

# Check if build.gradle exists
if [ -f "android/app/build.gradle" ]; then
    print_success "Found build.gradle"
    
    # Check for signing config
    if grep -q "signingConfigs" android/app/build.gradle; then
        print_success "Signing configuration found"
    else
        print_info "No signing configuration found"
        print_info "For production releases, add signing configuration to android/app/build.gradle"
        echo ""
        print_info "Example signing configuration:"
        cat << 'EOF'
android {
    signingConfigs {
        release {
            storeFile file("your-keystore.jks")
            storePassword "your-store-password"
            keyAlias "your-key-alias"
            keyPassword "your-key-password"
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
EOF
    fi
else
    print_error "build.gradle not found at android/app/build.gradle"
    print_info "Android project might be incomplete"
fi

print_header "Android SDK Check"
print_info "Checking Android SDK tools..."

# Check for Android SDK (simplified check)
if command -v adb &> /dev/null; then
    print_success "ADB (Android Debug Bridge) found"
else
    print_info "ADB not found. Install Android SDK tools for full Android development."
    print_info "Visit: https://developer.android.com/studio"
fi

print_header "Build Test"
print_info "Testing Android build configuration..."

# Try to get app bundle ID
if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
    PACKAGE_NAME=$(grep -o 'package="[^"]*"' android/app/src/main/AndroidManifest.xml | cut -d'"' -f2)
    if [ -n "$PACKAGE_NAME" ]; then
        print_success "Package name: $PACKAGE_NAME"
    fi
fi

print_header "Next Steps"
echo ""
print_info "1. For GitHub Actions workflow:"
echo "   - The workflow will automatically build APK"
echo "   - No local setup needed for CI builds"
echo ""
print_info "2. For local development builds:"
echo "   flutter build apk --debug          # Debug APK"
echo "   flutter build apk --release        # Release APK (unsigned)"
echo "   flutter build appbundle --release  # App Bundle for Play Store"
echo ""
print_info "3. For production releases:"
echo "   - Create keystore: keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key"
echo "   - Add signing config to android/app/build.gradle"
echo "   - Store keystore credentials in GitHub Secrets"
echo ""
print_info "4. To run on device:"
echo "   flutter run                         # Run on connected device"
echo "   flutter install                     # Install built APK"
echo ""
print_success "Android setup complete!"