---
name: crash-fuzzer
description: >-
  Find real crashes in a running app by launching the actual build (no mocks) in
  a simulator, emulator, or device, fuzzing real UI interactions until something
  crashes, root-causing the crash, and opening a fix PR. Every PR runs /verify
  and includes a minimal repro plus a truth table; progress is posted to a
  top-level "Fuzzer" thread in the designated Slack channel. Use for daily
  crash-fuzzing routines across iOS, Android, Desktop, web, CLI, and Agent SDK
  apps, or when a user says "fuzz the app", "find crashes", "crash-fuzz iOS /
  Android / desktop", or "why did the app crash".
---

# Crash Fuzzer

Open the **real app** — the actual build, no mocks, no stubbed backends — drive it
with fuzzed but realistic interactions until it crashes, find the true root
cause, and ship a small, verified fix PR. This is meant to run **once per app per
day** as an unattended routine and also on demand via `/crash-fuzzer`.

Read `reference.md` for platform launch/fuzz/capture recipes and the truth-table
format.

## Golden rules
1. **Real app, no mocks.** Launch the shipping build against real (or staging)
   services. A crash that only reproduces against mocks is not a crash worth a
   PR; a crash the fuzzer can't reproduce on the real app doesn't get filed.
2. **One crash → one PR.** Keep each PR to a single root cause, small and
   revertible. Don't bundle unrelated fixes.
3. **Root cause, not symptom.** A null-guard that hides the crash is not a fix.
   Trace to why the bad state happened and fix that. Say so explicitly in the PR.
4. **Every PR runs `/verify` and carries a repro + truth table.** No exceptions.
5. **All updates go to the top-level `Fuzzer` thread** in the designated channel
   (configure the channel per repo — see Configuration).

## The routine

### 1. Pick the target and launch the real app
- Determine the platform from the repo (iOS/Android/Desktop/web/CLI/Agent SDK)
  and launch the **release-configured** build on a simulator, emulator, or
  attached device. See `reference.md` for exact commands per platform.
- Point it at real or staging backends. Record the build SHA, OS/version, device,
  and locale — these go in every repro.

### 2. Fuzz realistic interactions
- Drive the UI (or CLI/API surface) with **plausible** sequences, not random
  bytes: tap/scroll/type/rotate/background-foreground/deep-link/paste,
  permission prompts, network flaps, low-memory, rapid navigation, empty and
  huge inputs, non-Latin text, offline→online transitions.
- Prefer the platform's own fuzz/monkey harness where one exists (e.g. Android
  `monkey`, XCUITest random walk, Playwright with a seeded random driver, a
  fuzzed CLI arg/stdin generator). **Seed the RNG** and log every action so any
  crash is replayable.
- Watch for crashes, ANRs/hangs, fatal logs, unhandled promise rejections, and
  non-zero exits. Capture the stack, logs, screenshot/recording, and the exact
  action sequence.

### 3. Reduce to a minimal repro
- Replay the logged action sequence, then **delta-debug**: remove steps until you
  have the shortest sequence that still crashes. That reduced sequence is the
  repro you ship.
- Confirm it reproduces from a clean launch at least twice.

### 4. Root-cause and write a failing test
- Trace the stack to the real cause (bad state transition, unchecked optional,
  race, off-by-one, contract violation). Model the state that led there.
- Add an **automated test that fails on `main` and passes with the fix** — a unit
  test, or a scripted UI test replaying the reduced repro.

### 5. Fix, verify, and open the PR
- Make the smallest fix that addresses the root cause.
- Run the project's **`/verify`** (build + lint + tests + whatever `/verify`
  covers for this repo) and paste the result into the PR.
- Open the PR with the body template below.

## PR body template
```md
## Crash: <one-line summary>

**Environment:** <platform> · build <sha> · <OS/version> · <device/sim> · <locale>

### Repro (minimal, seeded)
seed: <rng-seed>
1. <step>
2. <step>
3. <step>  ← crashes here

<stack trace excerpt / fatal log>

### Root cause
<why the bad state occurred — not just where it threw>

### Fix
<the smallest change that fixes the root cause>

### Truth table (verified e2e)
| Scenario | Input / state | Before | After |
| --- | --- | --- | --- |
| repro sequence | seed <n> | 💥 crash | ✅ handled |
| adjacent case A | ... | ✅ | ✅ (unchanged) |
| adjacent case B | ... | ✅ | ✅ (unchanged) |

### /verify
<pasted output — build ✓ lint ✓ tests ✓>
```
A failing-then-passing test is attached in the diff. The truth table must show
the repro fixed **and** neighbouring cases unchanged (no regressions).

## Slack updates (Fuzzer thread)
- Maintain **one top-level thread titled `Fuzzer`** in the designated channel.
  Post the day's run as a reply: target app, build, how long fuzzed, crashes
  found, PRs opened (with links), and "no crashes found" when clean.
- Never start a new top-level message per run — keep the history in the one
  thread so trends are visible.

## Configuration (per repo)
Read these from the repo's routine config / env; fall back to asking:
- `SLACK_CHANNEL` — where the `Fuzzer` thread lives.
- `PLATFORM` / launch target — else infer from the repo.
- `VERIFY_CMD` — defaults to the `/verify` command; else the repo's build+test.
- `FUZZ_BUDGET` — wall-clock or action count per run.

## Guardrails
- Never commit secrets, device tokens, or captured PII from real-backend runs;
  scrub logs/screenshots before attaching.
- If you can't reproduce a crash deterministically, **don't** open a PR — post
  the flaky signal to the Fuzzer thread for a human instead.
- Don't "fix" by swallowing the error. Root cause only.

## Provenance
Pure process/pattern skill — no API, no bundled code. Distilled from the public
Claude Code team routine described by Boris Cherny
(https://x.com/bcherny/status/2088014489438621990): daily e2e crash-fuzzing that
runs the real apps, opens root-cause fix PRs with a repro + truth table, runs
`/verify`, and reports in a top-level Fuzzer Slack thread.
