# SETUP.md — agentic-scaffold

Scaffold agentic best practices (AGENTS.md, CLAUDE.md, DECISIONS.md, ROADMAP.md, CHANGELOG.md) into any project folder with three composable skills: init, logchange, repo-audit.

---

## Quick Install (for AI agents)

If you're an AI agent installing this plugin, **detect the host first**, then pick the matching path. Only ask the user the questions explicitly listed below.

```
1. Detect host:
   ├── Cowork (Claude Desktop, sandboxed)
   │     → Path A: Cowork upload (no questions needed)
   │
   ├── Claude Code CLI (terminal, has `claude` command)
   │     → Path B: claude plugins install
   │     → ASK USER: "Install globally (every project) or locally (this project)?"
   │       • global → `claude plugins install github.com/montymerlin/agentic-scaffold-plugin`
   │       • local  → symlink `ln -s <path> ./.claude/plugins/agentic-scaffold`
   │
   ├── Codex (terminal, has `codex` command or $CODEX_HOME set)
   │     → Path C: bash scripts/install_codex_skills.sh --from-github
   │
   ├── Cursor / VS Code
   │     → NOT COMPATIBLE (no skill UI). Suggest Claude Code instead.
   │
   └── Unknown / custom Agent SDK host
         → Path D: Raw skills — copy `skills/*/SKILL.md` into the host's skill dir.
```

**Host detection signals:**
- `$CLAUDE_COWORK == "1"` or `mount | grep virtiofs` matches → Cowork
- `command -v claude` succeeds and not Cowork → Claude Code CLI
- `command -v codex` succeeds or `$CODEX_HOME` is set → Codex
- Otherwise → ask the user which environment they're in.

---

## Compatibility Matrix

| Host | Status | Notes |
|------|--------|-------|
| **Cowork** | ✓ | Upload `.plugin` file from `ops/plugins/_dist/`; skills appear in `/` menu |
| **Claude Code CLI** | ✓ | `claude plugins install github.com/montymerlin/agentic-scaffold-plugin` |
| **Codex** | ✓ | `bash scripts/install_codex_skills.sh --from-github` |
| **Cursor / VS Code** | ✗ | No skill support; MCP-only hosts cannot invoke Claude plugins |
| **Agent SDK** | ✓ | Standard plugin loader (custom host integration) |
| **Anthropic API direct** | partial | Manual tool wiring from `skills/` directory |

## Installation by Host

### Cowork (Claude Desktop App)

You need a `.plugin` zip to upload. Get one of these three ways:

**Option 1 — pre-built release (preferred when available):**
Download `agentic-scaffold-<version>.plugin` from the GitHub Releases page of `montymerlin/agentic-scaffold-plugin`.

**Option 2 — built locally from this repo:**

```bash
git clone https://github.com/montymerlin/agentic-scaffold-plugin.git
cd agentic-scaffold-plugin
zip -r /tmp/agentic-scaffold-0.6.0.plugin . \
  -x "*.DS_Store" "*/__pycache__/*" "*.pyc" ".git/*" "node_modules/*" "*.log" "_dist/*"
```

The output `/tmp/agentic-scaffold-0.6.0.plugin` is your upload artifact.

**Option 3 — built by the workspace `cowork-plugin-packager` skill** (montymerlinHQ collaborators only):
The packaged file lives at `ops/plugins/_dist/agentic-scaffold-0.6.0.plugin` after running the skill.

Then upload:

1. Open Claude Desktop → **Cowork** → **Plugins** sidebar.
2. Click **+ Add plugin** → **Upload a file** → select the `.plugin`.
3. Confirm install. Skills load under `/init`, `/logchange`, `/repo-audit`.

**Pre-upload verification (recommended):**

```bash
# Confirm the manifest is at the zip root
unzip -l /tmp/agentic-scaffold-0.6.0.plugin | head -20

# Confirm size is under 50 MB
du -h /tmp/agentic-scaffold-0.6.0.plugin
```

**Known quirks**:
- File size limit: 50 MB. (agentic-scaffold packages to ~60 KB.)
- Some Claude Desktop builds reject `.plugin` extension. Workaround: rename to `.zip` (contents identical). See [anthropics/claude-code#28337](https://github.com/anthropics/claude-code/issues/28337) and [#40414](https://github.com/anthropics/claude-code/issues/40414).
- The `.plugin` zip must have `.claude-plugin/plugin.json` at the top level (not nested inside an extra parent directory). The `zip` command above runs from inside the plugin dir specifically to avoid this.

### Claude Code CLI

Two install scopes — **ask the user which one fits**:

- **Global** (every project on this machine): `claude plugins install github.com/montymerlin/agentic-scaffold-plugin`
- **Local** (this project only, lives in `./.claude/plugins/`): symlink the cloned repo

**Global install:**

```bash
claude plugins install github.com/montymerlin/agentic-scaffold-plugin
```

**Local install** (project-scoped):

```bash
git clone https://github.com/montymerlin/agentic-scaffold-plugin.git ~/src/agentic-scaffold-plugin
mkdir -p ./.claude/plugins
ln -s ~/src/agentic-scaffold-plugin ./.claude/plugins/agentic-scaffold
```

Skills are invoked via slash commands (`/init`, `/logchange`, `/repo-audit`) or natural language.

### Codex

Codex doesn't read `.claude-plugin/`. Use the global install script:

```bash
bash scripts/install_codex_skills.sh --from-github
```

This writes skill stubs to `~/.codex/skills/agentic-scaffold-<skill>/` that source from a vendor clone at `${CODEX_HOME:-$HOME/.codex}/vendor_imports/repos/agentic-scaffold-plugin/`.

### Agent SDK (Custom Hosts)

Load the plugin using your host's standard plugin loader. The plugin exposes skills via the `.claude-plugin/plugin.json` manifest.

### Anthropic API Direct

Copy skill files from `skills/` into your system prompt or tool definitions:
- `skills/init/SKILL.md` — scaffolding logic
- `skills/logchange/SKILL.md` — changelog maintenance
- `skills/repo-audit/SKILL.md` — health and security audits

Reference `skills/<skill>/references/` for supporting templates and guidance.

## Runtime Requirements

- **No external dependencies**. All templates and workflows are markdown-first.
- **Git optional**. The plugin detects git repos and uses commit history when available; works in non-git directories.
- **Detected stacks**: JavaScript/TypeScript, Python, Rust, Go, Ruby, Java/Kotlin, and generic projects.

## What Gets Installed Where

**Cowork and Claude Code**:
- Skills appear in the `/` command menu.
- No MCP servers (this plugin is skill-only).
- Files generated by `/init` are written to your project folder.

**Codex**:
- Global skills installed to `~/.codex/skills/`.
- Vendor repo cloned to `${CODEX_HOME:-$HOME/.codex}/vendor_imports/repos/agentic-scaffold-plugin/`.

**Agent SDK / API Direct**:
- Skill logic lives in `skills/` and must be integrated according to your host's requirements.

## Known Quirks

1. **Cowork upload size**: 50 MB limit. This plugin typically ships under 5 MB.
2. **Extension handling**: If `.plugin` upload fails, rename to `.zip` before uploading.
3. **Git detection**: Non-git projects won't have commit history; `/logchange` will ask what changed instead.
4. **Template paths**: Skills resolve template and reference paths from `AGENTIC_SCAFFOLD_ROOT` (set by the plugin runtime). If you symlink the plugin, ensure this variable points to the canonical location.

## Verification

After install, verify the plugin loaded:

**Cowork**: Type `/` and look for `/init`, `/logchange`, `/repo-audit`.

**Claude Code CLI**:
```bash
claude plugins ls | grep agentic-scaffold
```

**Codex**:
```bash
ls ~/.codex/skills/ | grep agentic-scaffold
```

## Further Reading

- [install-pathways.md](https://github.com/montymerlin/montymerlinHQ/blob/main/.agents/skills/cowork-plugin-packager/references/install-pathways.md) — canonical host compatibility reference
- [AGENTS.md](./AGENTS.md) — canonical repo instructions
- [README.md](./README.md) — high-level overview for humans
