-- Reduce multiple-permissive-policy warnings without changing access semantics.
-- Strategy:
-- 1) Remove redundant UPDATE policies where a broader policy supersedes a narrower one.
-- 2) Replace "FOR ALL" write policies with INSERT/UPDATE/DELETE-only policies to avoid
--    overlapping SELECT policies.

-- (1) Redundant UPDATE policies (keep the broader policy)
drop policy if exists payout_profiles_update_own on public.creator_payout_profiles;
drop policy if exists creator_subscriptions_update_own on public.creator_subscriptions;

-- opportunity_applications: two identical UPDATE policies
drop policy if exists opportunity_applications_update_parties_or_admin on public.opportunity_applications;

-- story_seen: two identical UPDATE policies
drop policy if exists story_seen_update_owner on public.story_seen;

-- users: two equivalent UPDATE policies
drop policy if exists users_update_own on public.users;

-- posts: two equivalent UPDATE policies
drop policy if exists posts_update on public.posts;

-- (2) Split ALL policies that overlap with SELECT policies

-- feature_policies_owner_write: keep as write-only for the primary admin uid
drop policy if exists feature_policies_owner_write on public.feature_policies;
create policy feature_policies_owner_insert on public.feature_policies for insert to authenticated with check (((select auth.uid()) = '435f952e-2152-4f41-9878-6e46915a82e5'::uuid));
create policy feature_policies_owner_update on public.feature_policies for update to authenticated using (((select auth.uid()) = '435f952e-2152-4f41-9878-6e46915a82e5'::uuid)) with check (((select auth.uid()) = '435f952e-2152-4f41-9878-6e46915a82e5'::uuid));
create policy feature_policies_owner_delete on public.feature_policies for delete to authenticated using (((select auth.uid()) = '435f952e-2152-4f41-9878-6e46915a82e5'::uuid));

-- kill_switches_owner_write
drop policy if exists kill_switches_owner_write on public.kill_switches;
create policy kill_switches_owner_insert on public.kill_switches for insert to authenticated with check (((select auth.uid()) = '435f952e-2152-4f41-9878-6e46915a82e5'::uuid));
create policy kill_switches_owner_update on public.kill_switches for update to authenticated using (((select auth.uid()) = '435f952e-2152-4f41-9878-6e46915a82e5'::uuid)) with check (((select auth.uid()) = '435f952e-2152-4f41-9878-6e46915a82e5'::uuid));
create policy kill_switches_owner_delete on public.kill_switches for delete to authenticated using (((select auth.uid()) = '435f952e-2152-4f41-9878-6e46915a82e5'::uuid));

-- subscription_plans_write_admin
drop policy if exists subscription_plans_write_admin on public.subscription_plans;
create policy subscription_plans_admin_insert on public.subscription_plans for insert to authenticated with check (is_admin());
create policy subscription_plans_admin_update on public.subscription_plans for update to authenticated using (is_admin()) with check (is_admin());
create policy subscription_plans_admin_delete on public.subscription_plans for delete to authenticated using (is_admin());
