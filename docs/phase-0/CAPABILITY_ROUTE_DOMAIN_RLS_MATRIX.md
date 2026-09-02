# Capability, Route, Domain, and RLS Matrix

> Phase 0 control-plane reference for Spotlight Connect.
>
> Status: Draft

## Purpose

Use this matrix to define and verify the relationship among:

- Product capabilities
- Application routes
- Domain ownership
- Authenticated roles
- Supabase row-level security (RLS) policies

## Capability Matrix

| Capability | Route(s) | Domain / Owner | Allowed roles | RLS expectation | Phase 0 status |
| --- | --- | --- | --- | --- | --- |
| Authentication and session bootstrap | `/login`, `/signup`, `/auth/callback` | Auth | Public, authenticated user | Public access only to auth entry points; session data is scoped to the authenticated user | Define |
| Profile read and update | `/profile`, `/settings/profile` | Identity / Profiles | Authenticated user | Users can read/update only their own profile row; limited public profile fields may be readable where explicitly required | Define |
| Role resolution | App bootstrap and guarded routes | Identity / Roles | Authenticated user | Role assignments are not client-writable; users can read only the role data required for their session | Define |
| Creator workspace | `/creator`, `/creator/*` | Creator | Creator, admin | Creators can access only records they own or are explicitly assigned; admins retain governed access | Define |
| Business workspace | `/business`, `/business/*` | Business | Business, admin | Business users can access only their organization and authorized workspace records; membership must be enforced server-side | Define |
| Fan experience | `/fan`, `/fan/*` | Fan / Community | Fan, creator, admin as applicable | Fans can access their own private activity; public community content follows publication and visibility rules | Define |
| Organization membership | `/settings/team`, `/business/team` | Organizations / Memberships | Organization member, owner, admin | Members can view their own memberships; only authorized owners/admins can manage memberships | Define |
| Content and campaign management | `/creator/content`, `/business/campaigns` | Content / Campaigns | Creator, business, admin | Read/write authorization is based on ownership, organization membership, and record state | Define |
| Admin control plane | `/admin`, `/admin/*` | Administration | Admin | Admin-only routes require authoritative server-side role checks; policies must not rely solely on client route guards | Define |

## Route Guard Rules

| Route class | Authentication | Authorization source | Client behavior | Server / RLS requirement |
| --- | --- | --- | --- | --- |
| Public | Not required | None | Allow navigation | Tables and functions expose only intentionally public data |
| Auth entry | Not required | Auth provider | Redirect authenticated users when appropriate | No application data access without a valid session |
| Authenticated | Required | Valid session | Redirect unauthenticated users to login | Every protected-table policy checks `auth.uid()` or an equivalent trusted claim |
| Role workspace | Required | Authoritative role assignment | Block or redirect unauthorized roles | RLS validates role, ownership, and membership independently of client routing |
| Organization workspace | Required | Membership record | Require organization context | RLS validates membership against the record's organization ID |
| Admin | Required | Admin role / trusted claim | Deny non-admin navigation | Privileged mutations use restrictive policies and, where needed, secure server-side functions |

## Domain Ownership

| Domain | Primary entities | Ownership model | Required access checks |
| --- | --- | --- | --- |
| Identity | `profiles`, `user_roles` | User-owned with admin-governed role assignment | `auth.uid()` matches profile user ID; role writes restricted |
| Organizations | `organizations`, `organization_memberships` | Organization-owned | Active membership and membership permission level |
| Creator | Creator profile, creator-owned content, creator analytics | Creator-owned | Creator ID matches authenticated user or approved team membership |
| Business | Business profile, campaigns, business assets | Organization-owned | Authenticated user belongs to the corresponding organization |
| Fan / Community | Fan profile, follows, engagement, community activity | User-owned plus visibility rules | Fan ID matches `auth.uid()` for private records; published content is filtered by visibility |
| Administration | Moderation, audits, platform configuration | Platform-owned | Admin claim/role plus auditability for sensitive actions |

## RLS Baseline

1. Enable RLS on every application table in the public schema.
2. Default to deny; add only explicit `SELECT`, `INSERT`, `UPDATE`, and `DELETE` policies.
3. Treat Flutter route guards as user experience controls, not authorization controls.
4. Base user-owned policies on `auth.uid()` and a direct, indexed ownership column.
5. Base organization-owned policies on an active membership relationship.
6. Restrict role assignment, moderation, and platform configuration writes to trusted administrative paths.
7. Keep sensitive cross-table authorization logic in security-definer functions only when necessary, with a fixed `search_path` and narrowly scoped privileges.
8. Record policy tests for allowed and denied cases before each domain is released.

## Verification Checklist

- [ ] Every protected route has a documented route class.
- [ ] Every route maps to a domain owner and allowed role set.
- [ ] Every backing table has RLS enabled.
- [ ] Every protected operation has an allow policy and an expected-deny test.
- [ ] No client-side role check is the sole protection for data or mutations.
- [ ] Organization access is enforced through membership, not client-supplied organization IDs.
- [ ] Administrative actions are auditable.
- [ ] This matrix is updated whenever a route, role, table, or policy changes.
