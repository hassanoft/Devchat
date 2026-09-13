create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique,
  bio text not null default '',
  avatar_url text,
  github_url text,
  linkedin_url text,
  portfolio_url text,
  skills text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references public.profiles(id) on delete cascade,
  conversation_id uuid,
  content text not null default '',
  message_type text not null default 'text' check (message_type in ('text','code')),
  code_language text,
  code_filename text,
  created_at timestamptz not null default now(),
  edited_at timestamptz,
  deleted_at timestamptz
);

create index if not exists messages_created_at_idx on public.messages(created_at);
create index if not exists messages_sender_idx on public.messages(sender_id);
create index if not exists messages_conversation_idx on public.messages(conversation_id, created_at);

alter table public.profiles enable row level security;
alter table public.messages enable row level security;

drop policy if exists "profiles_select_authenticated" on public.profiles;
create policy "profiles_select_authenticated" on public.profiles for select to authenticated using (true);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles for insert to authenticated with check (id = auth.uid());

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists "messages_select_authenticated" on public.messages;
create policy "messages_select_authenticated" on public.messages for select to authenticated using (true);

drop policy if exists "messages_insert_own" on public.messages;
create policy "messages_insert_own" on public.messages for insert to authenticated with check (sender_id = auth.uid());

drop policy if exists "messages_update_own" on public.messages;
create policy "messages_update_own" on public.messages for update to authenticated using (sender_id = auth.uid()) with check (sender_id = auth.uid());

drop policy if exists "messages_delete_own" on public.messages;
create policy "messages_delete_own" on public.messages for delete to authenticated using (sender_id = auth.uid());

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  requested text;
  fallback_name text;
begin
  requested := coalesce(nullif(trim(new.raw_user_meta_data->>'username'), ''), 'dev_' || substr(new.id::text, 1, 8));
  begin
    insert into public.profiles(id, username) values (new.id, requested);
  exception when unique_violation then
    fallback_name := 'dev_' || substr(new.id::text, 1, 8);
    insert into public.profiles(id, username) values (new.id, fallback_name);
  end;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();

create table if not exists public.communities (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  description text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.community_members (
  community_id uuid not null references public.communities(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null default 'member' check (role in ('member','admin')),
  created_at timestamptz not null default now(),
  primary key (community_id, user_id)
);

create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  community_id uuid references public.communities(id) on delete set null,
  name text not null,
  description text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.group_members (
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null default 'member' check (role in ('member','admin')),
  created_at timestamptz not null default now(),
  primary key (group_id, user_id)
);

alter table public.communities enable row level security;
alter table public.community_members enable row level security;
alter table public.groups enable row level security;
alter table public.group_members enable row level security;

drop policy if exists "communities_select_authenticated" on public.communities;
create policy "communities_select_authenticated" on public.communities for select to authenticated using (true);
drop policy if exists "communities_insert_own" on public.communities;
create policy "communities_insert_own" on public.communities for insert to authenticated with check (owner_id = auth.uid());

drop policy if exists "community_members_select_authenticated" on public.community_members;
create policy "community_members_select_authenticated" on public.community_members for select to authenticated using (true);
drop policy if exists "community_members_insert_own" on public.community_members;
create policy "community_members_insert_own" on public.community_members for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "community_members_delete_own" on public.community_members;
create policy "community_members_delete_own" on public.community_members for delete to authenticated using (user_id = auth.uid());

drop policy if exists "groups_select_authenticated" on public.groups;
create policy "groups_select_authenticated" on public.groups for select to authenticated using (true);
drop policy if exists "groups_insert_own" on public.groups;
create policy "groups_insert_own" on public.groups for insert to authenticated with check (owner_id = auth.uid());

drop policy if exists "group_members_select_authenticated" on public.group_members;
create policy "group_members_select_authenticated" on public.group_members for select to authenticated using (true);
drop policy if exists "group_members_insert_own" on public.group_members;
create policy "group_members_insert_own" on public.group_members for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "group_members_delete_own" on public.group_members;
create policy "group_members_delete_own" on public.group_members for delete to authenticated using (user_id = auth.uid());

do $$
begin
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'messages') then
    alter publication supabase_realtime add table public.messages;
  end if;
end $$;
