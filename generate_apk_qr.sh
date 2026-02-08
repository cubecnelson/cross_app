#!/bin/bash
# generate_apk_qr.sh - Generate QR code for APK artifact URL

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

print_header "APK QR Code Generator"

# Check dependencies
if ! command -v qrencode &> /dev/null; then
    print_info "Installing qrencode..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y qrencode
    elif command -v brew &> /dev/null; then
        brew install qrencode
    else
        print_error "Cannot install qrencode automatically"
        print_info "Please install qrencode manually:"
        print_info "  Ubuntu/Debian: sudo apt-get install qrencode"
        print_info "  macOS: brew install qrencode"
        exit 1
    fi
fi

# Get URL from argument or prompt
if [ $# -eq 1 ]; then
    URL="$1"
else
    read -p "Enter APK download URL: " URL
    if [ -z "$URL" ]; then
        print_error "URL is required"
        exit 1
    fi
fi

# Validate URL format
if [[ ! "$URL" =~ ^https?:// ]]; then
    print_error "Invalid URL format. Must start with http:// or https://"
    exit 1
fi

# Create output directory
OUTPUT_DIR="qr_codes"
mkdir -p "$OUTPUT_DIR"

# Generate filename from URL
FILENAME=$(echo "$URL" | md5sum | cut -d' ' -f1)
OUTPUT_FILE="$OUTPUT_DIR/apk-$FILENAME.png"

# Generate QR code
print_info "Generating QR code for URL:"
echo "$URL"
echo ""

qrencode -o "$OUTPUT_FILE" -s 10 -l H -t PNG "$URL"

if [ $? -eq 0 ]; then
    print_success "QR code generated: $OUTPUT_FILE"
    
    # Show QR code info
    FILESIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    print_info "File size: $FILESIZE"
    print_info "QR code level: High (H) - 30% error correction"
    
    # Try to display QR code if in terminal with image support
    if command -v imgcat &> /dev/null; then
        echo ""
        print_info "QR Code Preview:"
        imgcat "$OUTPUT_FILE"
    elif command -v chafa &> /dev/null; then
        echo ""
        print_info "QR Code ASCII Preview:"
        chafa "$OUTPUT_FILE"
    fi
    
    echo ""
    print_info "To share:"
    echo "1. Send the PNG file: $OUTPUT_FILE"
    echo "2. Or share the URL directly: $URL"
    echo ""
    print_info "Scan the QR code with any smartphone camera to open the download page."
    
else
    print_error "Failed to generate QR code"
    exit 1
fi

# Generate HTML page for easy sharing
HTML_FILE="$OUTPUT_DIR/apk-$FILENAME.html"
cat > "$HTML_FILE" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Cross App APK Download</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            text-align: center;
        }
        .qr-container {
            margin: 40px auto;
            padding: 20px;
            border: 2px solid #4CAF50;
            border-radius: 10px;
            display: inline-block;
            background: white;
        }
        .instructions {
            text-align: left;
            margin: 30px auto;
            max-width: 600px;
            padding: 20px;
            background: #f5f5f5;
            border-radius: 8px;
        }
        .download-btn {
            display: inline-block;
            background: #4CAF50;
            color: white;
            padding: 15px 30px;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
            margin: 20px 0;
            font-size: 18px;
        }
        .download-btn:hover {
            background: #45a049;
        }
    </style>
</head>
<body>
    <h1>📱 Cross App APK Download</h1>
    
    <div class="qr-container">
        <h2>Scan QR Code</h2>
        <img src="apk-$FILENAME.png" alt="APK Download QR Code" width="300" height="300">
        <p>Scan with smartphone camera</p>
    </div>
    
    <div>
        <a href="$URL" class="download-btn" download>⬇️ Direct Download APK</a>
    </div>
    
    <div class="instructions">
        <h3>📝 Installation Instructions</h3>
        <ol>
            <li>Download the APK file using the button above or QR code</li>
            <li>On your Android device, enable "Install from unknown sources":
                <ul>
                    <li>Go to Settings → Security</li>
                    <li>Enable "Unknown sources" or "Install unknown apps"</li>
                </ul>
            </li>
            <li>Open the downloaded APK file</li>
            <li>Tap "Install" when prompted</li>
            <li>Launch the app after installation</li>
        </ol>
        
        <h3>⚠️ Security Note</h3>
        <p>This APK is for testing purposes only. For production use, download from official app stores.</p>
    </div>
    
    <footer>
        <p>Generated: $(date)</p>
        <p>Build: $FILENAME</p>
    </footer>
</body>
</html>
EOF

print_success "HTML download page generated: $HTML_FILE"
print_info "Open in browser: open $HTML_FILE"

print_header "Summary"
print_success "Files generated:"
echo "1. QR Code: $OUTPUT_FILE"
echo "2. HTML Page: $HTML_FILE"
echo "3. Target URL: $URL"
echo ""
print_info "All files saved in: $OUTPUT_DIR/"