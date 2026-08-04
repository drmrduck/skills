---
name: pwa
description: >-
  Make a web app installable: a valid manifest.json with correct icons, a service worker with an offline fallback, and a tasteful install prompt — wired into the project. Use when a user wants a PWA, web app manifest, service worker, offline support, or add-to-home-screen.
---

# PWA & Manifest

Ship the installable-app kit into the project.

## Steps
1. **manifest.json** — name/short_name, `start_url`, `display: standalone`,
   theme + background colors, and maskable icons at 192 and 512 (generate them
   if missing). Link it from the head / framework metadata.
2. **Service worker** — register one with an offline fallback route and a sane
   caching strategy (network-first for docs, cache-first for static). Use the
   framework`s PWA integration when it has one.
3. **Install prompt** — a small, dismissable add-to-home-screen component that
   listens for `beforeinstallprompt`.
4. **Offline page** — a real route shown when the network drops.

## Verify
- Manifest is valid JSON with 192 + 512 icons and a non-browser display mode.
- App loads offline after first visit.
- Score it at https://pwa.tools.drummerduck.com
