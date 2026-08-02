drop policy if exists "user_roles_admin_manage" on public.user_roles;

create policy "user_roles_admin_manage"
on public.user_roles for all
using (
  exists (
    select 1
    from public.profiles p
    where p.user_id = auth.uid()
      and coalesce(p.is_admin, false) = true
  )
)
with check (
  exists (
    select 1
    from public.profiles p
    where p.user_id = auth.uid()
      and coalesce(p.is_admin, false) = true
  )
);
