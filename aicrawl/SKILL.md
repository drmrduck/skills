---
name: aicrawl
description: >-
  Make a site legible to AI crawlers: generate a spec-compliant llms.txt (and llms-full.txt), correct robots.txt rules for GPTBot/ClaudeBot/PerplexityBot/Google-Extended, and a wired sitemap route — from the project's real routes and content. Use when a user asks about llms.txt, AI crawlability, GEO, robots for AI bots, or a sitemap.
---

# AI Crawlability

Write the files that let AI models read and cite the site correctly. Everything
lands in the repo — nothing to copy-paste.

## Steps
1. **Map the site.** Read the routes (Next `app/`/`pages/`, Astro/SvelteKit
   pages, or the sitemap if one exists) and the top-level content. Note the real
   sections a model should know about (docs, product, blog, pricing).
2. **Write `llms.txt`** at the web root (`public/llms.txt` for most frameworks):
   an `# H1` site name, a one-line `> summary`, then `## Section` lists of the
   best links with a short gloss each. Add `llms-full.txt` with the expanded copy
   when the content is small enough to inline.
3. **robots.txt** — allow the AI bots the user wants (GPTBot, ClaudeBot,
   PerplexityBot, Google-Extended, CCBot), block the rest, and declare
   `Sitemap:`. Prefer a generated route over a static file so it cannot rot.
4. **Sitemap** — wire a real sitemap route (Next `app/sitemap.ts`, etc.) from the
   routes, not a hand-maintained XML file.

## Verify
- `llms.txt`, `robots.txt` and a sitemap all resolve at the root.
- robots names the AI user-agents explicitly and declares the sitemap.
- Try it live in the browser first: https://aicrawl.tools.drummerduck.com
