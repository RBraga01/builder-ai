---
name: context-optimization
description: Use when a prompt is approaching context limits, latency is too high, or cost per call is unacceptable — structured context reduction without quality loss.
---

# Context Optimization

## When to Use

- Prompt + context exceeds 60% of the model's context window
- p95 latency is above acceptable threshold
- Cost per call is above budget
- Retrieval is stuffing too many chunks into the context
- Output quality is degrading (long context dilution)

## The Hierarchy of Reductions

Apply in this order — stop when the quality/cost target is met.

### 1 — Trim the System Prompt

Audit every sentence in the system prompt:
- Remove any instruction that is always followed without it (test by removing and measuring)
- Remove examples that duplicate what the model already knows
- Replace verbose explanations with concise directives
- Target: system prompt under 500 tokens for most tasks

### 2 — Reduce Retrieved Context

If using RAG:
- Lower `top_k` by 1 and measure faithfulness — often 3 chunks is as good as 10
- Add a reranker to select the most relevant chunks rather than passing all of them
- Set a hard context budget: `MAX_CONTEXT_TOKENS = context_window * 0.4`
- Filter chunks below cosine similarity threshold before injecting

### 3 — Compress Retrieved Content

Before injecting chunks:
- Strip headers, footers, and boilerplate from source documents
- Remove repeated whitespace and formatting artefacts
- For structured data: convert verbose JSON to a compact tabular format
- Consider a summarisation pre-pass for very long chunks (LLM-summarise to 1/3 length)

### 4 — Use a Cheaper + Faster Model for Pre-processing

Split the pipeline:
- **Small/fast model**: classify, filter, extract key fields, summarise context
- **Frontier model**: final answer generation only

This often cuts costs 5–10× with minimal quality loss.

### 5 — Cache Repeated Context

If the system prompt or retrieval context is the same across many calls:
- Use prompt caching (Anthropic / OpenAI both support this)
- Cache embeddings and retrieved chunks for identical queries
- Set TTL appropriate to data freshness requirements

## Measurement Protocol

Before and after each reduction:
1. Run the eval suite (eval-before-ship)
2. Measure: token count, latency p50/p95, cost per 1k calls
3. Stop reducing when quality drops below threshold

## Verification Checklist

- [ ] System prompt audited and trimmed to minimum effective form
- [ ] Retrieved context count reduced and reranker added if applicable
- [ ] Hard context budget set (context_window × 0.4 max for context)
- [ ] Pre-processing pipeline considered for expensive operations
- [ ] Prompt caching enabled for stable context segments
- [ ] Eval run before and after — quality regression verified as acceptable
- [ ] Token count, latency, and cost delta documented
