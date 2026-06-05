# skills

A public, tool-agnostic library of **agent skills** — one folder per skill, each
a self-contained `SKILL.md` plus any helper scripts. Publish once, pull into any
project or agent, anywhere.

These are designed to be **agent-first**: the agent reads the skill and does the
whole job end-to-end (look things up, generate, write files into the repo, wire
them in) instead of a human clicking a UI, downloading a zip, and shuffling files.

## Skills

| Skill | What it does |
| --- | --- |
| [`favicontools.com`](./favicontools.com) | Generate + install a complete favicon / app-icon / PWA stack (ico, all PNG sizes, apple-touch, theme-aware, env badges, manifest) from an emoji, named icon, logo file, or URL — written straight into the project. Powered by [favicontools.com](https://favicontools.com). |

## Pull it in anywhere

Each skill is a plain directory containing `SKILL.md`. To make it available to
Claude Code, drop the folder into a skills directory:

- **One project** → `<project>/.claude/skills/<name>/`
- **Every project (personal)** → `~/.claude/skills/<name>/`

### Quick install

```bash
# Install one skill globally (available in every project on this machine)
curl -fsSL https://raw.githubusercontent.com/drmrduck/skills/main/install.sh | bash -s favicontools.com

# Install into the current project only
curl -fsSL https://raw.githubusercontent.com/drmrduck/skills/main/install.sh | bash -s favicontools.com --here

# Install everything, globally
curl -fsSL https://raw.githubusercontent.com/drmrduck/skills/main/install.sh | bash -s all
```

### Or as a git submodule / clone

```bash
git clone https://github.com/drmrduck/skills ~/.drmrduck-skills
ln -s ~/.drmrduck-skills/favicontools.com ~/.claude/skills/favicontools.com
```

Restart Claude Code (or `/doctor`) and the skill is live — just ask, e.g.
*"make me a favicon of a fox"*.

## Adding a skill

1. Create `./<name>/SKILL.md` with YAML frontmatter (`name`, `description`) — the
   `description` is what triggers the skill, so make it concrete and keyword-rich.
2. Put any helper scripts in `./<name>/scripts/` and reference them by relative
   path from the skill.
3. Keep it self-contained and idempotent. Add a row to the table above.
4. **This repo is public.** Skills here may be built on top of private projects,
   but the skill itself must only depend on **public** surfaces (hosted APIs,
   open websites, public packages). Never copy source, keys, or internal
   endpoints from a private repo into a skill. List provenance below.

## Provenance

Where each skill's capability comes from, and what's public vs. private:

| Skill | Public surface it uses | Source project |
| --- | --- | --- |
| `favicontools.com` | [favicontools.com](https://favicontools.com) — public API `POST https://favicontools.com/api/favicons`; icon/emoji lookup via [Iconify](https://icon-sets.iconify.design) (`https://api.iconify.design`) | `mewc/favicon-generator` — **private** (https://github.com/mewc/favicon-generator). The skill calls only the public website API; no private source is included. |
