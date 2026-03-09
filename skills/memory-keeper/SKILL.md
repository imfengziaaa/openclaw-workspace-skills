---
name: memory-keeper
description: Maintain the workspace memory system. Use when the user asks to remember something, when new stable preferences/identity details are learned, when daily notes should be updated, or when long-term memory should be curated from recent events.
---

# Memory Keeper

Use this skill to store durable context in the workspace files.

## Files

- `memory/YYYY-MM-DD.md`: raw daily notes
- `MEMORY.md`: curated long-term memory
- `USER.md`: facts about the human
- `IDENTITY.md`: facts about the assistant identity

## Rules

1. Write things down instead of assuming they will be remembered.
2. Put short-lived or chronological events in the daily memory file.
3. Put durable preferences, decisions, and recurring context in `MEMORY.md`.
4. Update `USER.md` for stable user profile facts.
5. Update `IDENTITY.md` for assistant identity choices.
6. Keep entries short, specific, and useful.

## Suggested workflow

1. Read the relevant file.
2. Add or revise only the necessary lines.
3. Avoid duplicating the same fact across too many files.
4. If a new fact is important long-term, store it in both the daily note and the right durable file.
