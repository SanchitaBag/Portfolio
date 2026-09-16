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


create table if not exists public.brand_names (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  published boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

insert into public.brand_names (name, published, sort_order)
select v.name, true, v.sort_order
from (values
  ('Glow & Co.',0),
  ('Studio Mira',1),
  ('Nourish Labs',2),
  ('The Home Edit',3),
  ('Verdant Skincare',4),
  ('Loom & Leaf',5),
  ('Everyday Botanicals',6),
  ('Filtre',7)
) as v(name,sort_order)
where not exists (select 1 from public.brand_names b where b.name=v.name);


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
alter table public.brand_names enable row level security;
alter table public.site_profile enable row level security;
alter table public.testimonials enable row level security;

-- Remove/recreate policies so this script can safely be run again.
drop policy if exists "Public can view published portfolio" on public.portfolio_items;
drop policy if exists "Public can view published Instagram posts" on public.instagram_posts;
drop policy if exists "Public can view scrolling brands" on public.brand_names;
drop policy if exists "Sanchita can manage scrolling brands" on public.brand_names;
drop policy if exists "Public can view site profile" on public.site_profile;
drop policy if exists "Sanchita can manage site profile" on public.site_profile;
drop policy if exists "Sanchita can manage Instagram posts" on public.instagram_posts;
drop policy if exists "Sanchita can manage portfolio" on public.portfolio_items;
drop policy if exists "Public can view published testimonials" on public.testimonials;
drop policy if exists "Sanchita can manage testimonials" on public.testimonials;

-- PUBLIC: visitors can only read published content.
create policy "Public can view scrolling brands"
on public.brand_names
for select
to anon, authenticated
using (published = true);

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
create policy "Sanchita can manage scrolling brands"
on public.brand_names
for all
to authenticated
using ((auth.jwt() ->> 'email') = 'sanchitabag44@gmail.com')
with check ((auth.jwt() ->> 'email') = 'sanchitabag44@gmail.com');

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
create index if not exists brand_names_sort_order_idx on public.brand_names(sort_order, created_at);
create index if not exists portfolio_items_created_at_idx on public.portfolio_items(created_at desc);
create index if not exists instagram_posts_created_at_idx on public.instagram_posts(created_at desc);
create index if not exists instagram_posts_published_idx on public.instagram_posts(published);
create index if not exists testimonials_created_at_idx on public.testimonials(created_at desc);
create index if not exists portfolio_items_published_idx on public.portfolio_items(published);
create index if not exists testimonials_published_idx on public.testimonials(published);

-- Homepage hero stats managed from the private admin dashboard.
create table if not exists public.site_stats (
  id uuid primary key default gen_random_uuid(),
  stat_key text unique not null,
  value numeric not null,
  suffix text not null default '',
  label text not null,
  sort_order integer not null default 0,
  published boolean not null default true,
  updated_at timestamptz not null default now()
);

insert into public.site_stats (stat_key, value, suffix, label, sort_order, published)
values
  ('hero_1', 150, '+', 'Brand collabs', 0, true),
  ('hero_2', 1.2, 'M', 'Avg. reel views', 1, true),
  ('hero_3', 98, '%', 'Brand approval rate', 2, true)
on conflict (stat_key) do nothing;

alter table public.site_stats enable row level security;

drop policy if exists "Public can view published site stats" on public.site_stats;
drop policy if exists "Sanchita can manage site stats" on public.site_stats;

create policy "Public can view published site stats"
on public.site_stats
for select
to anon, authenticated
using (published = true);

create policy "Sanchita can manage site stats"
on public.site_stats
for all
to authenticated
using ((auth.jwt() ->> 'email') = 'sanchitabag44@gmail.com')
with check ((auth.jwt() ->> 'email') = 'sanchitabag44@gmail.com');

create index if not exists site_stats_sort_order_idx on public.site_stats(sort_order);
