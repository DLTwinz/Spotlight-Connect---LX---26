#!/usr/bin/env bash
# =============================================================================
# Spotlight Connect — curl Verification Script
# Verifies REST views + Edge Functions against your real Supabase project
#
# Fill in the three variables below from:
#   Supabase Dashboard → Project Settings → API / API Keys
# =============================================================================

PROJECT_REF="mdwvokenmehdfybgujpa"        # e.g. mdwvokenmehdfybgujpa
ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kd3Zva2VubWVoZGZ5Ymd1anBhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyODAzMzUsImV4cCI6MjA5MTg1NjMzNX0.tds2VeVEl05jd3cbaC4vutxnLRtTF6i2d5MMAJS3KJk"
SERVICE_ROLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kd3Zva2VubWVoZGZ5Ymd1anBhIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NjI4MDMzNSwiZXhwIjoyMDkxODU2MzM1fQ.ryMpDedEPfxKPn6KoGPsK-3CkXgfc2HY5nxhmp0in70"

BASE="https://${PROJECT_REF}.supabase.co"
REST="${BASE}/rest/v1"
FN="${BASE}/functions/v1"

PASS=0
FAIL=0

check() {
  local desc="$1"
  local expected="$2"
  shift 2

  local http_code
  http_code=$(curl -s -o /dev/null -w "%{http_code}" "$@")

  if [[ "$expected" == "2xx" ]]; then
    if [[ "$http_code" =~ ^2 ]]; then
      echo "  ✅  [$http_code] $desc"
      ((PASS++))
    else
      echo "  ❌  [$http_code] $desc  (expected $expected)"
      ((FAIL++))
    fi
  else
    if [[ "$http_code" == "$expected" ]]; then
      echo "  ✅  [$http_code] $desc"
      ((PASS++))
    else
      echo "  ❌  [$http_code] $desc  (expected $expected)"
      ((FAIL++))
    fi
  fi
}

echo ""
echo "============================================================"
echo "  Spotlight Connect — Endpoint Verification"
echo "  Project: ${PROJECT_REF}"
echo "============================================================"

# ------------------------------------------------------------
# CHECK 1 — brand_attribution_summary (service role → 200)
# ------------------------------------------------------------
echo ""
echo "── REST Views ──────────────────────────────────────────────"
check "brand_attribution_summary (service role)" "200" \
  "${REST}/brand_attribution_summary?select=brand_id,total_spend,completion_rate_pct&limit=1" \
  -H "apikey: ${SERVICE_ROLE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_ROLE_KEY}"

# ------------------------------------------------------------
# CHECK 2 — brand_attribution_summary (anon key → 200)
# ------------------------------------------------------------
check "brand_attribution_summary (anon — RLS scoped)" "200" \
  "${REST}/brand_attribution_summary?select=brand_id&limit=1" \
  -H "apikey: ${ANON_KEY}" \
  -H "Authorization: Bearer ${ANON_KEY}"

# ------------------------------------------------------------
# CHECK 3 — creator_attribution_summary (service role → 200)
# ------------------------------------------------------------
check "creator_attribution_summary (service role)" "200" \
  "${REST}/creator_attribution_summary?select=creator_id,total_earnings,pipeline_value&limit=1" \
  -H "apikey: ${SERVICE_ROLE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_ROLE_KEY}"

# ------------------------------------------------------------
# CHECK 4 — creator_attribution_summary (anon → 200)
# ------------------------------------------------------------
check "creator_attribution_summary (anon — RLS scoped)" "200" \
  "${REST}/creator_attribution_summary?select=creator_id&limit=1" \
  -H "apikey: ${ANON_KEY}" \
  -H "Authorization: Bearer ${ANON_KEY}"

# ------------------------------------------------------------
# CHECK 5 — column presence: brand_attribution_summary
# ------------------------------------------------------------
echo ""
echo "── Column Presence ─────────────────────────────────────────"
BRAND_COLS=$(curl -s \
  "${REST}/brand_attribution_summary?select=brand_id,brand_name,total_spend,avg_deal_value,completion_rate_pct,summary_generated_at&limit=0" \
  -H "apikey: ${SERVICE_ROLE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_ROLE_KEY}" \
  -H "Prefer: count=exact" \
  -o /dev/null -w "%{http_code}")

if [[ "$BRAND_COLS" == "200" ]]; then
  echo "  ✅  brand_attribution_summary — all key columns resolve"
  ((PASS++))
else
  echo "  ❌  brand_attribution_summary — column check failed [$BRAND_COLS]"
  ((FAIL++))
fi

# ------------------------------------------------------------
# CHECK 6 — column presence: creator_attribution_summary
# ------------------------------------------------------------
CREATOR_COLS=$(curl -s \
  "${REST}/creator_attribution_summary?select=creator_id,creator_name,total_earnings,pipeline_value,completion_rate_pct,summary_generated_at&limit=0" \
  -H "apikey: ${SERVICE_ROLE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_ROLE_KEY}" \
  -H "Prefer: count=exact" \
  -o /dev/null -w "%{http_code}")

if [[ "$CREATOR_COLS" == "200" ]]; then
  echo "  ✅  creator_attribution_summary — all key columns resolve"
  ((PASS++))
else
  echo "  ❌  creator_attribution_summary — column check failed [$CREATOR_COLS]"
  ((FAIL++))
fi

# ------------------------------------------------------------
# CHECK 7 — get-brand-attribution Edge Function
# ------------------------------------------------------------
echo ""
echo "── Edge Functions ──────────────────────────────────────────"
check "get-brand-attribution (service role)" "2xx" \
  "${FN}/get-brand-attribution" \
  -H "Authorization: Bearer ${SERVICE_ROLE_KEY}"

# ------------------------------------------------------------
# CHECK 8 — get-brand-attribution with brand_id param
# ------------------------------------------------------------
check "get-brand-attribution?brand_id=test" "2xx" \
  "${FN}/get-brand-attribution?brand_id=00000000-0000-0000-0000-000000000000" \
  -H "Authorization: Bearer ${SERVICE_ROLE_KEY}"

# ------------------------------------------------------------
# CHECK 9 — get-creator-attribution Edge Function
# ------------------------------------------------------------
check "get-creator-attribution (service role)" "2xx" \
  "${FN}/get-creator-attribution" \
  -H "Authorization: Bearer ${SERVICE_ROLE_KEY}"

# ------------------------------------------------------------
# CHECK 10 — get-creator-attribution with creator_id param
# ------------------------------------------------------------
check "get-creator-attribution?creator_id=test" "2xx" \
  "${FN}/get-creator-attribution?creator_id=00000000-0000-0000-0000-000000000000" \
  -H "Authorization: Bearer ${SERVICE_ROLE_KEY}"

echo ""
echo "============================================================"
TOTAL=$((PASS + FAIL))
echo "  Results: ${PASS}/${TOTAL} passed"
if [[ "$FAIL" -eq 0 ]]; then
  echo "  🟢 All checks passed — ready for Phase 6 dashboard integration"
else
  echo "  🔴 ${FAIL} check(s) failed — review errors above"
fi
echo "============================================================"
echo ""