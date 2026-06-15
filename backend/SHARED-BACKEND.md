# Shared "Apps" backend

#LLM-generated

This repo's Supabase project is no longer the *invisible-ink* project — it's your
shared **Apps** project. One Supabase project backs **every** app you ship, so you
stay on the free tier (2 projects total: one **Apps**, one **Games**) until revenue
justifies more. Each app is namespaced by a short `app` slug; **invisible-ink is the
first tenant**.

## The model

- One table, `app_state`, holds a per-user JSON state blob for each app:
  `app_state(app text, user_id uuid → auth.users, state jsonb, updated_at timestamptz)`,
  primary key `(app, user_id)`.
- RLS policy `own row` (`auth.uid() = user_id`) — a signed-in user can only touch
  their own rows. Each app's front-end additionally filters to its own `app` slug.
- Auth is shared (magic-link). A user who signs into two of your apps with the same
  email gets one identity and one row per app — no collisions.

Simple apps (one JSON state per user, like invisible-ink) just reuse `app_state`.
A more complex app can add its own tables in the same project — give each a
`not null` `app` column + an RLS policy, exactly like `app_state`.

## Apply the genericization (one time)

Run in the SQL editor of the project you're keeping as **Apps**:

1. `backend/migrations/001_genericize_apps.sql` — renames `manuscripts` → `app_state`,
   adds the `app` slug, backfills existing rows to `invisible-ink`, re-keys on
   `(app, user_id)`. Non-destructive.
2. Deploy this branch (GitHub Pages). The front-end now reads/writes `app_state`
   filtered by `APP_ID = "invisible-ink"`.

Order doesn't have to be exact: the app is **local-first**, so if the old site is
briefly live against the renamed table, sync just shows "offline — will retry" and
no writing is lost. `000_baseline.sql` documents the pre-genericization schema for
reproducibility (it's a no-op on the live project).

## Add a new app

1. Pick a slug (e.g. `nanny-planner`).
2. In the app's front-end, set `const APP_ID = "nanny-planner";` and point
   `SB_URL` / `SB_KEY` at this same Apps project (publishable key — safe to embed).
3. Reuse `app_state` (`.eq("app", APP_ID)` on reads, include `app: APP_ID` on
   upserts). No new Supabase project, no new migration.

## Credentials

Project URL + publishable key live in the front-end (safe to embed; RLS guards the
data). The database password / service_role key are **never** committed here — see
the private vault note `07_projects/its-invisible-ink/CREDENTIALS.md`.
