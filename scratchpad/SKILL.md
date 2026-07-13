---
name: scratchpad
description: >-
  Stand up (or extend) an operator-only in-app scratchpad / internal test-bed —
  a single gated internal page that reuses the project's real components and
  library functions so you can judge work-in-progress by eye: eyeball generated
  visuals (OG/social cards, emails, avatars, empty states), compare variants
  side by side or with live sliders, check config/env readiness, and exercise
  real side-effecting flows with fake data — without shipping any of it to users
  or clicking through the whole product. Boards and config panels get a "Copy as
  JSON" button so a tuned-by-eye result round-trips straight back into the code
  or to an agent to apply. Bootstraps into the user's existing
  stack: detects the framework, auth, and env conventions, writes a fail-closed
  access gate first, then a route with a section switcher seeded from their own
  code. Use when a user says "spin up a scratchpad", "internal test bed / dev
  playground / sandbox page", "an operator/admin preview page", "a page to
  eyeball my work", "preview my OG cards / emails / component variants", "add a
  test page for these components", or "an internal page to exercise a flow with
  fake data". NOT for public/user-facing features, NOT a replacement for tests
  (pass/fail machine-checkable → write a test), NOT Storybook (this lives inside
  the real app), and NOT a place to do load-bearing production operations.
---

# Scratchpad (internal test-bed) — agent-first

Bootstrap an operator-only **scratchpad**: one internal page inside the real app
where the user looks at and fiddles with their own work-in-progress — judging it
by **taste and eye**, not by assertion. You read the repo, detect its
conventions, and write the gate, route, and first sections tailored to that
stack. The whole point is that it **reuses the real code, never a fork of it**,
so what the user eyeballs is exactly what ships.

## What a scratchpad actually is

A single internal page inside the real app for judging your own work-in-progress
— **not** a public feature, **not** a test suite, **not** a separate tool like
Storybook. It's the in-app equivalent of a workbench: you keep it because the
things you want to judge only render correctly inside the real app (real auth,
real theme tokens, real data, real link-building, real rendering pipeline), and
you want to judge them by taste and by eye.

It answers questions a test can't:

- **"Does this look right?"** — a generated OG/social card, a rendered email, an
  avatar, an animated micro-interaction, an empty state. Frame it at its true
  size and just look.
- **"Which variant do I like?"** — every theme/palette/size side by side, or live
  sliders you drag until it feels right. Judgment, not correctness.
- **"Is this config wired up?"** — an env-readiness panel, a "what does the
  service account actually see" debug dump, the raw output of a matcher before a
  threshold is applied.
- **"Does this flow really work end-to-end?"** — a button that calls the real
  library function with placeholder data and shows what comes back, so you
  exercise the pipeline without going through the whole product UI or waiting on a
  real external event.

**The defining trait: it reuses the real code, never a fork of it.** You import
the same components the real pages use, call the same library function production
calls, hit the same rendering route. The moment a scratchpad reimplements the
thing it's previewing, it has started lying to you.

### When to reach for one

- You keep spinning up throwaway routes/scripts to look at one visual, then
  deleting them. Give them a permanent home instead.
- A thing renders differently in isolation (Storybook, a static mock) than in the
  real app — so isolation lies. The scratchpad lives in the app.
- You're tuning something by feel — spacing, motion timing, a color ramp, a match
  threshold — and need a tight **look → tweak → look** loop.
- You want to trigger a real side-effecting pipeline (an email round-trip, a
  webhook handler, a Slack alert) on demand with fake data, without waiting for
  the real trigger.

### When NOT to (say so if the user asks for these)

- **Anything users should see.** It's operator-only, forever.
- **Assertions.** If the answer is pass/fail and machine-checkable, write a
  **test** instead. A scratchpad is for the judgments a test can't make.
- **Load-bearing admin operations.** If you find yourself doing real production
  work from it (issuing refunds, editing live records), that's an **admin panel**
  — build that properly with audit trails. The scratchpad is for looking and
  fiddling; its writes target dev/dummy data.

## Bootstrap workflow

Run these in order. **Gate before anything else** — the page exposes internal
previews, debug dumps of real data, and buttons that call real code, so it must
be locked down before it renders a single byte of data.

### 1. Detect the stack

Answer these from the repo (grep/read, don't assume). The **Framework mapping**
table near the end translates each answer into concrete syntax.

- **How is a page/route defined?** (file-based router, a route registry, a
  controller + template, a single-page app view.)
- **What's the existing auth / session helper?** Find how other protected pages
  get the current user (e.g. a `requireUser()` / `getSession()` / `currentUser()`
  helper, middleware, or a decorator). **Reuse it** — do not invent a new one.
- **Where are env vars read, and what's the "is production" signal?**
  (`NODE_ENV`, `APP_ENV`, `import.meta.env.PROD`, a settings module, etc.)
- **How does this stack keep a view always-fresh / uncached?** So edits to the
  thing being previewed show up on a plain refresh.
- **How does it mark code as server-only** (never bundled to the client), if it's
  a stack where that distinction exists?
- **What's the static/asset dir**, if a section needs to serve a request-scoped
  preview (e.g. an image route).

### 2. Idempotency check

Look for an existing scratchpad route (`grep -ri "scratchpad" --include=*.{ts,tsx,js,jsx,py,rb,go}` and check the router). **If one already exists, don't
rebuild the scaffold — add a section** to its `sections` array (see step 5) and
stop. Only build the scaffolding (steps 3–4, 6) when there is none.

### 3. Build the access gate FIRST

Put the rule in **exactly one place** and import it everywhere (the page's
redirect and every request-scoped preview route). Open in local dev; locked to an
operator allowlist in production; checked **server-side** and kept off the client
bundle. See **The access gate** below for the full pattern and rules. Do this
before the route renders any data.

### 4. Create the route + section switcher

One route (e.g. `/scratchpad`), structured as a **section switcher**: a sidenav
or tabs that flips between independent sections, route-driven by a query param
(`?tab=<id>`) so a view is linkable and survives refresh. The page holds a
`sections` array of `{ id, label, node }`; the switcher just shows/hides the
active one. Render the route **always-fresh** (no cache) so edits show on
refresh. See **Minimal scaffold** below.

### 5. Seed 1–2 real sections

Don't start empty. Pick from what the user is actually building right now (see
**What to seed it with**). For momentum, start with **one visual preview** and
**one config/readiness panel** — the two cheapest, highest-signal archetypes —
then add a variant board or live tester as the need appears. Each section imports
the **real** components/libs, not copies.

### 6. Add the dev-only entry link

Reach the scratchpad from a **dev-only link strip that renders nothing in
production** — a tiny pinned corner element, not a nav menu item. No public entry
point ever.

### 7. Verify

Load it in the running dev app (use the project's dev server, or the `/run` or
`/verify` skill if present). Confirm:

- A seeded section renders with real data/components.
- The gate **redirects/404s** when you simulate a non-operator (e.g. temporarily
  return a non-allowlisted email, or unset the dev signal) — it must fail closed,
  not render-then-hide.
- Any request-scoped preview route also enforces the gate.

Then report to the user what you scaffolded, which sections you seeded, and the
one-liner for adding the next section.

## What to seed it with (discovery)

Turn "what are you building right now?" into concrete first sections by scanning
the repo:

| You find in the repo… | Seed this archetype |
| --- | --- |
| Recently-changed UI components; anything with theme/size/state variants | **Variant board** or **Visual preview** of the real component |
| A route/function that renders an image, OG/social card, or email template | **Visual preview** at true dimensions + an in-context mock |
| `lib/*` functions with side effects, external calls, or a tunable threshold | **Live flow tester** (read-only) and/or the raw pre-threshold output |
| Many `process.env.*` / settings reads scattered across the code | **Config / readiness panel** (booleans only) |
| An integration whose product UI *filters* what it shows (permissions, access) | **Debug dump** of the raw, unfiltered truth the integration sees |

Good defaults when unsure: ask the user "what are you tuning or eyeballing right
now?" and map their answer to the closest archetype, or just seed a visual
preview of the component they most recently touched (from `git log`/`git diff`).

## The access gate (non-negotiable — get this right first)

A scratchpad exposes internal previews, debug dumps of real data, and buttons
that call real code. It must be **open in local dev, locked to an operator
allowlist in production, checked server-side**, and kept off the client bundle so
it can never be reasoned about or bypassed from client code.

One place, imported everywhere (pseudocode — see the mapping table for your
stack's real syntax):

```
// scratchpad-access — the SINGLE source of truth for who's allowed.
// Mark this module server-only so it can never be bundled to the client.

const OPERATOR_EMAILS = new Set([
  "you@example.com",
  // …operator accounts
])

// Open in local dev; allowlisted operators only in production.
function scratchpadAllowed(email):
  if (not running in production) return true
  return email is present AND OPERATOR_EMAILS has email.trim().lowercased()
```

**Gate rules:**

- **Fail closed.** The page redirects (or 404s) a non-allowed user **before any
  data loads**; request-scoped routes return **404** (a 404 doesn't even admit
  the route exists — prefer it over 403). Never render then hide.
- **The gate lives above data fetching.** Check identity first; only then touch
  the DB or external services.
- **No public nav entry.** Reach it only from the dev-only link strip that
  renders nothing in production.
- **Reuse the existing identity helper.** Get the current user from whatever the
  rest of the app already uses; don't roll your own session logic.

## Section archetypes

A scratchpad is a mix of these. Each has its own discipline.

### 1. Visual preview — "does it look right?"

Render the **real artifact at its true dimensions**, plus a small in-context mock
so you catch how it reads at thumbnail size. Footer every visual with an **"Open
raw ↗"** link and **"Edit at `<path/to/source>`"** so you can jump straight to
the code that draws it.

- OG/social cards: frame at the real aspect ratio (e.g. 1.91:1), then a
  chat-bubble unfurl mock beside it.
- Emails: render the real template with sample props.
- **Host-aware:** if links/images resolve against the request host (custom
  domains, whitelabel), build them from the incoming host so the preview shows the
  right domain, not a hardcoded one.

### 2. Variant board — "which one do I like?"

The **taste engine**. Two flavors — use whichever fits:

- **Grid of variants** rendered side by side — every theme, palette, size, or
  state at once — so you compare at a glance instead of toggling one control and
  forgetting the last.
- **Live controls** (sliders, toggles, number inputs) wired to a single live
  instance of the **real** component, so you drag until it feels right. Re-import
  the actual production component so the tuning transfers 1:1.

Include the **awkward overlays and edge states** — the badge that only sometimes
shows, the longest possible title, the empty case. Those are exactly what you
can't judge from the happy path.

Give live-controls boards a **"Copy config as JSON"** button (see **Make tuned
state copy-out-able** below) — once a variant feels right, the exact prop/config
object is one click from being pasted back into the real code.

### 3. Config / readiness panel — "is this wired up?"

A compact status list. **Booleans only — never render secret values.** Show
`✓ set` / `○ optional, unset` / `✗ required, MISSING` with a one-line note on
what each key powers and what breaks without it.

```
// render booleans; NEVER the values themselves
env = {
  xai:       is XAI_API_KEY set?,
  firecrawl: is FIRECRAWL_API_KEY set?,
}
```

Also good here: a **raw, unfiltered debug dump** of what an integration actually
sees (e.g. every file a service account can access) — precisely because the real
product UI filters it. The scratchpad is where you see the unfiltered truth.

For tunable (non-secret) config — feature flags, thresholds, layout knobs — pair
the panel with a **"Copy config as JSON"** button so a tweaked config is one
click from being handed back to an agent to apply (see below). Never include
secret values in the copied blob.

### 4. Live flow tester — "does the real pipeline work?"

A button (or small form) that calls the **real** library function with
placeholder data and shows the result — so you exercise a pipeline without
clicking through the whole product or waiting on a real external trigger.

- **Default to read-only, and say so in the UI:** "runs the real matcher, writes
  nothing." Most testers should compute and display without persisting.
- **If a tester writes or fires a side effect, be loud about it:** label it,
  target a **dev/dummy tenant or dry-run address**, and never touch real user
  data. (E.g. an "inbound email loop test" that sends a real message through the
  real webhook → route → ingest, explicitly writing into the dev tenant.)
- **Show the seam to the real product:** a short "Real flow: go to X → do Y" note
  under each tester, mapping the isolated test back to where a user hits it. This
  keeps the scratchpad honest about what it's a proxy for.
- **Surface the raw truth before product-side massaging:** e.g. show a matcher's
  full ranked tail with sub-threshold rows dimmed under a dashed line, so you can
  calibrate the threshold — something the product view (which hides them) can't
  help you do.
- **Make the inputs copy-out-able too:** a "Copy inputs as JSON" button on the
  tester's form means the exact payload that produced an interesting result can be
  captured for a fixture, a bug report, or handing to an agent to wire in.

## Make tuned state copy-out-able (round-trip to code)

The scratchpad's real payoff is closing the loop: **tune by eye → capture the
exact config → hand it to an agent → the agent writes it into production.** Every
board/panel/tester whose state you're adjusting should expose a **"Copy as JSON"**
button that serializes its *current* state (chosen variant, slider/toggle values,
the config object, the tester's input payload) to the clipboard as a clean,
paste-ready object.

Why it matters: without it, the human eyeballs a good result, then has to
*describe* it back ("a bit more padding, warmer accent") and the agent guesses.
With it, the human copies the precise object and the agent applies it verbatim —
no translation loss, no round-trips.

Discipline:

- **Copy the real shape.** Serialize the actual prop/config object the production
  component or lib consumes — same keys, same types — so it pastes in with zero
  reshaping. If the component takes `{ radius, accent, density }`, copy exactly
  that.
- **Never copy secrets.** Config-panel copies include tunable, non-sensitive keys
  only — never env values or credentials. (Booleans-only still holds for the
  *readiness* view; the copy button is for the *tunable* config beside it.)
- **Make it obvious where it goes.** Pair the button with the "Edit at
  `<source>`" footer so the destination for the pasted object is one click away.
- **Optional niceties:** a "Copy as JSON" plus a "Copy as code" (the JSX/call-site
  snippet with the props inlined), and a matching *paste/import* field so a config
  handed back by an agent can be loaded straight into the controls to preview
  before it lands. Round-tripping both directions makes the human↔agent handoff
  instant.

```
// each controlled section keeps its live state in one object…
config = { radius: 12, accent: "#7c3aed", density: "compact" }

// …and a button serializes THAT object, verbatim, to the clipboard:
onCopy: copyToClipboard(JSON.stringify(config, null, 2))
// -> the user pastes it to an agent: "apply this to <Card>"  → agent writes it in.
```

## Framework mapping

Translate the framework-agnostic pattern above into the user's actual stack. This
is a translation aid, not a prescription — match whatever the repo already does.

| Capability | Server-rendered app + file router | SPA + separate API | Full-stack meta-framework | Non-web (CLI / notebook / desktop) |
| --- | --- | --- | --- | --- |
| **Route** | A file under the router dir (`/scratchpad`) | A dev-only client route + a gated API route that returns the data | A page route (loader/action or RSC) | A hidden subcommand / a dev-only notebook / a debug window |
| **Server-only guard** | An import that errors if bundled client-side (e.g. `server-only`) | Keep the gate on the API side; the client never holds the allowlist | Same server-only import + server components/actions | N/A — it already runs locally/privately |
| **Always-fresh render** | Disable caching for the route (e.g. `dynamic = "force-dynamic"`, `revalidate = 0`) | Client refetches on load; no CDN caching on the API route | Route-level no-store / dynamic | Re-run the command / re-execute the cell |
| **Static/asset dir** | `public/` (or the framework's static dir) | The API serves the bytes | `public/` / static route | Write to a temp file and open it |
| **Env access** | `process.env.*` on the server | Read on the API side only; expose booleans to the client | `process.env.*` server-side | `os.environ` / config file |
| **Identity / "is prod"** | Existing `requireUser()` + `NODE_ENV` | Session cookie/JWT verified on the API + `APP_ENV` | Existing session helper + env flag | Local user; a `--dev` flag or env toggle |

## The rules that make it good (not a junk drawer)

1. **Reuse, never fork.** Import the real components and call the real libs. A
   scratchpad that reimplements what it previews will drift and lie. This is the
   whole point.
2. **Read-only by default; loud and dev-scoped when not.** Looking is free;
   writing is a deliberate, labeled exception aimed at dummy data.
3. **Gate server-side, fail closed, no public entry.** Do this before anything
   else.
4. **Never leak secrets.** Config panels show booleans and notes, never values.
5. **Every section is self-describing.** A title + one-sentence subtitle that says
   what this is, where it comes from (name the source file), and what it maps to in
   the real product. Six months later you should understand a section without
   reading its code.
6. **Point back to source.** "Edit at `path/to/source`" footers turn eyeballing
   into a fast look → jump → tweak → refresh loop.
6b. **Make tuned state copy-out-able.** Any board/panel/tester you adjust gets a
   "Copy as JSON" button that serializes its current state in the real object
   shape — so a good result round-trips straight back into the code (or to an
   agent to apply). Never copy secrets.
7. **Additive and cheap to extend.** Adding a section is appending one array
   entry. Keep that true; if a section grows a lot of logic, push it into its own
   component and keep the page a table of contents.
8. **Always-fresh / no-cache** so what you see always reflects the current code.
9. **It's allowed to be scrappy — but not dishonest.** Ugly controls, placeholder
   copy, sample logos: all fine. Reimplemented behavior, leaked prod data, or
   silent writes to real records: never.

## Anti-patterns

| Don't | Because |
| --- | --- |
| Reimplement the thing you're previewing | It drifts from production and the scratchpad silently lies about what ships |
| Render the page, then hide it from non-operators client-side | The data already left the server; gate **before** fetching, fail closed |
| Print secret/env **values** in a config panel | One screenshot leaks a key; show booleans only |
| Write to real records "just to test" | That's an admin action without audit trails; target a dev/dummy tenant and label it loudly |
| Let it sprawl into one giant scroll of un-labeled widgets | It becomes a junk drawer no one trusts; one section = one self-describing thing |
| Add a nav link / menu entry to reach it | Users find it; entry is a dev-only strip that renders nothing in prod |

## Build checklist

- [ ] Access module: single source of truth, server-only, dev-open /
      prod-allowlist, imported by the page **and** every request-scoped route.
- [ ] Page redirects (or 404s) non-operators **before** loading data; routes
      return 404.
- [ ] Dev-only link strip (renders nothing in prod) to reach it — **no** real nav
      entry.
- [ ] Route-driven section switcher (`?tab=`), `sections` array, always-fresh
      rendering.
- [ ] Each section: title + subtitle (what / where-from / maps-to) and, for
      visuals, an "Edit at `<source>`" footer.
- [ ] Config panels expose booleans only (readiness view); tunable config beside
      it gets a "Copy as JSON" button in the real object shape, secrets excluded.
- [ ] Variant boards and testers you adjust expose "Copy as JSON" (and optionally
      a paste/import field) so tuned state round-trips back to code / to an agent.
- [ ] Testers default read-only and say so; any writer targets dummy data and is
      clearly labeled.
- [ ] Interactive widgets import the **real** production components/libs, not
      copies.
- [ ] Host-aware previews if links resolve per-host.

## Minimal scaffold

Framework-agnostic shape. Swap the bracketed mechanisms for your stack's real
syntax (see the mapping table).

```
// --- scratchpad-access module (server-only) -------------------------
mark-server-only

const OPERATOR_EMAILS = new Set([ "you@example.com" ])

function scratchpadAllowed(email):
  if (not production) return true
  return email present AND OPERATOR_EMAILS has email.trim().lowercased()

// --- the scratchpad page (server-rendered, always-fresh) ------------
configure route: always-fresh / no-cache

function ScratchpadPage(request):
  user = <existing identity helper>()          // reuse the app's auth
  if (not scratchpadAllowed(user.email)):
    return redirect("/") or 404                 // gate BEFORE any data

  sections = [
    // { id, label, node } — one per thing you're eyeballing/fiddling with.
    // Append here to add a section. Each node imports the REAL component/lib.
    // { id: "og", label: "OG · default", node: <VisualPreview .../> },
    // { id: "env", label: "Config",      node: <ReadinessPanel  .../> },
  ]
  activeId = sections.find(s => s.id == request.query.tab)?.id ?? sections[0]?.id

  return SectionSwitcher(sections, activeId)     // sidenav/tabs; shows active node

// --- dev-only entry link (renders nothing in production) ------------
function DevLinks():
  if (production) return nothing
  return <pinned corner strip linking to /scratchpad>
```

The rest is just sections. Start with one visual preview and one readiness panel;
add a variant board the first time you're choosing between looks, and a live
tester the first time you're tired of clicking through the whole product to test
one lib.
