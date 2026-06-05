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
| [`favicon`](./favicon) | Generate + install a complete favicon / app-icon / PWA stack (ico, all PNG sizes, apple-touch, theme-aware, env badges, manifest) from an emoji, named icon, logo file, or URL — written straight into the project. Powered by [favicontools.com](https://favicontools.com). |

## Pull it in anywhere

Each skill is a plain directory containing `SKILL.md`. To make it available to
Claude Code, drop the folder into a skills directory:

- **One project** → `<project>/.claude/skills/<name>/`
- **Every project (personal)** → `~/.claude/skills/<name>/`

### Quick install

```bash
# Install one skill globally (available in every project on this machine)
curl -fsSL https://raw.githubusercontent.com/DrummerDuck/skills/main/install.sh | bash -s favicon

# Install into the current project only
curl -fsSL https://raw.githubusercontent.com/DrummerDuck/skills/main/install.sh | bash -s favicon --here

# Install everything, globally
curl -fsSL https://raw.githubusercontent.com/DrummerDuck/skills/main/install.sh | bash -s all
```

### Or as a git submodule / clone

```bash
git clone https://github.com/DrummerDuck/skills ~/.drummerduck-skills
ln -s ~/.drummerduck-skills/favicon ~/.claude/skills/favicon
```

Restart Claude Code (or `/doctor`) and the skill is live — just ask, e.g.
*"make me a favicon of a fox"*.

## Adding a skill

1. Create `./<name>/SKILL.md` with YAML frontmatter (`name`, `description`) — the
   `description` is what triggers the skill, so make it concrete and keyword-rich.
2. Put any helper scripts in `./<name>/scripts/` and reference them by relative
   path from the skill.
3. Keep it self-contained and idempotent. Add a row to the table above.
