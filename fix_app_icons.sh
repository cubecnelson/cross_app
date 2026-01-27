#!/bin/bash
# Script to remove alpha channel from app icons
# iOS app icons CANNOT have transparency/alpha channel

set -e

echo "🔧 Fixing iOS App Icons - Removing Alpha Channel"
echo "================================================"

ICON_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"

# Check if ImageMagick is available
if ! command -v magick &> /dev/null && ! command -v convert &> /dev/null; then
    echo "❌ Error: ImageMagick is not installed"
    echo "Install with: brew install imagemagick"
    exit 1
fi

# Use magick if available, otherwise fall back to convert
if command -v magick &> /dev/null; then
    CMD="magick"
else
    CMD="convert"
fi

echo "📁 Processing icons in: $ICON_DIR"
echo ""

# Process all PNG files
count=0
for file in "$ICON_DIR"/*.png; do
    if [ -f "$file" ]; then
        $CMD "$file" -background black -alpha remove -alpha off "$file"
        echo "✅ Fixed: $(basename "$file")"
        ((count++))
    fi
done

echo ""
echo "================================================"
echo "✅ Successfully processed $count icon files"
echo ""

# Verify the main icon
echo "🔍 Verifying 1024x1024 icon..."
if sips -g hasAlpha "$ICON_DIR/1024.png" | grep -q "hasAlpha: no"; then
    echo "✅ Verification passed - No alpha channel detected"
else
    echo "⚠️  Warning: Alpha channel may still be present"
fi

echo ""
echo "================================================"
echo "✅ Done! Your app icons are now App Store compliant."
echo ""
echo "Next steps:"
echo "1. Clean build: flutter clean && cd ios && pod install"
echo "2. Rebuild app: flutter build ios --release"
echo "3. Upload to TestFlight via GitHub Actions or manually"
