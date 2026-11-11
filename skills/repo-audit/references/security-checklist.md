# Security Checklist

Reference patterns for the `agentic-scaffold:repo-audit` security scan (checks 9 to 12). They are suggestions: prefer the repo's own scanner where it has one. Update this file to expand the scan without touching `SKILL.md`.

---

## §1 — Secrets patterns

Grep these patterns against all tracked files (`git ls-files`):

| Pattern | What it catches |
|---|---|
| `sk-[a-zA-Z0-9]{20,}` | OpenAI / Anthropic API keys |
| `PRIVATE KEY` | PEM private key header |
| `-----BEGIN (RSA\|EC\|DSA) PRIVATE KEY-----` | Explicit PEM private key headers |
| `password\s*=\s*['"][^'"]{4,}` | Hardcoded passwords |
| `api_key\s*=\s*['"][^'"]{4,}` | Hardcoded API keys |
| `Bearer [a-zA-Z0-9\-_]{20,}` | Hardcoded auth tokens |
| `AKIA[0-9A-Z]{16}` | AWS access key IDs |
| `ghp_[a-zA-Z0-9]{36}` | GitHub personal access tokens |
| `xox[baprs]-[0-9a-zA-Z]{10,}` | Slack tokens |
| `AIza[0-9A-Za-z\-_]{35}` | Google API keys |

**Never print the secret value.** Report: pattern matched, filename, line number only.

---

## §2 — .gitignore baseline

A starting list, not a requirement. Judge `.gitignore` against what the repo actually produces and holds (check 10), and propose additions for the user to approve; never add them silently. Some entries, such as `build/` or `dist/`, would hide real folders in a repo that uses those names for content.

```
.env
.env.*
!.env.example
*.pem
*.key
*.p12
*.pfx
credentials*
*_credentials*
secrets/
.secrets/
.notion-sync/
.DS_Store
node_modules/
__pycache__/
*.pyc
.venv/
venv/
dist/
build/
*.log
```

Note: do not flag `.env.example` — example files are intentionally tracked.

---

## §3 — Overly broad agent permissions

Flag permission grants matching these patterns in `.claude/settings.json` or `settings.local.json`:

| Pattern | Risk |
|---|---|
| `"allow": ["*"]` or `"allow": ".*"` | All tools allowed — no guardrails |
| bash allow with no path restriction | Unrestricted shell access |
| `"allowedCommands": ["*"]` | All commands allowed |
| MCP tool `allow: true` with no scope restriction | All MCP tools whitelisted |

Report: file, key path, pattern matched, suggested tighter scope.

---

## §4 — OWASP LLM Top 10 reference (v1.1)

For context when evaluating prompt injection and other LLM-specific risks:

| Risk | Relevance to repo audit |
|---|---|
| **LLM01 — Prompt injection** | External MCP server URLs (check 12); AGENTS.md / CLAUDE.md files sourced from untrusted locations |
| **LLM02 — Insecure output handling** | Agent-generated code written to files without a human review gate |
| **LLM06 — Sensitive info disclosure** | Hardcoded secrets in tracked files (check 9); overly broad tool grants (check 11) |
| **LLM08 — Excessive agency** | Wildcard agent permissions (check 11); unrestricted bash allows |
| **LLM09 — Overreliance** | No review gate before agent commits or pushes; `finishing-a-development-branch` skipped |

Full reference: https://owasp.org/www-project-top-10-for-large-language-model-applications/

---

## §5 — Supply chain: live threat intelligence (ROADMAP)

The static security checks cover structural supply chain risks. A future evolution:

- Scheduled agent queries OSV / NVD for installed package CVEs
- Cross-references configured tools and services against recent breach reports
- Surfaces: "You're using X and X was compromised last week"

This requires network access and periodic re-running. Out of scope for v1 static audit. Tracked as ROADMAP idea: **Live dependency threat intelligence**.
