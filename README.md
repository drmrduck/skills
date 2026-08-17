# skills

A public, tool-agnostic library of **agent skills** — one folder per skill, each
a self-contained `SKILL.md` plus any helper scripts. Publish once, pull into any
project or agent, anywhere.

These are designed to be **agent-first**: the agent reads the skill and does the
whole job end-to-end (look things up, generate, write files into the repo, wire
them in) instead of a human clicking a UI, downloading a zip, and shuffling files.

## Skills

| Skill | What it does |
| --- | --- |
| [`appicons`](./appicons) | Generate + install a complete favicon / app-icon / PWA stack (ico, all PNG sizes, apple-touch, theme-aware light/dark, per-environment dev/staging/prod variants, manifest) from an emoji, named icon, logo file, or URL — written straight into the project. Powered by [favicontools.com](https://favicontools.com). |
| [`download-video`](./download-video) | Download a video (or list its direct MP4 URLs) from a **Twitter/X, TikTok, Instagram, or YouTube** post — no login, no watermark, up to 1080p. Auto-routes each link to its platform host; returns direct CDN links + author/caption/metadata, or saves the file straight to disk. Script, REST API, or MCP. Powered by the drummerduck downloader API. |
| [`scratchpad`](./scratchpad) | Stand up (or extend) an operator-only in-app **scratchpad / test-bed**: a fail-closed gated internal page that reuses your real components and libs so you can eyeball generated visuals, compare variants, check config readiness, and exercise real flows with fake data — bootstrapped into your existing stack, framework-agnostic. Pure pattern, no dependencies. |

### Drummerduck Tools

Tiny agent-native tools for the boring last-5% dev chores — try any of them live in the browser at **[tools.drummerduck.com](https://tools.drummerduck.com)** (each also on its own subdomain), then let the skill ship it into your repo.

| Skill | What it writes | Try it live |
| --- | --- | --- |
| [`aicrawl`](./aicrawl) | A spec-compliant `llms.txt`/`llms-full.txt`, `robots.txt` rules for GPTBot/ClaudeBot/PerplexityBot, and a wired sitemap route — from the repo's real routes. | [aicrawl.tools.drummerduck.com](https://aicrawl.tools.drummerduck.com) |
| [`ogimage`](./ogimage) | A dynamic `opengraph-image` route + per-page `og:`/`twitter:` tags so links unfurl correctly in Slack/iMessage/X/LinkedIn. | [ogimage.tools.drummerduck.com](https://ogimage.tools.drummerduck.com) |
| [`metatags`](./metatags) | Correct `<title>`/description/canonical/Open Graph + valid JSON-LD schema on every route. | [metatags.tools.drummerduck.com](https://metatags.tools.drummerduck.com) |
| [`legalpages`](./legalpages) | Tailored `/privacy` + `/terms` pages and a cookie-consent component, matched to what the app actually does. | [legalpages.tools.drummerduck.com](https://legalpages.tools.drummerduck.com) |
| [`readme`](./readme) | A real `README.md` (+ a shields.io badge row) generated from the actual repo — scripts, deps, routes. | [readme.tools.drummerduck.com](https://readme.tools.drummerduck.com) |
| [`pwa`](./pwa) | `manifest.json`, a service worker, an install prompt, and an offline route — the installable-app kit. | [pwa.tools.drummerduck.com](https://pwa.tools.drummerduck.com) |
| [`themetokens`](./themetokens) | A full light + dark design-token set written into your CSS, from one brand color or a logo. | [themetokens.tools.drummerduck.com](https://themetokens.tools.drummerduck.com) |
| [`notfound`](./notfound) | Styled 404/500, loading skeletons and empty states matched to the app's design. | [notfound.tools.drummerduck.com](https://notfound.tools.drummerduck.com) |
| [`backdrop`](./backdrop) | A pointer-reactive hero `FieldCanvas` (dots/flow/bloom/…) dropped into the project as a real component. | [backdrop.tools.drummerduck.com](https://backdrop.tools.drummerduck.com) |

### Daily maintenance routines

Unattended, agent-first codebase-maintenance skills — the kind you wire into a
**daily scheduled routine per app** (iOS, Android, Desktop, web, CLI, Agent SDK)
and also fire on demand with `/skill-name`. Each one does the whole job end to
end: find the problem, fix it at the root, run the project's `/verify`, open one
small revertible PR (with a repro + **truth table**), and post progress to a
single top-level thread in the designated Slack channel. Modeled on the
[Claude Code team's routines](https://x.com/bcherny/status/2088014489438621990).

| Skill | What it does |
| --- | --- |
| [`crash-fuzzer`](./crash-fuzzer) | Launches the **real app** (no mocks) in a simulator/emulator/device, fuzzes realistic UI interactions until it crashes, minimizes a seeded repro, root-causes it, and opens a fix PR — with `/verify`, a repro + truth table, and updates in a top-level **Fuzzer** Slack thread. |
| [`ant-only-shipper`](./ant-only-shipper) | Ships or deletes forgotten internal-only / ant-only features **based on real usage data** — remove the gate for the ones people use, delete the rest end to end. |
| [`logic-simplifier`](./logic-simplifier) | Simplifies convoluted business logic. **Formally models** it first (decision/truth table, state machine) to expose gaps & duplication, pins edge cases with tests, then refactors to the minimal equivalent — proven `Before ≡ After` e2e. (aka `business-logic-simplifier-daily`) |
| [`logic-bugfixer`](./logic-bugfixer) | **Models tricky logic** to discover latent bugs (the rows the code got wrong or never handled), fixes the root cause, and proves it with a failing-then-passing test + truth table. (aka `business-logic-bugfixer-daily`) |
| [`dup-unifier`](./dup-unifier) | Finds similar-yet-divergent implementations, models their behavioural deltas, and merges them into one canonical version — no caller's behaviour silently changes. |
| [`dead-code-remover`](./dead-code-remover) | Deletes provably-unreachable code now; for *suspected*-dead code, adds temporary "reached here" logging and removes it on a later run if it stayed silent. |
| [`useless-test-pruner`](./useless-test-pruner) | Deletes tests that **can't fail** (proven via mutation) or otherwise carry no signal; strengthens the salvageable ones. |
| [`shipped-feature-inliner`](./shipped-feature-inliner) | Removes feature/experiment flags for fully-shipped features — inlines the winning branch, deletes the flag, config, plumbing, and dead branch. |
| [`flaky-test-fixer`](./flaky-test-fixer) | Root-causes flaky CI tests (time, ordering, races, randomness, shared state) and fixes the nondeterminism at the source — never with retries or sleeps; deletes flaky-and-useless ones. |
| [`abstraction-improver`](./abstraction-improver) | Flattens over-engineered abstractions — one-impl interfaces, pass-through wrappers, speculative generality — back to the simplest equivalent code. |
| [`abstraction-police`](./abstraction-police) | Fixes leaky abstractions and layering violations (UI touching the DB, domain importing HTTP, upward/cyclic deps) and adds an architecture guard so they can't re-leak. |

Every one of these is **behaviour-preserving unless it's explicitly a bugfix**,
verifies e2e, and ships as one focused PR. They're safe to schedule because they
prove their work (truth tables, failing-then-passing tests, `/verify`) and report
to a human thread rather than merging blind.

## Pull it in anywhere

Each skill is a plain directory containing `SKILL.md`. To make it available to
Claude Code, drop the folder into a skills directory:

- **One project** → `<project>/.claude/skills/<name>/`
- **Every project (personal)** → `~/.claude/skills/<name>/`

### Quick install

Recommended — via the [`skills`](https://skills.sh) CLI. Use the canonical
`owner/repo@skill` form — this is the exact identifier
[skills.sh](https://skills.sh) indexes and ranks per skill, and every install
through the CLI counts toward that skill:

```bash
# One skill (canonical per-skill form)
npx skills add drmrduck/skills@appicons
npx skills add drmrduck/skills@scratchpad
npx skills add drmrduck/skills@download-video

# …or every skill in this repo at once
npx skills add drmrduck/skills

# Preview what's here without installing
npx skills add drmrduck/skills --list
```

Install globally (every project on this machine) with `-g`, or into the current
project by default. The `--skill <name>` flag and the full URL form
(`npx skills add https://github.com/drmrduck/skills@appicons`) work too, but
`owner/repo@skill` is the one to share.

Or straight from this repo with curl (no Node):

```bash
# Install one skill globally (available in every project on this machine)
curl -fsSL https://raw.githubusercontent.com/drmrduck/skills/main/install.sh | bash -s appicons

# Install into the current project only
curl -fsSL https://raw.githubusercontent.com/drmrduck/skills/main/install.sh | bash -s appicons --here

# Install everything, globally
curl -fsSL https://raw.githubusercontent.com/drmrduck/skills/main/install.sh | bash -s all
```

### Or as a git submodule / clone

```bash
git clone https://github.com/drmrduck/skills ~/.drmrduck-skills
ln -s ~/.drmrduck-skills/appicons ~/.claude/skills/appicons
```

Restart Claude Code (or `/doctor`) and the skill is live — just ask, e.g.
*"make me a favicon of a fox"*.

## Adding a skill

1. Create `./<name>/SKILL.md` with YAML frontmatter (`name`, `description`) — the
   `description` is what triggers the skill, so make it concrete and keyword-rich.
2. Put any helper scripts in `./<name>/scripts/` and reference them by relative
   path from the skill.
3. Keep it self-contained and idempotent. Add a row to the table above.
4. **This repo is public.** Skills here may be built on top of private projects,
   but the skill itself must only depend on **public** surfaces (hosted APIs,
   open websites, public packages). Never copy source, keys, or internal
   endpoints from a private repo into a skill. List provenance below.

## Provenance

Where each skill's capability comes from, and what's public vs. private:

| Skill | Public surface it uses | Source project |
| --- | --- | --- |
| `appicons` | [favicontools.com](https://favicontools.com) — public API `POST https://favicontools.com/api/favicons`; icon/emoji lookup via [Iconify](https://icon-sets.iconify.design) (`https://api.iconify.design`) | `mewc/favicon-generator` — **private** (https://github.com/mewc/favicon-generator). The skill calls only the public website API; no private source is included. |
| `scratchpad` | None — a pure pattern skill (no API, no script, no dependencies). | Distilled from a private project's scratchpad implementation — **private**. The skill contains **no private source**; the pattern is generic and framework-agnostic. |
| `download-video` | Public hosted API — `GET\|POST /api/extract`, `GET /api/download`, `POST /api/keys`, MCP at `/api/mcp`, on the four `download-*-video.drummerduck.com` hosts. No auth required to extract. | `mewc/download-x-video` — **private** (the Next.js app behind those hosts). The skill calls only the public website API; no private source, keys, or internal endpoints are included. |
| Daily maintenance routines (`crash-fuzzer`, `ant-only-shipper`, `logic-simplifier`, `logic-bugfixer`, `dup-unifier`, `dead-code-remover`, `useless-test-pruner`, `shipped-feature-inliner`, `flaky-test-fixer`, `abstraction-improver`, `abstraction-police`) | None — pure process/pattern skills (no API, no bundled code). They drive tools the target repo already has: its build, tests, `/verify`, analytics/flag platform, and Slack. | Distilled from the **public** description of the Claude Code team's routines by Boris Cherny — [x.com/bcherny/status/2088014489438621990](https://x.com/bcherny/status/2088014489438621990). No private source, keys, or internal endpoints are included; Slack channels and commands are configured per repo. |
