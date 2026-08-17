---
name: logic-bugfixer
description: >-
  Discover and fix bugs in tricky business logic by formally modeling it first (truth
  table / decision table / state machine) to reveal gaps, contradictions, and
  unhandled edge cases, then fixing the root cause and proving the fix e2e with a
  truth table. Also known as business-logic-bugfixer-daily. Use for daily
  logic-hardening routines or when a user says "find bugs in this logic", "this
  rule is wrong for some cases", "audit this business logic", or "why does this
  calculation break".
---

# Logic Bugfixer

Model tricky business logic formally to **discover** latent bugs — the edge cases
nobody enumerated — then fix the root cause and prove it. Where `logic-simplifier`
preserves behaviour, this skill deliberately hunts for cases where the current
behaviour is *wrong* and corrects it. Runs as a daily routine (once per app) and
on demand via `/logic-bugfixer`.

## Golden rules
1. **Model first — that's how you find the bug.** Enumerate the input/state
   cross-product; the bugs live in the rows the code got wrong or never handled.
2. **Fix the root cause.** Correct the rule, not the one failing symptom. A patch
   that only fixes the reported input but leaves its siblings wrong is incomplete.
3. **Failing test first.** Every bug gets a test that fails on `main` and passes
   with the fix.
4. **Verify e2e with a truth table.** `/verify` plus a table showing the buggy
   rows corrected and every other row unchanged.
5. **One bug (or one coherent rule) → one PR.**

## The routine

### 1. Formally model the logic
- Identify inputs, relevant state, and the intended output/effect. Enumerate the
  **cross-product of input classes** into a decision/truth table (or a state
  machine for stateful logic) — include boundaries and "can't happen" rows.
- For each row, record two things: **what the code does** and **what it should
  do** (from spec, product intent, invariants, or first principles).
- Rows where those two disagree are **bugs**. Rows with no defined behaviour are
  **gaps** (often latent bugs). Overlapping conditions with different outcomes are
  **contradictions**.

### 2. Confirm and reduce each bug
- Reproduce each disagreement with a concrete input. Reduce to the minimal case.
- Write it as a **failing test** first.

### 3. Fix the root cause
- Correct the rule so all sibling rows are right too, not just the reported one.
- Keep the fix minimal and local; if the correct behaviour is genuinely ambiguous,
  flag it for a human in the thread rather than guessing.

### 4. Verify e2e
- Run the new failing tests (now green) + the existing suite + `/verify`.
- Produce the **truth table** proving the buggy rows are fixed and the rest are
  unchanged (no regressions).

## PR body template
```md
## Fix: <logic unit> — <what was wrong>

### Model
<decision/truth table: for each row, code-does vs should-do; buggy rows marked>

### Bug(s) found
<the incorrect / unhandled rows, with a minimal repro input for each>

### Root cause & fix
<why the rule was wrong; the minimal correction that fixes the whole class>

### Truth table (verified e2e)
| Inputs / state | Should | Before | After |
| --- | --- | --- | --- |
| buggy case | Y | ✗ X | ✅ Y |
| sibling case | Y | ✗ X | ✅ Y |
| happy path | Z | ✅ Z | ✅ Z |

### /verify
<pasted output>
```

## Slack updates
Maintain **one top-level thread** for this routine in the designated channel
(configure `SLACK_CHANNEL` per repo). Each run: bugs found + severity, root
cause in a sentence, PRs opened, or "modeled X, no bugs found".

## Guardrails
- Don't change behaviour you can't justify against a spec/invariant/intent —
  ambiguous cases go to a human, not a guess.
- Pure refactors with no behaviour change belong to `logic-simplifier`, not here.
- Never fix a symptom while leaving sibling cases broken.

## Provenance
Pure process/pattern skill — no API, no bundled code. Distilled from the public
Claude Code team routine described by Boris Cherny
(https://x.com/bcherny/status/2088014489438621990): a daily
business-logic-bugfixer that formally models tricky logic to discover and fix
bugs, ensures edge cases are tested, and always verifies e2e with a truth table.
