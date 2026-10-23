#!/bin/bash
# Shorebird patch for iOS using .env for Supabase credentials
#
# Usage: ./scripts/shorebird_patch_ios.sh
# Requires: .env with SUPABASE_URL and SUPABASE_ANON_KEY

set -e
cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  echo "❌ .env file not found. Create one with SUPABASE_URL and SUPABASE_ANON_KEY"
  exit 1
fi

echo "📦 Loading environment from .env..."
set -a
source .env
set +a

echo "🚀 Running shorebird patch ios..."
shorebird patch ios \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
