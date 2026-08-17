---
name: dead-code-remover
description: >-
  Remove statically unreachable / provably dead code. Deletes code that static
  analysis proves can never run outright; for code that only *looks* dead
  (reachable in principle but maybe never in practice), it adds temporary
  "reached here" logging first and deletes it on a later run if the logging stayed
  silent. Verifies e2e that nothing else changed. Use for daily dead-code cleanup
  routines or when a user says "remove dead code", "is this ever called", or
  "delete unreachable code".
---

# Dead Code Remover

Delete code that can't run. Two tiers: **provably dead** (static analysis says no
path reaches it) goes immediately; **suspected dead** (reachable on paper, but you
suspect never in practice) gets a temporary log probe first, then is removed on a
later run if it never fired. Runs daily (once per app) and on demand via
`/dead-code-remover`.

## Golden rules
1. **Prove it, or probe it.** Static-unreachable → delete now. Only-suspected →
   instrument, wait, then delete. Never delete "probably unused" code on a hunch.
2. **Delete the whole thing.** Function + its now-orphaned imports, tests, types,
   and assets — no half-removed corpses.
3. **Careful with dynamic reachability.** Reflection, DI, string-keyed dispatch,
   public API, plugin hooks, serialization, and framework lifecycle methods can
   be "called" without a static reference. Treat these as suspected, not proven.
4. **Verify e2e.** `/verify` must pass unchanged; behaviour is identical (you only
   removed things nothing reached).
5. **One coherent removal → one PR.**

## The routine

### 1. Find statically dead code
- Use the language's own tools: `ts-prune`/`knip`/`eslint no-unused`, `deadcode`/
  `staticcheck` (Go), `vulture` (Python), compiler dead-code/`-Wunused` warnings,
  coverage-guided unreachable detection, `git grep` for zero-reference symbols.
- Confirm each candidate has **no** static references and isn't reachable via the
  dynamic mechanisms above.

### 2. Delete the provably-dead
- Remove it plus everything only it kept alive. Run `/verify`. Open the PR.

### 3. Probe the suspected-dead (the two-day protocol)
For code that's reachable in principle but you believe never runs:
- **Day 1 — instrument:** add a lightweight, rate-limited "reached: <site>" log/
  metric at the entry of the suspect path (guarded so it can't spam or affect
  behaviour). Ship it. Record the site in the routine's tracking note.
- **Wait** at least a full usage cycle (typically the next daily run / ~24h+, or
  longer for weekly-seasonal paths — state the window).
- **Day 2 — decide:** on the next run, check the probe.
  - **Never fired** → delete the path *and the probe* in one PR (cite the silent
    window as evidence).
  - **Fired** → it's live: remove the probe, leave the code, note it's not dead.

### 4. Verify e2e
- `/verify` green. Nothing else changed — that's the whole point.

## PR body template
```md
## Remove dead code: <what>

### Evidence
<static: tool output showing zero reachable references + no dynamic-dispatch use>
<or probe: log site added <date>, silent for <window> → safe to delete>

### Removed
<symbols/files + orphaned imports/tests/types also removed>

### /verify
<pasted output — unchanged; behaviour identical>
```

## Slack updates
Maintain **one top-level thread** for this routine in the designated channel
(configure `SLACK_CHANNEL` per repo). Each run: code deleted (proven), probes
newly added, probes that came due and their verdict (deleted / kept-because-fired).

## Guardrails
- Never delete public API / exported library surface as "unused" from an app's
  perspective — external callers exist off-repo. Flag instead.
- Probes must be behaviour-neutral and non-spammy; remove every probe you add
  (delete-because-silent, or on the same PR that keeps the code).
- If reachability depends on config/flags, check all configs before calling dead.

## Provenance
Pure process/pattern skill — no API, no bundled code. Distilled from the public
Claude Code team routine described by Boris Cherny
(https://x.com/bcherny/status/2088014489438621990): a daily dead-code remover that
deletes provably-unreachable code and, for suspected dead code, adds temporary
logging and removes it the next day if still unused.
