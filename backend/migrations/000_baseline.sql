-- It's Invisible Ink — original cloud-sync schema (the live state BEFORE genericization).  #LLM-generated
-- Captured from the 2026-06-10 build so the shared "Apps" backend is reproducible from
-- migrations. This documents the baseline; it already exists on the live project, so the
-- `if not exists` guards make a re-run a harmless no-op. 001_genericize_apps.sql transforms
-- this single-app table into the shared, multi-app schema.

create table if not exists public.manuscripts (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  state      jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.manuscripts enable row level security;

-- each user may only touch their own row (all ops)
do $$ begin
  create policy "own row" on public.manuscripts for all
    using (auth.uid() = user_id) with check (auth.uid() = user_id);
exception when duplicate_object then null; end $$;
