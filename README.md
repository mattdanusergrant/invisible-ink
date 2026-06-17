# Invisible Ink

A single-file journal that hides your words as you write them. Live at
**[itsinvisible.ink](https://itsinvisible.ink)**.

Two modes. **Flow** is for writing: each letter fades ten seconds after you type
it, so you keep moving forward instead of re-reading and second-guessing the last
sentence — the words are still there, just invisible. **Grow** is for looking
back: once you've written, it surfaces the moods, themes, and connections running
through your entries.

## What's in it

### Flow — write without looking back

- **Invisible ink** — each letter fades 10 s after you type it; nothing is ever
  lost. *Peek* reveals the draft on demand, and the day's entry is revealed in
  full the moment you hit your goal.
- **Forward-only** — while invisible ink is on you can't delete or edit; turn it
  off whenever you want to revise. Write a sustained burst with it off and it
  quietly re-arms itself.
- **Mood check** — a one-tap "how are you?" scale (rough → great) tags the day's
  entry, so Grow can colour it later.
- **Daily goal & streak** — a faint counter tracks today's characters against a
  goal (default 500); meeting it builds a streak. Encouragement only, no penalties.
- **Flow-first chrome** — while you type the toolbar fades away; pause and it
  fades back in. Nothing competes with the sentence you're writing.

### Grow — see what you've been thinking about

- **Timeline** — every past entry by date, with its mood and tracked themes. Open
  one to re-read it.
- **Reflections** — add a dated reflection to any past entry ("how do you feel
  about this now?"). The original is left as written; hold on the text to unlock
  it for an edit, like writing in the margins.
- **Themes** — words you return to surface automatically (after ~3 mentions
  across your entries); confirm the ones worth tracking and dismiss the rest.
  Tracked themes tag every entry that mentions them.
- **Graph** — a force-directed map of your themes and the entries they connect,
  filterable by theme or name.

### Across both

- **Just-in-time disclosure** — the workspace starts as a blank page and tools
  appear only as you reach for them: Grow and export after a first session, the
  Graph once enough themes and entries pile up. Write and nothing else, and the
  page stays a blank sheet.
- **Local-first** — entries live in your browser; no account required and it
  works fully offline.
- **Optional cloud sync — end-to-end encrypted** — sign in with an emailed code,
  then set a passphrase that never leaves your device. Your journal is encrypted
  in the browser before it's sent, so the server only ever stores ciphertext —
  we genuinely can't read it (and if you lose the passphrase, neither can we).
  Syncs across devices, with timestamp-based conflict prompts so a newer copy is
  never silently overwritten.
- **Export** — pull your entries out as Markdown (reflections included), a full
  JSON backup, or restore from one (↓ button).
- **Day / night theme** — toggle it, or let it follow the system setting.

## Run it

It's one static file. Open `index.html` in any browser, or serve the folder:

```bash
python3 -m http.server
```

State lives in `localStorage` (key `ii.journal.v1`; theme under
`writeordie.theme`, the project's original name). Append `?reset` to the URL to
wipe local state for testing.

## Deploy

Pushing to `main` publishes via GitHub Pages (`.github/workflows/deploy.yml`),
served at the domain in `CNAME`.
