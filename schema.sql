-- Recall Ledger — run this once in Supabase → SQL Editor → New query → Run.

create table if not exists public.lectures (
  id              text primary key,
  user_id         uuid not null references auth.users (id) on delete cascade,
  date            date not null,
  module          text not null default '',
  title           text not null default '',
  primary_reading text not null default 'Pending',
  uworld          text not null default 'Pending',
  uworld_pct      integer,
  flashcards      text not null default 'Pending',
  rep1            text not null default 'Pending',
  rep2            text not null default 'Pending',
  rep3            text not null default 'Pending',
  rep4            text not null default 'Pending',
  deleted         boolean not null default false,
  updated_at      timestamptz not null default now()
);

create index if not exists lectures_user_idx on public.lectures (user_id);

-- Row-level security: every row belongs to the account that created it,
-- and no other account can read or change it.
alter table public.lectures enable row level security;

drop policy if exists "own rows readable" on public.lectures;
create policy "own rows readable" on public.lectures
  for select using (auth.uid() = user_id);

drop policy if exists "own rows insertable" on public.lectures;
create policy "own rows insertable" on public.lectures
  for insert with check (auth.uid() = user_id);

drop policy if exists "own rows updatable" on public.lectures;
create policy "own rows updatable" on public.lectures
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "own rows deletable" on public.lectures;
create policy "own rows deletable" on public.lectures
  for delete using (auth.uid() = user_id);

-- Live updates, so a phone marking a rep Done refreshes the laptop straight away.
-- (Safe to run more than once.)
do $$
begin
  alter publication supabase_realtime add table public.lectures;
exception
  when duplicate_object then null;
end $$;

-- ---------------------------------------------------------------
-- Settings: one row per account, holding theme, wording, modules,
-- timetable and review intervals so both devices look the same.
-- ---------------------------------------------------------------
create table if not exists public.settings (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.settings enable row level security;

drop policy if exists "own settings readable" on public.settings;
create policy "own settings readable" on public.settings
  for select using (auth.uid() = user_id);

drop policy if exists "own settings insertable" on public.settings;
create policy "own settings insertable" on public.settings
  for insert with check (auth.uid() = user_id);

drop policy if exists "own settings updatable" on public.settings;
create policy "own settings updatable" on public.settings
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

do $$
begin
  alter publication supabase_realtime add table public.settings;
exception
  when duplicate_object then null;
end $$;
