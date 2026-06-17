# Many Doors Opus — Neon backend (Apps)

invisible-ink's cloud sync runs on the shared **Many Doors Opus** Neon project
(Neon Auth + Data API), off Supabase — **live since 2026-06-17**. One Neon project
backs every app, namespaced by an `app` slug; invisible-ink's slug is `invisible-ink`.

## Apply (in the Many Doors Opus project)
1. **Auth → Plugins:** enable **Magic Link** (the SDK's `signInWithOtp` sends a
   6-digit email **code** via this flow; the app has a code-entry step).
2. **SQL Editor:** run `001_app_state.sql` **then** `003_user_id_text.sql`.
   *(Skip `002` — it's a superseded intermediate. `003` makes `user_id` text and,
   crucially, (re)creates the `own row` policy.)*
3. **Data API → Settings:** add the app's origin(s) to **CORS** (e.g.
   `https://itsinvisible.ink`, `http://localhost:8000`). Click **Refresh schema
   cache** if the table 404s.
4. Front-end points at the **Data API URL** + **Auth URL** (both browser-safe;
   no secret key ships). Deploy.

## Model
- `app_state(app, user_id) -> state jsonb` — one row per user per app; PK `(app, user_id)`.
- `user_id` is **text** and defaults to `auth.user_id()`; the front-end **does not
  send `user_id`** (the DB stamps it), and reads rely on RLS rather than a filter.
- RLS `own row`: `auth.user_id() = user_id` for select/insert/update/delete.
- Auth: Neon Auth (managed Better Auth) via `@neondatabase/neon-js`'s
  **`SupabaseAuthAdapter`** — `signInWithOtp` → `verifyOtp({type:"email"})` → session.
- The app encrypts `state` **end-to-end** (passphrase → PBKDF2/AES-GCM) before it
  leaves the browser, so the DB only ever holds `{v,salt,iv,ct}` ciphertext.

## Gotchas (cost us a few rounds — read before adding an app)
- **`auth.user_id()` returns TEXT**, not uuid. A uuid `user_id` column makes the
  RLS check never match a client value. Use a **text** `user_id` with
  `default auth.user_id()` and let the DB stamp it.
- **RLS enabled with no policy = deny-all.** If `CREATE POLICY` silently doesn't
  land, every write fails with *"new row violates row-level security policy"* — the
  same error as a value mismatch. Verify the policy exists:
  `select policyname from pg_policies where tablename='app_state';`
- Use the **`SupabaseAuthAdapter`** (Supabase-shaped calls), not
  `BetterAuthVanillaAdapter` (whose API is `signIn.email()` etc.).

## Add another app
Pick a slug, point its front-end at this project's Data API + Auth URLs, set `APP_ID`,
reuse `app_state`. No new Neon project, no new migration.

## Note on existing data
invisible-ink is **local-first**, so each device re-seeds its writing to Neon on
first sign-in. Rows that lived **only** in the old Supabase cloud (not on any
device) are NOT auto-migrated — export/import them once if any matter.
