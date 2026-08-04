# Role Dashboard Data Contract

Spotlight Connect uses shared dashboard chrome, but each role must render a uniquely tailored dashboard with role-specific telemetry, analytics, and interactions.

## Required principles

- The shell can be shared, but the dashboard experience must not be generic.
- Each role must have its own optimized information hierarchy.
- Creator, Business, Audience, and Admin dashboards must each surface different primary metrics, different actions, and different supporting content.
- Telemetry, graph data, scores, and KPI cards must be role-specific unless a shared metric is intentionally defined as universal.
- If a user is temporarily viewing another shell for testing, the UI should still reflect that shell’s intended role contract, not mirror another role’s data model.
- No dashboard should look like a renamed copy of another role’s dashboard.

## Role-specific expectations

### Audience
- Focus on insights, engagement, fandom progression, claimable passes, and discovery.
- Optimize for understanding personal progression and interaction with creators.

### Creator
- Focus on applications, opportunities, support impact, fandom strength, campaign participation, and operational actions.
- Optimize for managing creator workflow and graph growth.

### Business
- Focus on campaigns, discovery, partnerships, suite tools, and brand-facing actions.
- Optimize for campaign creation, management, and relationship-building.

### Admin
- Focus on platform oversight, approvals, moderation, controls, and system health.
- Optimize for operational control and review.

## Enforcement intent

- Route access should determine which dashboard a user can enter.
- Dashboard content should determine what that role can see and do.
- Shared design language must not erase role-specific meaning.
- Any reused components must still be configured with role-specific data sources and copy.

## Product rule

Role dashboards must be uniquely tailored and optimized for that role. Shared UI structure is allowed; shared meaning is not.
