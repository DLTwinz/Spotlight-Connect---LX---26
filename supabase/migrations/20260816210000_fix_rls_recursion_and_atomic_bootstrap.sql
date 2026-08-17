-- =============================================================================
-- Migration: Fix RLS infinite recursion (42P17) + atomic creator bootstrap
-- Depends on: 20260815200000_fanmap_001_organizations_creators_memberships.sql
-- Status after apply: written; RLS verification requires live execution
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Helper functions (SECURITY DEFINER, narrow, stable)
--    All tenancy checks in policies MUST go through these. Never subquery
--    memberships (or any table whose RLS depends on memberships) directly
--    from inside a policy expression.
-- -----------------------------------------------------------------------------

create or replace function public.is_platform_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.memberships
    where user_id = auth.uid()
      and member_role = 'platform_admin'
  );
$$;

create or replace function public.is_member_of_creator(p_creator_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.memberships
    where user_id = auth.uid()
      and creator_id = p_creator_id
  );
$$;

create or replace function public.is_creator_owner(p_creator_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.memberships
    where user_id = auth.uid()
      and creator_id = p_creator_id
      and member_role = 'creator_owner'
  );
$$;

create or replace function public.is_member_of_org(p_org_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.memberships
    where user_id = auth.uid()
      and org_id = p_org_id
  );
$$;

create or replace function public.is_org_owner(p_org_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.memberships
    where user_id = auth.uid()
      and org_id = p_org_id
      and member_role in ('creator_owner', 'platform_admin')
  );
$$;

-- -----------------------------------------------------------------------------
-- 2. Drop all broken policies from Migration 001
-- -----------------------------------------------------------------------------

drop policy if exists "select_own_creators" on public.creators;
drop policy if exists "insert_own_creators" on public.creators;
drop policy if exists "update_own_creators" on public.creators;
drop policy if exists "delete_own_creators_owner" on public.creators;

drop policy if exists "select_own_orgs" on public.organizations;
drop policy if exists "insert_orgs_authenticated" on public.organizations;
drop policy if exists "update_own_orgs" on public.organizations;
drop policy if exists "delete_own_orgs_owner" on public.organizations;

drop policy if exists "select_own_memberships" on public.memberships;
drop policy if exists "insert_memberships_owner_or_admin" on public.memberships;
drop policy if exists "insert_memberships" on public.memberships;
drop policy if exists "update_memberships_owner_or_admin" on public.memberships;
drop policy if exists "delete_memberships_owner_or_admin" on public.memberships;

-- -----------------------------------------------------------------------------
-- 3. Recreate non-recursive policies
-- -----------------------------------------------------------------------------

-- ----- memberships (root tenancy table) -----
create policy "select_own_memberships" on public.memberships
  for select using (
    user_id = auth.uid()
    or public.is_platform_admin()
    or public.is_creator_owner(creator_id)
  );

-- Strict: no bootstrap clause. Initial ownership is created only by
-- create_creator_with_owner(). Subsequent staff adds require existing owner.
create policy "insert_memberships" on public.memberships
  for insert with check (
    public.is_platform_admin()
    or public.is_creator_owner(creator_id)
  );

create policy "update_memberships" on public.memberships
  for update using (
    public.is_platform_admin()
    or public.is_creator_owner(creator_id)
  );

create policy "delete_memberships" on public.memberships
  for delete using (
    public.is_platform_admin()
    or public.is_creator_owner(creator_id)
  );

-- ----- creators -----
create policy "select_own_creators" on public.creators
  for select using (
    public.is_member_of_creator(id)
    or public.is_platform_admin()
  );

create policy "insert_own_creators" on public.creators
  for insert with check (auth.uid() is not null);

create policy "update_own_creators" on public.creators
  for update using (
    public.is_member_of_creator(id)
    or public.is_platform_admin()
  );

create policy "delete_own_creators_owner" on public.creators
  for delete using (
    public.is_creator_owner(id)
    or public.is_platform_admin()
  );

-- ----- organizations -----
create policy "select_own_orgs" on public.organizations
  for select using (
    public.is_member_of_org(id)
    or public.is_platform_admin()
  );

create policy "insert_orgs_authenticated" on public.organizations
  for insert with check (auth.uid() is not null);

create policy "update_own_orgs" on public.organizations
  for update using (
    public.is_org_owner(id)
    or public.is_platform_admin()
  );

create policy "delete_own_orgs_owner" on public.organizations
  for delete using (
    public.is_org_owner(id)
    or public.is_platform_admin()
  );

-- -----------------------------------------------------------------------------
-- 4. Atomic bootstrap function
--    Client never does two separate inserts for initial ownership.
--    This function creates org (if needed) + creator + owner membership
--    in one transaction, eliminating the race window entirely.
-- -----------------------------------------------------------------------------

create or replace function public.create_creator_with_owner(
  p_display_name text,
  p_handle text,
  p_org_id uuid default null,
  p_talent_profile_id uuid default null,
  p_niche text default null,
  p_bio text default null,
  p_avatar_url text default null
)
returns uuid  -- returns the new creators.id
language plpgsql
security definer
set search_path = public
as $$
declare
  v_creator_id uuid;
  v_org_id uuid := p_org_id;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  -- If no org supplied, create a minimal independent org.
  -- NOTE: default naming (display_name || ' Org') is a placeholder convention
  -- only, not a permanent product rule. Subject to change.
  if v_org_id is null then
    insert into public.organizations (name, org_type, legal_structure_status)
    values (p_display_name || ' Org', 'independent', 'unresolved')
    returning id into v_org_id;
  end if;

  insert into public.creators (
    org_id,
    talent_profile_id,
    display_name,
    handle,
    niche,
    bio,
    avatar_url
  ) values (
    v_org_id,
    p_talent_profile_id,
    p_display_name,
    p_handle,
    p_niche,
    p_bio,
    p_avatar_url
  )
  returning id into v_creator_id;

  insert into public.memberships (user_id, creator_id, org_id, member_role)
  values (auth.uid(), v_creator_id, v_org_id, 'creator_owner');

  return v_creator_id;
end;
$$;

-- Grants:
-- - Revoke from PUBLIC so anonymous callers cannot execute.
-- - Grant to authenticated so logged-in clients can call via RPC.
-- - service_role bypasses RLS and privilege checks on functions by design;
--   it can call this function from Edge Functions without additional grants.
--   That assumption is intentional and documented here so it is not silent.
revoke all on function public.create_creator_with_owner from public;
grant execute on function public.create_creator_with_owner to authenticated;

-- =============================================================================
-- End of fix migration
-- Apply via Supabase SQL Editor or supabase db push.
-- After apply: re-test authenticated GET /rest/v1/creators as Test User B.
-- Expect: no 42P17 error (empty array or real rows is fine).
-- Then create Test User A data via create_creator_with_owner RPC and run
-- the cross-tenant isolation check.
-- =============================================================================
