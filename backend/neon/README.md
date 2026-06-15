# Opus — Neon backend (Apps)

invisible-ink's cloud sync now runs on the shared **Opus** Neon project (Neon Auth +
Data API), not Supabase. One Neon project backs every app, namespaced by an `app` slug;
invisible-ink's slug is `invisible-ink`.

## Apply (one time, in the Opus project)
1. **Auth → Plugins:** enable **Email OTP** (the sign-in method).
2. **SQL Editor:** run `001_app_state.sql` (creates `app_state` + RLS).
3. Redeploy the `invisible-ink` repo once the front-end is swapped to Neon.

## Model
- `app_state(app, user_id) -> state jsonb` — one row per user per app; PK `(app, user_id)`.
- RLS `own row`: a signed-in user touches only their own rows (`auth.user_id() = user_id`).
- Auth: Neon Auth email-OTP. The browser uses the **Data API URL** + **Auth URL** only —
  no secret key (the connection string / server key never ship).

## Add another app
Pick a slug, point its front-end at this project's Data API + Auth URLs, set `APP_ID`,
reuse `app_state`. No new Neon project, no new migration.

## Note on existing data
This is a fresh Neon database. invisible-ink is **local-first**, so each device re-seeds
its writing to Neon on first OTP sign-in. Rows that lived **only** in the old Supabase
cloud (not on any device) are NOT auto-migrated — if any matter, export/import them once.
