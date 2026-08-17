---
name: abstraction-improver
description: >-
  Flatten over-engineered abstractions — needless indirection, single-implementation
  interfaces, speculative generality, deep wrapper/factory/manager layers, and
  premature parameterization — by inlining them back to the simplest code that does
  the job. Preserves behaviour and proves it e2e. Use for daily abstraction-cleanup
  routines or when a user says "this is over-engineered", "too many layers",
  "flatten this abstraction", or "why is this so indirect".
---

# Abstraction Improver

Over-abstraction hides simple code behind layers that earn nothing: interfaces
with one implementation, factories that construct one thing, managers that just
forward calls, generics used at exactly one type. This routine **flattens** them
back to direct, readable code — same behaviour, fewer hops. Runs daily (once per
app) and on demand via `/abstraction-improver`.

## Over-engineering smells (flatten candidates)
- **Single-implementation interface / abstract class** with exactly one concrete
  type and no second on the horizon → inline the concrete type.
- **Speculative generality:** parameters, hooks, and config that no caller uses;
  "we might need it" seams with one caller.
- **Pass-through layers:** wrapper/manager/service/handler classes that only
  forward to another → collapse the hop.
- **Factory/builder for one shape** → a plain constructor / literal.
- **Premature generics/type-params** instantiated at one type → specialize.
- **Indirection for its own sake:** an event/observer/registry where a direct call
  would do; config-driven dispatch with one entry.

## Golden rules
1. **Rule of three, in reverse.** If an abstraction has one implementation / one
   caller / one config value and no imminent second, it's not earning its keep —
   inline it.
2. **Behaviour-preserving.** Flattening changes structure, never observable
   behaviour. Bugs found belong to `logic-bugfixer`; layering violations belong to
   `abstraction-police`.
3. **Flatten toward the call site.** Move code to where it's used; delete the
   now-empty seams, their tests-of-the-seam, and dead type params.
4. **Verify e2e.** `/verify` green; public behaviour identical.
5. **One abstraction → one PR.**

## The routine

### 1. Find over-abstraction
- Look for one-implementation interfaces, single-caller "extension points",
  wrapper classes that only delegate, factories/builders with one product, and
  generics pinned to one type. Count real implementations/callers — one (with no
  concrete second coming) is the tell.

### 2. Confirm it's not load-bearing
- Check it isn't a genuine seam: a public plugin API, a test seam that's actually
  used, or a boundary with a real second implementation planned/landed. If it is,
  leave it and note why.

### 3. Flatten
- Inline the single implementation; delete the interface/factory/wrapper; move the
  body to the call site or a plain function; specialize the generic; drop unused
  parameters. Remove tests that only exercised the removed indirection.

### 4. Verify e2e
- `/verify` green; behaviour unchanged. Note the layer/indirection-count and LOC
  reduction.

## PR body template
```md
## Flatten abstraction: <what>

### Smell
<one-impl interface / single-caller seam / pass-through wrapper / one-type generic>
implementations: 1 · callers: <n> · second impl planned? no

### Change
<inlined X into Y · deleted interface/factory/wrapper · dropped unused params>
layers: 4 → 2 · LOC: <before> → <after>

### Behaviour
Unchanged — structural only. (Any suspected bug filed separately.)

### /verify
<pasted output>
```

## Slack updates
Maintain **one top-level thread** for this routine in the designated channel
(configure `SLACK_CHANNEL` per repo). Each run: abstractions flattened,
layers/LOC removed, seams left in place (with reason), PRs opened.

## Guardrails
- Don't flatten a genuine boundary: public/plugin APIs, ports with real multiple
  adapters, or a seam whose second implementation is actually landing soon.
- Behaviour-preserving only — if flattening tempts you to "fix" logic, split that
  out to `logic-bugfixer`.
- Prefer clarity over dogma: inlining is a win only if the result reads simpler.

## Provenance
Pure process/pattern skill — no API, no bundled code. Distilled from the public
Claude Code team routine described by Boris Cherny
(https://x.com/bcherny/status/2088014489438621990): "abstraction improver —
flattens over-engineered abstractions." Companion to `abstraction-police` (leaky
abstractions / layering violations).
