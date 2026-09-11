# Phase 1 screenshot baseline index

Required captures were **not executed** in this agent environment.

## Why

- Flutter / Dart SDK are not installed here.
- Authenticated `/talent`, `/business`, and `/admin` require real sessions and role state.
- Phase 1 forbids changing the app to inject a screenshot harness.

These are **baseline protocol records**, not approved visuals.

## Required captures (owner or VM follow-up)

Use desktop width **1536** unless noted. Do not “fix” UI after looking at the shot.

| ID | Route | Viewport | Auth / role | Flags | Data status | Source files | Status |
|---|---|---|---|---|---|---|---|
| P1-WELCOME | `/welcome` | 1536×1024 | logged out | launch flag as deployed | no product data | `spotlight_marketing_landing_page.dart` | **missing** |
| P1-LOGIN | `/login` | 1536×1024 | logged out | — | auth form only | `landing_auth_page.dart` | **missing** — capture if materially different from welcome |
| P1-TALENT | `/talent` | 1536×1024 | approved talent | streams flag off unless documented | empty tables / local widgets | `talent_business_dashboards.dart`, `role_dashboard_shell.dart`, `dashboard_tabs.dart` | **missing** |
| P1-BUSINESS | `/business` | 1536×1024 | approved business | — | empty tables / local widgets | same shell family | **missing** |
| P1-ADMIN | `/admin` | 1536×1024 | admin | — | admin services | `admin_dashboard.dart` | **missing** |

For each future file drop, record: capture timestamp, exact URL, feature-flag dump, known visual defects, known functional defects.

## Known defects to annotate when captured (from code, not pixels)

| Surface | Likely defects (not screenshot-confirmed) |
|---|---|
| `/talent` and `/business` | Shared tab rhythm (Dashboard / Reels / Discover / Studio|Suite / …). Violates role-uniqueness law |
| `/business` | Not the locked decision-briefing Overview |
| `/talent` | Not Mira/Aria/Avery/Jade/Jalen locked pages |
| `/admin` | Dense operational UI; not a locked Admin authority |
| All role dashboards | Empty-table / incomplete live data; must not be labeled live |

## What not to use as Phase 1 baselines

- Locked C/T and B/B design JPGs (those are **target authorities**, not current-app baselines).
- August 2026 historical Flutter screenshots in chat attachments (not tied to `3ede84e`).
- Grok web prototype shots.

## Suggested VM commands (owner-run; not executed here)

```bash
cd /path/to/Spotlight-Connect---LX---26
git checkout integration/grok-spotlight-launch
git rev-parse HEAD   # expect 3ede84e plus docs commits
flutter --version
flutter pub get
flutter analyze
flutter test
# screenshot via running web on a known port, logged in as each role
```

Do not commit screenshot binaries unless the owner explicitly asks to version them.
