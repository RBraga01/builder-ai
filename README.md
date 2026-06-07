# builder-ai v1.0.0

Your AI assistant will skip the eval, change the prompt without versioning it, add no fallback, and ship without a safety review.

**This pack makes that impossible.**

Drop one folder into your project. Your AI coding assistant now enforces production standards for every LLM feature — not as suggestions it can ignore, but as gates it cannot pass without evidence.

**Mac / Linux / WSL:**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/RBraga01/builder-ai/main/install.sh)
```
**Windows PowerShell:**
```powershell
irm https://raw.githubusercontent.com/RBraga01/builder-ai/main/install.ps1 | iex
```

Works on Claude Code, Codex CLI, Cursor, and OpenCode. Works alongside [A Team](https://github.com/RBraga01/a-team), [builder-design](https://github.com/RBraga01/builder-design), [builder-product](https://github.com/RBraga01/builder-product), and [builder-growth](https://github.com/RBraga01/builder-growth).

---

## The Four Ways LLM Features Fail in Production

Every one of these has happened to a team that was confident before launch:

**1. Shipped without an eval**
"I tested it and it looked good." The feature worked on the 8 examples you chose. It failed on 30% of real traffic. Nobody knew which prompt change caused it because there was no baseline.

**2. Prompt changed, nobody noticed**
"Small tweak." A single instruction shifted pass rate from 89% to 72%. There was no previous version to compare against. The regression took three weeks to diagnose.

**3. No fallback when the model misbehaved**
Timeout at peak load → blank response → support ticket at 3am. "We'll add error handling after launch." You added it at 3am.

**4. Shipped without a safety review**
"Nobody will try that." Someone did, on day two. The injection vector was in the document upload — not the user message — and it had been there since the first commit.

builder-ai makes each of these a gate your AI assistant must pass before marking any LLM task complete.

---

## What's in the Pack

### Hard Gates — Cannot Be Skipped

| Skill | What It Blocks |
|---|---|
| [`eval-before-ship`](skills/eval-before-ship/SKILL.md) | No LLM feature merges without a named eval suite, documented pass rate, failure analysis, and baseline |
| [`prompt-versioning`](skills/prompt-versioning/SKILL.md) | No prompt goes to production without a version file in `prompts/` and a CHANGELOG entry |
| [`fallback-required`](skills/fallback-required/SKILL.md) | No LLM call ships without tested fallback paths for timeout, malformed output, low confidence, and refusal |

### Workflow Skills — How to Do the Work Right

| Skill | What It Enforces |
|---|---|
| [`rag-pipeline-design`](skills/rag-pipeline-design/SKILL.md) | Data audit + query audit before any pipeline decision — no "standard chunking" shortcuts |
| [`model-benchmarking`](skills/model-benchmarking/SKILL.md) | Task-specific benchmarking across three tiers before committing to a model |
| [`context-optimization`](skills/context-optimization/SKILL.md) | Measure → reduce by hierarchy → measure again — not guessing at token savings |
| [`ai-cost-audit`](skills/ai-cost-audit/SKILL.md) | Token count + call volume + cost at 10× scale before launch, not after the billing alert |
| [`ai-safety-review`](skills/ai-safety-review/SKILL.md) | Four-category review with tested attack surfaces before any feature reaches users |

### Agents — Specialist Roles

| Agent | Role | Model |
|---|---|---|
| [`prompt-engineer`](.claude/agents/prompt-engineer.md) | Writes, versions, and iterates prompts with eval criteria | Sonnet |
| [`eval-designer`](.claude/agents/eval-designer.md) | Designs evaluation suites and writes eval harnesses | Sonnet |
| [`rag-architect`](.claude/agents/rag-architect.md) | Designs and debugs retrieval pipelines | Opus |
| [`model-selector`](.claude/agents/model-selector.md) | Benchmarks models and recommends the cost-optimal choice | Sonnet |
| [`ai-safety-reviewer`](.claude/agents/ai-safety-reviewer.md) | Reviews for injection, hallucination, abuse, and agentic scope | Opus |

---

## How Enforcement Works

Each hard gate defines exactly what an agent must produce — not a checklist to tick, a formatted evidence block it must fill in with real numbers.

An agent reading `eval-before-ship` **cannot** say "task complete" without producing:

```
Eval complete.
Suite: evals/email-classifier/test-set.jsonl — 200 examples
Model: claude-sonnet-4-6, temperature: 0.0, seed: 42
Pass rate: 178/200 = 89% (threshold: ≥ 85% ✓)
Top failure mode: format violation (12 cases — emails > 2000 tokens)
Baseline: v1 = 82% → v2 = 89%, delta: +7pp ✓
Results stored: evals/email-classifier/results-2026-06-07.md
```

"It looks good" does not fill that template. That is the entire point.

Each skill also lists the **Rationalization Red Flags** — the exact things teams say when they want to skip the gate — and explains why each one is wrong. The agent has already read the rebuttals.

---

## Integration with A Team

If [A Team](https://github.com/RBraga01/a-team) is installed, builder-ai slots in with no conflicts:

```bash
cp -r builder-ai/skills/*         your-project/skills/
cp -r builder-ai/.claude/agents/* your-project/.claude/agents/
```

The builder-ai agents can be dispatched by the A Team orchestrator like any other specialist. All names are unique across both packs.

---

## Directory Layout After Installation

```
your-project/
├── skills/                ← drop-in enforcement rules
├── .claude/agents/        ← specialist roles
├── prompts/               ← versioned prompts  (prompt-engineer creates these)
├── evals/                 ← eval suites + results  (eval-designer creates these)
├── benchmarks/            ← model comparison results  (model-selector creates these)
├── cost-audit/            ← cost projections
└── safety-reviews/        ← safety review documents
```

---

## License

MIT — [Ricardo Romão Marques Braga](LICENSE)
