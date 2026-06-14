# Invisible Ink

A single-file writing studio that hides your words as you write them. Live at
**[itsinvisible.ink](https://itsinvisible.ink)**.

Type and each letter fades five seconds later — the text is still there, just
invisible, so you keep moving forward instead of editing the last sentence to
death. Hit your daily goal and the page reveals everything.

## What's in it

- **Invisible ink** — letters fade shortly after you type; nothing is lost.
  Toggle it off, or *Peek* to reveal the draft on demand.
- **Flow mode** — until you hit the day's goal you can't delete or edit, only
  write forward.
- **Daily character goal** — a ring tracks today's characters against your goal
  (default 500; click the goal chip to change it).
- **Progressive unlock** — the workspace starts as a blank page and reveals one
  zone per ~20% of the daily goal: top bar → chapters rail → editor tools →
  codex → projects. At 100% the ink is revealed and free editing unlocks.
- **Survival layer** — miss the goal and you lose one of three lives; hit zero
  and the manuscript "dies" (your text is always preserved). Meeting the goal
  restores a life and extends your streak.
- **Sprints** — timed writing bursts (10/15/25/45 min) with a per-sprint
  character count and cpm, plus recent-sprint history.
- **Projects, chapters & codex** — multiple WIPs, each with its own chapters and
  a searchable worldbuilding codex (characters, locations, factions, lore,
  timeline). Caret-aware cross-links jump from a name in the draft to its entry.
- **Blind mode** — seal prior sessions and only see what you write today.
- **Optional cloud sync** — magic-link sign-in via Supabase; local-first, so it
  runs fully offline if the cloud is unconfigured or unreachable.

## Run it

It's one static file. Open `index.html` in any browser, or serve the folder:

```bash
python3 -m http.server
```

State lives in `localStorage` (keys prefixed `writeordie.*`, the project's
original name). Append `?reset` to the URL to wipe local state for testing.
Export a manuscript (`.md`) or a full backup (`.json`) from the ↓ button.

## Deploy

Pushing to `main` publishes via GitHub Pages (`.github/workflows/deploy.yml`),
served at the domain in `CNAME`.
