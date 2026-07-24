#!/usr/bin/env bash
set -euo pipefail

PROJECT_REF="mdwvokenmehdfybgujpa"

echo "=== Spotlight Release Audit ==="
echo

echo "=== Git context ==="
git branch --show-current
git status --short
git log --oneline -n 5
echo
git diff main...HEAD --stat || true
echo

echo "=== Flutter clean ==="
flutter clean
echo

echo "=== Flutter dependencies ==="
flutter pub get
echo

echo "=== Dart format check ==="
dart format --output=none --set-exit-if-changed lib test
echo

echo "=== Flutter analyze ==="
flutter analyze
echo

echo "=== Flutter test ==="
flutter test
echo

echo "=== Supabase project list ==="
supabase projects list
echo

echo "=== Supabase link (safe to retry) ==="
supabase link --project-ref "$PROJECT_REF" || true
echo

echo "=== Supabase deploy all functions ==="
supabase functions deploy
echo

echo "=== Audit complete ==="
