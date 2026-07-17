#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Install agentic-scaffold skills globally for Codex.

Usage:
  install_codex_skills.sh [--from-github] [--ref <git-ref>] [--force]
                          [--codex-home <path>] [--source-root <path>]

Modes:
  --from-github    Clone or update the repo at $CODEX_HOME/vendor_imports/repos/agentic-scaffold-plugin
                   and install skills from there.

  default          Install from the current checkout (or --source-root).

Options:
  --force          Replace existing agentic-scaffold Codex skill links if present.
  --codex-home     Override CODEX_HOME (default: ~/.codex).
  --source-root    Install from a specific checkout instead of the current repo.
  --ref            Git ref to clone/update when using --from-github (default: main).
EOF
}

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SOURCE_ROOT=""
FROM_GITHUB=0
FORCE=0
REF="main"
REPO_URL="https://github.com/montymerlin/agentic-scaffold-plugin.git"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from-github) FROM_GITHUB=1 ;;
    --force) FORCE=1 ;;
    --codex-home) CODEX_HOME="$2"; shift ;;
    --source-root) SOURCE_ROOT="$2"; shift ;;
    --ref) REF="$2"; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
  shift
done

if [[ -z "$SOURCE_ROOT" ]]; then
  SOURCE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fi

if [[ "$FROM_GITHUB" -eq 1 ]]; then
  SOURCE_ROOT="$CODEX_HOME/vendor_imports/repos/agentic-scaffold-plugin"
  mkdir -p "$(dirname "$SOURCE_ROOT")"
  if [[ -d "$SOURCE_ROOT/.git" ]]; then
    git -C "$SOURCE_ROOT" fetch origin "$REF"
    git -C "$SOURCE_ROOT" checkout "$REF"
    git -C "$SOURCE_ROOT" pull --ff-only origin "$REF"
  else
    git clone --branch "$REF" "$REPO_URL" "$SOURCE_ROOT"
  fi
fi

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

mkdir -p "$CODEX_HOME/skills"

install_link() {
  local name="$1"
  local source="$2"
  local target="$CODEX_HOME/skills/$name"

  if [[ -e "$target" || -L "$target" ]]; then
    if [[ "$FORCE" -eq 1 ]]; then
      rm -rf "$target"
    else
      echo "Refusing to replace existing $target without --force" >&2
      exit 1
    fi
  fi

  ln -s "$source" "$target"
}

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
