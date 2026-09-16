-- Sanchita UGC Portfolio CMS
-- Run this entire script in Supabase SQL Editor.
-- Then create Sanchita's user in Authentication > Users.
-- IMPORTANT: change the email below to Sanchita's real login email.

create extension if not exists pgcrypto;

create table if not exists public.portfolio_items (
  id uuid primary key default gen_random_uuid(),
  brand text not null,
  category text not null,
  tag text not null,
  thumbnail_url text,
  video_url text,
  instagram_url text,
  description text,
  published boolean not null default true,
  created_at timestamptz not null default now()
);


create table if not exists public.instagram_posts (
  id uuid primary key default gen_random_uuid(),
  post_url text not null,
  thumbnail_url text not null,
  title text,
  published boolean not null default true,
  created_at timestamptz not null default now()
);


create table if not exists public.site_profile (
  id integer primary key,
  name text not null default 'Sanchita Bag',
  desc1 text,
  desc2 text,
  updated_at timestamptz not null default now()
);

insert into public.site_profile (id,name,desc1,desc2)
values (1,'Sanchita Bag','UGC Content Creator','Beauty · Lifestyle · Product Content')
on conflict (id) do nothing;

create table if not exists public.testimonials (
  id uuid primary key default gen_random_uuid(),
  quote text not null,
  person text not null,
  brand text not null,
  avatar_url text,
  published boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.portfolio_items enable row level security;
alter table public.instagram_posts enable row level security;
alter table public.site_profile enable row level security;
alter table public.testimonials enable row level security;

-- Remove/recreate policies so this script can safely be run again.
drop policy if exists "Public can view published portfolio" on public.portfolio_items;
drop policy if exists "Public can view published Instagram posts" on public.instagram_posts;
drop policy if exists "Public can view site profile" on public.site_profile;
drop policy if exists "Sanchita can manage site profile" on public.site_profile;
drop policy if exists "Sanchita can manage Instagram posts" on public.instagram_posts;
drop policy if exists "Sanchita can manage portfolio" on public.portfolio_items;
drop policy if exists "Public can view published testimonials" on public.testimonials;
drop policy if exists "Sanchita can manage testimonials" on public.testimonials;

-- PUBLIC: visitors can only read published content.
create policy "Public can view site profile"
on public.site_profile
for select
to anon, authenticated
using (true);
create policy "Public can view published Instagram posts"
on public.instagram_posts
for select
to anon, authenticated
using (published = true);

create policy "Public can view published portfolio"
on public.portfolio_items
for select
to anon, authenticated
using (published = true);

create policy "Public can view published testimonials"
on public.testimonials
for select
to anon, authenticated
using (published = true);

-- ADMIN: only the authenticated Sanchita account can manage CMS rows.
-- Change this email to the exact email used for her Supabase Auth account.
create policy "Sanchita can manage site profile"
on public.site_profile
for all
to authenticated
using ((auth.jwt() ->> 'email') = 'sanchitabag44@gmail.com')
with check ((auth.jwt() ->> 'email') = 'sanchitabag44@gmail.com');

create policy "Sanchita can manage Instagram posts"
on public.instagram_posts
for all
to authenticated
using ((auth.jwt() ->> 'email') = 'sanchitabag44@gmail.com')
with check ((auth.jwt() ->> 'email') = 'sanchitabag44@gmail.com');

create policy "Sanchita can manage portfolio"
on public.portfolio_items
for all
to authenticated
using ((auth.jwt() ->> 'email') = 'sanchitabag44@gmail.com')
with check ((auth.jwt() ->> 'email') = 'sanchitabag44@gmail.com');

create policy "Sanchita can manage testimonials"
on public.testimonials
for all
to authenticated
using ((auth.jwt() ->> 'email') = 'sanchitabag44@gmail.com')
with check ((auth.jwt() ->> 'email') = 'sanchitabag44@gmail.com');

-- Optional indexes for the public page.
create index if not exists portfolio_items_created_at_idx on public.portfolio_items(created_at desc);
create index if not exists instagram_posts_created_at_idx on public.instagram_posts(created_at desc);
create index if not exists instagram_posts_published_idx on public.instagram_posts(published);
create index if not exists testimonials_created_at_idx on public.testimonials(created_at desc);
create index if not exists portfolio_items_published_idx on public.portfolio_items(published);
create index if not exists testimonials_published_idx on public.testimonials(published);
