# builder-ai — Agent & Skill Roster v1.0.0

## Hard Gate Skills

| Skill | Description | Triggers |
|---|---|---|
| `eval-before-ship` | Blocks LLM features without documented eval results | Before any PR that adds or modifies a prompt or model |
| `prompt-versioning` | Enforces prompt version control in `prompts/` | Whenever writing or modifying a prompt |
| `fallback-required` | Blocks LLM calls without defined fallback paths | Before any PR that adds an LLM API call |

## Workflow Skills

| Skill | Description | Triggers |
|---|---|---|
| `rag-pipeline-design` | RAG pipeline design: chunking, embedding, retrieval, reranking, generation | Designing or auditing a RAG feature |
| `model-benchmarking` | Structured model comparison with cost-quality analysis | Selecting a model for any feature |
| `context-optimization` | Context reduction: prompt trimming, chunk reduction, caching | Latency or cost issues, or approaching context limits |
| `ai-cost-audit` | LLM spend audit and projection | Pre-launch cost estimate or unexpected cost growth |
| `ai-safety-review` | Safety review: injection, hallucination, abuse, agentic scope | Before any user-facing LLM feature ships |

## Agents

| Agent | Tier | Model | Trigger |
|---|---|---|---|
| `prompt-engineer` | Tier 2 | claude-sonnet-4-6 | Writing, iterating, or debugging prompts |
| `eval-designer` | Tier 2 | claude-sonnet-4-6 | Designing eval suites, writing harness code |
| `rag-architect` | Tier 1 | claude-opus-4-8 | Designing or debugging retrieval pipelines |
| `model-selector` | Tier 2 | claude-sonnet-4-6 | Model comparison and selection |
| `ai-safety-reviewer` | Tier 1 | claude-opus-4-8 | Safety review before user-facing features ship |

## Integration with A Team

If A Team is installed, builder-ai agents and skills slot in alongside the existing roster. No conflicts — all names are unique. builder-ai agents can be dispatched by the A Team orchestrator like any other specialist.
