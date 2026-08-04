---
name: backdrop
description: >
  Drop an interactive, pointer-reactive hero backdrop into a web project.
  Canvas-2D only (no WebGL, no deps). Implements one of: dots, mesh, grid,
  contour, flow, rings, waves, constellation, ribbons, magnetic, aurora, cells,
  bloom. Use when the user wants a living hero background, particle field,
  mouse-reactive canvas, or says "use the backdrop skill".
---

# Backdrop — interactive hero field

You write a single client React component that paints a mouse-reactive field
behind a hero section, using the user's chosen pattern + config.

## Steps

1. **Confirm the pattern + config.** If the user pasted a prompt from
   `backdrop.tools.drummerduck.com`, use those values as defaults. Otherwise
   pick a sensible default (`bloom` or `flow`) and their brand accent colour.

2. **Add `components/field-canvas.tsx`** (client component).
   - One `<canvas>`, one RAF loop, one pointer rig.
   - Cheap layered-sine height field (no noise lib).
   - Implement at least the requested pattern; extra patterns are welcome.
   - Accept a config object: `pattern`, `opacity`, `accent`, `lensRadius`,
     `density`, `amplitude`, `speed`, `repel`, `count`.
   - Cap DPR at 2; resize via `ResizeObserver`.
   - Pause when offscreen (`IntersectionObserver`) or tab hidden.
   - Honour `prefers-reduced-motion` (freeze drift, keep cursor response).
   - Batch draws into `Path2D` — do not thrash `fillStyle` per particle.

3. **Wire the hero.** Absolute/fixed backdrop under the headline with a bottom
   fade mask so body copy stays readable:

   ```tsx
   <section className="relative min-h-[70vh] overflow-hidden">
     <div
       aria-hidden
       className="pointer-events-none absolute inset-0
         [mask-image:linear-gradient(to_bottom,black,black_40%,transparent)]"
     >
       <FieldCanvas config={config} />
     </div>
     <div className="relative z-10 ...">{/* headline, CTA */}</div>
   </section>
   ```

4. **Theme.** Near-black page (`#0a0a0b`), white ink at low alpha, accent only
   near the cursor (from brand colour).

5. **Do not** add WebGL, three.js, or animation libraries. Canvas 2D only.

## Pattern cheat-sheet

| pattern        | idea                                              |
| -------------- | ------------------------------------------------- |
| dots           | halftone lattice, Bayer-inverted under cursor     |
| mesh           | wireframe lattice, lit edges near density peaks   |
| grid           | square grid vertices shove radially under cursor  |
| contour        | topo isolines that bulge/part under cursor        |
| flow           | particles stream along field contours, cursor repels |
| rings          | concentric ripples from cursor                    |
| waves          | horizontal waveforms that swell near cursor       |
| constellation  | drifting nodes, links + wires to cursor           |
| ribbons        | horizontal multi-sine silk streams                |
| magnetic       | particles orbit cursor with soft field lines      |
| aurora         | vertical glow bands that bend open                |
| cells          | hex-staggered living cells                        |
| bloom          | radial petals + rings leaning toward cursor       |

## Done when

- Hero has a live, pointer-reactive backdrop matching the requested pattern.
- Config values from the user (or gallery) are the defaults.
- No new runtime dependencies.
- Reduced-motion and offscreen pause both work.
