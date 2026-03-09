---
name: web-research
description: Research topics on the web using web_search, web_fetch, and browser. Use when the user asks for up-to-date information, comparisons, product research, documentation lookup, fact checking, link collection, or a concise researched summary with sources.
---

# Web Research

Use this skill to do current web research efficiently and cite sources.

## Workflow

1. Start with `web_search` to map the topic quickly.
2. Open the most promising results with `web_fetch` for readable extraction.
3. Use `browser` only when the page is highly interactive, blocked, or needs screenshots/UI inspection.
4. Prefer 2-5 strong sources over a long noisy list.
5. Cross-check claims when the topic is factual, commercial, or time-sensitive.
6. Summarize findings clearly and include source links or titles.

## Heuristics

- Prefer official docs for product/API behavior.
- Prefer primary sources for announcements, pricing, and policies.
- Prefer recent sources for fast-moving topics.
- Say when something is uncertain or conflicting.

## Output shape

Use a compact structure when helpful:

- Bottom line
- Key findings
- Caveats
- Sources
