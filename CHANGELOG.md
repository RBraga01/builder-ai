# Changelog

All notable changes to builder-ai are documented here.

## [1.0.0] — 2026-06-07

### Added

**Hard gate skills**
- `eval-before-ship` — blocks LLM features without documented eval results (pass rate, failure modes, baseline comparison)
- `prompt-versioning` — enforces versioned prompts in `prompts/<feature>/v<x.y.z>.md` with frontmatter and CHANGELOG
- `fallback-required` — blocks LLM calls without defined fallback for timeout, malformed output, low confidence, and refusal

**Workflow skills**
- `rag-pipeline-design` — full pipeline design guide: chunking strategy, embedding validation, hybrid retrieval, reranking, generation
- `model-benchmarking` — structured benchmarking framework: task definition, test set, candidate comparison, cost-quality table
- `context-optimization` — cost and latency reduction: prompt trimming, chunk reduction, compression, pipeline splitting, caching
- `ai-cost-audit` — spend audit and projection: token counting, call volume, cost at 10× scale, reduction levers
- `ai-safety-review` — safety review: prompt injection, hallucination risk, output safety, agentic scope, abuse resistance

**Agents**
- `prompt-engineer` (Sonnet) — writes, versions, and iterates prompts with eval criteria
- `eval-designer` (Sonnet) — designs eval suites, writes harness code, LLM-as-judge calibration
- `rag-architect` (Opus) — data and query audit before pipeline design, retrieval failure diagnosis
- `model-selector` (Sonnet) — four-stage benchmarking: define bar, build test set, benchmark candidates, recommend
- `ai-safety-reviewer` (Opus) — four-category review: injection, hallucination, output safety, agentic scope
