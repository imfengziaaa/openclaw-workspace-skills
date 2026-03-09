---
name: browser-troubleshooter
description: Investigate websites and web apps with browser snapshots, screenshots, and targeted actions. Use when a page needs UI inspection, a click/type flow, visual confirmation, debugging of interactive elements, or step-by-step browser troubleshooting.
---

# Browser Troubleshooter

Use this skill when plain fetching is not enough.

## Workflow

1. Open or focus the target page with `browser`.
2. Take a `snapshot` before acting.
3. Prefer stable refs from the snapshot for interactions.
4. Use screenshots when visual confirmation matters.
5. Keep actions minimal and state-aware.
6. Report what was observed, not just what was attempted.

## Good uses

- Login flow debugging
- Button/form inspection
- Reproducing UI issues
- Capturing screenshots for confirmation

## Avoid

- Long blind action chains
- Repeated wait loops without evidence of state changes
