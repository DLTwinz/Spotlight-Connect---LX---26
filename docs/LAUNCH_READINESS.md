# SPOTLIGHT Connect — Launch Readiness (GREEN LIGHT)
**Date:** 2026-08-06  
**Client HEAD:** `main` (auth harden + token alignment)  
**Track:** List A (Phase 0–5) — not Master Binder List B numbering

---

## Phase gate status (List A)

| Phase | Status | Evidence |
|-------|--------|----------|
| 0 Source of Truth + Merge | **LOCKED** | main owns best of sources; SpotlightTokens permanent |
| 1 Brand + Welcome | **LOCKED** | Tokens, welcome, CTAs pathways; hero crop deferred |
| 2 Clean Main | **LOCKED** | Foundation analyze clean at lock |
| 3 Role functional | **LOCKED** | Auth routing, Admin RPC, Creator/Business unique homes, Audience Insights+Passes, Shared empties |
| 3.2 Admin | **LOCKED** | admin_approve_profile, is_admin RLS, content_reports |
| Graph Law / v0+ | **LOCKED** | identity + fandom graph core; vertical OPEN; apply + claim densify |
| 4 Brand + externals | **LOCKED** | Token docs, Canva folder, Drive Master Binder, Notion pages |
| 5 Launch readiness | **COMPLETE** | This checklist + auth harden + token wiring |

---

## Non-negotiables (code)

| Item | Status |
|------|--------|
| JWT anon default in SupabaseConfig | PASS |
| Reject service_role / placeholders at init | PASS |
| approved_roles prefer talent/business dashboards | PASS |
| CreatorHomeTab ≠ FeedTab; BusinessHomeTab ≠ Feed | PASS |
| Profile ROLE = operating shell | PASS |
| Passes claim persist + id/title dedupe | PASS |
| Admin approve via SECURITY DEFINER RPC | PASS |
| Designed empty states (Reels, Discover, Opportunities, Passes) | PASS |
| `.env` untracked | PASS |
| Role accents from SpotlightTokens | PASS |
| Shell/panel/nav from SpotlightTokens | PASS |

## Explicit deferred (not blockers)

- Reject RPC / client setActiveRole  
- Hero collage final crop  
- Vertical lock (OPEN)  
- User-customizable themes  
- Full pixel parity on every legacy secondary surface beyond roleAccent system  
- Neo4j / Riverpod / realtime leaderboards  

---

## Brand law (runtime)

**Single source:** `lib/theme/spotlight_tokens.dart`

| Token | Use |
|-------|-----|
| `bgPrimary` / `shellBg` | App + role shell canvas |
| `bgSurface` / `shellPanel` | Cards / panels |
| `cyan` / roleBusiness | Marketing + business accent |
| `roleTalent` `#7CFFB2` | Creator OS |
| `roleAudience` `#38BDF8` | Fan surfaces |
| `roleAdmin` `#FF6B6B` | Trust / severity |
| Marketing only | `SpotlightAccents` cyan–purple–magenta on public landing |

Dashboards must call `context.roleAccent(role)` / `roleShellBackground` — not ad-hoc hex — for chrome and CTAs.

---

## Operator launch steps (not code)

1. `git pull origin main`  
2. Local `.env` with **anon JWT only** (never service_role)  
3. `flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080` + dart-defines  
4. Login admin → confirm session (not Invalid API key)  
5. Spot-check talent / business / audience / admin shells + accents  

---

## Freeze rule

No Phase 0–5 foundation reopen without a new phase ticket.  
Product core remains first-party identity + fandom graph.
