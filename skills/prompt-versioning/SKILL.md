---
name: prompt-versioning
description: Enforces that all prompts are version-controlled, named, and never modified in-place without a new version entry.
---

# Prompt Versioning

## The Law

Prompts are code. They live in version control, carry a version number, and are never edited in-place without creating a new version. Unversioned prompts cannot be debugged, rolled back, or compared.

## When to Use

Trigger whenever:
- Writing a new system prompt or user prompt template
- Modifying an existing prompt
- Switching between prompt variants in an experiment
- Rolling back after a regression

## Required Structure

All prompts live in `prompts/` with this layout:

```
prompts/
  feature-name/
    v1.0.0.md       ← original
    v1.1.0.md       ← iteration (changed tone, few-shots)
    v2.0.0.md       ← breaking change (restructured output format)
    current -> v2.0.0.md   ← symlink or reference
    CHANGELOG.md    ← what changed and why between versions
```

## Version Numbering

- **Patch** (1.0.x): whitespace, typo, minor wording that doesn't change output distribution
- **Minor** (1.x.0): new instructions, examples, or constraints — likely changes output
- **Major** (x.0.0): restructured format, new output schema, different reasoning chain

## Prompt File Format

```markdown
---
version: 1.2.0
feature: <feature-name>
model: <model-id>
temperature: 0.3
max_tokens: 512
created: YYYY-MM-DD
eval_suite: evals/<feature-name>/
---

<system>
[system prompt text]
</system>

<user>
[user turn template — use {{variable}} for substitutions]
</user>
```

## The Process

1. Create `prompts/<feature>/v1.0.0.md` with the frontmatter above
2. Run eval-before-ship before any version goes to production
3. On change: bump version, create new file, update CHANGELOG.md, update `current` reference
4. Never delete old versions — they are the audit trail

## Verification Checklist

- [ ] Prompt file exists in `prompts/` with version in filename
- [ ] Frontmatter complete (model, temperature, max_tokens, created, eval_suite)
- [ ] `current` reference updated
- [ ] CHANGELOG.md entry written explaining what changed and why
- [ ] eval-before-ship triggered for this version
