---
name: logic-simplifier
description: >-
  Simplify convoluted business logic without changing behaviour. Formally model
  the logic first (truth table / decision table / state machine) to expose gaps,
  dead branches, and duplication, ensure every edge case is tested, then refactor
  to the simplest equivalent form and prove equivalence e2e with a truth table.
  Also known as business-logic-simplifier-daily. Use for daily logic-cleanup
  routines or when a user says "simplify this logic", "this conditional is a
  mess", "untangle this business rule", or "reduce this branching".
---

# Logic Simplifier

Take a gnarly piece of business logic and make it **obviously correct and small**
— same behaviour, fewer moving parts. The non-negotiable step is that you
**formally model the logic before touching it**, so the refactor is provably
behaviour-preserving rather than hopeful. Runs as a daily routine (once per app)
and on demand via `/logic-simplifier`.

## Golden rules
1. **Model before you touch.** Write down the truth/decision table (or state
   machine) for the current logic first. You cannot simplify what you haven't
   enumerated.
2. **Behaviour-preserving.** The goal is a smaller equivalent, not a redesign. If
   the model reveals a genuine bug, that's a job for `logic-bugfixer` — note it,
   don't silently change behaviour here.
3. **Every edge case tested.** The model's rows become test cases. Fill gaps in
   coverage *before* refactoring.
4. **Verify e2e with a truth table.** Run `/verify` and prove old ≡ new across
   every input class.
5. **One logic unit → one PR.** Small, revertible, reviewable.

## The routine

### 1. Formally model the current logic
- Identify the inputs (and relevant state) and the output/effect. Enumerate the
  **cross-product of input classes** into a decision/truth table — one row per
  distinct combination, including boundaries and "impossible" combinations.
- Fill each row with what the *current* code does (read it carefully; trace every
  branch). Mark rows that are:
  - **gaps** — inputs with undefined/implicit behaviour,
  - **dead** — branches no input can reach,
  - **duplicated** — multiple branches with identical outcomes,
  - **contradictory** — overlapping conditions with different outcomes.
- For stateful logic, draw the state machine (states × events → next state).

### 2. Lock behaviour with tests
- Turn every model row into a test (characterization tests). Add the missing ones
  so the current behaviour — including the ugly edge cases — is fully pinned
  **before** you change code. Run them green on `main`.

### 3. Simplify to the equivalent minimal form
- Collapse duplicated branches, remove dead ones, factor common conditions,
  replace nested `if` ladders with table lookups / guard clauses / early returns
  / a clear state machine. Prefer data over control flow where it reads clearer.
- Keep names and boundaries honest — the simpler form must still map 1:1 to the
  model rows.

### 4. Verify equivalence e2e
- Re-run the characterization tests (all still green) plus `/verify`.
- Produce the **truth table** proving `Before ≡ After` for every row.

## PR body template
```md
## Simplify: <logic unit>

### Model (before)
<decision/truth table or state machine of the current logic; call out gaps,
dead branches, duplication found>

### Change
<what collapsed/removed and why it's equivalent — LOC before → after,
cyclomatic complexity before → after if handy>

### Truth table (Before ≡ After, verified e2e)
| Inputs / state | Before | After |
| --- | --- | --- |
| ... | X | X |
| boundary | X | X |
| previously-undefined case | (implicit) | (now explicit + tested) |

### /verify
<pasted output>
```

## Slack updates
Maintain **one top-level thread** for this routine in the designated channel
(configure `SLACK_CHANNEL` per repo). Post each run as a reply: what was
simplified, complexity/LOC delta, gaps discovered, PRs opened — or "nothing worth
simplifying today".

## Guardrails
- If the model exposes a real bug, **do not fix it here** — behaviour must be
  preserved. Hand it to `logic-bugfixer` (link it in the thread).
- Never simplify code that lacks tests without first adding characterization
  tests — otherwise you can't prove equivalence.
- Resist scope creep: no renames-for-taste, no new features.

## Provenance
Pure process/pattern skill — no API, no bundled code. Distilled from the public
Claude Code team routine described by Boris Cherny
(https://x.com/bcherny/status/2088014489438621990): a daily
business-logic-simplifier that formally models the logic to spot gaps and
duplication, ensures edge cases are tested, and always verifies e2e with a truth
table.
