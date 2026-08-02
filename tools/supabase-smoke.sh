#!/usr/bin/env bash
set -euo pipefail

PROJECT_REF="mdwvokenmehdfybgujpa"

echo "=== Supabase smoke checks ==="
echo "Project: $PROJECT_REF"
echo

echo "=== Project list ==="
supabase projects list
echo

echo "=== Dashboard URL ==="
echo "https://supabase.com/dashboard/project/$PROJECT_REF/functions"
echo

echo "=== Example invoke: campaignslist ==="
echo "curl --request POST https://$PROJECT_REF.supabase.co/functions/v1/campaignslist \\"
echo "  --header 'Content-Type: application/json' \\"
echo "  --header 'apikey: YOUR_PUBLISHABLE_OR_ANON_KEY' \\"
echo "  --data '{}'"
echo

echo "=== Example invoke: progresssnapshot ==="
echo "curl --request POST https://$PROJECT_REF.supabase.co/functions/v1/progresssnapshot \\"
echo "  --header 'Content-Type: application/json' \\"
echo "  --header 'apikey: YOUR_PUBLISHABLE_OR_ANON_KEY' \\"
echo "  --header 'Authorization: Bearer USER_JWT' \\"
echo "  --data '{}'"
echo

echo "=== Smoke script complete ==="
