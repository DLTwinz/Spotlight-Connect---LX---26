# Phase 1 baseline

**Status:** documentation / QA only. No product behavior changed.

| Field | Value |
|---|---|
| Repository | `DLTwinz/Spotlight-Connect---LX---26` |
| Canonical source-of-truth branch | `main` |
| Baseline SHA | `3ede84e89b31b46004d39bde9630885283c14c3f` |
| Integration branch | `integration/grok-spotlight-launch` |
| Created from | `main` @ `3ede84e` |
| Date | 2026-09-09 |
| Phase | 1 — integration branch and baseline protection |

`main` is the production **source of truth**. That is not a claim that the application, backend, security posture, legal posture, operations, data, visuals, or features are production-launch-ready.

## What Phase 1 did

- Created `integration/grok-spotlight-launch` from `main` at `3ede84e`.
- Added documentation artifacts listed below.
- Did not modify Flutter product source, routes, tokens, auth, landing, Supabase, dependencies, or CI workflows.

## Files added in this phase

- `docs/PHASE_1_BASELINE.md` (this file)
- `docs/ROUTE_AND_SURFACE_INVENTORY.md`
- `docs/VISUAL_AUTHORITY_REGISTRY.md`
- `docs/PHASE_2_ROUTE_TRANSITION_PROPOSAL.md`
- `docs/PHASE_2_CREATOR_IMPORT_ANALYSIS.md`
- `docs/PHASE_1_SCREENSHOT_BASELINE.md`

## Commands attempted from the Grok execution environment

| Command | Result | Classification |
|---|---|---|
| GitHub `create_branch` `integration/grok-spotlight-launch` from `main` | Success. Ref points at `3ede84e` | Phase 1 action |
| `which flutter` / `flutter --version` | Flutter SDK **not installed** in this agent environment | Environment limitation |
| `dart --version` | Dart SDK **not installed** here | Environment limitation |
| `git status --short` on a local clone of production | Not run. Agent used GitHub API against remote, not a local working copy of the app | Environment limitation |
| `git diff --check` | Not run locally | Environment limitation |
| `flutter pub get` | Not run | Environment limitation |
| `dart format --output=none --set-exit-if-changed lib test` | Not run | Environment limitation |
| `flutter analyze` | Not run here. Existing CI job `analyze` on PRs to `main` runs `flutter analyze --fatal-infos` | Deferred to CI on this PR |
| `flutter test` | Not run here. Existing CI job `test` runs `flutter test` | Deferred to CI on this PR |
| `flutter build web --release` | Not run here. Existing CI job `build-web` requires `SUPABASE_PUBLISHABLE_KEY` secret | Deferred to CI on this PR |
| `flutter pub outdated` | Not run | Environment limitation |
| Authenticated screenshot capture of `/welcome`, `/talent`, `/business`, `/admin` | Not run. Requires a running Flutter web build plus role sessions | Documented in `PHASE_1_SCREENSHOT_BASELINE.md` |

No Phase 1-introduced Flutter failure exists because no Flutter source was changed.

## CI workflow inspection (read-only)

### `.github/workflows/ci.yml`

- Triggers: push to `main` or `spotlight-ui-align`; pull_request targeting `main`.
- Jobs: `analyze` (`flutter analyze --fatal-infos`), `test` (`flutter test`), `build-web` (release web build).
- Format check is explicitly disabled (TODO in workflow).
- Web build refuses `sb_secret_*` / `service_role` keys.
- Web build uses `--dart-define=SUPABASE_URL=https://mdwvokenmehdfybgujpa.supabase.co` and publishable key from secrets.

### `.github/workflows/main.yml`

- Triggers: push to `main` only.
- Builds web release and uploads `build/web` artifact.
- Flutter version pin: `3.x` (channel not pinned to a patch).

PR CI for this branch will run when the pull request targets `main`. That is the evidence path for analyze / test / web build in this phase.

## Package / SDK record (from `pubspec.yaml` on baseline)

- Package: `spotlight_connect` `1.0.0+1`
- SDK constraint: `^3.9.0`
- Notable dependencies: `go_router`, `provider`, `supabase_flutter`, `google_fonts`, `fl_chart`, `livekit_client` `2.11.0`
- Assets declared: `assets/landing/`
- Outdated-package report: **not generated** in this environment. Do not upgrade anything in Phase 1.

## Known limitations (baseline, not introduced by Phase 1)

- Locked Creator Studio pages are **not** on `main`.
- Talent and Business share `RoleDashboardShell` + similar tab mix on `main`.
- `/studio/*` and locked Business subroutes are **proposed**, not active.
- Operator role is absent.
- `test/widget_test.dart` is the only reported test file.
- Backup / misplaced files exist and were **not** cleaned.
- Inspected Supabase tables previously reported empty.
- Material security debt remains (see below).

## Known security blockers (unchanged; do not remediate in visual phases)

Recorded from the accepted Phase 0 brief. Not re-scanned live in Phase 1.

- RLS-enabled tables without policies.
- `SECURITY DEFINER` views.
- Functions with mutable `search_path`.
- Broad execute grants on `SECURITY DEFINER` functions, including anonymous in the prior scan.
- Leaked-password protection disabled.

These block live-user / live-data launch. They do not block documentation.

## Rollback

If this branch or PR must be abandoned:

```bash
# do not merge the PR
git checkout main
git reset --hard 3ede84e89b31b46004d39bde9630885283c14c3f
# optional: delete remote integration branch after owner approval
git push origin --delete integration/grok-spotlight-launch
```

`main` was not modified by Phase 1 branch creation. Deleting the integration branch leaves `main` at `3ede84e`.

## Statement

`main` is untouched. No product UI, route, auth, backend, schema, RLS, or dependency behavior was changed in Phase 1.
