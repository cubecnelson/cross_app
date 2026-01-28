#!/bin/bash

echo "========================================="
echo "Certificate & Profile Verification Tool"
echo "========================================="
echo ""

# Check for certificate file
if [ ! -f "distribution.p12" ]; then
  echo "❌ distribution.p12 not found in current directory"
  echo ""
  echo "Please export your Apple Distribution certificate:"
  echo "1. Open Keychain Access"
  echo "2. Find 'Apple Distribution: Your Name (TEAM_ID)'"
  echo "3. Right-click → Export → Save as distribution.p12"
  echo ""
  exit 1
fi

# Check for provisioning profile
PROFILE_FILE=$(ls *.mobileprovision 2>/dev/null | head -1)
if [ -z "$PROFILE_FILE" ]; then
  echo "❌ No .mobileprovision file found"
  echo ""
  echo "Please download your App Store provisioning profile from:"
  echo "https://developer.apple.com/account/resources/profiles/list"
  echo ""
  exit 1
fi

echo "Found files:"
echo "  Certificate: distribution.p12"
echo "  Profile: $PROFILE_FILE"
echo ""

# Get password for p12
read -sp "Enter .p12 password: " P12_PASSWORD
echo ""
echo ""

# Verify certificate
echo "========================================="
echo "Certificate Details"
echo "========================================="
openssl pkcs12 -in distribution.p12 -passin pass:"$P12_PASSWORD" -nokeys -clcerts 2>/dev/null | openssl x509 -noout -subject -dates -fingerprint

if [ $? -ne 0 ]; then
  echo "❌ Invalid certificate or wrong password"
  exit 1
fi

# Check if it has private key
echo ""
echo "Checking for private key..."
PRIVATE_KEY=$(openssl pkcs12 -in distribution.p12 -passin pass:"$P12_PASSWORD" -nocerts 2>/dev/null)
if [ -z "$PRIVATE_KEY" ]; then
  echo "❌ No private key found in certificate!"
  echo "   You must export the certificate WITH its private key"
  exit 1
else
  echo "✅ Private key found"
fi

# Get certificate subject
CERT_SUBJECT=$(openssl pkcs12 -in distribution.p12 -passin pass:"$P12_PASSWORD" -nokeys -clcerts 2>/dev/null | openssl x509 -noout -subject)
echo ""
echo "$CERT_SUBJECT"

# Check if it's the right type
if [[ $CERT_SUBJECT == *"Apple Distribution"* ]]; then
  echo "✅ Certificate type: Apple Distribution (correct for App Store)"
elif [[ $CERT_SUBJECT == *"iPhone Distribution"* ]]; then
  echo "⚠️  Certificate type: iPhone Distribution (old type, should update)"
else
  echo "❌ Certificate type: Unknown"
fi

# Verify provisioning profile
echo ""
echo "========================================="
echo "Provisioning Profile Details"
echo "========================================="

PROFILE_DATA=$(security cms -D -i "$PROFILE_FILE")
PROFILE_NAME=$(echo "$PROFILE_DATA" | /usr/libexec/PlistBuddy -c "Print :Name" /dev/stdin 2>/dev/null)
PROFILE_UUID=$(echo "$PROFILE_DATA" | /usr/libexec/PlistBuddy -c "Print :UUID" /dev/stdin 2>/dev/null)
PROFILE_TYPE=$(echo "$PROFILE_DATA" | /usr/libexec/PlistBuddy -c "Print :ProvisionsAllDevices" /dev/stdin 2>/dev/null)
PROFILE_APPID=$(echo "$PROFILE_DATA" | /usr/libexec/PlistBuddy -c "Print :Entitlements:application-identifier" /dev/stdin 2>/dev/null)
PROFILE_TEAM=$(echo "$PROFILE_DATA" | /usr/libexec/PlistBuddy -c "Print :TeamIdentifier:0" /dev/stdin 2>/dev/null)

echo "Name: $PROFILE_NAME"
echo "UUID: $PROFILE_UUID"
echo "App ID: $PROFILE_APPID"
echo "Team ID: $PROFILE_TEAM"

if [ "$PROFILE_TYPE" == "true" ]; then
  echo "Type: App Store (✅ correct for CI/CD)"
else
  echo "Type: Development or Ad Hoc"
fi

# Generate base64
echo ""
echo "========================================="
echo "GitHub Secrets (Base64 encoded)"
echo "========================================="
echo ""
echo "1. BUILD_CERTIFICATE_BASE64:"
echo "----------------------------------------"
base64 -i distribution.p12
echo "----------------------------------------"
echo ""
echo "2. P12_PASSWORD:"
echo "$P12_PASSWORD"
echo ""
echo "3. BUILD_PROVISION_PROFILE_BASE64:"
echo "----------------------------------------"
base64 -i "$PROFILE_FILE"
echo "----------------------------------------"
echo ""
echo "✅ Verification complete!"
echo ""
echo "Copy the values above to your GitHub Secrets:"
echo "https://github.com/YOUR_USERNAME/cross_app/settings/secrets/actions"
