begin;

create extension if not exists pgcrypto;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

grant usage on schema public to anon, authenticated;

create or replace function private.current_user_is_platform_admin()
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select exists (
    select 1
    from public.users u
    where u.id = (select auth.uid())
      and coalesce(u.is_admin, false) = true
  );
$$;
