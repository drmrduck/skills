---
name: shipped-feature-inliner
description: >-
  Remove feature flags / experiment flags for features that are fully shipped —
  inline the winning branch, delete the losing branch and the flag itself, and
  clean up the now-dead config, plumbing, and tests. Confirms the flag is truly at
  100% (or the experiment is concluded) before inlining, and verifies e2e that
  behaviour equals the shipped state. Use for daily flag-cleanup routines or when a
  user says "remove this feature flag", "this experiment is done", or "inline the
  shipped flag".
---

# Shipped-feature Inliner

Fully-shipped features leave their flag scaffolding behind: `if (flag) {…} else
{…}`, config entries, flag-eval plumbing, and dead "old path" code. This routine
proves a flag is done and **inlines** it — keep the shipped branch, delete the
flag and the dead branch. Runs daily (once per app) and on demand via
`/shipped-feature-inliner`.

## Golden rules
1. **Prove it's shipped first.** Flag at 100% for all cohorts (or experiment
   concluded with a decided winner) for a stable window — verified against the
   flag/experiment platform, not assumed.
2. **Inline the winner, delete the rest.** Remove the flag check, the losing
   branch, the flag definition/config, its eval plumbing, and tests that only
   exercised the dead branch.
3. **Behaviour = shipped state.** After inlining, every user gets exactly what the
   100% rollout already gave them — nothing observable changes.
4. **Verify e2e with a truth table.** `/verify` plus a table: old flag=on/off vs
   new (only the on/shipped behaviour remains).
5. **One flag → one PR.**

## The routine

### 1. Inventory flags and their state
- Find flag reads in code and match them to the flag/experiment platform
  (LaunchDarkly, Statsig, PostHog, config, env). For each, get rollout %, cohort
  targeting, and last-changed date.

### 2. Select the truly-shipped
- Keep only flags that are **100% on for everyone** (or an experiment that's
  **concluded** with a winner) and have been stable long enough to trust (no
  pending ramp, no active holdback). Skip anything still rolling out, held back,
  or kill-switch-critical (see Guardrails).

### 3. Inline
- Replace `if (flag) A else B` with `A` (the shipped branch); delete `B`.
- Delete the flag definition, its config/env entries, and eval plumbing that
  nothing else uses. Remove tests that only covered the dead branch; keep/relabel
  tests that assert the (now unconditional) behaviour.
- Run `dead-code-remover`'s logic on anything only the dead branch kept alive.

### 4. Verify e2e
- `/verify` green. Truth table proving the shipped behaviour is unchanged and the
  old branch is gone.

## PR body template
```md
## Inline shipped flag: <flag key>

### Shipped evidence
<100% for all cohorts since <date> / experiment concluded, winner = <branch>>

### Change
<flag check removed · dead branch deleted · flag def + config + plumbing removed ·
dead-branch-only tests removed>

### Truth table (verified e2e)
| Flag state (old) | Old behaviour | New (inlined) |
| --- | --- | --- |
| on (shipped) | A | A |
| off (dead) | B | — (removed; nobody was on it) |

### /verify
<pasted output>
```

## Slack updates
Maintain **one top-level thread** for this routine in the designated channel
(configure `SLACK_CHANNEL` per repo). Each run: flags inlined, LOC/config removed,
flags skipped-because-not-fully-shipped, PRs opened.

## Guardrails
- **Never inline a kill switch / operational toggle** (circuit breakers,
  maintenance mode, quota guards) even at 100% — those exist to be flipped. Flag,
  don't inline.
- Don't inline flags still ramping, with holdbacks, or with cohort targeting that
  isn't universally on.
- Also remove the flag from the flag platform (or note it for a human) so it
  doesn't linger as a dangling key.

## Provenance
Pure process/pattern skill — no API, no bundled code. Distilled from the public
Claude Code team routine described by Boris Cherny
(https://x.com/bcherny/status/2088014489438621990): "shipped-feature inliner —
removes flags for fully shipped features."
