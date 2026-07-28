#!/usr/bin/env bash
#
# dl.sh — download a social video (or list its variants) via the public
# drummerduck downloader API. Detects the platform from the URL and routes to
# the correct host. No login, no watermark; returns direct CDN MP4 URLs.
#
# Usage:
#   dl.sh <post-url> [options]
#
# Options:
#   --json              Print the full ExtractResult JSON (all media + variants) and exit.
#   --info              Print compact metadata (author, text, media types/qualities) and exit.
#   --quality <label>   Pick a specific variant, e.g. 720p, 480p (default: highest mp4).
#   --n <index>         Pick the Nth media item in a multi-photo/video post (default: best video).
#   --out <path>        Output file, or directory to save into (default: current dir, server filename).
#   --key <KEY>         API key for higher rate limits (or set DXV_API_KEY). 30/hr anon → 300/hr keyed.
#   --host <base-url>   Override the API base (e.g. http://localhost:3000). Skips platform routing.
#   -h, --help          Show this help.
#
# Supported platforms: Twitter/X, TikTok, Instagram, YouTube.
# Requires: curl. JSON output is prettier with jq or python3 present (optional).
set -euo pipefail

usage() { sed -n '2,26p' "$0" | sed 's/^# \{0,1\}//'; }

URL=""; MODE="download"; QUALITY=""; N=""; OUT=""; KEY="${DXV_API_KEY:-}"; HOST_OVERRIDE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --json)    MODE="json";  shift ;;
    --info)    MODE="info";  shift ;;
    --quality) QUALITY="${2:-}"; shift 2 ;;
    --n)       N="${2:-}";       shift 2 ;;
    --out)     OUT="${2:-}";     shift 2 ;;
    --key)     KEY="${2:-}";     shift 2 ;;
    --host)    HOST_OVERRIDE="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    -*)        echo "unknown option: $1" >&2; exit 1 ;;
    *)         URL="$1"; shift ;;
  esac
done

[ -n "$URL" ] || { echo "error: pass a post URL. See --help." >&2; exit 1; }

# --- Route the URL to the right platform host --------------------------------
# Each host serves ONLY its own platform, so a Twitter link must go to the
# Twitter host, etc. Override with --host to hit a single deployment directly.
host_for() {
  local u; u="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  case "$u" in
    *twitter.com*|*//x.com*|*.x.com*|*t.co/*) echo "https://download-twitter-video.drummerduck.com" ;;
    *tiktok.com*)                             echo "https://download-tktk-video.drummerduck.com" ;;
    *instagram.com*)                          echo "https://download-instagram-video.drummerduck.com" ;;
    *youtube.com*|*youtu.be*)                 echo "https://download-youtube-video.drummerduck.com" ;;
    *) echo "" ;;
  esac
}

if [ -n "$HOST_OVERRIDE" ]; then
  BASE="${HOST_OVERRIDE%/}"
else
  BASE="$(host_for "$URL")"
  [ -n "$BASE" ] || { echo "error: unsupported URL — expected a Twitter/X, TikTok, Instagram, or YouTube post." >&2; exit 1; }
fi

AUTH=()
[ -n "$KEY" ] && AUTH=(-H "Authorization: Bearer $KEY")

# Pretty-print JSON if a parser is available; otherwise pass through raw.
pretty() {
  if command -v jq >/dev/null 2>&1; then jq .
  elif command -v python3 >/dev/null 2>&1; then python3 -m json.tool
  else cat; fi
}

enc() {  # URL-encode the post URL for the query string
  if command -v jq >/dev/null 2>&1; then printf '%s' "$1" | jq -sRr @uri
  elif command -v python3 >/dev/null 2>&1; then python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1],safe=""))' "$1"
  else printf '%s' "$1"; fi
}
EU="$(enc "$URL")"

case "$MODE" in
  json)
    curl -fsS --max-time 60 ${AUTH[@]+"${AUTH[@]}"} "$BASE/api/extract?url=$EU" | pretty
    ;;
  info)
    # Extract, then trim to metadata + a per-media quality list.
    RESP="$(curl -fsS --max-time 60 ${AUTH[@]+"${AUTH[@]}"} "$BASE/api/extract?url=$EU")"
    if command -v jq >/dev/null 2>&1; then
      echo "$RESP" | jq '{source:.data.source, url:.data.url, author:.data.author,
        text:.data.text, createdAt:.data.createdAt, thumbnail:.data.thumbnail,
        media:[.data.media[]? | {type, durationMs, width, height,
          qualities:[.variants[]? | select(.container!="m3u8") | .quality]}]}
        // .'
    else
      echo "$RESP" | pretty
    fi
    ;;
  download)
    q=""; [ -n "$QUALITY" ] && q="&quality=$(enc "$QUALITY")"
    [ -n "$N" ] && q="$q&n=$N"
    DL="$BASE/api/download?url=$EU$q"
    if [ -n "$OUT" ] && [ ! -d "$OUT" ]; then
      # Explicit output file path.
      curl -fL --max-time 300 ${AUTH[@]+"${AUTH[@]}"} -o "$OUT" "$DL"
      echo "saved: $OUT" >&2
    else
      # Save into a directory (or cwd) using the server-provided filename.
      dir="${OUT:-.}"
      ( cd "$dir" && curl -fL --max-time 300 ${AUTH[@]+"${AUTH[@]}"} -OJ "$DL" )
      echo "saved into: ${dir%/}/" >&2
    fi
    ;;
esac
