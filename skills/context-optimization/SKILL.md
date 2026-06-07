---
name: context-optimization
description: Use when prompt cost is too high, latency is above threshold, or context window limits are being approached. Requires measurement before and after each reduction. Blocks "I shortened the prompt so it should be cheaper" completions.
---

# Context Optimization

## The Law

```
PROMPT COST IS NOT OPTIMISED BY GUESSING.
"I already have a short prompt" is a guess about token count.
"Reducing context will hurt quality" is a guess about the quality/cost curve.
Measure first. Apply the hierarchy. Measure again. THEN claim improvement.
```

## When to Use

Trigger when:
- Prompt + context exceeds 60% of the model's context window
- p95 latency is above target
- Cost per 1k calls exceeds budget
- RAG pipeline is stuffing too many chunks into each call
- Output quality is degrading on long inputs (long context dilution)

## When NOT to Use

- The feature has < 100 calls/month and total monthly cost is < $20 — optimisation ROI is negative at this volume
- Quality is currently below threshold — fix quality first; optimising a broken pipeline only makes it cheaper to be wrong
- The system prompt changes every call — prompt caching (Level 5) has no effect; skip straight to Level 1–3

## The Reduction Hierarchy

Apply in order. Stop when the target is met. Do not apply all steps preemptively.

### Level 1 — Trim the System Prompt

Audit every sentence:
- Run the prompt without each instruction — does output quality change?
- Remove any instruction the model follows without it
- Remove few-shot examples that duplicate knowledge the model already has
- Replace verbose explanations with single directives

Target: system prompt under 500 tokens for most tasks. Measure token count precisely:

```python
import tiktoken
enc = tiktoken.get_encoding("cl100k_base")
print(len(enc.encode(system_prompt)))
```

### Level 2 — Reduce Retrieved Context

If using RAG, before any other change:
1. Reduce `top_k` by 1 and run eval-before-ship — recall often holds at lower top_k
2. Add or tighten a similarity threshold (filter chunks below 0.75 cosine similarity)
3. Set a hard context budget: `MAX_CONTEXT_TOKENS = context_window × 0.4`

### Level 3 — Compress Retrieved Content

Before injecting:
- Strip document headers, footers, and repeated boilerplate
- Normalise whitespace and remove formatting artefacts
- Convert verbose JSON to compact tabular format
- For chunks over 600 tokens: LLM-summarise to 1/3 length with a fast model

### Level 4 — Split the Pipeline

Move expensive operations to a cheaper model:

```
Before: Frontier model does everything
After:  Fast/cheap model → classify, extract, summarise
        Frontier model → final answer generation only
```

This typically cuts costs 5–10× with minimal quality loss. The frontier model only sees pre-processed, high-signal input.

### Level 5 — Cache Stable Context

If system prompt or retrieval context is identical across many calls:
- Enable prompt caching (Anthropic Beta, OpenAI prompt caching)
- Cache embedding results for repeated queries (TTL matched to data freshness)

Prompt caching saves 50–90% on the cached portion. It is the highest-leverage optimization when the system prompt is long and stable.

## Measuring Before and After

Run this before applying any reduction, and after:

```
Token count:  <input tokens>, <output tokens>, <total>
Latency:      p50 = Xs, p95 = Ys
Cost/1k:      $Z
Quality:      <eval suite pass rate: A%>
```

A reduction that saves 30% cost but drops quality 10% past threshold is not an optimization — it is a regression.

## Rationalization Red Flags

These thoughts mean the prompt has not been measured — stop:

- *"I already have a short prompt"* — count the tokens; "short" is not a token count
- *"Reducing context will hurt quality"* — you don't know until you measure with eval-before-ship
- *"It costs too little to matter now"* — $0.05/call is $1,500/month at 1k calls/day; growth events don't announce themselves; run the 10× projection from ai-cost-audit before calling it negligible
- *"Prompt caching is complex to set up"* — it is a one-line header change; do Level 5 before assuming it's hard
- *"The frontier model is only marginally more expensive"* — at 10k calls/day, "marginally" compounds

## Completion Statement Format

When context-optimization is satisfied, state it like this:

```
Context optimized.
Reductions applied: <list of levels: e.g., L1 (trim), L2 (top_k 10→5), L5 (caching)>

Before:
  Input tokens: N (system: A, context: B, user: C)
  Latency p95: Xs
  Cost/1k: $Y
  Quality: Z% — evals/<feature>/results-<date-before>.md

After:
  Input tokens: N' (system: A', context: B', user: C')
  Latency p95: X's
  Cost/1k: $Y'
  Quality: Z'% — evals/<feature>/results-<date-after>.md ✓ (above threshold)

Delta: -X% cost, -Ys latency, quality delta: Z'% - Z% = ±Xpp
```

Quality must be verified with eval-before-ship — not eyeballed.

## Why This Matters

LLM API costs compound with volume. A pipeline that costs $0.05/call at 1k calls/day costs $1,800/month. The same pipeline at 10k calls/day costs $18,000/month. Optimization at 1k is a 2-hour project. Optimization at 10k is a crisis sprint.
