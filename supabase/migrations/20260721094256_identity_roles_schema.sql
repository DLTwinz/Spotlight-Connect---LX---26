-- Phase 1: Identity + Roles schema
-- profiles, user_roles, brand_memberships, creator_settings + RLS

create extension if not exists "pgcrypto";

-- === profiles ===
create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid unique references auth.users(id) on delete cascade,
  email text,
  username text unique,
  approved_roles text[] not null default array['audience']::text[],
  active_role text not null default 'audience',
  onboarding_complete boolean not null default false,
  ecosystem_identity_key text,
  routing_token_claim text,
  database_protocol text,
  is_admin boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_profiles_user_id on public.profiles(user_id);
create index if not exists idx_profiles_active_role on public.profiles(active_role);

-- === user_roles (normalized role grants, separate from profiles.approved_roles) ===
create table if not exists public.user_roles (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  role text not null check (role in ('audience','talent','business','admin')),
  status text not null default 'pending' check (status in ('pending','approved','revoked')),
  requested_at timestamptz not null default now(),
  approved_at timestamptz,
  unique (profile_id, role)
);

create index if not exists idx_user_roles_profile_id on public.user_roles(profile_id);

-- === brand_memberships ===
create table if not exists public.brand_memberships (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  brand_org_id uuid not null,
  role_in_org text not null default 'member' check (role_in_org in ('owner','admin','member')),
  created_at timestamptz not null default now()
);

create index if not exists idx_brand_memberships_profile_id on public.brand_memberships(profile_id);
create index if not exists idx_brand_memberships_org_id on public.brand_memberships(brand_org_id);

-- === creator_settings ===
create table if not exists public.creator_settings (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null unique references public.profiles(id) on delete cascade,
  hud_preferences jsonb not null default '{}'::jsonb,
  profile_layout jsonb not null default '{}'::jsonb,
  visibility jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- === updated_at triggers ===
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists trg_creator_settings_updated_at on public.creator_settings;
create trigger trg_creator_settings_updated_at
before update on public.creator_settings
for each row execute function public.set_updated_at();

-- === RLS enable ===
alter table public.profiles enable row level security;
alter table public.user_roles enable row level security;
alter table public.brand_memberships enable row level security;
alter table public.creator_settings enable row level security;

-- === profiles policies ===
drop policy if exists "profiles_select_own_or_admin" on public.profiles;
create policy "profiles_select_own_or_admin"
on public.profiles for select
using (
  auth.uid() = user_id
  or exists (select 1 from public.profiles p where p.user_id = auth.uid() and p.is_admin = true)
);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
on public.profiles for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
on public.profiles for insert
with check (auth.uid() = user_id);

-- === user_roles policies ===
drop policy if exists "user_roles_select_own_or_admin" on public.user_roles;
create policy "user_roles_select_own_or_admin"
on public.user_roles for select
using (
  exists (select 1 from public.profiles p where p.id = profile_id and p.user_id = auth.uid())
  or exists (select 1 from public.profiles p where p.user_id = auth.uid() and p.is_admin = true)
);

drop policy if exists "user_roles_insert_own" on public.user_roles;
create policy "user_roles_insert_own"
on public.user_roles for insert
with check (
  exists (select 1 from public.profiles p where p.id = profile_id and p.user_id = auth.uid())
);

drop policy if exists "user_roles_admin_manage" on public.user_roles;
create policy "user_roles_admin_manage"
on public.user_roles for update
using (exists (select 1 from public.profiles p where p.user_id = auth.uid() and p.is_admin = true));

-- === brand_memberships policies ===
drop policy if exists "brand_memberships_select_own_or_admin" on public.brand_memberships;
create policy "brand_memberships_select_own_or_admin"
on public.brand_memberships for select
using (
  exists (select 1 from public.profiles p where p.id = profile_id and p.user_id = auth.uid())
  or exists (select 1 from public.profiles p where p.user_id = auth.uid() and p.is_admin = true)
);

drop policy if exists "brand_memberships_insert_own" on public.brand_memberships;
create policy "brand_memberships_insert_own"
on public.brand_memberships for insert
with check (
  exists (select 1 from public.profiles p where p.id = profile_id and p.user_id = auth.uid())
);

-- === creator_settings policies ===
drop policy if exists "creator_settings_select_own_or_admin" on public.creator_settings;
create policy "creator_settings_select_own_or_admin"
on public.creator_settings for select
using (
  exists (select 1 from public.profiles p where p.id = profile_id and p.user_id = auth.uid())
  or exists (select 1 from public.profiles p where p.user_id = auth.uid() and p.is_admin = true)
);

drop policy if exists "creator_settings_upsert_own" on public.creator_settings;
create policy "creator_settings_upsert_own"
on public.creator_settings for insert
with check (
  exists (select 1 from public.profiles p where p.id = profile_id and p.user_id = auth.uid())
);

drop policy if exists "creator_settings_update_own" on public.creator_settings;
create policy "creator_settings_update_own"
on public.creator_settings for update
using (
  exists (select 1 from public.profiles p where p.id = profile_id and p.user_id = auth.uid())
);
