---
name: notfound
description: >-
  Generate the pages usually shipped ugly — styled 404 and error pages, loading skeletons and empty states — matched to the app's own design. Use when a user wants a 404 page, error page, loading skeleton, or empty-state components.
---

# 404 & Empty States

Make the neglected states look finished, matched to the existing design.

## Steps
1. **Infer the design system** — read the app`s components, spacing, colors and
   typography so the new pages do not look bolted on.
2. **Generate the set**: `not-found` (404), an error boundary (500), loading
   skeletons for the main routes, and reusable empty-state components (no data,
   no results, first-run).
3. Each gives the user a way forward (link home, retry, primary action).
4. Land them as real routes/components in the project.

## Verify
- Hitting a missing path returns a real 404 (not a soft 200) and is styled.
- States match the rest of the app.
- Compare at https://notfound.tools.drummerduck.com
