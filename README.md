<p align="center">
  <img src="assets/builder-ai-logo.png" alt="builder-ai logo" width="160">
</p>

# builder-ai — Build LLM Products That Don't Fail Silently v1.0.0

A drop-in skill and agent pack for teams building LLM-powered products. Three hard gates block work that isn't ready. Five workflow skills cover the full build cycle. Five specialist agents handle prompt engineering, evaluation, RAG, model selection, and safety.

Works standalone on any AI coding assistant. Works alongside [A Team](https://github.com/RBraga01/a-team) if you already have it.

**[→ A Team](https://github.com/RBraga01/a-team)** — the full pre-configured engineering team this pack extends.

---

## What's in the Pack

### Hard Gates — Work That Cannot Ship Without These

| Skill | What It Blocks |
|---|---|
| `eval-before-ship` | No LLM feature ships without documented eval results |
| `prompt-versioning` | No prompt goes to production without version control |
| `fallback-required` | No LLM call ships without a defined fallback for errors and bad outputs |

These are enforced as pre-ship checks. An agent citing these skills cannot mark a task complete without evidence.

### Workflow Skills — How to Do the Work Right

| Skill | When to Use |
|---|---|
| `rag-pipeline-design` | Designing or auditing a RAG pipeline (chunking, embedding, retrieval, reranking) |
| `model-benchmarking` | Selecting or comparing models for a specific task |
| `context-optimization` | Reducing prompt cost and latency without quality loss |
| `ai-cost-audit` | Auditing LLM spend before it becomes a problem |
| `ai-safety-review` | Safety and abuse review before any user-facing LLM feature ships |

### Agents — Specialist Roles

| Agent | Role | Model |
|---|---|---|
| `prompt-engineer` | Writes, versions, and iterates prompts | Sonnet |
| `eval-designer` | Designs evaluation suites and writes eval harnesses | Sonnet |
| `rag-architect` | Designs and debugs retrieval pipelines | Opus |
| `model-selector` | Benchmarks models and recommends the cost-optimal choice | Sonnet |
| `ai-safety-reviewer` | Reviews for injection, hallucination, abuse, and agentic scope | Opus |

---

## Installation

### Option A — Copy the folders

```bash
# Clone (shallow)
git clone --depth 1 https://github.com/RBraga01/builder-ai.git

# Copy into your project
cp -r builder-ai/skills  your-project/
cp -r builder-ai/.claude your-project/
```

### Option B — Use alongside A Team

If you already have A Team installed:

```bash
# Add builder-ai skills to your existing skills directory
cp -r builder-ai/skills/* your-project/skills/

# Add builder-ai agents to your existing agents directory
cp -r builder-ai/.claude/agents/* your-project/.claude/agents/
```

The agents and skills are additive — they don't replace anything in A Team.

---

## How It Works

### Skills

Skills are markdown files your AI coding assistant reads. When you're building an LLM feature, the agent reads the relevant skill and follows its process.

Example: before merging a PR that changes a prompt, mention `eval-before-ship` and the agent will require documented eval results before marking the task complete.

### Agents

Agents are specialist roles your AI assistant can adopt. Use them explicitly:

- `Use prompt-engineer to write the system prompt for the email classifier`
- `Use eval-designer to build a test suite for the summarisation feature`
- `Use ai-safety-reviewer to review the document Q&A feature before we ship`

### Hard Gates vs. Workflow Skills

**Hard gates** (`eval-before-ship`, `prompt-versioning`, `fallback-required`) are mandatory checkpoints. The agent cannot complete a task that requires them without evidence they were satisfied.

**Workflow skills** (`rag-pipeline-design`, `model-benchmarking`, etc.) are process guides — rich, structured instructions for how to approach a specific type of work.

---

## Why This Exists

Most LLM features fail in one of four ways:
1. **No eval** — shipped based on vibes, broke silently in production
2. **No versioning** — "the old prompt worked better" but nobody can find it
3. **No fallback** — model timeout → blank screen → angry user
4. **No safety review** — "we didn't think anyone would try that"

This pack makes each of those a gate, not a suggestion.

---

## License

MIT — use freely, attribution appreciated.
