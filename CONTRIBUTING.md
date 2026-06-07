# Contributing to builder-ai

## The Builder-AI Test

Before proposing a new skill or agent, ask:

> **Would this be essential for at least 50% of teams building LLM-powered products?**

If the answer is "it depends heavily on the stack" — it belongs in a specialised extension, not in this pack. builder-ai is a baseline, not a comprehensive catalogue.

## What to Contribute

### Adding a Skill

Skills are the core contribution. A good skill:
- Has a clear trigger: agents and developers know exactly when to use it
- Enforces something that teams consistently skip
- States an immutable law in a code block
- Lists rationalization red flags — the things people say when they want to avoid it
- Defines a completion statement format based on evidence, not assertions

Skills that add checklists without enforcement mechanisms will be rejected.

### Adding an Agent

Agents are roles an AI assistant can adopt. A good agent:
- Has a narrower scope than a generic assistant
- Makes opinionated decisions within its domain
- Explicitly states what it does NOT do (scope boundary)
- Requires a specific model tier appropriate to the task

### What NOT to Contribute

- Generic coding standards (use A Team for that)
- Skills specific to a single provider (e.g., "OpenAI cost audit") — keep skills provider-agnostic
- Agents that duplicate an existing agent's scope with minor differences

## File Format

### Skill format (`skills/<name>/SKILL.md`)

```markdown
---
name: skill-name
description: One sentence: when to trigger this skill and what it blocks.
---

# Skill Title

## The Law

`​`​`
STATEMENT IN CAPS. What you cannot do without this skill.
What does NOT count. What DOES count.
`​`​`

## When to Use

## When NOT to Use (if scope needs bounding)

## The Process

(Steps, tables, code examples)

## Rationalization Red Flags

(Things agents say when they want to skip this — and why they're wrong)

## Completion Statement Format

`​`​`
Evidence-based format.
Numbers required.
File paths required.
`​`​`

## Why This Matters
```

### Agent format (`.claude/agents/<name>.md`)

```markdown
---
name: agent-name
description: Trigger description — when to invoke this agent.
allowedTools:
  - read
  - write
  - edit
  - shell
model: sonnet
---

[System prompt — what the agent does, how it reasons, what it explicitly does NOT do]
```

## Process

1. Fork the repo
2. Create a branch: `feat/skill-<name>` or `feat/agent-<name>`
3. Add the skill or agent file following the format above
4. Update `AGENTS.md` with the new entry in the correct table
5. Run `python scripts/check_consistency.py` — must pass before opening a PR
6. Open a PR using the provided template
7. In the PR description, answer the builder-ai test: who needs this, and why would a generic LLM builder skip it without enforcement?

## Updating Existing Skills

Minor fixes (typos, clarifications): PR is fine.

Breaking changes (restructured process, new required fields in completion format): increment the skill's internal version if it has one, and note the breaking change in the PR.

## Questions

Open a discussion rather than an issue for design questions or proposals.
