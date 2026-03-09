---
name: repo-inspector
description: Inspect a code or docs repository to understand structure, status, risks, and likely next steps. Use when entering an unfamiliar repo, auditing project layout, checking git state, locating key files, or preparing to implement changes safely.
---

# Repo Inspector

Use this skill to quickly understand a repository before changing it.

## Workflow

1. Check `git status --short`.
2. List top-level files and important config files.
3. Identify languages, package managers, build/test commands, and entry points.
4. Find the files most relevant to the user's goal.
5. Summarize the repo shape before editing.

## Output pattern

- Repo state
- Key files
- Architecture sketch
- Risks / gotchas
- Recommended next move
