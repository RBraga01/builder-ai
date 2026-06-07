---
name: ai-cost-audit
description: Use when LLM API costs are unconstrained, growing unexpectedly, or before launching a feature to estimate spend at scale.
---

# AI Cost Audit

## When to Use

- Before launching any LLM feature (pre-launch cost projection)
- When monthly API bill increased > 20% with no obvious cause
- When scaling a feature and unsure of cost trajectory
- Before committing to a model or provider

## Cost Drivers to Audit

### Input Tokens

Most expensive single driver. Audit:
- System prompt length (run `tiktoken` / model tokeniser — count precisely)
- Average user message length (measure from production logs)
- Injected context size (chunks, tool results, history)
- Few-shot examples in prompt (often removable)

### Output Tokens

- Are you requesting longer outputs than you use?
- Are you streaming and stopping early? If so, are you billed for the full generation?
- Set `max_tokens` to the minimum that covers 99% of valid outputs

### Call Volume

- Calls per user session
- Calls per background job
- Re-calls on retry (are retries counted? are they necessary?)
- Cache hit rate — what % of calls are duplicate or near-duplicate?

### Model Tier

- Is every call using the frontier model? Could pre-processing use a smaller model?
- Are classification / routing decisions using a cheap model?

## Cost Projection Formula

```
monthly_cost = (calls_per_day × 30)
             × ((avg_input_tokens × input_price_per_1k / 1000)
               + (avg_output_tokens × output_price_per_1k / 1000))
```

Run projections at 1×, 10×, and 100× current volume. If 10× projection exceeds budget, optimise before scaling.

## Reduction Levers

| Lever | Typical Saving |
|---|---|
| Prompt caching (Anthropic / OpenAI) | 50–90% on cached input |
| Downgrade system prompt model tier | 3–10× cheaper |
| Reduce top_k in RAG | 20–50% fewer input tokens |
| Semantic deduplication / caching | 30–70% fewer calls |
| Batching async requests | Better throughput, same cost |
| Output length cap | 10–30% cheaper output |

## Audit Deliverable

Create `cost-audit/<feature>/<date>.md` with:
- Current monthly cost (measured or projected)
- Top 3 cost drivers with token counts
- Cost at 10× scale
- Reduction plan with expected savings
- Post-optimisation projection

## Verification Checklist

- [ ] Input token count measured precisely (system prompt + context + average user message)
- [ ] Output `max_tokens` set to minimum viable
- [ ] Call volume logged and counted (calls/session, calls/day)
- [ ] Retry rate measured
- [ ] Cache hit rate measured or estimated
- [ ] Cost at 10× volume projected
- [ ] Reduction plan written with expected savings
- [ ] Results stored in `cost-audit/`
