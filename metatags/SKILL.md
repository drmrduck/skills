---
name: metatags
description: >-
  Fill in the whole <head> correctly, per route: title, meta description, canonical, Open Graph, Twitter, and valid JSON-LD schema — audited and patched in place. Use when a user wants a meta-tag audit, structured data / schema markup, JSON-LD, canonical tags, or SEO head fixes.
---

# Meta Tags & Schema

Audit every route`s `<head>` and patch what is missing or wrong.

## Steps
1. **Crawl the routes** and record, per page: title (10–65 chars), meta
   description (50–160), canonical URL, OG trio (title/description/image),
   `twitter:card`, `<html lang>`, and a responsive `viewport`.
2. **Flag** every missing/duplicate/oversized field.
3. **Patch in place** — write correct framework metadata (Next `metadata`
   objects, `<svelte:head>`, Astro frontmatter). No per-page copy-paste.
4. **Add JSON-LD** that matches what each page *is* (Article, Product,
   Organization, FAQ, Breadcrumb). Ensure it parses and passes Rich Results.

## Verify
- No page is missing a title, description or canonical.
- JSON-LD is valid JSON and the right @type.
- Cross-check with https://metatags.tools.drummerduck.com
