# Spotlight Connect: Master Architecture Specification

## Executive overview

Spotlight Connect should be built as a creator-commerce operating system whose core moat is proof, not discovery alone. Existing platforms such as CreatorIQ and Archive already position themselves around creator marketing intelligence, workflow management, and ROI proof, which means Spotlight must differentiate by making deterministic attribution, settlement-aware economics, supporter identity, and audit-grade operational trust the center of the product rather than a reporting add-on.[1][2][3]

The platform is best framed as a multi-sided market network connecting brands, creators, supporters, and platform operators through a single system of record. NFX’s marketplace framing and the Design Council’s Double Diamond both support a strategy where the product is designed around network effects, workflow lock-in, and validated jobs-to-be-done instead of superficial feature parity.[4][5]

## Product vision

### Product definition

Spotlight Connect is an enterprise-grade performance, attribution, and operational orchestration platform for creator commerce. It is a role-aware system of record that tracks verified events, connects them to economic outcomes, and converts that data into execution workflows for creators, brands, and supporters.[1][2]

### Product boundaries

Spotlight Connect is not a link-in-bio tool, not a social content feed, and not a shallow influencer CRM. It should not optimize around vanity engagement metrics alone, because current research and category positioning increasingly emphasize business outcomes, creative effectiveness, and proof of impact over soft awareness-only reporting.[6][7][3]

### Core jobs-to-be-done

| Actor | Core job | System response |
|---|---|---|
| Brand | Allocate creator spend into audiences that can produce verified profitable return | Margin-aware campaign engine, audit ledger, creator portfolio optimizer |
| Creator | Prove economic value and activate the supporters who matter most | Creator Operations HUD, Gravity Map, action engine |
| Supporter | Turn verified support into recognized identity, access, and influence | Support ledger, tier engine, privilege and governance systems |
| Admin / Trust | Protect system integrity and resolve exceptions | Fraud console, dispute workflows, audit surfaces |

## Strategic differentiation

### Competitive reality

CreatorIQ publicly emphasizes creator marketing scale, intelligence, governance, and benchmarking, while Archive emphasizes creator content capture, automation, and ROI proof.[1][8][2][9] That means Spotlight should not try to win with generic campaign management alone. Its differentiation should come from treating verified events, confidence scoring, settlement status, fraud state, supporter economics, and margin-aware attribution as one integrated operating model.[3][7]

### Distinctive product systems

Spotlight should add the following product systems as explicit differentiators:

- Proof Graph Engine: links creator, brand, supporter, asset, event, order, settlement, and dispute objects into one attributable chain.
- Margin Intelligence Engine: computes gross, net, refund-adjusted, and margin-weighted performance.
- Trust Integrity Engine: handles fraud signals, replay detection, refunds, disputes, and confidence scoring.
- Supporter Dynamics Engine: models supporter recency, repeat value, diversity of support, and retention.
- Action Recommendation Engine: turns data into next-best actions for creators and brands.
- Governance Engine: supports top-tier supporter review, participation, and controlled decision rights.

## Market and research basis

System1’s creator-effectiveness work suggests that creators can drive meaningful brand-building and performance outcomes when the creative quality and integration are strong, reinforcing the need to measure more than reach.[6][7] MIDiA’s work on subscriptions and fan monetization also supports the premise that the most valuable fan relationships are durable, identity-driven, and economically compound, which strengthens the case for a supporter-layer architecture rather than a simple audience list.[10][11]

The product development process should follow the Double Diamond: discover the real pain, define the initial wedge, develop the solution set, and deliver through a validated operating model.[5] For Spotlight, the initial wedge should likely focus on creator-commerce environments where verified purchase, attendance, membership, or merch events can be captured with high integrity and tied to meaningful brand or creator outcomes.[11][3]

## Architecture principles

The system should follow these principles:

- Ledger first: economic truth is derived from verified event records, not manually curated dashboards.
- Security at the data boundary: RLS enforces exposure rules; privileged orchestration is isolated in Edge Functions.
- Confidence over certainty theater: reports should expose confidence levels, settlement state, and dispute status.
- No mock data in production UI surfaces.
- Function-specific privilege: service role is used only for trusted orchestration paths and never exposed to the browser.[12][13][14]

## Technical stack

- Frontend: React 19 + Vite + TypeScript + React Router + TailwindCSS.
- Backend platform: Supabase Auth, Postgres, Realtime, Storage, Edge Functions, Cron, and typed APIs.[15][12]
- Data and security: PostgreSQL with Row-Level Security, constrained schemas, typed RPC, and service-side privileged workflows.[12][13]
- Visualization: Canvas or WebGL for the Gravity Map and dense supporter topology.

## Domain model

### Core actors

- Supporter (fan, buyer, contributor, member)
- Creator
- Brand
- Platform admin
- Trust operator

### Core business objects

- Profile
- Brand organization
- Creator organization or creator profile
- Campaign
- Contract
- Attribution ledger event
- Settlement event
- Supporter economic summary
- Tier snapshot
- Access grant
- Governance motion
- Fraud case
- Dispute
- Export artifact
- Notification job

## Database architecture

### Primary tables

| Domain | Tables |
|---|---|
| Identity | `profiles`, `user_roles`, `brand_memberships`, `creator_settings`, `fan_wallets` |
| Campaigns | `campaigns`, `contracts`, `brand_allocations`, `creator_programs` |
| Ledger | `attribution_ledger`, `settlement_events`, `refund_events`, `chargeback_events` |
| Economics | `fan_creator_scores`, `tier_snapshots`, `creator_economics`, `campaign_economics` |
| Access & governance | `fan_access_grants`, `sovereign_motions`, `sovereign_resolutions` |
| Trust | `fraud_cases`, `ledger_disputes`, `integrity_audits`, `webhook_deliveries` |
| Operations | `creator_actions`, `campaign_exports`, `audit_exports`, `notification_jobs` |
| Derived graph | `gravity_map_nodes`, `proof_graph_edges`, `confidence_snapshots` |

### Essential field guidance

`attribution_ledger` should include identifiers for campaign, creator, supporter, source integration, event type, event timestamp, gross value, net value, fee value, margin rate, settlement status, confidence grade, and source metadata. Ledger rows should be append-oriented and immutable in principle, with corrections represented by compensating rows or system-managed state transitions rather than arbitrary user edits.[3][16]

`fan_creator_scores` should track supporter-creator relationship value, including lifetime spend, recent spend, event diversity, refund penalties, dispute penalties, fraud penalties, recency weighting, and final contribution quality score. `tier_snapshots` should represent time-bounded supporter tier state rather than mutable one-off flags.

## Metrics framework

### Core formulas

Recommended implementation-grade metric set:

- ROCS = `verified_net_value / creator_cost_basis`
- IMI = `verified_margin_value - baseline_margin_value`
- Verified Revenue Density = `verified_net_value / engaged_supporter_count`
- Settlement Integrity Rate = `cleared_value / gross_attributed_value`
- Audience Conversion Depth = `supporters_with_2plus_events / total_verified_supporters`
- Supporter Retention Yield = `retained_supporter_margin / prior_period_supporter_margin`
- Supporter Concentration Risk = `top_1_or_5_supporters_value / total_supporter_value`
- Proof Confidence Score = weighted composite of source integrity, settlement state, dispute exposure, and fraud exposure.

### Contribution Quality Score

A recommended contribution quality model:

`CQS = w1*lifetime_value + w2*recent_value + w3*event_diversity + w4*retention_signal - w5*refund_penalty - w6*fraud_penalty - w7*dispute_penalty`

Weights should be configurable by creator program or brand policy, but default models should favor verified cleared value and recency over stale historic totals.

## Tiering and supporter dynamics

The supporter system should avoid gamified points and instead use economic and behavioral qualification. Suggested tiers:

- Supporter: first verified contribution and baseline trust state.
- Patron: moderate spend plus recurring support and at least two event classes.
- Partner: high contribution, repeat behavior, low refund/dispute rate, long-term signal.
- Sovereign: top percentile contributors by creator-specific value, subject to review and trust thresholds.

Tier progression should be dynamic, recalculated on schedule, and visible as a governed state rather than a permanent collectible badge. Sovereign status should support manual review and controlled governance pathways.

## UI architecture

### Global shell

The application should use a role-sensitive app shell with a left navigation rail, top utility bar, command surface, and dynamic work canvas. Routes should be explicit React Router file routes backed by typed hooks and RLS-safe queries.

### Creator Operations HUD

The Creator Operations HUD should be the creator’s command center for verified economic performance. Required surfaces:

- KPI cards: verified earnings, cleared value, active campaigns, conversion depth, supporter retention yield.
- Gravity Map: supporter nodes sized by lifetime value and positioned by contribution quality and recency.
- Action Queue: recommended actions triggered by cohort thresholds.
- Supporter Cohort Explorer: filters by spend, recency, diversity, churn risk, and tier.
- Economic Narrative Feed: natural-language change summaries tied to ledger events.

### Brand Impact Engine

The Brand Impact Engine should map spend to evidence. Required surfaces:

- Campaign control panel.
- Proof Console with confidence-filtered attribution rows.
- Portfolio optimizer comparing creator cohorts.
- Scenario planner for allocation modeling.
- Audit export center for deterministic ledger exports.

### Supporter workspace

The supporter-facing product should include:

- Support ledger.
- Tier and privilege center.
- Access and event timeline.
- Governance participation for eligible tiers.
- Contribution path guidance explaining how access and status are earned.

## Product modes

### Creator modes

- Growth mode.
- Retention mode.
- Launch mode.
- Recovery mode.
- Sovereign mode.

### Brand modes

- Exploration mode.
- Efficiency mode.
- Scale mode.
- Incubation mode.
- Defense mode.

Modes should influence UI defaults, recommended actions, alerting, and which metrics are prioritized in dashboards.

## API architecture

### Design split

The API should be split into three layers:

- Direct client access through Supabase Data API and RLS-protected views for safe reads and low-risk writes.[12][13]
- Edge Functions for privileged workflows, exports, webhook handling, and multi-step orchestration.[15][17]
- Scheduled or internal jobs for recomputation, decay, graph refresh, and integrity tasks.[18][19]

### Example client-facing resources

- `/profiles/me`
- `/creator/actions`
- `/creator/supporter-cohorts`
- `/brand/campaigns`
- `/brand/impact-overview`
- `/ledger/events`
- `/supporter/self-tier`
- `/gravity-map/nodes`

### Recommended RPC or derived endpoints

- `get_creator_economic_summary(creator_id, timeframe)`
- `get_brand_campaign_margin_summary(brand_id, timeframe)`
- `get_supporter_tier_history(user_id)`
- `simulate_campaign_allocation(campaign_id, strategy_mode)`
- `get_proof_confidence_rollup(campaign_id)`

## Edge Functions architecture

The full Edge Functions layer should be grouped into six domains.

### Ingestion functions

- `ledger-ingest-webhook`
- `settlement-sync-webhook`
- `refund-sync-webhook`
- `chargeback-sync-webhook`
- `fraud-signal-webhook`
- `tracking-event-webhook`

These receive external events, validate authenticity, deduplicate deliveries, normalize payloads, and write trusted state.[20][16][21]

### Economics functions

- `recompute-fan-economics`
- `recompute-creator-economics`
- `recompute-campaign-economics`
- `refresh-dynamic-tiers`
- `refresh-gravity-map-state`

### Creator operations functions

- `trigger-creator-action`
- `review-sovereign-candidate`
- `issue-fan-access-grant`
- `revoke-fan-access-grant`
- `create-sovereign-motion`
- `record-sovereign-resolution`

### Brand operations functions

- `deploy-campaign-infrastructure`
- `pause-campaign`
- `resume-campaign`
- `run-smart-yield-allocation`
- `export-ledger-audit`
- `export-campaign-performance`

### Admin and trust functions

- `manual-tier-freeze`
- `manual-tier-override`
- `resolve-fraud-case`
- `resolve-ledger-dispute`
- `ban-linked-accounts`
- `unlock-qualified-status`
- `run-integrity-audit`

### Platform utility functions

- `dispatch-notifications`
- `generate-export-artifact`
- `queue-job-dispatch`
- `webhook-healthcheck`
- `system-status-probe`

## Webhook security requirements

Webhook functions should use `verify_jwt = false` only when they implement their own validation. Every critical-integrity webhook should require:

- raw-body signature verification,
- HMAC-SHA256 or stronger,
- signed timestamp,
- delivery identifier,
- replay protection,
- idempotent event handling,
- timing-safe digest comparison,
- secret rotation using `key_id`,
- restricted logging that excludes secrets and sensitive digests.[22][20][23][21][24]

A recommended canonical message format is `timestamp.delivery_id.raw_body`, signed by the provider secret and validated before any payload processing begins.[16][25]

## Security architecture

### RLS first, service role second

RLS should remain the primary exposure boundary for all app-facing tables. The service role key bypasses RLS entirely and therefore must never be exposed outside trusted backend execution contexts.[14][26] Service role should be used only for tightly scoped orchestration tasks such as ingestion, exports, recomputation, trust operations, and cross-tenant administrative maintenance.[17][27]

### Service role vs scoped RLS for high-concurrency ledger writes

For high-end concurrency ledger writes, the safest and most scalable split is not “service role everywhere” or “RLS everywhere,” but a hybrid model.

Scoped RLS writes are preferable for normal user-driven mutations because they preserve tenant isolation directly at the database layer and keep the browser on a least-privilege path.[12][13] However, high-concurrency ledger ingestion is a special case: these writes often originate from external systems, require idempotency, signature validation, normalization, deduplication, and may need cross-tenant or cross-domain side effects, which makes pure client-style RLS writes a poor fit.[20][16][21]

Service role is operationally superior for webhook-driven ledger ingestion because it bypasses policy overhead, avoids accidental user-session contamination when correctly isolated, and allows the system to write to multiple protected tables in one trusted flow.[14][26][28] That said, service role must be wrapped in strict preconditions: validated webhook authenticity, schema validation, duplicate checks, append-only semantics, audited writes, and narrow-purpose function boundaries.[17][27]

The recommended rule is:

- Use RLS-scoped writes for low-risk user-authored records such as profile edits, creator settings, or campaign drafts.
- Use service-role Edge Functions for ingestion into `attribution_ledger`, `settlement_events`, `refund_events`, `fraud_cases`, and other integrity-sensitive write paths.
- Expose resulting data back to the app through RLS-scoped reads, security-invoker views, and redacted summaries.

This gives Spotlight the write throughput and orchestration flexibility needed for concurrent ledger updates without sacrificing a zero-trust exposure model.[12][29][14]

### RLS policy strategy

Identity and ledger domain tables should use a hybrid of self-owned, creator-scoped, brand-scoped, and admin/service-controlled policies. Direct client writes should be blocked for all integrity-sensitive tables, especially ledger, settlement, fraud, exports, and derived economic scores.[12][30]

Representative policy rules:

- `profiles`: self-read and self-update on mutable fields only.
- `user_roles`: self-read, admin write.
- `brand_memberships`: membership-scoped read, owner/admin write.
- `attribution_ledger`: creator-read for creator rows, brand-read for owned campaigns, admin global read, no direct client write.
- `settlement_events`: participant-scoped read, function/service write only.
- `fan_creator_scores`: supporter self-read, creator scoped read, service recompute write only.
- `tier_snapshots`: supporter self-read, creator supporter-scope read, service write only.
- `webhook_deliveries`: admin read, function write only.

## RLS performance strategy

Across a 35-table architecture, RLS performance must be tested and audited continuously. Production guidance emphasizes:

- indexing columns referenced in policy predicates,
- minimizing joins or repeated lookups inside policies,
- wrapping repeated auth expressions efficiently,
- using helper functions carefully in private schemas,
- benchmarking with `EXPLAIN ANALYZE`,
- and enforcing deny/allow policy tests with pgTAP in CI.[31][32][33][34]

A practical audit process should include:

1. Policy inventory for all tables and actors.
2. Query plan review for creator, brand, supporter, and admin workloads.
3. Index verification for every policy path.
4. Regression tests for allow and deny cases.
5. Ongoing monitoring of slow protected queries.
6. Quarterly policy drift audits.

## Algorithms and intelligence systems

### Proof Confidence algorithm

Each ledger event should receive a confidence score built from:

- source integrity,
- signature validity,
- settlement status,
- refund state,
- fraud exposure,
- dispute state,
- event linkage completeness,
- duplication certainty.

Confidence grades can then be surfaced as `A`, `B`, `C`, `D`, where only high-confidence cleared value is included in strict finance-grade reporting by default.

### Smart-Yield allocation

The brand routing engine should score creators by a composite of:

- creator margin efficiency,
- verified supporter density,
- partner/sovereign concentration,
- supporter retention yield,
- dispute-adjusted proof confidence,
- campaign fit score.

The engine should support hard constraints such as budget cap, brand safety exclusions, minimum confidence threshold, and target margin floor.

### Gravity Map layout

The Gravity Map should be a live topological visualization where node radius reflects supporter value, radial distance reflects contribution quality score, hue or opacity reflects recency, and halo state reflects trust or tier state. Cluster detection should be used to identify retention cohorts, activation pockets, and concentration risk.

## Analytics and graphing

Recommended dashboard graph types:

- cleared vs gross value trend line,
- proof confidence stacked bar,
- supporter cohort retention curve,
- concentration risk area chart,
- creator portfolio efficiency scatter plot,
- refund and dispute trend monitor,
- event diversity heatmap,
- campaign allocation scenario comparison chart.

These should appear as role-aware analytics modules rather than a single generic dashboard.

## Storage and exports

Storage should be used for generated exports, brand briefs, creator collateral, and signed artifacts. Export generation should create immutable records referencing source query scope, generated timestamp, requesting actor, and artifact checksum where feasible.

## Observability and operations

The platform should emit structured operational logs for:

- webhook verification results,
- duplicate suppression,
- export generation,
- settlement sync outcomes,
- fraud case transitions,
- tier recalculation jobs,
- creator action execution,
- campaign allocation decisions.

Operational dashboards should expose ingestion health, job latency, queue backlog, error rates, and reconciliation drift.

## Development and delivery plan

### Build sequence

1. Stand up database schemas, enums, helper functions, and baseline RLS.
2. Build auth, profiles, and role bootstrap flows.
3. Implement ledger and settlement ingestion paths.
4. Add derived economics and tier recalculation jobs.
5. Build Creator Operations HUD and Brand Impact Engine.
6. Add exports, trust workflows, and governance systems.
7. Add simulation, optimization, and advanced recommendation layers.
8. Harden observability, performance, and audit systems.

### Engineering directives

- No production route may rely on mock data.
- Every integrity-sensitive mutation path must have an audited backend function.
- Every exposed table must have explicit RLS enabled at creation time.[12]
- Every policy path must be indexed if used at scale.[32]
- Service-role code paths must be isolated and minimal.[14][26]
- Every critical webhook must be replay-safe and idempotent.[16][21][24]

## Final directive

Spotlight Connect should be built as a proof-native creator-commerce operating system that combines deterministic attribution, settlement-aware economics, supporter identity, trusted workflow orchestration, and enterprise-grade auditability. The system will stand out not by adding more influencer-platform features, but by unifying brand finance logic, creator operating intelligence, supporter value recognition, and cryptographically verifiable event flows into one defensible platform architecture.[1][2][7]