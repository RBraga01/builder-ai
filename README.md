# builder-ai — Build LLM Products That Don't Fail Silently v1.0.0

A drop-in skill and agent pack for teams building LLM-powered products.

**3 hard gates** block work that isn't ready to ship. **5 workflow skills** cover the full build cycle: RAG design, model selection, cost auditing, context optimisation, safety review. **5 specialist agents** handle prompt engineering, evaluation, retrieval architecture, model selection, and safety.

Works standalone on any AI coding assistant. Works alongside [A Team](https://github.com/RBraga01/a-team) if you already have it.

**[→ A Team](https://github.com/RBraga01/a-team)** — the full pre-configured engineering team this pack extends.

---

## Installation

**Mac / Linux / WSL:**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/RBraga01/builder-ai/main/install.sh)
```

**Windows PowerShell:**
```powershell
irm https://raw.githubusercontent.com/RBraga01/builder-ai/main/install.ps1 | iex
```

To install into a specific project directory:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/RBraga01/builder-ai/main/install.sh) /path/to/project
```

Or copy manually:
```bash
git clone --depth 1 https://github.com/RBraga01/builder-ai.git
cp -r builder-ai/skills  your-project/
cp -r builder-ai/.claude your-project/
```

---

## What's in the Pack

### Hard Gates — Work That Cannot Ship Without These

| Skill | The Law |
|---|---|
| [`eval-before-ship`](skills/eval-before-ship/SKILL.md) | An LLM feature is not ready until numbers exist |
| [`prompt-versioning`](skills/prompt-versioning/SKILL.md) | A prompt without a version number cannot be debugged, rolled back, or improved |
| [`fallback-required`](skills/fallback-required/SKILL.md) | LLM calls without fallbacks are ticking failures |

Hard gates are enforced by agents: they cannot mark a task complete without evidence the gate was satisfied — not a checkbox, actual results.

### Workflow Skills — How to Do the Work Right

| Skill | The Law |
|---|---|
| [`rag-pipeline-design`](skills/rag-pipeline-design/SKILL.md) | You cannot design a RAG pipeline without first auditing the data and the queries |
| [`model-benchmarking`](skills/model-benchmarking/SKILL.md) | A model is not chosen until it has been tested on your task data |
| [`context-optimization`](skills/context-optimization/SKILL.md) | Prompt cost is not optimised by guessing — measure, reduce by hierarchy, measure again |
| [`ai-cost-audit`](skills/ai-cost-audit/SKILL.md) | Every LLM feature has a cost trajectory — discover it before 10× scale discovers you |
| [`ai-safety-review`](skills/ai-safety-review/SKILL.md) | An LLM feature is not safe until an adversary has tried to break it |

### Agents — Specialist Roles

| Agent | Role | Model |
|---|---|---|
| [`prompt-engineer`](.claude/agents/prompt-engineer.md) | Writes, versions, and iterates prompts | Sonnet |
| [`eval-designer`](.claude/agents/eval-designer.md) | Designs evaluation suites and writes eval harnesses | Sonnet |
| [`rag-architect`](.claude/agents/rag-architect.md) | Designs and debugs retrieval pipelines | Opus |
| [`model-selector`](.claude/agents/model-selector.md) | Benchmarks models and recommends the cost-optimal choice | Sonnet |
| [`ai-safety-reviewer`](.claude/agents/ai-safety-reviewer.md) | Reviews for injection, hallucination, abuse, and agentic scope | Opus |

---

## How Hard Gates Work

Each hard gate skill defines:
1. **The Law** — the immutable rule in a code block
2. **What counts as evidence** — specific fields required to satisfy the gate
3. **Rationalization Red Flags** — the things teams say when they want to skip it
4. **Completion Statement Format** — the exact output an agent must produce

An agent reading `eval-before-ship` cannot say "task complete" without producing:
```
Eval complete.
Suite: evals/<feature>/test-set.jsonl — N examples
Pass rate: A/N = B% (threshold: ≥ C% ✓)
Top failure mode: <category> (N cases)
Baseline: <previous> = X% → this version = Y%, delta: +Zpp ✓
Results stored: evals/<feature>/results-<date>.md
```

"It looks good" does not satisfy this format. That is by design.

---

## Why This Exists

Most LLM products fail in one of four ways — and all four are silent:

1. **No eval** — shipped on vibes, broke silently, nobody knew which prompt change caused it
2. **No versioning** — "the old prompt worked better" but nobody can find what the old prompt was
3. **No fallback** — model timeout → blank screen → support ticket at 3am
4. **No safety review** — "we didn't think anyone would try that"

This pack makes each one a gate, not a suggestion.

---

## Integration with A Team

If A Team is installed in your project, builder-ai slots in with no conflicts:

```bash
# Add builder-ai skills alongside A Team skills
cp -r builder-ai/skills/* your-project/skills/
cp -r builder-ai/.claude/agents/* your-project/.claude/agents/
```

The builder-ai agents can be dispatched by the A Team orchestrator like any other specialist. All skill and agent names are unique across both packs.

---

## Directory Layout After Installation

```
your-project/
├── skills/
│   ├── eval-before-ship/SKILL.md
│   ├── prompt-versioning/SKILL.md
│   ├── fallback-required/SKILL.md
│   ├── rag-pipeline-design/SKILL.md
│   ├── model-benchmarking/SKILL.md
│   ├── context-optimization/SKILL.md
│   ├── ai-cost-audit/SKILL.md
│   └── ai-safety-review/SKILL.md
├── .claude/agents/
│   ├── prompt-engineer.md
│   ├── eval-designer.md
│   ├── rag-architect.md
│   ├── model-selector.md
│   └── ai-safety-reviewer.md
├── prompts/           ← versioned prompts (created by prompt-engineer)
├── evals/             ← eval suites and results (created by eval-designer)
├── benchmarks/        ← model comparison results (created by model-selector)
├── cost-audit/        ← cost audit reports
└── safety-reviews/    ← safety review documents
```

---

## License

MIT — [LICENSE](LICENSE)
