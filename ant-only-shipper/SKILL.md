---
name: ant-only-shipper
description: >-
  Find forgotten internal-only / ant-only / employee-gated features and decide,
  from real usage data, whether to ship them to everyone or delete them — then do
  it. Pulls actual usage (analytics/feature-flag exposure) to avoid guessing, and
  opens a ship PR or a delete PR with the evidence. Use for daily internal-feature
  cleanup routines or when a user says "what internal features are we sitting on",
  "ship or kill the ant-only stuff", or "is anyone using this internal feature".
---

# Ant-only Shipper

Internal-only features (behind an employee / "ant-only" / dogfood gate) pile up:
some are quietly load-bearing and should graduate to everyone, most are abandoned
and should be deleted. This routine decides **from real usage data**, not vibes,
and executes the decision as a PR. Runs daily (once per app) and on demand via
`/ant-only-shipper`.

## Golden rules
1. **Data decides, not opinion.** Ship or delete based on real exposure/usage over
   a meaningful window — never guess.
2. **Two clean outcomes only:** *ship to everyone* (remove the gate) or *delete*
   (remove the feature + its gate + dead code). No "leave it for later".
3. **Deleting a feature deletes all of it** — UI, code paths, flags, tests,
   analytics, docs — so nothing rots behind the removed gate.
4. **Verify e2e.** `/verify` on every PR; for ship PRs include a truth table
   showing gated vs ungated behaviour is what's intended.
5. **One feature → one PR.**

## The routine

### 1. Inventory the internal-only features
- Find the gates: employee/ant/dogfood/internal flags, `isInternal`/`isStaff`
  checks, allow-lists, `NODE_ENV`-style internal switches, hidden routes.
- For each, map its full surface: entry points, code, tests, analytics events,
  docs, and the flag definition.

### 2. Pull real usage
- Query the actual analytics / feature-flag platform (PostHog, Statsig, internal
  telemetry — whatever the repo uses) for exposure and engagement over a
  meaningful window (e.g. 30–90 days):
  - Is it exposed at all? To how many internal users? Repeat usage or one-off?
  - Does it drive the outcome it was built for?
- Record the numbers — they go in the PR.

### 3. Decide
- **Actively used + valuable** → *ship*: remove the internal gate so all users get
  it; clean up now-dead internal-only branches; ensure it meets the bar for GA
  (works, tested, no internal-only assumptions leaking to prod).
- **Unused / abandoned** → *delete*: remove the feature end-to-end and its gate.
- **Ambiguous / borderline** → don't force it; post the data to the thread and ask
  a human. Optionally add temporary logging and revisit (see
  `dead-code-remover`'s log-then-remove pattern).

### 4. Execute + verify
- Make the ship or delete change. Run `/verify`. For ship PRs, add/keep tests for
  the now-public behaviour and a truth table.

## PR body template
```md
## <Ship | Delete>: <feature> (was internal-only)

### Gate
<flag / staff check / allow-list that gated it, and where>

### Usage evidence (last <window>)
<exposed to N internal users · M active · trend · drove <outcome>? yes/no>
→ Decision: <ship to everyone | delete>

### Change
<ship: gate removed, dead internal branches cleaned>
<delete: UI + code + flag + tests + analytics + docs removed>

### Truth table (ship PRs; verified e2e)
| User | Before | After |
| --- | --- | --- |
| internal | had feature | has feature |
| external | no feature (gated) | has feature |

### /verify
<pasted output>
```

## Slack updates
Maintain **one top-level thread** for this routine in the designated channel
(configure `SLACK_CHANNEL` per repo). Each run: features reviewed, the
data-backed ship/delete decision for each, PRs opened, borderline cases escalated.

## Guardrails
- Never ship an internal feature that assumes internal-only conditions (test data,
  unthrottled endpoints, missing rate limits, PII exposure) — audit before GA.
- Never delete without usage evidence and a clean, reversible PR.
- Deleting means *all* of it — leaving orphaned flags/tests/analytics is a fail.

## Provenance
Pure process/pattern skill — no API, no bundled code. Distilled from the public
Claude Code team routine described by Boris Cherny
(https://x.com/bcherny/status/2088014489438621990): "ant-only shipper — ships or
deletes forgotten internal-only features based on usage."
