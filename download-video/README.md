# download-video

Download a video — or get its direct MP4 URLs — from a **Twitter/X, TikTok,
Instagram, or YouTube** post. No login, no watermark, up to 1080p. Paste a link;
get the file (or every quality's CDN URL, plus author/caption/metadata).

Powered by the public drummerduck downloader API. Works three ways:

- **Script** — `scripts/dl.sh <url>` saves the best MP4 to disk (auto-routes by platform).
- **REST** — `GET|POST /api/extract` for URLs + metadata, `GET /api/download` to stream the file.
- **MCP** — a streamable-HTTP server per platform at `/api/mcp`.

See [`SKILL.md`](./SKILL.md) for the full contract, endpoints, quality/`--info`
options, rate limits, and how to mint a free API key.

## Quick try

```bash
# best quality into the current dir
scripts/dl.sh "https://x.com/SpaceX/status/1732824684683784516"

# list available qualities + metadata first
scripts/dl.sh "https://www.tiktok.com/@user/video/1234567890" --info
```

Needs `curl`; `jq`/`python3` optional (prettier JSON + encoding).

## Install

```bash
npx skills add https://github.com/drmrduck/skills --skill download-video
# or
curl -fsSL https://raw.githubusercontent.com/drmrduck/skills/main/install.sh | bash -s download-video
```
