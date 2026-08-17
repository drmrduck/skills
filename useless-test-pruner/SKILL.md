---
name: useless-test-pruner
description: >-
  Delete tests that can never fail or otherwise carry no signal — tautologies,
  fully-mocked tests that only assert the mock, tests with no assertions, always-
  skipped tests, snapshot tests that rubber-stamp anything, and duplicates. Proves
  a test is useless (e.g. it still passes when the code under test is broken) before
  deleting it. Use for daily test-suite cleanup routines or when a user says "prune
  useless tests", "this test can't fail", or "delete no-op tests".
---

# Useless Test Pruner

A test that can't fail is worse than no test: it costs CI time and fakes
confidence. This routine finds tests with **no signal** and deletes them — after
proving they're useless. Runs daily (once per app) and on demand via
`/useless-test-pruner`.

## What "useless" means (delete candidates)
- **Can't fail:** passes even when the code under test is broken (mutation
  survives) — the strongest signal.
- **No assertions:** runs code but asserts nothing (or only `expect(true)`).
- **Tests the mock, not the code:** everything meaningful is mocked, so it only
  asserts the mock returns what you told it to.
- **Tautological:** asserts a literal equals itself, or re-implements the code in
  the assertion.
- **Permanently skipped/`xit`/`.todo`:** disabled and rotting — delete or fix.
- **Snapshot rubber-stamps:** giant snapshots auto-updated on every change, never
  read — they assert "the output is whatever it currently is".
- **Exact duplicates:** identical coverage to another test.

## Golden rules
1. **Prove uselessness before deleting.** Prefer a mutation check: break the code
   under test; if the test still passes, it can't fail → delete. Or show
   structurally that it has no meaningful assertion.
2. **Delete useless, don't weaken good.** If a test is *poor* but salvageable
   (real intent, weak assertion), fixing it is better than deleting — note which
   you chose.
3. **Coverage must not drop meaningfully.** Removing a no-signal test shouldn't
   lose real coverage; if it does, the test wasn't useless — fix it instead.
4. **Verify e2e.** `/verify` still green with the tests gone.
5. **One coherent batch → one PR.**

## The routine

### 1. Find candidates
- Scan for: zero-assertion test bodies, `skip`/`xit`/`todo`, assertions on mocked
  return values only, `toMatchSnapshot` on large auto-managed snapshots, and
  suspiciously duplicated test names/bodies.
- Cross-reference with mutation-testing output (Stryker/PIT/`cargo-mutants`/
  `mutmut`) if available — surviving mutants that *should* be caught point at
  tests that don't actually test.

### 2. Prove each is useless
- **Mutation probe:** introduce a representative fault in the code the test claims
  to cover; run just that test. Still green ⇒ useless. Revert the fault.
- Or document the structural reason (no assertion / asserts only the mock / always
  skipped / self-tautology).

### 3. Delete (or fix)
- Delete proven-useless tests and their now-orphaned fixtures/mocks/snapshots.
- For salvageable ones, strengthen the assertion instead and say so.

### 4. Verify e2e
- `/verify` green; confirm real coverage didn't drop (only no-signal tests left).

## PR body template
```md
## Prune useless tests (<N> deleted, <M> strengthened)

### Deleted — with proof
| Test | Why useless | Proof |
| --- | --- | --- |
| <name> | asserts only the mock | broke <fn>, test still passed |
| <name> | no assertions | — |
| <name> | permanently skipped | skipped since <ref> |

### Strengthened (kept)
<tests that had real intent but weak assertions — now assert behaviour>

### Coverage
<no meaningful drop — only no-signal tests removed>

### /verify
<pasted output>
```

## Slack updates
Maintain **one top-level thread** for this routine in the designated channel
(configure `SLACK_CHANNEL` per repo). Each run: tests deleted (with the one-line
proof), tests strengthened, CI-time saved if measurable.

## Guardrails
- Never delete a failing/flaky test to "clean up" — flaky belongs to
  `flaky-test-fixer`; a failing test may be catching a real bug.
- Don't delete a test just because it's currently green — green ≠ useless. The bar
  is *can't fail*, proven.
- Keep security/regression tests even if narrow — they exist to stay silent.

## Provenance
Pure process/pattern skill — no API, no bundled code. Distilled from the public
Claude Code team routine described by Boris Cherny
(https://x.com/bcherny/status/2088014489438621990): "useless-test pruner — deletes
tests that can't fail," alongside the flaky-test work.
