---
name: tool-fallbacks
description: Choose practical fallback paths when a preferred tool, binary, API, or permission is unavailable. Use when commands fail due to missing binaries, auth, permissions, sandbox limits, or network restrictions and a useful alternative path is needed.
---

# Tool Fallbacks

When the first plan fails, degrade gracefully.

## Workflow

1. Identify the exact blocker: missing binary, missing auth, permission, network, or unsupported OS.
2. Check for a first-class alternative tool already available.
3. Prefer in-platform tools over shell hacks.
4. If no full substitute exists, offer the highest-value partial completion.
5. Explain the constraint briefly and continue with the fallback.

## Common patterns

- `web_fetch` before browser automation
- workspace skill before third-party skill
- local file analysis before external upload
- manual git/file workflow before specialized CLI
