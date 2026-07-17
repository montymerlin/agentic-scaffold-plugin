# Codex Installer Repair Design

**Date:** 2026-07-17
**Status:** Approved

## Problem

The Codex installer currently creates links for only `init` and `logchange`, even though the plugin now ships five skills. The omission happened because `scripts/install_codex_skills.sh` contains an explicit two-item install list that was not updated when `nest`, `repo-audit`, and `session-closeout` were added.

The two links installed on Monty's machine are also broken because they point to the workspace's former filesystem location. As a result, none of the agentic-scaffold skills appear in the current Codex skill catalogue.

Codex invocation is a related documentation issue, not an installer feature: Codex skills are selected implicitly or invoked with `$skill-name`; Claude-style `/session-closeout` is not created by installing a Codex skill.

## Goals

- Install every valid skill shipped under `skills/` without maintaining a second manual inventory.
- Preserve deterministic, namespaced link names of the form `agentic-scaffold-<skill>`.
- Repair stale or broken links when the installer is run with `--force`.
- Keep the existing local-development and GitHub-vendor installation modes.
- Add repeatable, zero-dependency tests for the installer's core behavior.
- Correct the Codex documentation so it distinguishes `$` skill invocation from Claude slash commands.
- Reinstall the five live skills from the current checkout after the repair passes verification.

## Non-goals

- Building native `.codex-plugin/` packaging or a Codex marketplace release.
- Migrating this installer or the other HQ plugin installers from `~/.codex/skills` to another global skill root.
- Changing any skill's `name:` frontmatter, which must remain bare for Claude plugin namespacing compatibility.
- Publishing or pushing the repair to GitHub without separate approval.

## Design

### Skill discovery

The installer will enumerate immediate children of `${SOURCE_ROOT}/skills` in stable lexical order. A directory is installable only when it contains a regular `SKILL.md` file. For each valid directory named `<skill>`, the installer will create:

```text
${CODEX_HOME}/skills/agentic-scaffold-<skill>
  -> ${SOURCE_ROOT}/skills/<skill>
```

Discovering valid directories makes the canonical `skills/` tree the sole inventory. Adding a future skill with a `SKILL.md` automatically makes it installable without another script edit. Files such as `.DS_Store` and directories without `SKILL.md` are ignored.

The installer will fail before modifying links if `${SOURCE_ROOT}/skills` does not exist or contains no valid skills. This prevents a mistyped `--source-root` from reporting a successful empty installation.

### Replacement behavior

Existing behavior remains intact:

- Without `--force`, any existing target causes a clear refusal and a non-zero exit.
- With `--force`, an existing file, directory, valid link, or broken link at the target is removed and replaced.

The live repair will run the updated installer with `--force` and `--source-root` pointing at the current checkout. This replaces the two broken old-path links and installs the other three skills in the same operation.

### Output

Successful output will list each installed namespaced skill, followed by the skill root and source root. It will remind the user that Codex detects skill changes automatically but may require a restart if the new skills do not appear.

### Documentation

`SETUP.md` will describe all five installed skills and use Codex's `$skill-name` syntax for explicit invocation. Claude Code and Cowork documentation will retain slash-command syntax because those hosts expose plugin skills that way.

The plugin's `AGENTS.md` structure and version metadata will be corrected where they still describe the pre-`nest` or pre-`session-closeout` inventory. `CHANGELOG.md` will record the installer repair as a maintenance change without broadening it into a native Codex packaging redesign.

## Testing

A shell integration test will run the installer against temporary Codex homes and assert observable filesystem behavior:

1. A clean install creates exactly five namespaced symlinks.
2. Every link targets the matching skill directory in the supplied source checkout.
3. A second install without `--force` fails rather than overwriting an existing target.
4. `--force` replaces a deliberately broken link and restores the complete valid set.
5. A source root with no valid `skills/*/SKILL.md` fails with a diagnostic.

The test will use only POSIX shell utilities already required by the installer and will clean up its temporary directories with a trap.

## Verification and rollout

The repair is complete when:

- the new integration test passes;
- `bash -n` passes for both installer scripts and the test;
- an isolated temporary installation exposes the same five skills as the source tree;
- the live `~/.codex/skills/agentic-scaffold-*` links all resolve into the current checkout;
- the repository diff contains only the installer repair, its tests, and directly related documentation.

The current Codex task will not gain newly discovered skill metadata retroactively. A new task—or an app restart if necessary—will expose the repaired skills, where `session-closeout` can be invoked explicitly with `$session-closeout` or triggered by a matching natural-language request.
