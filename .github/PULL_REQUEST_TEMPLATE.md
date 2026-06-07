## Change Type

- [ ] New skill
- [ ] New agent
- [ ] Enhancement to existing skill or agent
- [ ] Bug fix (skill/agent content)
- [ ] Infrastructure (scripts, workflows, docs)

## What Does This Change?

## The Builder-AI Test (for new skills/agents)

> Would this be essential for at least 50% of teams building LLM-powered products?

Answer:

## Skill / Agent Quality Checklist

For new or modified skills:
- [ ] The Law stated in a code block, ALL CAPS, immutable
- [ ] When to Use defined (clear triggers)
- [ ] When NOT to Use defined (scope boundary)
- [ ] The Process is step-by-step with concrete examples (not just description)
- [ ] Rationalization Red Flags listed — things teams say when they want to skip this
- [ ] Completion Statement Format is evidence-based (numbers, file paths, results — not assertions)
- [ ] Why This Matters section present

For new or modified agents:
- [ ] Frontmatter complete: name, description, allowedTools, model
- [ ] Agent states what it explicitly does NOT do
- [ ] Model tier appropriate to the task (opus for high-stakes reasoning, sonnet for standard)
- [ ] Description is a valid trigger sentence an AI assistant can match

## AGENTS.md Updated

- [ ] New skill/agent added to the correct table in `AGENTS.md`

## Consistency Check

- [ ] `python scripts/check_consistency.py` passes

## Platform Tested

The skill/agent was validated against a real AI coding session on:
- [ ] Claude Code
- [ ] Codex CLI
- [ ] Cursor
- [ ] OpenCode
