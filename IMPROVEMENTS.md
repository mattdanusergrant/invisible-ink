# Improvement Plan — invisible-ink

> Generated 2026-07-02 from a full 12-repo portfolio audit (Claude Code session).
> Companion career report: ConductiveOS vault, `09_personal/2026-07-02-life-audit-and-career-plan.md`.

**What this is:** A privacy-focused freewriting/mental-health journal ("Flow" hides your words as you type via a caret-pinned ribbon; "Grow" surfaces moods/themes/graph afterwards), shipped as a single dependency-free HTML file with optional end-to-end-encrypted cloud sync on Neon, live at itsinvisible.ink.

**Stack:** Vanilla JavaScript (single-file, zero dependencies), CSS (custom properties, masks, contenteditable ribbon layout), SVG (hand-rolled force-directed graph), Web Crypto API (PBKDF2 + AES-GCM client-side E2E encryption), Neon Postgres (Auth + PostgREST-style Data API, RLS), SQL migrations, GitHub Pages + Actions deploy, localStorage local-first persistence · **Maturity:** shipped-live · **Live:** https://itsinvisible.ink
**Size:** ~1.3k lines active (index.html: HTML/CSS/JS inline, 59KB) + ~1k archived prototype (archive/novel-studio.html) + ~60 lines SQL — ~2.4k total

## What's genuinely good here

- Actually shipped: custom domain (CNAME → itsinvisible.ink), auto-deploy on push (.github/workflows/deploy.yml), built and launched in a 10-day sprint (51 commits, 2026-06-11 → 06-20)
- Real client-side E2E encryption done correctly at the crypto level: PBKDF2(250k)→AES-GCM with fresh random salt+IV per write and a versioned blob {v,salt,iv,ct} (index.html deriveKey/encState/decState, ~lines 1015-1030) — the server genuinely only stores ciphertext
- backend/neon/README.md is an exemplary runbook: documents the auth.user_id() TEXT-vs-uuid RLS trap and the 'RLS with no policy = deny-all' gotcha, learned through three real migrations (001→003) — evidence of debugging a production auth/RLS stack, not tutorial-following
- Commit history reads like a professional changelog: narrative messages explaining why ('faithful locked-cursor tutorial demo (was misleading)', 'confirm passphrase on first-set (prevent E2E lockout from a typo)'), including an honest documented pivot (novel tool → journal) with the old version archived, not deleted
- Clever, minimal engineering: the ribbon pins the caret with pure CSS (right-anchored content-sized contenteditable + linear-gradient mask, index.html lines 104-124) — no per-keystroke JS repositioning; force-directed theme graph implemented from scratch in ~90 lines of SVG
- Strong product/UX instincts: progressive disclosure (tools appear only when reached for), animated onboarding tutorial with a live sandbox, forward-flowing Backspace policy, mobile safe-area insets and the 16px-input iOS zoom fix, prefers-color-scheme support
- Correct privacy architecture for the product: local-first with sync strictly optional, storage choice surfaced in onboarding, timestamp-based conflict prompts so data is never silently overwritten


## Issues found

- Zero tests and no CI beyond deploy — .github/workflows/deploy.yml only publishes; a syntax error in index.html would ship straight to the live domain (contrast ronin-survivor, which has test/smoke.js + a test workflow)
- The passphrase is persisted in plaintext localStorage (PASS_KEY='ii.pass', index.html lines 1007 and 1048) — on a shared/compromised device the E2E promise collapses; the code comment acknowledges it but the README's 'we genuinely can't read it' pitch doesn't
- PBKDF2 at 250k iterations (line 1017) is below current OWASP guidance (600k for SHA-256); the blob is versioned (v:1) so an upgrade path exists but isn't used
- Sync conflict resolution uses blocking native confirm() dialogs (push() line 1076, pull() line 1093) and whole-journal last-writer-wins granularity — a multi-device user can still lose a day's entry by answering wrong
- pull() fires on every window focus (line 1058) and wholesale-replaces S and the draft (S=normalize(obj); setDraftText(...), lines 1096-1099) — can clobber in-progress typing and resets the caret
- README claims 'works fully offline' but there is no service worker or manifest — a cache-evicted or first-time visit to itsinvisible.ink offline fails, and neon-js loads from esm.sh CDN
- esc() only escapes &<> (line 433), and the UI is built via string-concatenated innerHTML with inline onclick handlers (renderTimeline, renderThemes, drawGraph) — safe today because inputs are regex-constrained, but a fragile pattern one restored-backup field away from XSS
- Grow's theme detection is naive single-word frequency over a ~40-word English stoplist (runThemeCheck, lines 905-921) — the 'patterns emerge, connections you didn't know were there' promise far exceeds what it delivers
- Native prompt() for the daily goal (line 653) and a '1/2/3' prompt() for the export menu (doExport, line 974) — jarring against the otherwise polished chrome
- Dormant since 2026-06-20 (~2 weeks at audit time) with no analytics, so there is no way to know if anyone uses the live product


## Ranked improvements

### 1. Add a headless smoke test + CI gate (mirror ronin-survivor's pattern)  `impact 5/5 · effort M`

**Why:** The live site deploys on every push to main with zero verification; one typo bricks itsinvisible.ink. He already proved the pattern works in ronin-survivor (test/smoke.js driving the app through a DOM stub).

**How:** Create test/smoke.js loading index.html's inline script in Node behind a minimal DOM stub: assert normalize() round-trips a fresh and a corrupted state, getDraftText/setDraftText round-trip multi-line text, creditStreak/liveStreak day math, runThemeCheck stoplist behavior, and an encState→decState round-trip (Node's global webcrypto supports PBKDF2/AES-GCM). Add npm test + a test job in .github/workflows (or a job before deploy in deploy.yml) so a failing test blocks Pages publish.

**Career angle:** Turns 'ships fast' into 'ships fast with a safety net' — the single biggest credibility gap between hobby repos and hireable engineering practice, and it makes the repo consistent with his best repo (ronin-survivor).

### 2. Stop persisting the passphrase in plaintext; harden the KDF  `impact 4/5 · effort M`

**Why:** For a product whose entire pitch is 'we genuinely can't read it', localStorage.setItem(PASS_KEY,p) (index.html line 1048) is the weakest link and an easy critique from any security-literate reviewer.

**How:** Keep the passphrase in-memory only by default, with an explicit 'remember on this device' opt-in that stores a non-extractable wrapped CryptoKey in IndexedDB instead of the raw string. Bump PBKDF2 to 600k iterations as blob v:2 in encState/decState with lazy re-encrypt-on-next-push migration (the {v} field already exists for exactly this). Update the README security paragraph to state the exact threat model honestly.

**Career angle:** A short 'threat model and how I fixed it' section is a strong security-engineering artifact for interviews — E2E crypto plus honest limits reads far better than E2E crypto plus a plaintext key.

### 3. Make 'works offline' true: PWA manifest + service worker  `impact 4/5 · effort M`

**Why:** The README claims full offline operation but the live site has no service worker; a journaling app also badly wants to be an installable home-screen icon on iPhone (his own primary mobile device per ConductiveOS docs).

**How:** Add manifest.json + a ~40-line cache-first service worker precaching index.html (and vendoring or gracefully skipping the esm.sh neon-js import, which cloudInit already try/catches). Register it at boot near the existing boot block (index.html line 1235+). Test install on iOS Safari.

**Career angle:** PWA/service-worker experience is a checkbox in most frontend job specs he currently can't tick from any repo.

### 4. Portfolio pass: demo GIF in README + case-study page on mattdanusergrant.com  `impact 4/5 · effort S`

**Why:** The ribbon effect is the entire hook and it is invisible in the README — a hiring manager skimming GitHub sees a wall of text describing a visual/kinetic experience. This is the highest-leverage 30 minutes in the repo.

**How:** Record a 10-second GIF/mp4 of typing in Flow (words sliding away, Enter poof) and one of the Grow graph; embed both at the top of README.md above the feature list. Then write a short case study for the mattdanusergrant repo covering: the pivot (archive/README.md is the receipt), the CSS caret-pinning trick (lines 104-124), and the Neon RLS debugging saga (backend/neon/README.md) — three genuinely interesting stories already sitting in the repo.

**Career angle:** Purely a career asset: converts existing work into visible, linkable proof of product+engineering skill with zero new code.

### 5. Replace confirm()/prompt() dialogs and guard focus-pull from clobbering the draft  `impact 3/5 · effort M`

**Why:** Native dialogs (push() line 1076, pull() line 1093, doExport line 974, goal prompt line 653) undercut the app's polish, and the focus-triggered pull() can replace the draft mid-thought via setDraftText (lines 1096-1099).

**How:** Build one small in-app modal (the .card/.ov pattern already exists for ovCloud) with 'keep mine / take theirs / export both' for sync conflicts; replace the export prompt() with three buttons; make the goal an inline editable field. In pull(), skip the draft replacement when document.activeElement===draft and text was entered in the last N seconds, deferring to the next idle.

**Career angle:** Shows UX follow-through — the difference between a demo and a product — useful for product-engineer positioning.

### 6. Optional AI insights layer for Grow (privacy-preserving)  `impact 3/5 · effort L`

**Why:** Grow's word-frequency themes (runThemeCheck, lines 905-921) underdeliver on the README's promise; this is also the repo's only path to demonstrating AI/LLM engineering, his highest-paying career lane.

**How:** Add an opt-in 'Deeper reflections' feature: client calls Claude API (user-supplied key, or a tiny proxy) with the decrypted-locally entry text to extract themes/mood/summary, with an explicit consent screen acknowledging the E2E tradeoff for that request. Design the extraction as structured output (JSON themes with evidence quotes) and fall back to the existing frequency method offline. Keep the whole thing behind a flag so the pure-local promise stays default.

**Career angle:** Direct AI-engineering artifact: consent-aware LLM integration with structured outputs in a privacy-sensitive domain — a genuinely differentiated interview story versus yet another chatbot.

### 7. Add privacy-respecting usage signal  `impact 3/5 · effort S`

**Why:** The product has been live since June 17 with no way to know if a single stranger has used it; every monetization or iteration decision is currently blind.

**How:** Add a cookieless counter (Plausible/GoatCounter script tag, or a one-line hit to a Neon table via the existing Data API with no user data) recording page loads and tutorial completions only. Document in the README what is and isn't collected — consistent with the privacy brand.

**Career angle:** Demonstrates product-metrics literacy; also the prerequisite for any monetization claim on a resume ('X users') being more than a guess.

### 8. Per-entry sync merge instead of whole-blob last-writer-wins  `impact 3/5 · effort L`

**Why:** The single JSONB app_state blob (backend/neon/001_app_state.sql) forces all-or-nothing conflict resolution; entries are append-mostly and keyed by id/timestamp, so a field-level merge is straightforward and eliminates the main data-loss path.

**How:** In pull()/push(), when both sides changed, merge journals by entry id (union entries, union reflections per entry, newest body per entry by timestamp) in a mergeStates(local, remote) function before writing back; keep the confirm-style prompt only for true same-entry body conflicts. No schema change needed — the blob shape stays the same.

**Career angle:** Distributed-state/CRDT-adjacent reasoning is a strong systems talking point for full-stack and infra-flavored roles.


## Skills this repo proves (for hiring managers)

- Client-side cryptography with Web Crypto: PBKDF2 key derivation + AES-GCM with per-write random salt/IV and versioned ciphertext envelope, plus UX guards against E2E footguns (passphrase confirm on first set)
- Postgres row-level security in production: authored and debugged RLS policies across three migrations, including diagnosing the TEXT-vs-uuid auth.user_id() mismatch — and wrote it up as a reusable runbook
- Advanced vanilla JS/CSS without frameworks: contenteditable editing model (beforeinput input-type filtering, selection/range caret control), CSS mask + anchoring trick to pin a caret with zero per-keystroke JS, from-scratch force-directed SVG graph with spring/repulsion physics
- Local-first architecture: localStorage as source of truth, optional encrypted sync layered on top, debounced persistence, state normalization/migration on load (normalize(), index.html lines 455-471)
- Full solo shipping loop: domain purchase, CNAME + GitHub Pages Actions deploy, CORS configuration, CDN ESM imports with graceful degradation
- Product design: progressive disclosure onboarding, animated tutorial with live sandbox, deliberate friction design (forward-flowing Backspace, hold-to-unlock entry editing framed as 'writing in the margins')
- Technical writing: user-facing README and an ops runbook with documented gotchas, both concise and accurate
- Decisive product iteration: pivoted from a novel-writing tool to a mental-health journal mid-project, archived the prior version with a dated snapshot README


## Career signals

- Shipped-and-live: real custom domain, working auto-deploy, a product a recruiter can open on their phone in 10 seconds — rarer than it should be in portfolios
- Velocity with narrative: 51 well-written commits in 10 days telling a coherent build→pivot→launch story; commit hygiene alone reads senior
- The backend/neon/README.md gotchas section is the kind of postmortem-style documentation hiring managers at infra/platform teams explicitly screen for
- Security thinking is above hobbyist level (E2E design, lockout-prevention UX, honest 'we can't recover it' copy) but has one hole (plaintext passphrase cache) a security interview would find — fixing and writing it up flips a weakness into a story
- Gaps a hiring manager will notice: zero tests, no TypeScript or any framework exposure in this repo, no evidence of users/metrics, and momentum stopped 2 weeks after launch — the classic solo-dev 'ships v1, never iterates' pattern
- No AI/LLM content despite AI-adjacent ambitions — as it stands this repo supports frontend/product-engineer roles, not AI-engineering roles, unless the Grow insights layer gets built
- The single-file zero-dependency discipline is a genuine differentiator (mirrors ronin-survivor) — positions him well for 'pragmatic engineer who doesn't cargo-cult tooling', which lands well at senior product-engineering interviews


## Monetization angles

- Freemium with E2E sync as the paywall: local-first stays free forever, cloud sync at $2-4/mo or a one-time 'lifetime sync' (~$25) via LemonSqueezy/Gumroad — server cost is near-zero on Neon's free tier, so margins are ~100% at small scale
- iOS App Store wrapper (Capacitor/PWA-to-app): journaling is one of the best-monetizing app categories, and 'the journal that hides your words + genuinely can't read them' is a clean differentiator against Day One/Journey; the PWA improvement is the prerequisite
- Paid AI insights tier: the opt-in Claude-powered Grow layer (themes, mood trends, weekly reflection summaries) is the natural $5/mo tier — AI cost passes through, privacy stance stays the free-tier default
- Niche audience content play: the freewriting/morning-pages/'write or die' community is small but findable (r/Journaling, writing Twitter); the ribbon GIF is inherently shareable and the .ink domain is memorable — realistic as a portfolio-amplifier and trickle income rather than a business
- Realistic ceiling check: solo consumer journaling apps rarely clear hobby income without distribution; the higher-EV use of this asset is as a hiring/consulting credibility piece (live product, E2E crypto, Postgres RLS) rather than chasing MRR


## Standout artifacts to show off

- backend/neon/README.md — a production-quality ops runbook with a 'Gotchas (cost us a few rounds)' section documenting RLS/auth debugging; show this to any platform/infra hiring manager
- index.html lines 104-124 — the ribbon: caret pinned dead-centre using only CSS (right-anchored content-sized contenteditable + linear-gradient mask), no per-keystroke JS; a genuinely clever piece of frontend engineering worth a blog post
- index.html lines 1011-1030 (deriveKey/encState/decState) — a complete, correct, ~20-line client-side E2E encryption module (PBKDF2 250k → AES-GCM, random salt+IV, versioned envelope)
- backend/neon/001_app_state.sql + 003_user_id_text.sql — a minimal multi-tenant state table with RLS, and a migration whose comment block explains the bug it fixes better than most team PRs
- The git log itself (2026-06-11 → 06-20) — 51 narrative commits showing idea → rebrand → pivot → backend saga → launch → polish; walkable in an interview as a 10-day shipping case study
- The live product at itsinvisible.ink with the ?tour replayable tutorial — the fastest possible demo link for a resume


## Cross-repo connections

- ConductiveOS: Invisible Ink's Markdown export (doExport, entries + reflections) maps almost 1:1 onto the vault's 08_journal/daily/YYYY-MM-DD.md format — a small export preset (or a Cloud-avatar routine pulling the encrypted blob with the passphrase) would feed Archivist's journal check-ins automatically, making the two products one story: private capture → personal-OS reflection
- ronin-survivor / jabberjawbreaker / fortkickass: the Neon app_state pattern (001_app_state.sql keyed by app slug — it was literally designed as the shared 'Many Doors Opus' backend) plus the deriveKey/encState/decState module is a drop-in cloud-save system for the games; extracting it as a tiny shared library ('one table, RLS, E2E blob') is a portfolio piece in itself
- mattdanusergrant (personal site): the pivot story, the CSS caret-pinning ribbon, and the RLS debugging saga are three ready-made case studies; the existing case-study-forge skill in ConductiveOS can produce them in the site's style
- keepingcadence: the streak/daily-goal mechanics (creditStreak/liveStreak, rollover) and the mood-check pattern are shared habit-loop primitives — extract or at least cross-pollinate rather than reimplementing
- ronin-survivor's test/smoke.js harness is the direct template for this repo's missing test suite — porting it is a half-day job because both are single-file vanilla JS apps with the same structure
- mustdesigngames / dankomphalos: the progressive-disclosure onboarding and animated-tutorial techniques (tutorial sandbox, animateTutInk/animateTutGraph) are reusable game-onboarding patterns worth writing up as a design essay for the design brand


#LLM-generated
