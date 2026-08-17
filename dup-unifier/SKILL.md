---
name: dup-unifier
description: >-
  Scan the codebase for similar-yet-slightly-divergent abstractions and
  near-duplicate implementations, reconcile their differences (including the
  subtle behavioural ones), and open PRs that merge them into one clean, canonical
  version. Formally models the divergent behaviours before merging and verifies
  e2e with a truth table so no caller's behaviour silently changes. Use for daily
  de-duplication routines or when a user says "these two functions are basically
  the same", "unify these implementations", "DRY this up", or "we have three
  versions of this".
---

# Dup Unifier

Find the places where the same idea has been implemented two, three, five times —
each copy drifting slightly — and merge them into a single canonical
implementation, **without** silently changing what any caller sees. Runs as a
daily routine (once per app) and on demand via `/dup-unifier`.

## Golden rules
1. **Merge, don't just delete.** The winner must cover the union of every copy's
   real behaviour, or each dropped difference must be a deliberate, noted choice.
2. **Model the divergence first.** Near-duplicates differ in subtle ways (a null
   check here, a rounding rule there). Enumerate those differences before
   collapsing them.
3. **Behaviour-preserving per caller.** After unification, every existing call
   site must behave the same — or the change is called out and justified.
4. **Verify e2e with a truth table.** `/verify` plus a table proving each former
   copy's callers get identical results from the unified version.
5. **One duplicate cluster → one PR.**

## The routine

### 1. Detect near-duplicates
- Scan for structural and semantic clones: copy-pasted functions/components,
  parallel utils (`formatDate`, `formatDate2`, `dateUtils.format`), repeated
  validation/parsing, sibling classes with 90%-identical bodies.
- Use whatever's available: token/AST similarity, `jscpd`/PMD-CPD-style scans,
  grep for suspicious name families, or read clusters the team already suspects.
- Group into **clusters** — all the copies of one idea.

### 2. Model the divergence
- For each cluster, build a **difference table**: rows = input/edge cases, columns
  = each copy, cells = what that copy does. This surfaces the real behavioural
  deltas (error handling, defaults, rounding, ordering, locale, empty/null).
- Decide the **canonical behaviour** for each divergent row — usually the correct
  or most-complete one. Note any row where copies genuinely *should* differ (then
  they may not be true duplicates — keep them separate).

### 3. Unify
- Write (or pick) the single canonical implementation covering the agreed union.
- Redirect every call site to it. Delete the redundant copies. Parameterize only
  where a real, justified difference remains — don't invent config knobs to
  paper over drift.

### 4. Verify e2e
- Run the full suite + `/verify`. Add tests for any divergent row that wasn't
  covered.
- Produce the **truth table**: for each former copy's caller, Before vs After.

## PR body template
```md
## Unify: <the duplicated idea> (<N> copies → 1)

### Copies found
- <path A> · <path B> · <path C>

### Divergence model
| Case | Copy A | Copy B | Copy C | Canonical |
| --- | --- | --- | --- | --- |
| null input | throws | "" | "" | "" (chosen; A was a bug) |
| rounding | floor | round | round | round |

### Change
<the canonical impl; call sites redirected; copies deleted; LOC removed>

### Truth table (verified e2e)
| Caller / case | Before (its old copy) | After (unified) |
| --- | --- | --- |
| A's callers | X | X |
| B's callers | Y | Y |
| divergent case | see model | canonical (noted) |

### /verify
<pasted output>
```

## Slack updates
Maintain **one top-level thread** for this routine in the designated channel
(configure `SLACK_CHANNEL` per repo). Each run: clusters found, copies merged,
LOC removed, any behavioural deltas that were deliberately resolved, PRs opened.

## Guardrails
- If two "duplicates" genuinely need to differ, they're not duplicates — leave
  them and note why.
- Never collapse copies whose divergence you don't understand; model first.
- Watch for a hidden bug in one copy (a divergent row that's simply wrong) — that
  becomes the canonical fix, and gets called out as a behaviour change.

## Provenance
Pure process/pattern skill — no API, no bundled code. Distilled from the public
Claude Code team routine described by Boris Cherny
(https://x.com/bcherny/status/2088014489438621990): a daily dup-unifier that
merges similar-yet-divergent implementations into one clean version, with the same
formal-modeling + e2e truth-table discipline as the logic routines.
