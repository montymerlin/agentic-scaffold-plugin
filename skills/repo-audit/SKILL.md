---
name: agentic-scaffold:repo-audit
description: >
  Audit a repo's scaffold health and security posture. Use when the user asks to
  "audit", "check scaffold", "repo audit", "check repo health", "verify reasoning
  artifacts", "check changelog", "scaffold check", "audit repo", or wants to verify
  that CHANGELOG, DECISIONS, ROADMAP, and version numbers are consistent and up to
  date. Also runs as an optional pre-step inside finishing-a-development-branch when
  this plugin is installed.
---

# repo-audit

Audit a repo's scaffold health and security posture in two sequential phases: **Artifact Audit** then **Security Scan**. Read-only except for mechanical zero-judgment fixes (version number mismatches, missing standard `.gitignore` entries, etc.) which are applied silently. Everything else surfaces as a punch list with proposed actions and waits for confirmation.

**Relation to `agentic-scaffold:init`:** `init` creates missing scaffold files. `repo-audit` checks that existing files are fresh, consistent, and secure.

> **Security reference:** Set `AGENTIC_SCAFFOLD_ROOT="${AGENTIC_SCAFFOLD_ROOT:-${CLAUDE_PLUGIN_ROOT:-${CODEX_HOME:-$HOME/.codex}/vendor_imports/repos/agentic-scaffold-plugin}}"`. Read `${AGENTIC_SCAFFOLD_ROOT}/skills/repo-audit/references/security-checklist.md` during the Security Scan phase for the full pattern lists, gitignore baseline, and OWASP LLM Top 10 reference.

## Step 1: Detect repo type

Run these checks to determine which audit subset to apply:

```bash
# Scaffold files presence
for f in AGENTS.md CLAUDE.md README.md CHANGELOG.md DECISIONS.md ROADMAP.md; do
  [ -f "$f" ] && echo "EXISTS: $f" || echo "MISSING: $f"
done

# Plugin signals
[ -f ".claude-plugin/plugin.json" ] && echo "TYPE: plugin"
[ -f "plugin.json" ] && grep -q '"version"' plugin.json && echo "TYPE: plugin"

# Versioned package signals
grep -l '"version"' package.json pyproject.toml Cargo.toml 2>/dev/null && echo "TYPE: versioned-package"

# Submodules
[ -f ".gitmodules" ] && echo "HAS: submodules"

# Dependencies
[ -f "package.json" ] && echo "HAS: package.json"
{ [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; } && echo "HAS: python-deps"

# Agent config
[ -f ".claude/settings.json" ] && echo "HAS: claude-settings"
[ -f ".claude/settings.local.json" ] && echo "HAS: claude-settings-local"
```

Classify as:
- **Plugin** — `.claude-plugin/plugin.json` or root `plugin.json` present with `version` field
- **Versioned package** — `package.json` / `pyproject.toml` / `Cargo.toml` with `version` field
- **General** — everything else

## Step 2: Artifact Audit

Reuses the same gap-analysis logic as `agentic-scaffold:init` but in report mode — no files are created.

### 2a. Scaffold files present

```bash
for f in AGENTS.md CLAUDE.md README.md CHANGELOG.md DECISIONS.md ROADMAP.md; do
  [ -f "$f" ] && echo "✅ $f" || echo "❌ $f — missing"
done
```

### 2b. Version consistency (plugin and versioned-package repos only)

```bash
# Extract version from manifests
plugin_version=$(grep -o '"version": "[^"]*"' plugin.json 2>/dev/null | grep -o '[0-9][^"]*')
marketplace_version=$(grep -o '"version": "[^"]*"' .claude-plugin/marketplace.json 2>/dev/null | grep -o '[0-9][^"]*')
pkg_version=$(grep -o '"version": "[^"]*"' package.json 2>/dev/null | grep -o '[0-9][^"]*')

# Find latest CHANGELOG entry version
changelog_version=$(grep -m1 '^## ' CHANGELOG.md 2>/dev/null | grep -oE 'v?[0-9]+\.[0-9]+\.[0-9]+' | head -1)

echo "plugin.json: ${plugin_version:-(none)}"
echo "marketplace.json: ${marketplace_version:-(none)}"
echo "package.json: ${pkg_version:-(none)}"
echo "CHANGELOG latest: ${changelog_version:-(none)}"
```

**Silent auto-fixes** — apply without asking, then note them in the report:
- Version mismatch across manifest files: bump lagging file(s) to match the leading one
- Missing standard `.gitignore` entries from the baseline list in security-checklist.md §2

If the manifest version is *ahead* of the CHANGELOG, flag it (❌ — a CHANGELOG entry is missing, not just a stale number). Do not auto-fix this.

**Principle for all auto-fixes:** mechanical + reversible + zero judgment required. If writing new content or making a call about *what* something should say, always ask first.

### 2c. CHANGELOG freshness

```bash
last_changelog_commit=$(git log -1 --format="%H" -- CHANGELOG.md 2>/dev/null)
new_commits=$(git log --oneline ${last_changelog_commit}..HEAD 2>/dev/null | wc -l | tr -d ' ')
echo "Commits since last CHANGELOG update: $new_commits"
```

If `$new_commits > 0`: ⚠️ CHANGELOG stale — suggest invoking `agentic-scaffold:logchange`.

### 2d. ROADMAP → DECISIONS consistency

```bash
# Items marked decided in ROADMAP
grep -n 'status: decided' ROADMAP.md 2>/dev/null

# Decision entries in DECISIONS
grep -oE 'Decision [0-9]+' DECISIONS.md 2>/dev/null | sort -t' ' -k2 -n
```

For each `status: decided` item in ROADMAP.md, verify a corresponding entry exists in DECISIONS.md. Flag orphans as ⚠️.

### 2e. AGENTS.md canonical sections

```bash
for section in "## Key Conventions" "## What Not To Do"; do
  grep -q "$section" AGENTS.md 2>/dev/null && echo "✅ $section" || echo "⚠️ $section — missing from AGENTS.md"
done
```

Missing canonical sections → suggest re-running `agentic-scaffold:init` to fill gaps.

## Step 3: Security Scan

Load `${AGENTIC_SCAFFOLD_ROOT}/skills/repo-audit/references/security-checklist.md` for full pattern lists. All checks here are read-only — no auto-fixes.

### 3a. Secrets scan

```bash
git ls-files | xargs grep -lE \
  "(sk-[a-zA-Z0-9]{20,}|PRIVATE KEY|password\s*=\s*['\"][^'\"]{4,}|api_key\s*=\s*['\"][^'\"]{4,}|Bearer [a-zA-Z0-9\-_]{20,}|AKIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36})" \
  2>/dev/null
```

Flag any matches with filename and line number only. **Never print the secret value.**

See security-checklist.md §1 for the full pattern list.

### 3b. Gitignore completeness

```bash
cat .gitignore 2>/dev/null || echo "NO .gitignore"
```

Compare against the baseline in security-checklist.md §2. Flag missing entries as ⚠️ — propose adding them (or auto-fix if running Step 2b auto-fix mode).

### 3c. Overly broad agent permissions

```bash
cat .claude/settings.json .claude/settings.local.json 2>/dev/null
```

Check for patterns in security-checklist.md §3 (wildcard allows, unrestricted bash, broad MCP grants). Flag as ⚠️ with explanation of risk.

### 3d. Dependency audit

```bash
# Node
[ -f "package.json" ] && npm audit --json 2>/dev/null | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print(d.get('metadata',{}).get('vulnerabilities',{}))" 2>/dev/null

# Python
command -v pip-audit >/dev/null 2>&1 && pip-audit --format json 2>/dev/null | \
  python3 -c "import sys,json; vulns=json.load(sys.stdin); print(f'{len(vulns)} vulnerable packages')" 2>/dev/null || true
```

Flag high/critical findings with CVE identifier where available.

### 3e. Sensitive files in git history

```bash
git log --all --full-history --oneline -- \
  '*.env' '*.pem' '*.key' '*.p12' '*credentials*' '*secret*' 2>/dev/null
```

Flag any results with commit hash and filename. Note that the file may no longer exist — flag for review regardless.

### 3f. Dependency pinning

```bash
# Node — flag ^ ~ * version ranges (excluding the "version" field itself)
grep -nE '"[\^~\*]' package.json 2>/dev/null | grep -v '"version"'

# Python — flag lines without == (unpinned)
grep -vE '(==|^#|^$)' requirements.txt 2>/dev/null
```

Flag unpinned deps as ⚠️ — unpinned ranges are a supply chain attack surface.

### 3g. Custom registry overrides

```bash
grep -v '^#' .npmrc 2>/dev/null | grep -i registry
grep -i 'index-url' pip.conf ~/.pip/pip.conf 2>/dev/null
grep -i registry .yarnrc .yarnrc.yml 2>/dev/null
```

Flag any non-standard registry URLs as ⚠️.

### 3h. Submodule URL verification

```bash
[ -f ".gitmodules" ] && grep -A2 '\[submodule' .gitmodules | grep url
```

Flag any submodule URLs not pointing to github.com, gitlab.com, or known internal hosts as ⚠️.

### 3i. MCP server external URLs

```bash
grep -E '"url"|"host"|"endpoint"' .claude/settings.json .claude/settings.local.json 2>/dev/null
```

Flag any MCP server configs pointing to non-localhost / non-127.0.0.1 URLs as ⚠️ — potential prompt injection surface.

## Step 4: Repo-specific audit

After completing the standard checks above, look for a repo-specific companion audit skill:

```bash
ls .agents/skills/*:repo-audit/SKILL.md 2>/dev/null
```

**If one or more local skills exist:**

1. Load and run all checks defined in each. (Multiple matches is rare but allowed — run them all.)
2. Report findings in the Step 5 report under a `## Local audit skill` subsection, using the same ✅/⚠️/❌ convention as the standard sections.
3. Evaluate whether the local skill itself is stale. Flag it (⚠️) if:
   - New tooling, scripts, hooks, plugin manifests, or sibling skills have appeared since the local skill was last touched
   - New project directories have appeared that the skill doesn't reference
   - Any of its checks are now redundant with the standard audit

```bash
for skill_path in $(ls .agents/skills/*:repo-audit/SKILL.md 2>/dev/null); do
  skill_mtime=$(git log -1 --format="%ct" -- "$skill_path" 2>/dev/null)
  [ -z "$skill_mtime" ] && continue
  infra_changes=$(git log --since="@$skill_mtime" --name-only --pretty=format: -- \
    .scripts/ .githooks/ .agents/ .claude/ .claude-plugin/ '*.plugin/skills/' 2>/dev/null \
    | sort -u | grep -c .)
  echo "Local skill: $skill_path (last touched: $(date -r "$skill_mtime" '+%Y-%m-%d' 2>/dev/null))"
  echo "Infra/script/skill changes since: $infra_changes"
done
```

**If no local skill exists:**

Offer to create one. Explain the concept: it captures repo-specific health checks the generic scaffold audit doesn't cover — frontmatter patterns, corpus link integrity, project structure conventions, custom scripts, etc.

Infer the namespace:
1. Reuse the prevailing prefix from existing `.agents/skills/*:*/` entries (e.g. `bw:`, `myproject:`).
2. If `.agents/skills/` doesn't exist or has no namespaced entries, fall back to the repo directory's basename, lowercased and hyphenated.
3. Confirm the namespace with the user before scaffolding — it's sticky.

If the user agrees, scaffold `.agents/skills/<namespace>:repo-audit/SKILL.md` with this skeleton (mirrors the placeholder style used by `agentic-scaffold:init` — gives the user something concrete to edit rather than blank sections):

````markdown
---
name: <namespace>:repo-audit
description: >
  Repo-specific audit checks that complement agentic-scaffold:repo-audit. Use when
  running a full repo audit or when explicitly invoked.
---

# <namespace>:repo-audit

Repo-specific health checks for this repo. Invoked by `agentic-scaffold:repo-audit`
after the standard scaffold and security checks complete. Can also be run standalone.

## Step 1: Corpus / content checks

<!-- Frontmatter consistency, link integrity, content structure, etc. -->

```bash
# Example: check that all markdown files in <corpus dir> have required frontmatter keys
```

## Step 2: Custom script health

<!-- Anything in .scripts/ worth validating: shellcheck, dry-run, version pinning, etc. -->

```bash
# Example
```

## Step 3: Project structure consistency

<!-- Per-project sub-directory patterns specific to this repo -->

```bash
# Example
```

## Step 4: After completing checks

If this skill was invoked by `agentic-scaffold:repo-audit`, **stop here** — the parent
audit owns the audit-log writeback and will include findings from this skill in its
report.

If running standalone, append a row to the `## Audit Log` table at the bottom of
`CHANGELOG.md` (create the section if absent) following the format defined in
`agentic-scaffold:repo-audit` Step 5.
````

## Step 5: Report

Present results as two separate punch lists (plus a `## Local audit skill` subsection if Step 4 ran a local skill). Format:

```
## Artifact Audit

✅ All six scaffold files present
✅ v0.6.0 consistent across plugin.json, marketplace.json, and CHANGELOG
⚠️  CHANGELOG stale — 3 commits since last update → run /logchange
❌  ROADMAP item "scaffold-check audit skill" marked `decided` but no matching Decision entry

## Security Scan

✅ No secrets patterns found in tracked files
✅ .gitignore covers standard sensitive patterns
⚠️  package.json has 2 unpinned dependencies (^ ranges) — supply chain risk
❌  .env found in git history (commit abc1234) — review and rotate credentials if sensitive

## Silent fixes applied
- Bumped marketplace.json version from 0.5.0 → 0.6.0 to match plugin.json
```

After presenting the report:
1. List any silent fixes already applied
2. For ⚠️ and ❌ items, ask which the user wants to address now vs note for later
3. For CHANGELOG staleness, offer to invoke `agentic-scaffold:logchange` immediately
4. After fixes are confirmed (applied, deferred, or dismissed), append a single row to the `## Audit Log` section at the bottom of `CHANGELOG.md`. This **always** runs — even if the audit was clean, even if the user dismissed every finding — because absence of a row is ambiguous (was it clean, or was the audit skipped?).

   **Skip the writeback only if** `CHANGELOG.md` doesn't exist. In that case, suggest running `agentic-scaffold:init` first and do not create `CHANGELOG.md` mid-audit.

   **If the section doesn't exist yet, create it at the bottom of the file:**

   ```markdown
   ## Audit Log

   Lightweight record of when full repo audits were run and what was fixed. Detail lives in git log.

   | Date       | Commit  | Notes                                              |
   |------------|---------|----------------------------------------------------|
   | YYYY-MM-DD | abc1234 | One-sentence summary of what was found and fixed.  |
   ```

   - **Date** comes from `$(date +%Y-%m-%d)` — don't infer from conversation context.
   - **Commit** is the short SHA of `HEAD` at audit time: `git rev-parse --short HEAD`. Lets readers run `git log <prev row commit>..<this row commit>` to see what changed between audits.
   - **Notes** is one sentence covering both standard and local-skill findings combined. If clean, write something like "Clean audit, no issues found."
   - Running the audit twice in one day produces two rows — don't dedupe by date. Each run is a discrete event.
   - New rows can go most-recent-first (top) or appended (bottom) — either is fine as long as the log grows over time. Match whichever direction the existing table uses.
   - **Ownership when a local sub-skill is invoked:** the parent audit (this skill) owns the writeback. Do not let the local skill add its own row in the same run.

**Do not write any fixes until the user approves** — except the silent auto-fix category defined in Step 2b.
