#!/bin/bash
# ============================================
# SPOTLIGHT CONNECT — Secure Dev Runner
# ============================================
# Loads .env variables and injects them into
# Flutter via --dart-define (safe, no hardcoding)
#
# Usage: ./run_dev.sh
#        ./run_dev.sh --web        (web target)
#        ./run_dev.sh --android    (android target)
# ============================================

if [ ! -f .env ]; then
  echo "ERROR: .env file not found."
  echo "Run: cp .env.example .env  then fill in your values."
  exit 1
fi

# Load env vars
set -o allexport
source .env
set +o allexport

# Parse optional target flag
TARGET_FLAG=""
if [ "$1" == "--web" ]; then
  TARGET_FLAG="-d web"
elif [ "$1" == "--android" ]; then
  TARGET_FLAG="-d android"
fi

echo "🚀 Starting Spotlight Connect..."
echo "   URL: ${SUPABASE_URL:0:40}..."
echo "   Key: ${SUPABASE_ANON_KEY:0:20}..."
echo ""

flutter run $TARGET_FLAG \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"
