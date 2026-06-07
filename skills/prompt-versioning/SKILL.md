---
name: prompt-versioning
description: Use whenever writing or modifying a prompt that will run in production. Enforces version-controlled prompts in prompts/<feature>/v<x.y.z>.md. Blocks "the prompt is in the code somewhere" completions.
---

# Prompt Versioning

## The Law

```
A PROMPT WITHOUT A VERSION NUMBER CANNOT BE DEBUGGED, ROLLED BACK, OR IMPROVED.
"It's tracked in git" is not versioning — the file has no history of intent.
"I'll version it later" means you'll debug a production regression with no baseline.
prompts/<feature>/v<x.y.z>.md with a CHANGELOG entry IS versioning.
```

## When to Use

Trigger whenever:
- Writing a new system prompt or user prompt template
- Modifying an existing prompt in any way (even a single word)
- Switching between prompt variants in an experiment
- Rolling back after a quality regression

## When NOT to Use

- One-off manual queries not used in any automated pipeline
- Prompts that exist only in a prototype that will be discarded

## Required Structure

```
prompts/
  <feature-name>/
    v1.0.0.md        ← original version
    v1.1.0.md        ← iteration (changed few-shots, added constraint)
    v2.0.0.md        ← breaking change (new output schema)
    CHANGELOG.md     ← what changed between versions and why
```

The `current` version is the highest version number. Never delete old versions — they are the rollback path.

## Version Numbering

| Bump | When | Example |
|---|---|---|
| Patch (x.y.**Z**) | Whitespace, typo, minor wording — output distribution unchanged | "Please" → "please" |
| Minor (x.**Y**.0) | New instruction, example, or constraint — output likely changes | Added 3 few-shot examples |
| Major (**X**.0.0) | New output schema, restructured reasoning, different task framing | JSON → structured XML |

## Prompt File Format

```markdown
---
version: 1.2.0
feature: <feature-name>
model: claude-sonnet-4-6
temperature: 0.3
max_tokens: 512
created: 2026-06-07
eval_suite: evals/<feature-name>/
---

<system>
[system prompt text]
</system>

<user>
[user turn template — use {{variable}} for substitutions]
</user>
```

All fields are required. `eval_suite` links to the eval that validates this version.

## The Process

### Step 1 — Create the Versioned File

Before writing the prompt text, create the file at its versioned path:
```
prompts/<feature>/v1.0.0.md
```

Fill in the frontmatter completely. Writing the metadata first makes the constraints explicit before the prompt body.

### Step 2 — Write the Prompt in the File

Write the prompt in the versioned file — not in a scratch pad, not in the chat, not inline in the codebase as a string. The file IS the source of truth. If the codebase contains the prompt text as a string, the prompt is not versioned. The code must reference `prompts/<feature>/v<x.y.z>.md` as a file path — not copy its content inline. Inline prompts cannot be rolled back in 30 seconds; they require a code deploy.

### Step 3 — Update CHANGELOG.md

Every version requires a CHANGELOG entry:
```markdown
## v1.2.0 — 2026-06-07
Changed: Added refusal instruction for out-of-scope queries
Why: Eval showed 8% refusal rate drop in v1.1.0 failure analysis
Eval: evals/<feature>/results-2026-06-07.md (89% → 93%)
```

### Step 4 — Trigger eval-before-ship

No version goes to production without an eval run. Reference the eval in the frontmatter's `eval_suite` field.

### Rollback Path

If a version regresses in production, the rollback is a one-line change: point the code to the previous version file.

```python
# Before (broken)
PROMPT_PATH = "prompts/classifier/v1.2.0.md"

# After (rollback — takes 30 seconds)
PROMPT_PATH = "prompts/classifier/v1.1.0.md"
```

This is only possible if the old version was not overwritten. Never edit in place — always create a new version file.

## Rationalization Red Flags

These thoughts mean the prompt is not versioned — stop:

- *"It's hardcoded in the codebase so git tracks it"* — git tracks the file's bytes, not the intent, the eval result, or what the previous version looked like for comparison; without a CHANGELOG you cannot explain the regression
- *"It's just a minor change, not worth versioning"* — every prompt regression in production starts with "it was just a minor change"; the version is how you find which change caused it
- *"I'll version it after I confirm it works"* — the version you can't find later is the one that was working; you needed to save it before changing it
- *"The prompt is in the config file"* — config files don't carry CHANGELOG entries, version semantics, or eval links; they are deployment targets, not the source of truth
- *"We only have one prompt version"* — that statement is always true until the night a regression reaches production and nobody can answer "what did the prompt look like before?"

## Completion Statement Format

When prompt-versioning is satisfied, state it like this:

```
Prompt versioned.
File: prompts/<feature>/v<x.y.z>.md
Frontmatter: model, temperature, max_tokens, eval_suite — all set
CHANGELOG.md: entry written (what changed, why, eval reference)
Previous version: v<prev> → this version: v<x.y.z>
Eval: <pending / evals/<feature>/results-<date>.md ✓>
```

## Why This Matters

Prompts are the most fragile part of an LLM system. A word change shifts the output distribution. Without versioning you cannot: compare what changed, reproduce the version that worked, run A/B tests with confidence, or diagnose a regression after it reaches users.
