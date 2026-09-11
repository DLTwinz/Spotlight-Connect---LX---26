# Phase 2 Creator import analysis

**Analysis only. Do not import, cherry-pick, or merge `feat/creator-studio-completion`.**

| Ref | SHA |
|---|---|
| `main` | `3ede84e89b31b46004d39bde9630885283c14c3f` |
| `feat/creator-studio-completion` | `8954fb29d5468b29ef1d2e4d17865b08f78e428c` |

## How the feature branch differs

`AppRoutes` is **identical**. The feature branch does not add `/studio`.

It changes `/talent` to render `CreatorStudioShell` instead of `RoleDashboardShell`.

Studio destinations are selected by `_selectedIndex` inside the shell (Overview=0 … Analytics=8 … Profile=9). That cannot satisfy locked deep links without a later route contract.

Business on that branch still uses `RoleDashboardShell`.

## File comparison

| Path | Purpose | On `main`? | Reusable? | Conflicts / assumptions | Recommendation |
|---|---|---|---|---|---|
| `lib/pages/dashboards/creator_studio_shell.dart` | Creator rail + top bar + index switcher | No | Partial. Rail/top-bar patterns useful after route contract | Hard-coded persona “Avery Jordan”; fixture momentum 82; empty Quick Create; in-shell routing not URL routes | **adapt** later as shared shell only after route-transition approval. Do not bulk-port |
| `lib/pages/dashboards/creator_analytics_economics_page.dart` | Analytics page | No | Candidate for first locked page | Feature-branch file is a prior implementation, not screenshot-approved. Fixture economics copy risk | **port selectively** as the first page, then overlay-rebuild. Do not treat branch file as final |
| `lib/pages/dashboards/creator_portfolio_proof_page.dart` | Portfolio | No | Later | Not overlay-approved | **defer** until Analytics lands |
| `lib/pages/dashboards/creator_gravity_map_page.dart` | Gravity | No | Later | Graph is schematic vs lock | **defer** |
| `lib/pages/dashboards/creator_opportunities_page.dart` | Opportunities (derived) | No | Later | Not a locked authority | **defer** |
| `lib/pages/dashboards/creator_overview_page.dart` | Overview | No | Concept only | Overview PDF is not locked | **defer** |
| `lib/pages/dashboards/creator_workspace_pages.dart` | Momentum / workflow / community / programs / profile placeholders | No | Weak | Generic workspace specs; Community/Identity locks need dedicated pages | **replace** for locked Identity and Community; **defer** derived pages |
| `lib/pages/dashboards/talent_business_dashboards.dart` | Talent entry swap | Yes (different body) | N/A | Feature branch TalentDashboard → CreatorStudioShell | **retain `main` version** until Phase 2 is approved |
| `lib/theme/spotlight_tokens.dart` | Tokens | Yes | Yes | Verify before any port | **retain `main`**. Do not overwrite tokens from the feature branch without a diff |
| `lib/nav.dart` / `app_routes.dart` | Router | Yes | Yes | Feature `app_routes.dart` SHA matches `main` | **retain `main`** |
| `lib/core/access/role_capabilities.dart` | Guards | Yes | Yes | Still `talent` / `business` / `audience` / `admin` | **retain** |
| Services / models | Existing domain | Yes | Yes | Analytics must stay fixture-first; empty tables | **retain**. Do not wire live economics |

## Hidden coupling if someone bulk-copied the branch

- Talent route meaning changes immediately.
- Ten studio destinations appear without URL addressability.
- Overview / Community / Identity quality is placeholder-level in `creator_workspace_pages.dart`.
- Fixture names and scores can be mistaken for live data.
- No new tests accompany those pages.

## Smallest coherent set for a *future* Analytics-only port

Only after Phase 2 route contract is approved:

1. Keep `/talent` working as today.
2. Add approved `/studio/analytics` (or in-shell only if owner rejects new routes).
3. Port or rewrite **one** page file plus only shared primitives actually required.
4. Do not import Overview, Gravity, Portfolio, workspace bundle, or the full shell in the same commit.

Exact file list for that future commit must be re-stated and owner-approved. Not authorized now.

## Explicit rule

Do not cherry-pick `feat/creator-studio-completion` as a branch or bulk feature set.
