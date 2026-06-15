-- Apps platform — genericize the invisible-ink project into a SHARED "Apps" Supabase
-- backend so EVERY app reuses ONE project (Supabase free tier = 2 projects total).  #LLM-generated
--
-- Each app is identified by a short `app` slug; invisible-ink is the first tenant. This is
-- non-destructive: it RENAMES the table (rows, indexes, RLS policy and the FK all move with
-- it), backfills existing rows to 'invisible-ink', and re-keys on (app, user_id) so the same
-- user can hold separate state per app. The app is local-first — during the brief cutover
-- window where an old front-end still queries `manuscripts`, sync just degrades to
-- offline-retry (no data loss), so migration + redeploy need not be perfectly simultaneous.
--
-- Apply once in the SQL editor of the project you're keeping as your "Apps" project.

-- 1. generic table name (preserves all rows, indexes, the "own row" RLS policy and the FK)
alter table public.manuscripts rename to app_state;

-- 2. tenant slug; existing rows backfill to 'invisible-ink' via the temporary default
alter table public.app_state add column if not exists app text not null default 'invisible-ink';

-- 3. re-key on (app, user_id) so one user can have one row PER app in the shared DB
do $$
declare pk text;
begin
  select conname into pk from pg_constraint
   where conrelid = 'public.app_state'::regclass and contype = 'p';
  if pk is not null then execute format('alter table public.app_state drop constraint %I', pk); end if;
end $$;
alter table public.app_state add primary key (app, user_id);

-- 4. future apps MUST declare their own slug (no silent default to invisible-ink)
alter table public.app_state alter column app drop default;

-- The "own row" policy (auth.uid() = user_id) carries over unchanged and still applies —
-- each user only ever touches their own rows; each app's front-end filters to its own slug.
