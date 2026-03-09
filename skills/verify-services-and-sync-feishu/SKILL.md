---
name: verify-services-and-sync-feishu
description: Verify already-deployed services with minimum business checks, produce local execution assets, prepare a Feishu-doc-ready summary, and normalize Feishu folder/name management. Use when an agent needs to validate services like RSSHub, changedetection.io, n8n, Meilisearch, or similar deployed systems, then leave behind reusable local artifacts and a clean sync package for Feishu documentation/archival.
---

# Verify Services And Sync Feishu

Use this skill when the job is not "build a new system", but "prove the existing one works, capture the proof, and organize the result so it can be synced into Feishu cleanly".

## What this skill is for

Handle one narrow but recurring workflow:

1. Verify an already-deployed service with the smallest meaningful business check.
2. Save local artifacts that let another agent re-run or inspect the validation.
3. Produce a concise markdown summary that can be pasted or synced into a Feishu doc.
4. Place outputs under a stable folder/name convention so later retrieval and Feishu filing stay clean.

This skill is for **post-deployment validation and documentation handoff**.
It is not for broad architecture design, greenfield deployment, or speculative expansion.

## Recommended workflow

Follow this order unless the user explicitly asks otherwise:

### 1) Verify

Run the **minimum business validation**, not a platform vanity check.

Prefer checks like:

- **RSSHub**: fetch one expected route and confirm usable feed content is returned.
- **changedetection.io**: confirm a watch exists or can evaluate a target page and produce a detectable state/result.
- **n8n**: trigger or inspect one concrete workflow path and confirm expected input/output or run success.
- **Meilisearch**: index/search one representative document set and confirm retrieval quality is acceptable.

Validation standard:

- Prove one real use path works end to end, or the smallest defensible slice of it.
- Capture exact endpoint / workflow / query / sample payload used.
- Record result, status, and any obvious caveat.
- Stop once the service is sufficiently proven for the current business goal.

Avoid bloated validation like exhaustive feature tours, cross-service dashboards, or speculative benchmarking unless explicitly requested.

### 2) Document locally

After verification, create local artifacts in the workspace so another agent can inspect, reuse, or re-run the work.

Minimum local assets should usually include:

- one markdown summary
- one structured or semi-structured evidence artifact when relevant
- optional command/query snippets if they materially improve repeatability

Good local evidence examples:

- sample HTTP request and response excerpt
- saved JSON result
- search query plus top hits
- workflow run ID or execution note
- screenshot only when text evidence is insufficient

Prefer text artifacts over screenshots when possible.

### 3) Prepare Feishu sync content

Create a markdown document that is already suitable for Feishu doc syncing or direct paste.

The Feishu-ready summary should be:

- short enough to scan quickly
- specific enough to defend the conclusion
- structured for later updates
- free of local-only clutter like shell noise or irrelevant debug logs

Include:

- what was verified
- how it was verified
- result
- evidence location
- risks / follow-ups

Do not create a second, redundant "overview of the overview" unless the user asks.

### 4) Archive cleanly

Put all outputs in stable, predictable locations.

Archive the run so future agents can find:

- latest validation summary
- per-run evidence
- Feishu-ready markdown
- any naming/folder choice already made

Prefer one clean trail over many parallel folders.

## Minimum output checklist

Produce these unless the user explicitly wants less:

1. **Validation summary markdown**
   - human-readable result
   - service name
   - validation time
   - pass/fail/partial
   - method used

2. **Evidence artifact**
   - JSON, TXT, CSV, or compact markdown appendix
   - enough detail to support the conclusion

3. **Feishu-ready markdown**
   - concise title
   - executive result first
   - sectioned body for direct sync/paste

4. **Archive location note**
   - final folder path
   - naming used

If the summary markdown can serve both as the local summary and the Feishu-ready version, reuse one file instead of duplicating.

## File and directory convention

Prefer workspace paths under `/home/node/.openclaw/workspace/outputs/`.

Recommended structure:

- `outputs/markdown/<topic>/<YYYY>/`
- `outputs/csv/<topic>/<YYYY>/` when CSV is actually useful
- `outputs/json/<topic>/<YYYY>/` or a sibling evidence folder if JSON outputs become common

For this workflow, prefer a stable topic folder such as:

- `service-validation`
- `feishu-sync-prep`
- or a service-specific stream like `service-validation-rsshub`

Use one topic per recurring workflow. Do not invent a new top-level topic for every run.

### Naming convention

Use filenames that sort well and reveal purpose:

- `<YYYY-MM-DD>_<service>_verification.md`
- `<YYYY-MM-DD>_<service>_feishu-sync.md`
- `<YYYY-MM-DD>_<service>_evidence.json`
- `<YYYY-MM-DD>_<service>_notes.txt`

If multiple runs occur on the same day, append a short suffix:

- `<YYYY-MM-DD>_<service>_verification_v2.md`
- `<YYYY-MM-DD>_<service>_verification_1730utc.md`

Keep names:

- lowercase
- hyphen/underscore simple
- stable across runs
- descriptive without being essay-length

## Feishu folder and naming rules

When preparing for Feishu sync or manual filing, keep folder logic boring and predictable.

### Folder rules

Prefer a hierarchy like:

- `Projects/<project-or-domain>/Service Validation/`
- `Operations/<team-or-domain>/Service Validation/`
- `Archive/<YYYY>/Service Validation/`

Choose **one** primary home for active material.
Do not scatter the same validation result across multiple sibling folders unless the user explicitly wants duplication.

### Document title rules

Use a title shape that survives search:

- `<service>: verification summary (<YYYY-MM-DD>)`
- `<project> / <service> verification (<YYYY-MM-DD>)`

Example:

- `RSSHub: verification summary (2026-03-08)`
- `AI Infra / Meilisearch verification (2026-03-08)`

Title should reveal:

- service or project
- document purpose
- date

Avoid vague titles like:

- `进展`
- `验证结果`
- `今日记录`

## What to capture in the Feishu-ready summary

Use this section order unless a better order is obvious:

1. **Conclusion** — one paragraph or 3 bullets max
2. **Scope** — what service / route / workflow / query was checked
3. **Method** — how the validation was executed
4. **Result** — actual outcome and confidence level
5. **Evidence** — local file paths or key excerpts
6. **Open issues / next actions** — only real ones

Keep it concrete. Prefer:

- "Queried RSSHub route X and received parsable feed with expected item titles"
- not "Service appears healthy"

## What not to do

Unless the user asks, do **not**:

- open a parallel grand-summary doc just because several services were touched
- produce both a long report and a near-duplicate short report
- over-automate the workflow before the pattern is stable
- deploy new infrastructure just because validation exposed future possibilities
- introduce browserless, OpenBB, extra monitoring stacks, or adjacent tooling prematurely
- turn a minimum business verification into a full QA project
- create many screenshots when text output already proves the point
- create many nested folders for a single run

The default posture is: **verify narrowly, document clearly, archive cleanly**.

## Reuse heuristics

When deciding how much to produce, use this rule:

- If someone else needs to trust the result, include evidence.
- If someone else may repeat the result, include the exact command/query/path.
- If the result may be synced to Feishu, remove local debugging noise before finalizing the markdown.
- If a file will not help a future agent, do not create it.

## Suggested execution pattern

1. Identify the service and the smallest meaningful business check.
2. Execute the check.
3. Save evidence in a machine-friendly or quote-friendly form.
4. Write/update the markdown summary.
5. Shape the summary into Feishu-ready form.
6. Put all files into the agreed topic/year folder.
7. Report final paths clearly.

## Reference

For a reusable summary template, read:

- `references/feishu-sync-template.md`
