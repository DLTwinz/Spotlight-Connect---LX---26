-- Migration 001: Fan Map foundation — organizations, creators, memberships
-- Authorized 2026-08-15. Gap 1 + Gap 3 approvals applied.
-- Status after apply: written; RLS verification pending — not yet executed.

-- =============================================================================
-- 1. organizations
-- =============================================================================
create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  org_type text not null check (org_type in ('label', 'agency', 'independent')),
  branding jsonb default '{}'::jsonb,
  -- Gap 3 approved field (default-deny)
  legal_structure_status text not null default 'unresolved'
    check (legal_structure_status in (
      'unresolved',
      'licensed_talent_agency',
      'structured_no_procurement',
      'deferred_with_reason'
    )),
  legal_structure_set_at timestamptz,
  legal_structure_set_by uuid references auth.users(id),
  legal_structure_notes text,
  created_at timestamptz default now()
);

comment on column public.organizations.legal_structure_status is
  'Sole authorization gate for deal creation. Default unresolved = deny. Human-set only.';

-- =============================================================================
-- 2. creators (thin projection; talent_profile_id NON-unique per Gap 1 approval)
-- =============================================================================
create table if not exists public.creators (
  id uuid primary key default gen_random_uuid(),
  org_id uuid references public.organizations(id),
  talent_profile_id uuid references public.talent_profiles(id),  -- non-unique (approved)
  display_name text not null,
  handle text unique not null,
  niche text,
  bio text,
  avatar_url text,
  onboarded_at timestamptz default now(),
  status text default 'active' check (status in ('active', 'paused', 'churned')),
  created_at timestamptz default now()
);

create index if not exists idx_creators_talent_profile_id
  on public.creators(talent_profile_id);

create index if not exists idx_creators_org_id
  on public.creators(org_id);

-- =============================================================================
-- 3. memberships (tenancy authority for Fan Map + deals RLS)
-- =============================================================================
create table if not exists public.memberships (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) not null,
  creator_id uuid references public.creators(id),
  org_id uuid references public.organizations(id),
  member_role text not null check (member_role in (
    'creator_owner',
    'creator_staff',
    'platform_admin'
  )),
  created_at timestamptz default now(),
  unique (user_id, creator_id, org_id)
);

create index if not exists idx_memberships_user_id
  on public.memberships(user_id);

create index if not exists idx_memberships_creator_id
  on public.memberships(creator_id);

create index if not exists idx_memberships_org_id
  on public.memberships(org_id);

-- =============================================================================
-- 4. RLS enable
-- =============================================================================
alter table public.organizations enable row level security;
alter table public.creators enable row level security;
alter table public.memberships enable row level security;

-- =============================================================================
-- 5. RLS policies — organizations
-- =============================================================================
create policy "select_own_orgs" on public.organizations
  for select using (
    id in (
      select org_id from public.memberships
      where user_id = auth.uid() and org_id is not null
    )
    or exists (
      select 1 from public.memberships
      where user_id = auth.uid() and member_role = 'platform_admin'
    )
  );

create policy "insert_orgs_authenticated" on public.organizations
  for insert with check (
    auth.uid() is not null
  );

create policy "update_own_orgs" on public.organizations
  for update using (
    id in (
      select org_id from public.memberships
      where user_id = auth.uid()
        and member_role in ('creator_owner', 'platform_admin')
        and org_id is not null
    )
  ) with check (
    id in (
      select org_id from public.memberships
      where user_id = auth.uid()
        and member_role in ('creator_owner', 'platform_admin')
        and org_id is not null
    )
  );

-- legal_structure_status may only be changed by platform_admin (enforced in app + optional tighter policy later)

create policy "delete_own_orgs_owner" on public.organizations
  for delete using (
    id in (
      select org_id from public.memberships
      where user_id = auth.uid()
        and member_role = 'creator_owner'
        and org_id is not null
    )
  );

-- =============================================================================
-- 6. RLS policies — creators
-- =============================================================================
create policy "select_own_creators" on public.creators
  for select using (
    id in (
      select creator_id from public.memberships
      where user_id = auth.uid() and creator_id is not null
    )
    or exists (
      select 1 from public.memberships
      where user_id = auth.uid() and member_role = 'platform_admin'
    )
  );

create policy "insert_own_creators" on public.creators
  for insert with check (
    auth.uid() is not null
  );

create policy "update_own_creators" on public.creators
  for update using (
    id in (
      select creator_id from public.memberships
      where user_id = auth.uid()
        and member_role in ('creator_owner', 'creator_staff', 'platform_admin')
        and creator_id is not null
    )
  ) with check (
    id in (
      select creator_id from public.memberships
      where user_id = auth.uid()
        and member_role in ('creator_owner', 'creator_staff', 'platform_admin')
        and creator_id is not null
    )
  );

create policy "delete_own_creators_owner" on public.creators
  for delete using (
    id in (
      select creator_id from public.memberships
      where user_id = auth.uid()
        and member_role = 'creator_owner'
        and creator_id is not null
    )
  );

-- =============================================================================
-- 7. RLS policies — memberships
-- =============================================================================
create policy "select_own_memberships" on public.memberships
  for select using (
    user_id = auth.uid()
    or exists (
      select 1 from public.memberships m2
      where m2.user_id = auth.uid() and m2.member_role = 'platform_admin'
    )
    or creator_id in (
      select creator_id from public.memberships
      where user_id = auth.uid() and member_role = 'creator_owner'
    )
  );

create policy "insert_memberships_owner_or_admin" on public.memberships
  for insert with check (
    exists (
      select 1 from public.memberships
      where user_id = auth.uid()
        and member_role in ('creator_owner', 'platform_admin')
    )
    or not exists (  -- bootstrap: allow first membership for a new creator/org
      select 1 from public.memberships
      where creator_id = memberships.creator_id
         or org_id = memberships.org_id
    )
  );

create policy "update_memberships_owner_or_admin" on public.memberships
  for update using (
    exists (
      select 1 from public.memberships m2
      where m2.user_id = auth.uid()
        and m2.member_role in ('creator_owner', 'platform_admin')
        and (
          m2.creator_id = memberships.creator_id
          or m2.org_id = memberships.org_id
          or m2.member_role = 'platform_admin'
        )
    )
  );

create policy "delete_memberships_owner_or_admin" on public.memberships
  for delete using (
    exists (
      select 1 from public.memberships m2
      where m2.user_id = auth.uid()
        and m2.member_role in ('creator_owner', 'platform_admin')
        and (
          m2.creator_id = memberships.creator_id
          or m2.org_id = memberships.org_id
          or m2.member_role = 'platform_admin'
        )
    )
  );

-- =============================================================================
-- End Migration 001
-- RLS policies written; verification requires live execution, not yet performed.
-- Do not proceed to Migration 002 until Test User A/B PASS is confirmed by owner.
-- =============================================================================
