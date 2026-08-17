---
name: abstraction-police
description: >-
  Fix leaky abstractions and layering violations — implementation details bleeding
  through interfaces, lower layers reaching up, higher layers reaching past their
  boundary (UI touching the DB, domain importing HTTP, cross-module reach-ins), and
  encapsulation breaks. Restores clean layering behind the existing interface and
  proves behaviour is unchanged e2e. Use for daily architecture-hygiene routines or
  when a user says "this abstraction leaks", "layering violation", "the UI is
  talking to the database", or "fix this boundary".
---

# Abstraction Police

Guard the boundaries. This routine finds where abstractions **leak** (callers
depend on internals the interface shouldn't expose) and where **layering is
violated** (a layer reaches across or up past its allowed dependencies), and
restores clean separation — without changing what the app does. Companion to
`abstraction-improver` (which removes *too much* abstraction; this fixes *broken*
abstraction). Runs daily (once per app) and on demand via `/abstraction-police`.

## Violations it fixes
- **Leaky abstraction:** callers reach through an interface to its internals
  (return the concrete impl's private fields, ORM entities escaping the repo,
  `any`/downcasts to get at hidden state, error types from an inner layer thrown to
  an outer one).
- **Layering violation:** dependencies pointing the wrong way — UI/presentation
  touching the DB or HTTP directly, domain/business layer importing framework/IO,
  a lower layer importing an upper layer (dependency cycle), cross-module reach-ins
  that bypass the public entry point.
- **Encapsulation break:** public mutable state, exported internals, "friend"
  access via file path instead of the module's API.

## Golden rules
1. **Depend on the boundary, not the innards.** Fix so each caller goes through
   the intended interface and the interface stops exposing internals.
2. **Dependencies point one way.** Enforce the layer order (e.g. UI → app →
   domain ← infra via ports). No upward or sideways reach-ins; break cycles.
3. **Behaviour-preserving.** Re-route dependencies and tighten types/visibility;
   don't change observable behaviour. Real bugs → `logic-bugfixer`.
4. **Verify e2e.** `/verify` green; behaviour identical; the boundary now holds
   (add an architecture test/lint rule so it can't re-leak).
5. **One violation (or one boundary) → one PR.**

## The routine

### 1. Detect violations
- Map the intended layers/modules and their allowed dependency direction. Then
  find breaches: import-graph tools (`dependency-cruiser`, `import-linter`,
  `madge`, ArchUnit, `go list`/`depgraph`), cycles, and greps for lower layers
  importing upper ones or UI importing DB/HTTP clients directly.
- Find leaks: interfaces returning concrete internals, downcasts, ORM/DTO types
  crossing a boundary they shouldn't, exported mutable internals.

### 2. Design the clean seam
- Decide the correct boundary: an interface/port at the layer edge, a mapping to a
  boundary type (DTO/domain model) instead of leaking the inner type, dependency
  inversion so the arrow points the right way.

### 3. Fix
- Route callers through the interface; add the missing port/adapter or mapping;
  make internals private; invert the dependency to break cycles. Keep the change
  mechanical and behaviour-preserving.
- Add an **architecture guard** (dep-cruiser rule / ArchUnit test / lint) so the
  violation can't silently return.

### 4. Verify e2e
- `/verify` green; behaviour identical. The new architecture rule passes and would
  fail on the old code.

## PR body template
```md
## Fix layering: <boundary> — <violation>

### Violation
<UI imported the DB client directly / repo returned the ORM entity / domain
imported HTTP / cycle A→B→A> — shown via <import-graph tool output>

### Fix
<routed through <interface/port>; mapped to <boundary type>; inverted dependency;
made <internals> private>

### Guard added
<dep-cruiser rule / ArchUnit test / lint rule that now forbids this — fails on old code>

### Behaviour
Unchanged — dependency re-routing + visibility only.

### /verify
<pasted output>
```

## Slack updates
Maintain **one top-level thread** for this routine in the designated channel
(configure `SLACK_CHANNEL` per repo). Each run: violations found (leaks vs
layering), boundaries restored, guard rules added, PRs opened.

## Guardrails
- Behaviour-preserving only — re-routing dependencies must not change outputs; a
  discovered bug goes to `logic-bugfixer`.
- Don't over-correct into new indirection for its own sake — if the fix is
  tempting you to add ceremony, check against `abstraction-improver`.
- Prefer adding an enforceable guard to every fix; a boundary with no test re-leaks.

## Provenance
Pure process/pattern skill — no API, no bundled code. Distilled from the public
Claude Code team routine described by Boris Cherny
(https://x.com/bcherny/status/2088014489438621990): "abstraction police — fixes
leaky abstractions and layering violations." Companion to `abstraction-improver`.
