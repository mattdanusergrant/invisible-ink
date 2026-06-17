-- Definitive RLS fix for app_state (supersedes 002). Run once in Many Doors Opus.
--
-- auth.user_id() returns TEXT, but user_id was uuid — so the "own row" check was
-- a text-vs-uuid comparison that never matched a client value, and writes failed
-- with "new row violates row-level security policy". Make user_id TEXT so the
-- check is a clean text = text, and have the DB stamp it from auth.user_id().
-- (The front-end no longer sends user_id.) The policy must be dropped before the
-- type change because it references the column, then recreated unchanged.

drop policy if exists "own row" on public.app_state;

alter table public.app_state alter column user_id drop default;
alter table public.app_state alter column user_id type text using user_id::text;
alter table public.app_state alter column user_id set default auth.user_id();

create policy "own row" on public.app_state for all to authenticated
  using (auth.user_id() = user_id)
  with check (auth.user_id() = user_id);
