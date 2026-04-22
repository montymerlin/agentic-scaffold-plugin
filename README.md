# agentic-scaffold

Scaffold agentic best practices into any project folder. One `/init` command detects a project's stack and state, then generates a coordinated set of documentation and configuration files with `AGENTS.md` as the canonical agent instruction file, `CLAUDE.md` as a compatibility wrapper, and smart defaults adapted to what's already there.

## What It Generates

### Core files

These files are always scaffolded when missing:

| File | Audience | Purpose |
|------|----------|---------|
| README.md | Humans | Project overview, setup, usage |
| AGENTS.md | AI agents | Canonical conventions, boundaries, stack-specific instructions |
| CLAUDE.md | Claude-family agents | Thin compatibility wrapper pointing to AGENTS.md |
| DECISIONS.md | Both | Architectural decision records |
| ROADMAP.md | Both | Future directions and idea pipeline |
| CHANGELOG.md | Both | Narrative change history |

### Adaptive files

These are generated only when the environment or project setup warrants them:

| File | When generated | Purpose |
|------|---------------|---------|
| .cursorrules | Cursor users | Editor-specific conventions |
| .claude/settings.local.json | Claude Code users | Host-specific configuration |
| CONTRIBUTING.md | Team projects | Collaboration guide |

## Design Position

The core design shift is simple:

- `AGENTS.md` is canonical
- `CLAUDE.md` is a compatibility layer
- tool-specific files should point back to the same source of truth instead of duplicating it

This keeps scaffolded repos future-friendly across hosts while preserving clean Claude compatibility.

## Why This Structure

The scaffold is built around a few stable principles:

1. **Progressive disclosure** — keep root instructions compact and defer extra structure until it is earned.
2. **Dual-audience documentation** — README serves humans; AGENTS.md serves agents.
3. **Compatibility over duplication** — host-specific wrappers should point to canonical files, not fork them.
4. **Adaptive detection** — infer from the repo first, ask only what cannot be discovered.
5. **Source-grounded defaults** — template choices should trace to documented conventions rather than taste.

## Installation

### Claude Code CLI

```bash
claude plugins install github.com/montymerlin/agentic-scaffold-plugin
```

### Claude Desktop (Cowork)

Install the plugin from the marketplace or package the repo for upload:

```bash
zip -r agentic-scaffold.plugin . -x ".git/*" ".DS_Store"
```

### Codex

```bash
bash scripts/install_codex_skills.sh --from-github
```

This installs global Codex skills that point back to a vendor clone of the same repo.

### Other Hosts

Clone the repository and load the skills according to your host's skill or plugin conventions. The workflows are markdown-first and have no runtime dependencies.

## Repo Conventions

- The repo itself follows the same pattern it generates.
- `AGENTS.md` is canonical for this repo.
- `CLAUDE.md` stays intentionally thin.
- `.claude-plugin/` is Claude packaging metadata, not the canonical source of skill logic.
- `skills/` and `templates/` are the product.

## Roadmap

See [ROADMAP.md](ROADMAP.md) for future directions such as monorepo support, knowledge garden scaffolds, and scaffold auditing.

## License

MIT
