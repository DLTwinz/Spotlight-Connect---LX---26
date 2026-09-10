# Route and surface inventory

Source: `main` @ `3ede84e`  
Primary files: `lib/core/routing/app_routes.dart`, `lib/nav.dart`, `lib/core/access/role_capabilities.dart`

Proposed routes from planning documents are listed only as **proposed**. They are not active.

## Classification key

- **active** — registered and reachable under documented conditions
- **incomplete** — reachable but not the locked visual/product contract
- **fixture-only** — UI present; data is local/demo or empty-table backed
- **feature-gated** — feature flag and/or env required
- **permission-gated** — role/approval/admin required
- **legacy** — older alias or leftover surface
- **duplicate** — overlapping path or constant
- **dead** — file exists but not wired, or constant unused
- **proposed** — planning/visual authority only; not in `AppRoutes`

## Public and auth

| Route | Class | Roles | Page | Shell | Data | Flags | Risks / notes |
|---|---|---|---|---|---|---|---|
| `/` | active | public / session bootstrap | landing or splash while profile loads | none | auth session | `launchEnabled` | Logged-out beta users often redirected to `/early-access` |
| `/welcome` | active | public | `lib/pages/landing/spotlight_marketing_landing_page.dart` | marketing | none | — | **Do-not-regress visual parent** |
| `/early-access` | active / feature-gated | logged-out beta | `early_access_gate_page.dart` | gate | early-access service | launch flag | Hidden when launch enabled |
| `/login` | active | public | `landing_auth_page.dart` | auth | Supabase auth | — | Also consumes recovery params |
| `/onboarding` | permission-gated | authenticated incomplete | `onboarding_page.dart` | onboarding | profile | — | Query `role` preserved |
| `/auth/callback` | active | auth links | `auth_callback_page.dart` | none | Supabase tokens/PKCE | — | Must not be redirected away |
| `/reset-password` | active | recovery | `reset_password_page.dart` | auth | session | — | Allowed even if profile missing |
| `/waiting-approval` | permission-gated | pending talent/business | `waiting_approval_page.dart` | status | profile state | — | Pending users may still use `/audience` |
| `/access` | active | denied states | `permission_denied_page.dart` | status | query `missing` | — | Alias `AppRoutes.accessDenied` |
| `/permission-denied` | active / duplicate | denied states | same family | status | query | — | Dual denied paths |
| `/feature-disabled` | active | any | `feature_disabled_page.dart` | message | query | flags | UX only |

## Role dashboards (canonical on `main`)

| Route | Class | Roles | Page | Shell | Data | Flags | Risks / notes |
|---|---|---|---|---|---|---|---|
| `/audience` | active incomplete | audience (approved); pending users | `audience_dashboard.dart` | `RoleDashboardShell` | posts/groups/etc when wired; tables empty | — | Current Fan stand-in. **No locked Fan screenshot** |
| `/talent` | active incomplete | approved talent; admin impersonating talent | `TalentDashboard` in `talent_business_dashboards.dart` | `RoleDashboardShell` | mixed services | LiveKit tab gated | **Not** locked Creator Studio. Shared tab pattern with Business |
| `/business` | active incomplete | approved business | `BusinessDashboard` same file | `RoleDashboardShell` | mixed services | — | Path matches locked Overview **route intent** but **not** locked Overview composition |
| `/admin` | active incomplete / permission-gated | `user.isAdmin` | `admin_dashboard.dart` | admin | approvals/moderation | — | Not locked Admin IA |

## Dashboard aliases

| Route | Class | Notes |
|---|---|---|
| `/audience/dashboard` | duplicate / likely unused | Constant only in `AppRoutes` |
| `/talent/dashboard` | duplicate / likely unused | Constant only |
| `/business/dashboard` | duplicate / likely unused | Constant only |

Confirm in a later code search of `GoRoute` registrations before deleting. Do not delete in Phase 1.

## Progression and studio-adjacent

| Route | Class | Roles | Page | Data | Flags | Notes |
|---|---|---|---|---|---|---|
| `/campaigns` | active incomplete | logged-in | `campaigns_page.dart` | progression/campaigns | progression policy | **Not** locked B/B Campaigns |
| `/missions` | active incomplete / feature-gated | logged-in | `missions_page.dart` (tiny current file) | missions | progression policy | Backup files exist; current file 522 bytes |
| `/rewards` | active incomplete | logged-in | `rewards_page.dart` | rewards | — | |
| `/progress` | active incomplete | logged-in | `progress_page.dart` | progression | — | |
| `/admin/missions` | permission-gated | admin | `admin_missions_page.dart` | missions | — | |
| `/admin/campaigns` | permission-gated | admin | `admin_campaigns_page.dart` | campaigns | — | |
| `/livekit` | feature-gated | talent-adjacent | `livekit_room_page.dart` | LiveKit | `AppFeature.streams` + `SPOTLIGHT_LIVEKIT_URL` | Incomplete without env |
| `/__qa` | permission-gated | admin or QA flag; blocked in release | `qa_harness_page.dart` | harness | `AppFeature.qaHarness` | Current file is a stub (523 bytes); large backups exist |

## Proposed only (not on `main`)

| Intended route | Authority | Do not treat as active |
|---|---|---|
| `/studio` | Creator Overview PDF — **concept only** | yes |
| `/studio/analytics` | Mira Solis Analytics lock | yes |
| `/studio/identity` | Aria Voss Identity lock | yes |
| `/studio/community` | Avery Nova Community lock | yes |
| `/studio/gravity` | Jade Monroe Gravity lock | yes |
| `/studio/portfolio` | Jalen Reyes Portfolio lock | yes |
| `/business/talent-intelligence` | locked B/B | yes |
| `/business/campaigns` | locked B/B | yes |
| `/business/portfolio` | locked B/B | yes |
| `/business/attribution` | locked B/B | yes |
| `/business/audience-signals` | locked B/B (misnamed A/F file) | yes |
| `/business/reports` | locked B/B (misnamed A/F file) | yes |
| `/fan/*` | derived Fan | yes |
| `/ops/*` | no role in model | yes |

## Access rules already in code

- Client redirects in `nav.dart` are UX, not authorization.
- `RoleCapabilities.canAccessRoute` gates `/admin`, `/talent`, `/business`, `/audience`.
- Approved talent/business are steered away from `/audience`.
- Pending review: Audience allowed; talent/business/admin paths wait.
- Rejected / restricted / suspended: permission denied.
- Invalid profile: permission denied.

## Transition notes (not implemented)

See `docs/PHASE_2_ROUTE_TRANSITION_PROPOSAL.md`. No route may be added or redirected until that proposal is approved.
