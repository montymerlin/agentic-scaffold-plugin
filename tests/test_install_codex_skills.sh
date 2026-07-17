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
