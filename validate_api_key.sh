#!/bin/bash
# API Key Format Validator

echo "=== API Key Format Validator ==="
echo ""
echo "This script helps diagnose API key issues:"
echo "1. Check if your .p8 file has correct PEM format"
echo "2. Detect if it's base64 encoded"
echo "3. Show proper format for GitHub Secrets"
echo ""

# Simulate what the workflow does
echo "Expected PEM format (for GitHub Secret APP_STORE_CONNECT_API_KEY_CONTENT):"
echo "-----BEGIN PRIVATE KEY-----"
echo "MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgI..."
echo "... (approximately 2.2KB of base64 content) ..."
echo "-----END PRIVATE KEY-----"
echo ""
echo "Lines: Should be ~32 lines total (including BEGIN/END lines)"
echo ""

echo "Common issues:"
echo "1. ❌ Missing 'BEGIN PRIVATE KEY' or 'END PRIVATE KEY' lines"
echo "2. ❌ Extra whitespace or line breaks added"
echo "3. ❌ File saved as binary instead of text"
echo "4. ❌ Copied wrong file (not the .p8 file)"
echo ""

echo "To fix:"
echo "1. Download the .p8 file from Apple Developer Portal"
echo "2. Open in text editor (TextEdit, VS Code)"
echo "3. Copy EXACT content (Ctrl+A, Ctrl+C)"
echo "4. Paste into GitHub Secret"
echo "5. No modifications!"
echo ""

echo "Checking local certificate.txt (if exists):"
if [ -f "certificate.txt" ]; then
    echo "Found certificate.txt"
    head -3 certificate.txt
    echo "..."
    tail -3 certificate.txt
else
    echo "No certificate.txt found"
fi

echo ""
echo "=== Debug Commands ==="
echo "# To check a .p8 file format:"
echo "head -5 AuthKey_*.p8"
echo "tail -5 AuthKey_*.p8"
echo "wc -l AuthKey_*.p8"
echo ""
echo "# To check if base64 encoded:"
echo "base64 --decode AuthKey_*.p8 2>/dev/null | head -3"
