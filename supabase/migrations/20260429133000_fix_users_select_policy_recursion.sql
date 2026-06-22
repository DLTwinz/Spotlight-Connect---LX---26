-- Fix recursive RLS on public.users.
--
-- Root cause:
--   The previous SELECT policy referenced public.is_admin(), and public.is_admin()
--   queries public.users, causing infinite recursion:
--     users SELECT policy -> is_admin() -> users SELECT policy -> ...
--   which manifests as: "stack depth limit exceeded" and breaks login/profile fetch.
--
-- Approach:
--   Keep users readable by the authenticated user for their own row,
--   and allow service_role/postgres for privileged server-side operations.
--   Admin cross-user reads should be done via Edge Functions (service_role),
--   not client-side direct table selects.

begin;

drop policy if exists zz_select_consolidated on public.users;

create policy zz_select_consolidated
on public.users
for select
using (
  id = auth.uid()
  or auth.role() in ('service_role', 'postgres')
);

commit;
