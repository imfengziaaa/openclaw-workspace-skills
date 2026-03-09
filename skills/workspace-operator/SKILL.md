---
name: workspace-operator
description: Operate safely inside the OpenClaw workspace. Use when exploring files, editing docs, creating small automations, checking git status, organizing notes, or making careful non-destructive changes in /home/node/.openclaw/workspace.
---

# Workspace Operator

Use this skill for careful workspace maintenance and implementation work.

## Workflow

1. Inspect before editing.
2. Prefer precise edits for small changes.
3. Use full writes for new files or complete rewrites.
4. Avoid destructive commands unless the user explicitly asked.
5. After edits, check results and commit changes.

## Git routine

1. Run `git status --short`.
2. Review diffs before committing.
3. Create a small, descriptive commit message.

## Safety

- Treat `/home/node/.openclaw/workspace` as home.
- Prefer recoverable actions.
- Ask before external or destructive actions.
