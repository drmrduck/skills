---
name: flaky-test-fixer
description: >-
  Root-cause and fix flaky CI tests — tests that pass and fail nondeterministically
  — by identifying the source of nondeterminism (time, ordering, concurrency,
  network, randomness, shared state, animations) and fixing it properly, not by
  adding retries or sleeps. Deletes tests that are flaky *and* useless. Confirms
  the fix by running the test many times green. Use for daily flaky-test routines
  or when a user says "this test is flaky", "fix the flaky CI", or "the suite is
  nondeterministic".
---

# Flaky Test Fixer

Flaky tests erode trust in the whole suite and mask real failures. This routine
finds them, **root-causes the nondeterminism**, and fixes it at the source —
never with a blind retry or `sleep`. Flaky *and* useless tests get deleted. Runs
daily (once per app) and on demand via `/flaky-test-fixer`.

## Golden rules
1. **Root-cause the nondeterminism.** A retry or bigger timeout hides flakiness;
   it doesn't fix it. Find *why* the outcome varies.
2. **Prove flaky, prove fixed.** Reproduce the flake (many runs, randomized
   order/seed/parallelism) and, after the fix, run it many times all-green.
3. **Delete flaky-and-useless.** If a test is both nondeterministic *and* carries
   no signal (see `useless-test-pruner`), delete it instead of fixing.
4. **Verify e2e.** `/verify` plus the repeated-run evidence.
5. **One flaky test (or one shared root cause) → one PR.**

## Common root causes (and the real fix)
| Symptom | Root cause | Fix (not this) |
| --- | --- | --- |
| passes alone, fails in suite | shared/global state, leaked singletons | isolate + reset state per test (not: run serially) |
| fails at midnight / month-end | real clock, timezone, DST | inject a fixed clock (not: widen assertion) |
| random pass rate | unseeded randomness | seed the RNG (not: loosen the assert) |
| intermittent timeout | real network / async race | mock the boundary or await the actual signal (not: bump timeout / add sleep) |
| order-dependent | tests depend on each other | make each self-contained (not: pin order) |
| UI intermittent | animations, non-deterministic render | wait on state not time; disable animations (not: retry) |

## The routine

### 1. Identify the flaky tests
- Pull CI history for pass/fail variance on unchanged code; scan retry logs and
  quarantine lists. Reproduce locally with **randomized order, seeds, and
  parallelism** and repeated runs (e.g. `--runInBand` vs parallel, `-count=100`,
  `--repeat-each`).

### 2. Root-cause the nondeterminism
- Bisect the source: clock, ordering, concurrency/races, network, randomness,
  shared/global state, filesystem, animations, locale. Confirm the hypothesis by
  forcing the condition and seeing the failure become reliable.

### 3. Fix at the source (or delete)
- Apply the real fix from the table (inject clock, seed RNG, isolate state, await
  the real signal, mock the boundary). **No** `sleep`, no retry-wrapper, no
  timeout inflation as the fix.
- If the test is also useless, delete it (cite `useless-test-pruner` criteria).

### 4. Verify e2e
- Run the test **many times** (randomized order/seed/parallel) — all green. Run
  `/verify`. Paste the repeated-run evidence.

## PR body template
```md
## Fix flaky test: <name>

### Flake evidence
<CI failure rate on unchanged code · repro: N runs, K failed, seed/order that triggers it>

### Root cause
<the exact source of nondeterminism — proven by forcing it to fail reliably>

### Fix
<inject clock / seed RNG / isolate state / await real signal — NOT retry/sleep>

### Proof of fix
<same test: 200 runs randomized order+seed, 200 green> + /verify below

### /verify
<pasted output>
```

## Slack updates
Maintain **one top-level thread** for this routine in the designated channel
(configure `SLACK_CHANNEL` per repo). Each run: flaky tests found + failure rates,
root cause per fix, tests fixed vs deleted-as-useless, PRs opened.

## Guardrails
- Never "fix" flakiness with `sleep`, a retry wrapper, `test.retry(n)`, or a
  wider timeout — that's masking, and it's an explicit anti-pattern here.
- Don't quarantine indefinitely; quarantine is a holding pen, this routine drains
  it.
- A flaky test that keeps catching a *real* intermittent product bug isn't the
  test's fault — fix the product, note it.

## Provenance
Pure process/pattern skill — no API, no bundled code. Distilled from the public
Claude Code team routine described by Boris Cherny
(https://x.com/bcherny/status/2088014489438621990): a daily routine for "finding
and fixing root causes of flaky tests, and deleting useless ones."
