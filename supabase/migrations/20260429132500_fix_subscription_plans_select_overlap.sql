-- Avoid multiple permissive SELECT policies for authenticated on subscription_plans
-- by limiting the public-read policy to anon only.

drop policy if exists subscription_plans_select_public on public.subscription_plans;
create policy subscription_plans_select_public_anon on public.subscription_plans for select to anon using (true);
