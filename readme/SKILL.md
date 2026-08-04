---
name: readme
description: >-
  Write a real README from the actual repo — install, usage, scripts, badges — read from what is there, not a template to fill in. Use when a user wants a README, GitHub badges (shields.io), or repo documentation.
---

# README & Badges

Generate a `README.md` from the real project, proposing a diff first.

## Steps
1. **Read the repo**: `package.json` (name, description, scripts, bin, deps),
   the entry points, config, license, and any existing docs.
2. **Write the README**: title + one-liner, a shields.io badge row (license,
   version, build, stack), Install, Usage (a real example inferred from the
   code), Scripts, and License.
3. **Propose a diff** against any existing README; let the user choose what
   lands. Do not clobber hand-written prose.

## Verify
- Commands in Install/Usage actually exist in `package.json`.
- Badge links resolve.
- Preview shape at https://readme.tools.drummerduck.com
