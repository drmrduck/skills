---
name: ogimage
description: >-
  Generate social preview images that do not look broken: a dynamic og:image route that renders a branded 1200x630 card for every page, plus correct og:/twitter: meta tags. Use when a user wants OG images, social/link previews, Twitter cards, or their links unfurl badly in Slack/iMessage/X.
---

# OG Image Generator

Give every page a sharp, branded social card and the tags to point at it.

## Steps
1. **Detect the stack.** Next App Router → an `opengraph-image.tsx` (or an
   `app/api/og/route.tsx` using `next/og` `ImageResponse`) that reads the page
   title/description. Other frameworks → a serverless image route or a
   build-time generator.
2. **Design one card** from the site brand (title, a subtle accent glow, the
   domain). Keep it 1200×630 and legible at thumbnail size.
3. **Wire the tags per route**: `og:title`, `og:description`, `og:image`
   (absolute URL), `og:image:width/height`, and `twitter:card=summary_large_image`.
   In Next, set these in each route`s `metadata`.
4. **Backfill** any pages missing tags.

## Verify
- The og:image URL returns an image and 200s.
- Paste a page URL into a link-preview checker (or
  https://ogimage.tools.drummerduck.com) and confirm each platform unfurls.
