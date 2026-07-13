# scratchpad

> Stand up an operator-only **scratchpad / internal test-bed** inside your real
> app — one gated page that reuses your real components and libraries so you can
> judge work-in-progress by eye: eyeball generated visuals, compare variants,
> check config readiness, and exercise real flows with fake data. Bootstrapped
> straight into your existing stack, framework-agnostic.

A scratchpad is the in-app equivalent of a workbench: the things you want to
judge — a generated OG card, a rendered email, a color ramp, a match threshold,
a whole side-effecting pipeline — only look and behave correctly inside the real
app, and you want to judge them by **taste and eye**, not by assertion. Its
defining trait: **it reuses the real code, never a fork.** What you eyeball is
exactly what ships.

It's the permanent home for all those throwaway preview routes you keep spinning
up and deleting.

## What the agent does for you

From a prompt like *"spin up a scratchpad for these components"* the agent:

1. **Detects your stack** — router style, the auth/session helper you already
   use, how you read env vars, and how your framework does "always-fresh" and
   "server-only".
2. **Writes a fail-closed access gate first** — open in local dev, locked to an
   operator allowlist in production, checked server-side, off the client bundle.
3. **Creates one route with a section switcher** (`?tab=`-driven, linkable,
   always-fresh).
4. **Seeds real sections** picked from what you're building right now — a visual
   preview, a variant board, a config/readiness panel, or a live flow tester —
   each importing your **real** components and libs.
5. **Adds a dev-only entry link** (renders nothing in production; no public nav).
6. **Verifies** it in your dev app and confirms the gate fails closed.

If a scratchpad already exists, it just **adds a section** instead of
rebuilding scaffolding.

## The four section archetypes

- **Visual preview** — render the real artifact at true size (+ a thumbnail mock),
  with an "Edit at `<source>`" footer. *"Does it look right?"*
- **Variant board** — a grid of every theme/size/state, or live sliders on the
  real component. *"Which one do I like?"*
- **Config / readiness panel** — booleans only, never secret values. *"Is this
  wired up?"*
- **Live flow tester** — a button that calls the real lib with fake data;
  read-only by default, loud and dev-scoped when it writes. *"Does the pipeline
  work?"*

Every board/panel you tune gets a **"Copy as JSON"** button that serializes its
current state in the real object shape — so once a variant feels right, the exact
config is one click from being pasted back into the code (or handed to an agent to
apply verbatim, no translation loss).

## When NOT to use it

- Anything users should see — it's operator-only, forever.
- Pass/fail machine-checkable answers — write a **test**.
- Load-bearing production operations — build a real **admin panel** with audit
  trails.
- Isolated component previews divorced from the app — that's Storybook; a
  scratchpad deliberately lives **inside** the real app.

## Install

Copy this folder into your agent's skills directory:

- **Claude Code:** `~/.claude/skills/scratchpad/` (global) or
  `.claude/skills/scratchpad/` (per-project)
- Other agents: wherever your harness loads skills from.

```bash
npx skills add https://github.com/drmrduck/skills --skill scratchpad
```

Or copy it manually:

```bash
git clone https://github.com/drmrduck/skills
cp -r skills/scratchpad ~/.claude/skills/scratchpad
```

Then just ask your agent to spin up a scratchpad.

## Provenance

A pure **pattern** skill — no external API, no script, no dependencies. Distilled
from a private project's real scratchpad implementation; contains **no private
source** — the pattern itself is generic and framework-agnostic.
