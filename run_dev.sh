#!/bin/bash
# Development run script for Cross app

# Your Supabase credentials
SUPABASE_URL="https://zwolfdcwatqazhjxmymg.supabase.co"
SUPABASE_ANON_KEY="sb_publishable_jdnMG1WY5_DVsY3fqrolcA_DIToYnn_"

# Note: Get your complete anon key from Supabase dashboard
# Settings > API > Project API keys > anon/public key

echo "🚀 Running Cross app with Supabase credentials..."

flutter run \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

