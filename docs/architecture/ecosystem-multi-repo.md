# Spotlight Multi-Repository Ecosystem Architecture

## Decision

Spotlight will use a multi-repository architecture with one shared Supabase project initially. Repositories isolate deployable domain surfaces and team ownership; they do **not** create independent identity systems or divergent database schemas.

## Repository topology

| Repository | Responsibility | Owns migrations? | Deploys |
|---|---|---:|---|
| `spotlight-platform-core` | Canonical Supabase schema, RLS policies, Edge Functions, generated client contracts, security tests | Yes — exclusive owner | Supabase database/functions |
| `spotlight-mobile` | Flutter iOS/Android app and role-aware dashboards | No | Mobile release artifacts |
| `spotlight-web` | Web application, public discovery, organization consoles | No | Web artifacts |
| `spotlight-integrations` | Notion/GitHub/partner webhook adapters, ingestion workers, connector health | No | Integration workers/Edge Functions only by core-repo contract |
| `spotlight-intelligence` | Matching, recommendation, explainability, fairness evaluation, offline jobs | No direct production DDL | Models, jobs, evaluation artifacts |
| `spotlight-design-system` | Shared Flutter/web tokens, accessible component specifications, localization patterns | No | Versioned packages |
| `spotlight-ops` | Notion schemas, governance docs, operating runbooks, incident procedures | No | Documentation and configuration |

## Non-negotiable ownership rules

1. `spotlight-platform-core` is the only repository allowed to add, alter, or delete production database objects.
2. Every change to the shared data contract requires a core-repo pull request, migration review, RLS tests, and a generated client-contract release.
3. Client repositories consume versioned contracts. They never issue ad hoc schema migrations.
4. Every public table is RLS-enabled. Grants and RLS policies are added together in the same migration.
5. The browser/mobile client may use a publishable key only. Secret/service keys remain in trusted server environments.
6. The `eco_*` tables are additive and coexist with current Spotlight application tables while migration adapters are built. This scaffold intentionally does not rewrite existing tables such as `users`, `profiles`, `opportunities`, or `communities`.

## Canonical entity namespaces

- Existing product tables retain their current names during transition.
- New full-ecosystem tables use the `eco_` prefix to avoid destructive collisions:
  - organizational graph: `eco_organizations`, `eco_organization_memberships`
  - people and context: `eco_person_role_assignments`, `eco_user_contexts`
  - work and credit graph: `eco_works`, `eco_work_contributors`
  - project operations: `eco_projects`, `eco_project_memberships`, `eco_project_dependencies`
  - opportunities: `eco_opportunities`, `eco_opportunity_applications`
  - trust and governance: `eco_relationships`, `eco_verification_claims`, `eco_consents`, `eco_audit_events`
  - economic intelligence: `eco_economic_signals`
  - explainable recommendations: `eco_recommendations`

## Deployment workflow

1. Create a GitHub feature branch from `main` in `spotlight-platform-core`.
2. Create a Supabase development branch from the production project.
3. Apply and test migrations against the Supabase development branch.
4. Run RLS allow/deny tests and database advisors.
5. Generate and publish versioned client contracts.
6. Update mobile/web/integrations against that contract version.
7. Open a core-repo pull request. Production migration requires an explicit human approval gate.
8. After merge, deploy migration, rerun advisors, and monitor logs and error rates.

## Security decisions embedded in the foundation migration

- `private` schema contains security-definer authorization and audit functions; it is not granted to client roles.
- RLS policies use `(select auth.uid())` and helper functions to permit query-planner caching and avoid per-row auth evaluation.
- Anonymous access is revoked for all ecosystem foundation tables.
- A user can control personal role assignments, context, relationships, applications, consents, and recommendations only where policy permits.
- Organization, project, opportunity, contributor, and economic data are restricted to appropriate creators, active members, project participants, or platform administrators.
- Economic signals deliberately represent ranges, commitments, capacity, and dependencies. They do not create payroll, payroll administration, tax filing, tax compliance, or tax optimization functionality.

## Review issues before applying

- Existing application tables currently include multiple overlapping identity and opportunity models. The foundation is additive by design. A separate reconciliation migration is required before replacing any legacy model.
- The `eco_organization_memberships_create` policy expects the creator/owner membership to be created in a trusted server-side transaction or bootstrap RPC. Client-side creation of the first owner membership is intentionally restricted.
- `eco_audit_events` retains full before/after JSON states. Production privacy policy must define redaction rules and retention periods before sensitive values are written into audited columns.
- Funding, payment-dependency visibility, rights metadata, licensing, cross-border data processing, and AI recommendation disclosures require specialized legal review before public launch.
