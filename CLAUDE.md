# builder-ai — Build LLM Products That Don't Fail Silently v1.0.0

A drop-in skill and agent pack for teams building LLM-powered products. Three hard gates block
incomplete work. Five workflow skills cover the full build cycle. Five specialist agents handle
prompt engineering, evaluation, RAG, model selection, and safety.

Works standalone. Works alongside A Team.

## Skills in This Pack

### Hard Gates (mandatory before shipping)

- `eval-before-ship` — no LLM feature ships without documented eval results
- `prompt-versioning` — all prompts must be versioned in `prompts/`
- `fallback-required` — every LLM call must have a fallback path

### Workflow Skills

- `rag-pipeline-design` — chunking, embedding, retrieval, reranking, generation
- `model-benchmarking` — structured benchmarking before committing to a model
- `context-optimization` — reduce cost and latency without quality loss
- `ai-cost-audit` — audit and project LLM API spend
- `ai-safety-review` — injection, hallucination, abuse, and agentic scope review

## Agents in This Pack

| Agent | Trigger |
|---|---|
| `prompt-engineer` | Writing, iterating, or debugging prompts |
| `eval-designer` | Designing evaluation suites for LLM outputs |
| `rag-architect` | Designing or debugging retrieval pipelines |
| `model-selector` | Selecting the cost-optimal model for a task |
| `ai-safety-reviewer` | Safety and abuse review before user-facing features ship |

## Expected Directory Layout After Installation

```
your-project/
├── prompts/              ← versioned prompts (created by prompt-engineer)
│   └── feature-name/
│       ├── v1.0.0.md
│       └── CHANGELOG.md
├── evals/                ← eval suites and results (created by eval-designer)
│   └── feature-name/
│       ├── test-set.jsonl
│       └── results-<date>.md
├── benchmarks/           ← model comparison results (created by model-selector)
├── cost-audit/           ← cost audit reports (created by ai-cost-audit skill)
├── safety-reviews/       ← safety review documents (created by ai-safety-reviewer)
├── skills/               ← this pack's skills
└── .claude/agents/       ← this pack's agents
```

## Using Hard Gates

When an agent encounters a task that requires a hard gate, it must:
1. Read the relevant skill file
2. Follow the process
3. Produce the required evidence (eval results, versioned prompt, fallback tests)
4. Only then mark the task complete

"Looks good" is not evidence. The skill files specify exactly what counts.
