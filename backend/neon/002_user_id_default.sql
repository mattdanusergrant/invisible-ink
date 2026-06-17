-- Fix RLS writes for app_state (run once in the Many Doors Opus project).
--
-- auth.user_id() returns TEXT (the JWT `sub`), but app_state.user_id is uuid, so
-- a client-supplied user_id never matched the "own row" check and every write
-- failed with "new row violates row-level security policy".
--
-- Fix: let the DB stamp user_id from auth.user_id() itself on insert (cast to
-- uuid). The front-end no longer sends user_id, so the stored value and the RLS
-- check come from the same source and always match. Policy is unchanged.

alter table public.app_state
  alter column user_id set default auth.user_id()::uuid;
