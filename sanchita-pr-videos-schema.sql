create table if not exists public.pr_videos (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  video_url text not null,
  label text default 'PR Video',
  published boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

alter table public.pr_videos enable row level security;

drop policy if exists "Public can read published PR videos" on public.pr_videos;
create policy "Public can read published PR videos" on public.pr_videos
for select using (published = true);

drop policy if exists "Authenticated admins can manage PR videos" on public.pr_videos;
create policy "Authenticated admins can manage PR videos" on public.pr_videos
for all to authenticated using (true) with check (true);
