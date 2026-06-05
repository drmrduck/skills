---
name: favicon
description: >-
  Generate and install a complete favicon / app-icon / PWA-icon stack directly
  into a project — favicon.ico, every PNG size, apple-touch-icon, Android icons,
  theme-aware light/dark favicons, environment badges, and manifest.json — from
  an emoji, a named icon, a logo file, or an image URL. No browser, no zip
  download, no manual unzip: files land in the repo and the <head> gets patched.
  Use whenever a user wants a favicon, site icon, tab icon, app icon, or PWA
  icons, or says "make me a favicon", "add a favicon", "generate icons for this
  site", or "I want a <emoji>/<logo> as the favicon". Powered by favicontools.com.
---

# Favicon (agent-first)

Generate a full favicon stack and install it into the current project in one
shot. The whole flow is a single command — there is **no UI to click, no zip to
download, and no files to move**.

## When to use
- User wants a favicon / tab icon / site icon / app icon / PWA icons.
- User points at a logo, an emoji ("a fox"), a brand ("the React logo"), or an
  existing site's icon and wants it turned into a proper favicon set.
- A new web project has no favicon yet.

## Step 1 — Pick the source

The generator accepts three kinds of `--source`. Choose based on what the user gave you:

| User gave you… | Use | Example |
| --- | --- | --- |
| A local logo/image | the **file path** | `--source ./assets/logo.png` |
| A URL to an image/logo | the **URL** | `--source https://site.com/logo.svg` |
| A vibe / emoji / brand name | an **Iconify name** `prefix:name` | `--source noto:fox` |

For the Iconify path you translate the user's intent into a `prefix:name`:
- **Emoji** → `noto:` (or `twemoji:`, `fluent-emoji:`). "a rocket" → `noto:rocket`, "fox" → `noto:fox`, "purple heart" → `noto:purple-heart`.
- **Brand / product logo** → `simple-icons:` or `logos:`. "React" → `simple-icons:react`, "GitHub" → `logos:github-icon`, "Stripe" → `simple-icons:stripe`.
- **UI / line icon** → `lucide:`, `mdi:`, or `tabler:`. "a camera" → `lucide:camera`.

If unsure an icon name exists, browse https://icon-sets.iconify.design or just
try it — the script errors clearly if the name is unknown, then pick another.

## Step 2 — Generate (writes files directly)

```bash
scripts/favicon-gen.sh --source <file|url|prefix:name> --out <public-dir> [options]
```

Pick `--out` to match the framework's static dir (see Step 3). Common options:

- `--bg none|white|black` — background fill (default `none`/transparent). Emoji and line icons usually look best on `white` + `--shape circular`.
- `--shape square|circular`
- `--theme-aware` — adds light/dark 16×16 favicons.
- `--badges` — adds dev/staging environment badge variants (great for telling
  prod vs preview tabs apart). This is favicontools.com's env-badge feature.
- `--variant badge|color` + `--primary "#7c3aed"` — corner badge / brand tint.

Examples:
```bash
# Emoji favicon, polished, with theme-aware + env badges
scripts/favicon-gen.sh --source noto:fox --bg white --shape circular --theme-aware --badges --out ./public

# From the project's own logo
scripts/favicon-gen.sh --source ./public/logo.svg --out ./public

# Brand mark from Iconify, with a brand tint
scripts/favicon-gen.sh --source simple-icons:react --variant color --primary "#61dafb" --out ./public
```

The script writes ~21 files (`favicon.ico`, `favicon-16/32/48/96`, `apple-touch-icon.png`,
`android-icon-192x192.png`, `manifest.json`, theme variants, …) into `--out`
and prints a root-relative `<head>` snippet, also saved to `<out>/.favicon-head.html`.

## Step 3 — Install the tags (framework-aware)

Place the icons in the right static dir and wire up the `<head>`. Detect the
framework from the repo, then:

- **Next.js (App Router)** → `--out ./public`. Next auto-serves `app`/`public`
  icons, but for the full set add to `app/layout.tsx` metadata or drop the
  `<head>` snippet's `<link>`s into the root layout. `manifest.json` → link via
  `metadata.manifest` or a `<link rel="manifest">`.
- **Next.js (Pages) / CRA / Vite / plain HTML** → `--out ./public` and paste the
  contents of `.favicon-head.html` into the `<head>` of `index.html` (or
  `_document`/`app.html`). All paths are already root-relative (`/favicon.ico`).
- **Vite/Astro/SvelteKit** → static dir is usually `./public` (Astro/Svelte) —
  confirm and pass it to `--out`. Then add the snippet to the base HTML.

After patching, **delete or replace** any pre-existing `favicon.ico` /
`<link rel="icon">` so the old icon doesn't win the cache.

## Step 4 — Verify
- Confirm the files exist in the static dir (at minimum `favicon.ico`,
  `favicon-32x32.png`, `apple-touch-icon.png`, `manifest.json`).
- Confirm the `<head>` (or layout metadata) references them.
- Report the coverage table (which sizes/variants were produced) to the user.
- If a dev server is running, the favicon may be cached — mention a hard refresh.

## Notes
- Network is required (calls `favicontools.com`). Override the endpoint with
  `--api` or the `FAVICON_API` env var (e.g. a self-hosted instance).
- The API rasterizes SVG sources server-side, so vector logos and Iconify icons
  come out crisp at every size.
- Requires `curl`, `unzip`, and either `python3` or `jq` (for JSON parsing).

## Provenance
- Generation API: `POST https://favicontools.com/api/favicons` (public, no auth).
- Icon/emoji lookup: Iconify — `https://api.iconify.design/<prefix>/<name>.svg`
  (public). Browse names at https://icon-sets.iconify.design.
- Built from the **private** source project `mewc/favicon-generator`
  (https://github.com/mewc/favicon-generator). This skill uses only the public
  website API above — it contains no private source.
