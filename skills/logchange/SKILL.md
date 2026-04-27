---
name: logchange
description: >
  Log high-level changes to a CHANGELOG.md file in the current working directory. Use when
  the user says "logchange", "log change", "update changelog", "what's changed", "record
  what we did", or any variation of wanting a human-readable summary of recent work. Works
  in both git repos (summarises from commit history) and non-git folders (manual change logging).
---

# logchange

Maintain a high-level, human-readable CHANGELOG.md in the current working directory. This is not a commit log — it distills meaningful changes into a narrative that anyone can scan to understand what's different and why.

## Step 1: Detect the environment

Determine whether the current directory is a git repository:

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

- **If git repo**: proceed to the git-based workflow (Step 2a)
- **If not a git repo**: proceed to the manual workflow (Step 2b)

## Step 2a: Git-based workflow

### Find the boundary

Read CHANGELOG.md (if it exists) and identify where the last entry ends. Then get all commits since that entry was written:

```bash
# Find the commit that last touched CHANGELOG.md
last_changelog_commit=$(git log -1 --format="%H" -- CHANGELOG.md)

# Get all commits since then
git log --oneline $last_changelog_commit..HEAD
```

If CHANGELOG.md doesn't exist or has never been committed, check whether the repo has any commits at all:

```bash
git rev-list --count HEAD 2>/dev/null
```

- **Zero commits** (empty repo): no git history to summarise. Route to the manual workflow (Step 2b) and ask the user to describe what's been built so far.
- **Commits exist**: use the full recent history (`git log --oneline -20`).

If there are no new commits since the last changelog update, tell the user there's nothing new to log and stop.

### Understand the changes

Read commit messages and diff stats to understand the substance:

```bash
git log --stat $last_changelog_commit..HEAD
```

For commits with unclear messages, check the actual changes:

```bash
git diff --stat $last_changelog_commit..HEAD
```

### Write the entry

Group changes thematically, not by commit. Proceed to Step 3.

## Step 2b: Manual workflow (no git)

If there's no git repo, the changelog serves as the primary record of changes.

### Check existing changelog

Read CHANGELOG.md if it exists. Note the most recent entry's date.

### Ask what changed

Ask the user what work was done since the last entry. If this is the first entry, ask what the folder contains and what they've been working on.

### Write the entry

Based on the user's description, write a clear summary. Proceed to Step 3.

## Step 3: Write the changelog entry

If CHANGELOG.md doesn't exist, create it with a title:

```markdown
# Changelog
```

Add the new entry at the top (below the header). Use this format:

```markdown
## YYYY-MM-DD — Short descriptive title

1-3 sentences of prose summarising the overall thrust — structural changes, new capabilities,
high-level shifts. Keep it conversational.

### Content updates

- **Topic or area name** — one sentence on what changed
- **Another topic** — brief description
```

The entry has two layers:

1. **Prose summary** (always present): high-level description of structural, infrastructure, or conceptual changes. If the only changes are content updates, a single sentence is fine before the list.

2. **Content updates** (when applicable): a bulleted list naming each piece of work that was created, significantly updated, or reorganised. Name the topics and say what changed in one line each.

### Guidelines

- **Prose for structure, list for content.** Reorganisations, new tooling, workflow changes go in the prose. Content and document updates get named bullets.
- **High-level only for infrastructure.** Don't enumerate individual file renames or config tweaks. "Set up search indexing" is enough.
- **Name the work.** When documents or research are written or substantially updated, name them and say what's new. This is the most valuable part of the changelog.
- **Skip the trivial.** Housekeeping, typo fixes, minor formatting — these don't warrant changelog entries. In git repos, commits handle the detail.
- **Don't hardcode file counts.** They go stale immediately.

## Step 4: Check if README needs updating

If a README.md exists in the same directory, read it and compare against the current state:

- New sections or major documents that should be reflected
- Structural changes (new directories, renamed areas)
- Descriptions that are now out of date

If it needs updating, make the edits. If it's fine, say so.

## Step 5: Present and confirm

Show the user the new changelog entry (and any README edits) before writing. Wait for confirmation.

**In a git repo:** after the user confirms, ask if they'd like to commit the changelog update. If yes, use the commit skill.

**Without git:** write the entry directly after confirmation.
