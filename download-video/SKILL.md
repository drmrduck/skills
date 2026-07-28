---
name: download-video
description: >-
  Download a video (or list its direct MP4 URLs) from a Twitter/X, TikTok,
  Instagram, or YouTube post — no login, no watermark, up to 1080p. Give it a
  post/tweet/reel/short URL and it returns direct CDN download links for every
  quality variant, plus author, caption, thumbnail and metadata, and can save
  the file straight to disk. Use whenever a user says "download this video",
  "grab this tweet video", "save this TikTok / Reel / Short", "get the MP4",
  "download without watermark", "rip this video", or pastes a social post link
  and wants the media. Powered by the public drummerduck downloader API — works
  as a one-line script, a plain REST call, or an MCP server.
---

# Download Video (agent-first)

Turn a social post URL into a downloadable video. The whole flow is one hosted
API call — **no browser, no login, no watermark, no yt-dlp install**. It returns
direct CDN MP4 URLs for every quality (up to 1080p) plus author/caption/metadata,
and can stream the file straight to disk.

## When to use
- User pastes a **Twitter/X, TikTok, Instagram, or YouTube** post link and wants
  the video, the MP4 URL, a GIF, or the images.
- User says "download / save / grab / rip this video", "get the highest quality",
  "download without watermark", or "just give me the direct link".
- An agent needs a video file (or its CDN URL) to feed into another step.

## How it works (routing)
There is **one host per platform**, and each host serves only its own platform.
The helper script detects the platform from the URL and routes automatically —
you normally don't pick the host yourself:

| Platform | Host |
| --- | --- |
| Twitter / X | `https://download-twitter-video.drummerduck.com` |
| TikTok | `https://download-tktk-video.drummerduck.com` |
| Instagram | `https://download-instagram-video.drummerduck.com` |
| YouTube | `https://download-youtube-video.drummerduck.com` |

Sending a TikTok link to the Twitter host returns `INVALID_URL` — always match
the link to its platform host (the script does this for you).

## Step 1 — The fast path (script)

```bash
scripts/dl.sh <post-url> [options]
```

- `scripts/dl.sh <url>` — download the **best-quality MP4** into the current dir,
  using the server-provided filename (`<handle>-<id>-<quality>.mp4`).
- `--info` — print compact metadata + the list of available qualities (run this
  first if the user wants a specific resolution — labels differ per post).
- `--json` — print the full result JSON (every media item and variant URL).
- `--quality 720p` — pick a specific variant label (falls back to best if that
  label isn't offered for this post).
- `--n 2` — pick the Nth media item in a multi-photo/video post.
- `--out ./clips/` (a dir) or `--out ./clip.mp4` (a file) — where to save.
- `--key <KEY>` (or `DXV_API_KEY` env) — API key for higher limits (see Limits).
- `--host http://localhost:3000` — hit a specific deployment; skips routing.

Examples:
```bash
# Best quality, into ./
scripts/dl.sh "https://x.com/SpaceX/status/1732824684683784516"

# See what's available first, then grab 720p into a folder
scripts/dl.sh "https://www.tiktok.com/@user/video/1234567890" --info
scripts/dl.sh "https://www.tiktok.com/@user/video/1234567890" --quality 720p --out ./clips/

# Just the direct MP4 URLs, no download (pipe to jq etc.)
scripts/dl.sh "https://www.instagram.com/reel/Cxyz/" --json
```

The script needs only `curl`. `jq` or `python3`, if present, make `--json`/`--info`
output pretty and handle URL-encoding — but it degrades gracefully without them.

## Step 2 — Or call the API directly

No script needed — it's a plain HTTP API. Two endpoints per host:

**`GET|POST /api/extract`** → JSON metadata + all variant URLs (you download the
CDN URL yourself, or hand it to the user):
```bash
curl "https://download-twitter-video.drummerduck.com/api/extract?url=<POST_URL>"
# POST form:
curl -X POST -H "content-type: application/json" \
  -d '{"url":"<POST_URL>"}' \
  https://download-twitter-video.drummerduck.com/api/extract
```
Response: `{ "ok": true, "data": { source, id, url, author{name,handle,avatar},
text, createdAt, thumbnail, engine, media: [ { type, poster, durationMs, width,
height, variants: [ { quality, width, height, bitrate, container, mimeType, url,
size } ] } ] } }`. Variants are sorted best-first; `url` is a direct CDN link.

**`GET /api/download`** → streams the actual file as an attachment (this is what
`dl.sh` uses). Params: `url` (required), `quality` (optional label), `n`
(optional media index):
```bash
curl -OJ "https://download-tktk-video.drummerduck.com/api/download?url=<POST_URL>&quality=720p"
```

Errors come back as `{ "ok": false, "error": { "code", "message" } }` —
`INVALID_URL` (wrong platform or unparseable), `NO_MEDIA` (post has no video),
`RATE_LIMITED` (see below), `BLOCKED`, `UPSTREAM_ERROR`, `INTERNAL`.

## Step 3 — Or wire it as an MCP server

Each host also exposes a streamable-HTTP MCP server at `/api/mcp`. Add the one(s)
you need:
```json
{
  "mcpServers": {
    "twitter-video":  { "type": "http", "url": "https://download-twitter-video.drummerduck.com/api/mcp" },
    "tiktok-video":   { "type": "http", "url": "https://download-tktk-video.drummerduck.com/api/mcp" },
    "instagram-video":{ "type": "http", "url": "https://download-instagram-video.drummerduck.com/api/mcp" },
    "youtube-video":  { "type": "http", "url": "https://download-youtube-video.drummerduck.com/api/mcp" }
  }
}
```
Tools (named per platform): `extract_<platform>_video` (full media + URLs),
`get_<platform>_info` (metadata only), and `get_free_api_key` (mint a key).

## Limits & API keys
- **Anonymous:** ~30 requests/hour per IP.
- **Free key:** ~300/hour, 2000/day. Mint one (no signup) and reuse it:
  ```bash
  curl -X POST -H "content-type: application/json" -d '{"label":"my-bot"}' \
    https://download-twitter-video.drummerduck.com/api/keys
  ```
  Save the returned key (shown once) and send it as `Authorization: Bearer <KEY>`
  (or `X-API-Key: <KEY>`), or export `DXV_API_KEY` for the script. `GET /api/keys`
  is self-documenting and, with a key, reports that key's tier/limits.
- Rate-limit state is on `x-ratelimit-limit` / `x-ratelimit-remaining` /
  `x-ratelimit-reset` response headers; a `RATE_LIMITED` error includes
  `retry-after`.

## Verify
- Confirm the saved file exists and is non-trivial in size, or that the printed
  variant URLs resolve.
- If the user wanted a specific resolution, check `--info` first — available
  quality labels (e.g. `1080p`, `720p`, `360p`) vary per post; an unavailable
  label silently falls back to best.
- Report which platform host was used and the quality actually downloaded.

## Provenance
- Public hosted API — no auth required to extract:
  - `GET|POST /api/extract`, `GET /api/download`, `POST /api/keys`, MCP at
    `/api/mcp` — on the four `download-*-video.drummerduck.com` hosts above.
- Built from the private source project `mewc/download-x-video` (the Next.js app
  behind these hosts). This skill calls **only** the public website API — it
  contains no private source, keys, or internal endpoints.
