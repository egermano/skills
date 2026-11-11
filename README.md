# Skills

Personal repository for skills I use on a daily basis.

## Purpose

- Keep a curated collection of practical skills and workflows.
- Maintain quick references for recurring tasks.
- Evolve and version personal best practices over time.

## Structure

- Add one skill per folder when possible.
- Include concise usage notes and examples.
- Keep files small, focused, and easy to scan.

## Installation

Install skills directly using `npx skills add`:

```bash
npx skills add <skill-name>
```

Example:

```bash
npx skills add split-commits-by-diff
```

This installs the selected skill into your local skills directory.

## Available Skills

| Skill | Description |
|-------|-------------|
| `cleanup-to-main` | Clean up local git branches removed from remote |
| `create-pr-with-template` | Create GitHub PRs with repository templates |
| `split-commits-by-diff` | Split mixed git changes into coherent commits |
| `escrever-como-bruno` | Write in Bruno Germano’s voice, grounded in historical OBG scripts and technical conversations; portable across Codex, Claude Code, and OpenCode |
| `xp` | Extreme Programming practices and roles reference |

## Usage

Use this repository as a personal knowledge base for repeatable tasks and day-to-day execution.

### Bruno’s writing voice

[`escrever-como-bruno`](skills/escrever-como-bruno/SKILL.md) includes historical voice samples and guidance for scripts, articles, short posts, and messages. Keep its supporting files when installing it.

See [compatibility and usage](skills/escrever-como-bruno/references/compatibilidade.md) for Claude Code, OpenCode, and Codex. The same skill directory works across these agents; no separate instruction variants are required.
