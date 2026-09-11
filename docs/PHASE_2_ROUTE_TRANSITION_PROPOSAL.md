# Phase 2 route-transition proposal

**Proposal only. Do not implement in Phase 1.**

## Current facts

- Canonical talent entry on `main` is `/talent` → `TalentDashboard` → `RoleDashboardShell`.
- Canonical business entry is `/business` → `BusinessDashboard` → same shell family.
- `AppRoutes` has **no** `/studio` constants on `main` or on `feat/creator-studio-completion`.
- On `feat/creator-studio-completion`, `/talent` is swapped to `CreatorStudioShell` **without** adding `/studio` routes. Studio destinations are in-shell index switches, not URLs.
- Aliases `/talent/dashboard`, `/business/dashboard`, `/audience/dashboard` exist as constants.

## Recommended direction (needs owner decision)

Make `/studio` the canonical Creator/Talent workspace **root** in a later phase, and keep `/talent` as a temporary compatibility redirect.

Rationale:

- Locked visual contracts and product language say Creator Studio.
- Current role enum and approval key remain `talent`.
- In-shell-only navigation on the feature branch cannot deep-link Analytics vs Identity vs Gravity. Locked pages need addressable routes.

This is a recommendation, not an implementation.

## Decision table

| Question | Options | Recommendation | Owner |
|---|---|---|---|
| Canonical Creator root | `/studio` vs keep `/talent` | `/studio` | required |
| Product label | Talent / Creator / Creator/Talent | UI: Creator Studio. Role key: keep `talent` until a migration | required |
| `/talent` | redirect to `/studio` / remain / become public profile | client redirect `/talent` → `/studio` for one release | required |
| `/talent/dashboard` | keep temporarily / remove | keep as redirect until usage is known | required |
| Who may enter Creator Studio | approved talent; admin acting as talent | same as current `/talent` capability | confirm |
| Pending users | wait page vs audience | keep current: Audience allowed; Studio denied | confirm |
| Denied / restricted / suspended | permission denied | keep current | confirm |
| Unknown / invalid profile | permission denied | keep current | confirm |
| `/studio/analytics` etc. | real routes vs shell index | real child routes after contract approval | required |

## Suggested future map (not wired)

| URL | Surface | Guard |
|---|---|---|
| `/studio` | Overview (concept PDF until locked) | approved talent |
| `/studio/analytics` | Mira lock | approved talent |
| `/studio/identity` | Aria lock | approved talent |
| `/studio/community` | Avery lock | approved talent |
| `/studio/gravity` | Jade lock | approved talent |
| `/studio/portfolio` | Jalen lock | approved talent |
| `/talent` | redirect → `/studio` | same |
| `/talent/dashboard` | redirect → `/studio` | same |

Business stays on `/business` as root. Locked Business children become `/business/...` later. Do not invent those routes in Phase 2 Creator work.

## Compatibility

- Existing bookmarks to `/talent` must not 404.
- Email/deep links that land on `/login?role=talent` should still onboard into the talent approval path, then the canonical studio root.
- Do not create two live UIs (`/talent` old shell and `/studio` new shell) at the same time.

## Migration sequence (after approval)

1. Owner answers the decision table.
2. Add route constants only.
3. Add `/studio` layout + one child (Analytics) using existing `/talent` guard.
4. Point `/talent` redirect at `/studio`.
5. Keep old `TalentDashboard` file until redirect is proven.
6. Tests: approved talent allow; audience deny; pending deny studio; admin allow; anonymous redirect to welcome/early-access.

## Tests required before any redirect ships

- Anonymous `/studio` → public auth path.
- Audience approved `/studio` → denied or audience home, never talent private data.
- Talent approved `/studio` and `/talent` → same studio root.
- Business approved `/studio` → denied.
- Pending talent `/studio` → waiting-approval.
- Restricted `/studio` → permission-denied.

## Rollback

Revert the routing commit on `integration/grok-spotlight-launch`. `/talent` shell remains the baseline behavior on `main` @ `3ede84e`.

## Owner decisions required before Phase 2 code

1. Is `/studio` canonical?
2. Does `/talent` redirect or stay?
3. Canonical product label in UI copy?
4. First implemented studio child (recommended: Analytics only)?
5. Confirm Business children stay unimplemented in the Creator phase.
