# Feishu Sync Template

Use this template when a verification result needs to be preserved locally and then synced or pasted into Feishu.

## Suggested title

`<service>: verification summary (<YYYY-MM-DD>)`

## Body template

```markdown
# <service>: verification summary (<YYYY-MM-DD>)

## Conclusion
- Status: Pass | Partial | Fail
- Verdict: <one-line conclusion>
- Confidence: High | Medium | Low

## Scope
- Service: <service name>
- Target checked: <route / workflow / index / endpoint / watch target>
- Goal: <what this validation was supposed to prove>

## Method
1. <step 1>
2. <step 2>
3. <step 3>

## Result
- Expected: <expected outcome>
- Actual: <actual outcome>
- Notes: <important nuance only>

## Evidence
- Local summary: `<path>`
- Evidence file(s): `<path>`
- Key excerpt:
  - `<short excerpt or metric>`

## Open issues / Next actions
- <only real follow-up items>
```

## Field guidance

### Status

Use:

- `Pass` when the business check succeeded clearly
- `Partial` when the service works but some expectation remains unproven or degraded
- `Fail` when the intended validation did not succeed

### Confidence

Use:

- `High` when the evidence is direct and repeatable
- `Medium` when the result is credible but narrow or incomplete
- `Low` when access, time, or evidence quality is limited

## Local file pairing

A minimal pairing usually looks like:

- summary markdown: `<YYYY-MM-DD>_<service>_verification.md`
- evidence artifact: `<YYYY-MM-DD>_<service>_evidence.json`

If the markdown is already Feishu-ready, do not create a duplicate file unless the user needs a separate Feishu-facing version.
