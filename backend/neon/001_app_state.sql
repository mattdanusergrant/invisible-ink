-- Many Doors Opus (Apps) — Neon shared backend.
-- One JSON state blob per user, per app: app_state(app, user_id) -> state.
-- Auth: Neon Auth (Better Auth, email-OTP). Access: Data API (PostgREST) + RLS.
-- The current user is auth.user_id() (the JWT `sub` claim, a uuid matching neon_auth.users_sync.id).
-- Run once in the Many Doors Opus project's SQL Editor.

create table if not exists public.app_state (
  app        text  not null,
  user_id    uuid  not null,        -- = auth.user_id(); no FK to neon_auth.users_sync (it syncs async)
  state      jsonb not null,
  updated_at timestamptz not null default now(),
  primary key (app, user_id)
);

alter table public.app_state enable row level security;

-- a signed-in user may read/write ONLY their own row(s), in any app
create policy "own row" on public.app_state for all to authenticated
  using (auth.user_id() = user_id)
  with check (auth.user_id() = user_id);

-- let the Data API's `authenticated` role reach the table (RLS still gates which rows)
grant usage on schema public to authenticated;
grant select, insert, update, delete on public.app_state to authenticated;
