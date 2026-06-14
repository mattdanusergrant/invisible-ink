# Invisible Ink

A single-file writing studio that hides your words as you write them. Live at
**[itsinvisible.ink](https://itsinvisible.ink)**.

Type and each letter fades ten seconds later — the text is still there, just
invisible, so you keep moving forward instead of editing the last sentence to
death. The whole app is built to protect flow: while you type the page is a
blank sheet, and tools appear only at the moment you actually reach for them.

## What's in it

- **Invisible ink** — each letter fades 10 s after you type it; nothing is ever
  lost. Turn it off to edit freely, *Peek* to reveal the draft on demand, and if
  you write a sustained burst with ink off it quietly re-arms itself. Hitting the
  daily goal reveals everything as a reward.
- **Flow mode** — while invisible ink is on you can only write forward (no
  deleting, no editing). Turn it off whenever you want to revise.
- **Flow-first chrome** — while you're typing every panel fades away; pause and
  the tools fade back in. Nothing competes with the sentence you're writing.
- **Just-in-time disclosure** — the workspace starts as a blank page and a tool
  appears only when a real gesture calls for it, then stays (sticky): select
  text → the codex; add a 2nd chapter → the chapters rail; start a 2nd WIP → the
  projects rail; finish a session → export; come back another day → cloud sync.
  Write and nothing else, and the page stays blank forever.
- **Daily character goal** — a faint floating counter tracks today's characters
  against your goal (default 500; click it to change). Meeting it builds a streak
  — encouragement only, no penalties.
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
