
create table if not exists public.content_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_user_id uuid references auth.users(id) on delete set null,
  target_user_id uuid references auth.users(id) on delete set null,
  target_type text not null default 'content',
  reason text not null default 'other',
  severity text not null default 'medium'
    check (severity in ('low', 'medium', 'high')),
  body text,
  status text not null default 'open'
    check (status in ('open', 'reviewing', 'removed', 'dismissed')),
  created_at timestamptz not null default now(),
  resolved_at timestamptz,
  resolver_user_id uuid references auth.users(id) on delete set null
);

create index if not exists content_reports_status_created_idx
  on public.content_reports (status, created_at desc);

alter table public.content_reports enable row level security;
