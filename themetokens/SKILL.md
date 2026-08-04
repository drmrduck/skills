---
name: themetokens
description: >-
  Turn one brand color (or a logo) into a complete light + dark design-token set, written into the project CSS/Tailwind config with WCAG-checked scales. Use when a user wants a color palette, design tokens, a Tailwind theme, CSS variables, or dark-mode colors.
---

# Theme Tokens

Expand a brand color into a full, accessible token set in both modes.

## Steps
1. **Get the seed** — a brand hex, or extract one from an uploaded logo/image.
2. **Build the ramp** — a 50→950 scale at perceptually-even lightness, plus
   semantic tokens (background, foreground, primary, muted, border) for **light
   and dark** so they actually match.
3. **Check contrast** — foreground/background pairs against WCAG AA; nudge
   lightness until they pass.
4. **Write it in** — CSS custom properties in `globals.css` (`:root` + `.dark`)
   or the Tailwind theme config, matching the project`s existing convention.

## Verify
- Both modes render and text passes AA on its background.
- Preview at https://themetokens.tools.drummerduck.com
