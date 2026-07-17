# Codex Installer Repair Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Status:** Complete (2026-07-17)

**Goal:** Make the Codex installer expose every valid agentic-scaffold skill, repair broken links safely with `--force`, and document the correct Codex invocation model.

**Architecture:** Keep the existing symlink installer and its local/GitHub source modes, but replace the duplicated two-skill inventory with deterministic discovery of immediate `skills/*/SKILL.md` directories. A zero-dependency Bash integration test exercises the installer against temporary Codex homes before the live links are repaired from the current checkout.

**Tech Stack:** Bash 3.2-compatible shell, filesystem symlinks, Markdown documentation, Git.

## Global Constraints

- Keep the plugin zero-dependency.
- Continue installing under `${CODEX_HOME:-$HOME/.codex}/skills` for this focused repair.
- Keep bare skill `name:` frontmatter for Claude plugin namespacing compatibility.
- Install only immediate `skills/<name>/` directories containing a regular `SKILL.md`.
- Do not add native `.codex-plugin/` packaging or migrate other HQ plugin installers.
- Do not push any commit without separate user approval.

## File Structure

- Create `tests/test_install_codex_skills.sh`: end-to-end installer regression test using isolated temporary homes.
- Modify `scripts/install_codex_skills.sh`: validate the source tree, discover all valid skills, install them in lexical order, and report installed names and roots.
- Modify `AGENTS.md`: correct the current version and canonical five-skill/test structure.
- Modify `SETUP.md`: list all five skills and distinguish Codex `$skill` invocation from Claude slash commands.
- Modify `README.md`: make the host-specific invocation distinction visible at the skill table and Codex install summary.
- Modify `CHANGELOG.md`: record the maintenance repair and its tested behavior.

---

### Task 1: Add the failing Codex installer regression test

**Files:**
- Create: `tests/test_install_codex_skills.sh`
- Test: `tests/test_install_codex_skills.sh`

**Interfaces:**
- Consumes: `scripts/install_codex_skills.sh --codex-home <path> --source-root <path> [--force]`
- Produces: a standalone test command that exits zero only when all five skills install correctly and invalid sources fail safely.

- [x] **Step 1: Write the failing integration test**

Create an executable Bash test with these assertions:

```bash
#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER="$REPO_ROOT/scripts/install_codex_skills.sh"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/agentic-scaffold-codex-test.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

expected_skills=(init logchange nest repo-audit session-closeout)
codex_home="$TMP_ROOT/codex-home"

bash "$INSTALLER" --codex-home "$codex_home" --source-root "$REPO_ROOT"

for skill in "${expected_skills[@]}"; do
  target="$codex_home/skills/agentic-scaffold-$skill"
  [[ -L "$target" ]] || fail "missing symlink: $target"
  [[ "$(readlink "$target")" == "$REPO_ROOT/skills/$skill" ]] || fail "wrong target: $target"
done

actual_count="$(find "$codex_home/skills" -type l | wc -l | tr -d ' ')"
[[ "$actual_count" == "${#expected_skills[@]}" ]] || fail "expected 5 links, found $actual_count"

if bash "$INSTALLER" --codex-home "$codex_home" --source-root "$REPO_ROOT" >"$TMP_ROOT/no-force.log" 2>&1; then
  fail "installer overwrote existing links without --force"
fi

broken="$codex_home/skills/agentic-scaffold-session-closeout"
rm "$broken"
ln -s "$TMP_ROOT/missing-session-closeout" "$broken"
bash "$INSTALLER" --force --codex-home "$codex_home" --source-root "$REPO_ROOT"
[[ -e "$broken/SKILL.md" ]] || fail "--force did not repair broken link"

invalid_root="$TMP_ROOT/invalid-source"
mkdir -p "$invalid_root/skills/empty"
if bash "$INSTALLER" --codex-home "$TMP_ROOT/invalid-home" --source-root "$invalid_root" >"$TMP_ROOT/invalid.log" 2>&1; then
  fail "installer accepted source root with no valid skills"
fi
grep -q "No valid skills found" "$TMP_ROOT/invalid.log" || fail "missing invalid-source diagnostic"

echo "PASS: Codex installer exposes and repairs all agentic-scaffold skills"
```

- [x] **Step 2: Make the test executable and verify shell syntax**

Run:

```bash
chmod +x tests/test_install_codex_skills.sh
bash -n tests/test_install_codex_skills.sh
```

Expected: `bash -n` exits 0 with no output.

- [x] **Step 3: Run the test and verify RED**

Run:

```bash
bash tests/test_install_codex_skills.sh
```

Expected: FAIL with `missing symlink` for `agentic-scaffold-nest`, proving the current hard-coded two-skill installer reproduces the bug.

---

### Task 2: Discover and install every valid skill

**Files:**
- Modify: `scripts/install_codex_skills.sh`
- Test: `tests/test_install_codex_skills.sh`

**Interfaces:**
- Consumes: `${SOURCE_ROOT}/skills/*/SKILL.md`, `--force`, `--codex-home`, and `--source-root`.
- Produces: sorted symlinks named `agentic-scaffold-<directory-name>` plus a human-readable install summary.

- [x] **Step 1: Add source validation and skill discovery**

Before creating the destination skill root, collect valid skill directories without relying on Bash 4-only features:

```bash
SKILLS_SOURCE="$SOURCE_ROOT/skills"

if [[ ! -d "$SKILLS_SOURCE" ]]; then
  echo "Skills directory not found: $SKILLS_SOURCE" >&2
  exit 1
fi

skill_dirs=()
while IFS= read -r candidate; do
  [[ -d "$candidate" && -f "$candidate/SKILL.md" ]] || continue
  skill_dirs+=("$candidate")
done < <(printf '%s\n' "$SKILLS_SOURCE"/* | LC_ALL=C sort)

if [[ "${#skill_dirs[@]}" -eq 0 ]]; then
  echo "No valid skills found under $SKILLS_SOURCE" >&2
  exit 1
fi
```

- [x] **Step 2: Replace the hard-coded install calls**

Install the discovered directories and collect names for the summary:

```bash
installed_skills=()
for source in "${skill_dirs[@]}"; do
  skill="$(basename "$source")"
  name="agentic-scaffold-$skill"
  install_link "$name" "$source"
  installed_skills+=("$name")
done

echo "Installed Codex skills:"
printf '  - %s\n' "${installed_skills[@]}"
echo
echo "Skills root: $CODEX_HOME/skills"
echo "Source root: $SOURCE_ROOT"
echo
echo "Codex detects skill changes automatically; restart if the new skills do not appear."
```

- [x] **Step 3: Verify GREEN**

Run:

```bash
bash -n scripts/install_codex_skills.sh scripts/update_codex_skills.sh tests/test_install_codex_skills.sh
bash tests/test_install_codex_skills.sh
```

Expected: syntax checks exit 0 and the integration test prints `PASS: Codex installer exposes and repairs all agentic-scaffold skills`.

- [x] **Step 4: Commit the tested installer behavior**

```bash
git add scripts/install_codex_skills.sh tests/test_install_codex_skills.sh
git commit -m "fix: install every agentic-scaffold Codex skill" \
  -m "Discover valid skills from the canonical skills tree and cover clean installs, overwrite refusal, broken-link repair, and invalid sources with an isolated Bash integration test."
```

---

### Task 3: Reconcile host-specific documentation

**Files:**
- Modify: `AGENTS.md`
- Modify: `SETUP.md`
- Modify: `README.md`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: the verified five-skill installer behavior and Codex's `$skill-name` invocation model.
- Produces: consistent human and agent guidance without changing skill frontmatter or Claude invocation behavior.

- [x] **Step 1: Correct the canonical repository description**

In `AGENTS.md`, set the current version to `0.8.0`, list `nest` and `session-closeout` in the `skills/` tree, and add `tests/test_install_codex_skills.sh` to the canonical structure.

- [x] **Step 2: Correct installation and invocation guidance**

In `SETUP.md`:

- list all five skills for Cowork, Claude Code, Codex, and raw-skill hosts;
- describe Codex installation as symlinks rather than stubs;
- show explicit Codex invocation as `$init`, `$nest`, `$logchange`, `$repo-audit`, and `$session-closeout`;
- state that `/session-closeout` is Claude/Cowork syntax, not a Codex custom slash command;
- extend verification to require all five namespaced Codex links.

In `README.md`, change the invocation column to show both forms, for example `Claude: /session-closeout · Codex: $session-closeout`, and add the Codex invocation note beside the install command.

- [x] **Step 3: Record the maintenance repair**

Add an unreleased 2026-07-17 entry to `CHANGELOG.md` describing dynamic discovery, the regression test, broken-link repair, and corrected host-specific invocation guidance. Do not bump the published plugin manifest version.

- [x] **Step 4: Verify documentation consistency**

Run:

```bash
rg -n "0\.6\.0|Skills appear|skill stubs|/session-closeout|\$session-closeout" AGENTS.md SETUP.md README.md
git diff --check
bash tests/test_install_codex_skills.sh
```

Expected: `AGENTS.md` no longer reports version 0.6.0; Codex sections use `$session-closeout`; remaining `/session-closeout` references are explicitly Claude/Cowork-facing or explanatory; diff and integration test pass.

- [x] **Step 5: Commit the reconciled documentation**

```bash
git add AGENTS.md SETUP.md README.md CHANGELOG.md
git commit -m "docs: clarify agentic-scaffold skill invocation" \
  -m "Reconcile the five-skill inventory and distinguish Claude slash commands from Codex dollar-sign skill mentions without changing published plugin metadata."
```

---

### Task 4: Repair and verify the live Codex links

**Files:**
- Modify outside repo: `~/.codex/skills/agentic-scaffold-*` symlinks only.

**Interfaces:**
- Consumes: the verified installer in the current checkout.
- Produces: five resolving global symlinks available to subsequent Codex tasks.

- [x] **Step 1: Run the verified installer against the live Codex home**

Run:

```bash
bash scripts/install_codex_skills.sh \
  --force \
  --codex-home "$HOME/.codex" \
  --source-root "$PWD"
```

Expected: the installer lists exactly five namespaced skills and reports the current checkout as its source root.

- [x] **Step 2: Verify every live link resolves**

Run:

```bash
for skill in init logchange nest repo-audit session-closeout; do
  target="$HOME/.codex/skills/agentic-scaffold-$skill"
  test -L "$target"
  test -f "$target/SKILL.md"
  printf '%s -> %s\n' "$target" "$(readlink "$target")"
done
```

Expected: all five commands succeed and every target points into the current `agentic-scaffold-plugin/skills/` checkout.

- [x] **Step 3: Run final repository verification**

Run:

```bash
bash -n scripts/install_codex_skills.sh scripts/update_codex_skills.sh tests/test_install_codex_skills.sh
bash tests/test_install_codex_skills.sh
git diff --check HEAD~2..HEAD
git status --short --branch
```

Expected: syntax and integration checks pass; the branch contains the planned commits; no unrelated files are modified.

- [x] **Step 4: Report restart behavior**

Tell the user that the current task's initial skill catalogue is already fixed in context, so the newly installed skills should be verified from a new Codex task. If they do not appear there, restart Codex. Explicit invocation is `$session-closeout`, while natural-language triggers such as “run session closeout” also work.
