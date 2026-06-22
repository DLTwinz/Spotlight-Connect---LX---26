-- Supabase advisor: RLS enabled but no policies.
-- Adding explicit deny policies is a no-behavior-change hardening step:
-- when RLS is enabled and there are no policies, API roles are denied anyway.

do $$
begin
  -- comments
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='comments') then
    execute 'create policy comments_deny_all_select on public.comments for select to anon, authenticated using (false)';
  end if;

  -- feature_policy_audit
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='feature_policy_audit') then
    execute 'create policy feature_policy_audit_deny_all_select on public.feature_policy_audit for select to anon, authenticated using (false)';
  end if;

  -- group_members
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='group_members') then
    execute 'create policy group_members_deny_all_select on public.group_members for select to anon, authenticated using (false)';
  end if;

  -- portfolio_items
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='portfolio_items') then
    execute 'create policy portfolio_items_deny_all_select on public.portfolio_items for select to anon, authenticated using (false)';
  end if;

  -- rewards
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='rewards') then
    execute 'create policy rewards_deny_all_select on public.rewards for select to anon, authenticated using (false)';
  end if;

  -- studio_sessions
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='studio_sessions') then
    execute 'create policy studio_sessions_deny_all_select on public.studio_sessions for select to anon, authenticated using (false)';
  end if;

  -- user_campaign_memberships
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='user_campaign_memberships') then
    execute 'create policy user_campaign_memberships_deny_all_select on public.user_campaign_memberships for select to anon, authenticated using (false)';
  end if;

  -- user_mission_progress
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='user_mission_progress') then
    execute 'create policy user_mission_progress_deny_all_select on public.user_mission_progress for select to anon, authenticated using (false)';
  end if;

  -- user_progression
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='user_progression') then
    execute 'create policy user_progression_deny_all_select on public.user_progression for select to anon, authenticated using (false)';
  end if;

  -- user_rewards
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='user_rewards') then
    execute 'create policy user_rewards_deny_all_select on public.user_rewards for select to anon, authenticated using (false)';
  end if;
end $$;
