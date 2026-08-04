---
name: legalpages
description: >-
  Generate a tailored privacy policy, terms of service and a cookie-consent banner that match what the app actually does — as real, editable pages in the repo. Use when a user needs a privacy policy, terms of service, GDPR/cookie banner, or legal pages. Not legal advice — a strong starting draft.
---

# Legal Pages

Draft privacy/terms that fit the app, as pages the user can keep editing.

## Steps
1. **Learn what the app collects.** Read the code for analytics, auth, payments,
   cookies, third-party SDKs, and stored user data.
2. **Draft `/privacy`** with clauses that match that reality (what is collected,
   why, sharing/processors, retention, user rights, contact) — not generic
   filler.
3. **Draft `/terms`** (acceptable use, accounts, liability, changes, governing
   law placeholder).
4. **Add a cookie-consent component** wired to the analytics you found, only if
   cookies/trackers are actually present.
5. Land them as normal routes in the repo, styled to match the site.

## Notes
- This is a tailored draft, **not legal advice** — tell the user to have counsel
  review before relying on it.
