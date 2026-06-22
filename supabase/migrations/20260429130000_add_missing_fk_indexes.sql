-- Adds covering indexes for foreign keys flagged by Supabase performance advisor.

create index if not exists idx_campaign_missions_mission_id on public.campaign_missions (mission_id);

create index if not exists idx_comments_author_id on public.comments (author_id);
create index if not exists idx_comments_post_id on public.comments (post_id);

create index if not exists idx_creator_subscriptions_creator_user_id on public.creator_subscriptions (creator_user_id);
create index if not exists idx_creator_subscriptions_plan_id on public.creator_subscriptions (plan_id);

create index if not exists idx_feature_policy_audit_actor_user_id on public.feature_policy_audit (actor_user_id);

create index if not exists idx_group_members_user_id on public.group_members (user_id);

create index if not exists idx_groups_created_by_user_id on public.groups (created_by_user_id);

create index if not exists idx_opportunity_saves_opportunity_id on public.opportunity_saves (opportunity_id);

create index if not exists idx_portfolio_items_user_id on public.portfolio_items (user_id);

create index if not exists idx_story_seen_story_id on public.story_seen (story_id);

create index if not exists idx_studio_sessions_host_id on public.studio_sessions (host_id);

create index if not exists idx_user_campaign_memberships_campaign_id on public.user_campaign_memberships (campaign_id);

create index if not exists idx_user_follows_following_user_id on public.user_follows (following_user_id);

create index if not exists idx_user_milestones_milestone_id on public.user_milestones (milestone_id);

create index if not exists idx_user_mission_progress_mission_id on public.user_mission_progress (mission_id);

create index if not exists idx_user_missions_mission_id on public.user_missions (mission_id);

create index if not exists idx_user_rewards_granted_by on public.user_rewards (granted_by);
create index if not exists idx_user_rewards_reward_id on public.user_rewards (reward_id);
