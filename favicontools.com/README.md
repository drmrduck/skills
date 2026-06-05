# favicontools.com

> Agent-first favicon generation. Turn an emoji, a named icon, a logo file, or an
> image URL into a complete, production-ready favicon stack — and have it
> installed straight into your project. No clicking, no zip, no manual unzip.

**Website:** https://favicontools.com · **API:** `POST https://favicontools.com/api/favicons`

This directory is a [skill](./SKILL.md) wrapping [favicontools.com](https://favicontools.com)
so AI coding agents (Claude Code, Cursor, Windsurf, …) can generate and install
favicons autonomously. Install it with:

```bash
npx skills add drmrduck/skills          # via the skills CLI
# or
curl -fsSL https://raw.githubusercontent.com/drmrduck/skills/main/install.sh | bash -s favicontools.com
```

## What favicontools.com does

favicontools.com generates a **complete favicon package** from a single source
image and gives you a one-click install snippet. It produces every asset a modern
site needs across browsers, iOS/Android home screens, and PWAs:

- `favicon.ico` (multi-resolution) + `favicon.png`
- PNG favicons at **16, 32, 48, 96** px
- `apple-touch-icon.png` (180px) and the full Apple icon set (57–180px)
- `android-icon-192x192.png` + `ms-icon-144x144.png`
- **Theme-aware** light/dark 16×16 favicons
- **Environment badges** — dev/staging variants so you can tell prod from preview
  tabs at a glance
- `manifest.json` (PWA web app manifest) wired to the generated icons

You feed it any image; it rasterizes vectors (SVG) server-side, so logos and
icons come out crisp at every size.

## What this skill adds (agent-first)

The website is a one-click UI. This skill makes the **same engine** fully
autonomous for an agent — it removes the human-in-the-loop entirely:

| Manual (website) | This skill (agent) |
| --- | --- |
| Find/prepare a source image | Agent resolves intent → file, URL, or an [Iconify](https://icon-sets.iconify.design) name (`noto:fox`, `simple-icons:react`) |
| Click generate, download a zip | Agent calls the API and gets the package back directly |
| Move the zip, unzip it | Files are written straight into the project's static dir |
| Copy/paste the `<head>` tags | Agent installs the tags into the framework's layout |

So instead of *"go to favicontools.com, pick an emoji, download, unzip, move the
files, add the tags"*, you just say **"make me a favicon of a fox"** and the agent
does all of it.

See [`SKILL.md`](./SKILL.md) for the exact agent instructions and
[`scripts/favicon-gen.sh`](./scripts/favicon-gen.sh) for the one-shot generator.

## Requirements

- Network access (calls `favicontools.com` and `api.iconify.design`)
- `curl`, `unzip`, and either `python3` or `jq`

## Provenance

- **Public surfaces used:** favicontools.com API (no auth) and Iconify
  (`https://api.iconify.design`) for icon/emoji lookup.
- **Source project:** `mewc/favicon-generator` — **private**
  (https://github.com/mewc/favicon-generator). This skill depends only on the
  public website API and ships no private source.
