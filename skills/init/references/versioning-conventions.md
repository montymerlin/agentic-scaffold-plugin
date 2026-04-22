# Versioning Conventions — Reference for Scaffolded Projects

When the `/init` skill detects that a project needs version tracking, inject a Versioning subsection into the generated AGENTS.md. This file provides the pattern and rationale — adapt the specifics to the project's version source.

## The convention to inject

The generated `### Versioning` section should cover these four rules, adapted to the project's manifest:

### 1. Single source of truth

Every project has exactly one canonical place where the version lives. Everything else (CHANGELOG headings, commit messages, git tags) references it — never the other way around.

| Project type | Version source |
|---|---|
| Claude Agent SDK plugin | `.claude-plugin/plugin.json` `version` field |
| Node.js package | `package.json` `version` field |
| Python package | `pyproject.toml` `[project] version` or `setup.py` |
| Rust crate | `Cargo.toml` `[package] version` |
| Go module | Git tags (Go modules don't have a manifest version) |
| Ruby gem | `lib/<name>/version.rb` or `.gemspec` |
| Other | Whichever file the build/release system reads the version from |

### 2. Semantic versioning

Use semver (MAJOR.MINOR.PATCH):
- **Patch** — bug fixes, documentation tweaks, skill adjustments that don't change behaviour
- **Minor** — new features, new skills, backward-compatible additions
- **Major** — breaking changes (renamed exports, removed APIs, changed conventions that require consumer updates)

Start at `0.1.0` for new projects. The `0.x` range signals "API may change." Bump to `1.0.0` when the project has external consumers relying on stability.

### 3. Git tags anchor releases

Every version bump commit must be tagged: `git tag v0.2.0`. Tags are immutable — they survive rebases, branch deletions, and commit message edits. Without tags, versions exist only as strings in files and commit messages, which can drift (and do).

Push tags explicitly: `git push --tags`.

For projects with CI/CD, tags often trigger release workflows (npm publish, PyPI upload, GitHub Release creation). Even without CI, tags make `git log v0.1.0..v0.2.0` work, which is the cleanest way to see what changed between releases.

### 4. Pre-commit version check

Before committing a version bump, verify three things agree:

1. The version source (plugin.json, package.json, etc.) has the new version
2. The latest CHANGELOG.md heading names the same version
3. The commit message references the same version

If any of these disagree, fix them before committing. This is the single most common source of version drift — it happened across multiple real plugins before this convention was established.

## When NOT to include versioning

Skip the versioning section for:
- Knowledge gardens and personal wikis — they evolve continuously, not in releases
- Research corpora and reading collections — content grows by accretion, not versioned releases
- Documentation sites that deploy on every commit — the deploy IS the release
- Journals, logs, and note collections — no consumers depend on a version number

The test: "Does anything or anyone depend on a specific version of this project?" If no, skip versioning conventions.

## Source

This convention was developed from real experience managing six Claude Agent SDK plugins (mdpowers, agentic-scaffold, superpowers-cowork, git-cowork, regen-network, notion-sync). The version-drift pattern that motivated it: mdpowers had plugin.json at v0.3.2 while CHANGELOG tracked v0.4.2 and git had no tags — four conflicting sources of truth with no anchoring mechanism. The pre-commit version check and git-tag-on-release rules were introduced to prevent recurrence. See mdpowers Decision 010.
