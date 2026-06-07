---
name: ai-cost-audit
description: Use before launching any LLM feature or when monthly API costs are growing unexpectedly. Requires token count measurement, call volume analysis, and cost projection at 10× scale. Blocks "it's cheap enough now" completions.
---

# AI Cost Audit

## The Law

```
EVERY LLM FEATURE HAS A COST TRAJECTORY. DISCOVER IT BEFORE 10× SCALE DISCOVERS YOU.
"It's cheap enough now" is a claim about current volume, not future volume.
"The API has reasonable pricing" is not a projection.
Token counts + call volume + cost at 10× scale IS a cost audit.
```

## When to Use

Trigger:
- Before launching any LLM feature (pre-launch projection)
- When monthly API bill increased > 20% with no obvious cause
- Before scaling a feature to a new user segment
- Before committing to a model or provider for a high-volume use case

## When NOT to Use

- Internal one-off scripts or developer tools with < 50 calls/day — cost is negligible; write the call, move on
- Features still in prototype where the call structure will change significantly before launch — audit after the design stabilises
- When total monthly API cost is guaranteed < $50 regardless of 10× scale — skip the audit, check the bill quarterly

## The Process

### Step 1 — Count Tokens Precisely

Do not estimate. Count:

```python
import tiktoken

enc = tiktoken.get_encoding("cl100k_base")  # cl100k for GPT/Claude

def count_tokens(text: str) -> int:
    return len(enc.encode(text))

# Measure each segment separately
print("System prompt:", count_tokens(system_prompt))
print("Avg context:", count_tokens(avg_context_sample))
print("Avg user message:", count_tokens(avg_user_message_sample))
print("Avg output:", count_tokens(avg_output_sample))
```

Get real samples from logs or representative test data — not the "hello world" example.

### Step 2 — Measure Call Volume

```
Calls per user session: N
Sessions per day: M
Background/batch calls per day: K
Retry rate: R% (from logs or estimate)
Total calls per day: (N × M) + K × (1 + R/100)
```

### Step 3 — Calculate Current Cost

```python
COST_PER_1K_INPUT  = 0.003   # $/1k tokens — replace with actual model pricing
COST_PER_1K_OUTPUT = 0.015

def cost_per_call(input_tokens, output_tokens):
    return (input_tokens / 1000 * COST_PER_1K_INPUT
          + output_tokens / 1000 * COST_PER_1K_OUTPUT)

daily_cost    = cost_per_call(avg_input, avg_output) * calls_per_day
monthly_cost  = daily_cost * 30
```

### Step 4 — Project at 10× Scale

Scale is never gradual — launches cause spikes. Always project at 10×:

| Scale | Calls/day | Monthly cost | Verdict |
|---|---|---|---|
| Current (1×) | N | $X | Baseline |
| 10× | 10N | $10X | **Must be under budget** |
| 100× | 100N | $100X | Directional awareness |

If 10× monthly cost exceeds your budget threshold, optimise before scaling.

### Step 5 — Identify Top Cost Drivers

Rank by token contribution:

```
1. Context injection (RAG chunks): 3,200 tokens avg — 68% of input cost
2. System prompt: 800 tokens — 17% of input cost
3. User message: 200 tokens — 4% of input cost
4. Output: 400 tokens — 11% of total cost
```

Optimise the top driver first. The others compound on the same multiplier.

### Step 6 — Apply Reduction Levers

| Lever | Typical Saving | Apply When |
|---|---|---|
| Prompt caching | 50–90% on cached input | System prompt > 500 tokens and stable |
| Reduce top_k in RAG | 20–50% input token reduction | Context injection is top cost driver |
| Downgrade model tier | 3–10× cost reduction | Quality meets threshold at lower tier (see model-benchmarking) |
| Semantic caching | 30–70% call reduction | High repeat query rate |
| Pipeline splitting | 5–10× cost reduction | Frontier model doing pre-processing tasks |
| Output cap | 10–30% output cost | `max_tokens` not set or set too high |

### Step 7 — Document

Store in `cost-audit/<feature>/<date>.md`:

```
## AI Cost Audit — <feature> — <date>

Token breakdown (averages from N samples):
  System prompt: X tokens
  Context: Y tokens
  User message: Z tokens
  Output: W tokens
  Total per call: T tokens

Call volume: N calls/day (M sessions × P calls + K background)
Retry rate: R%

Cost at current volume: $X/month
Cost at 10× volume: $10X/month

Top driver: <context injection — Y tokens, Z%>

Reductions applied:
  1. <lever> — estimated saving: X%
  2. <lever> — estimated saving: Y%

Post-optimization projection: $X'/month at 10×
```

## Rationalization Red Flags

These thoughts mean no cost audit was done — stop:

- *"It's cheap enough now"* — at what volume? with what growth rate?
- *"We'll deal with costs when they're a problem"* — you'll deal with them at 3am after the billing alert fires
- *"The model pricing is reasonable"* — "reasonable" has no units; calculate the monthly figure
- *"It's not a consumer product so usage will be low"* — internal tools get the most surprising usage
- *"The context is only a few paragraphs"* — a few paragraphs is 400–800 tokens; multiply by call volume

## Completion Statement Format

When ai-cost-audit is satisfied, state it like this:

```
Cost audit complete.
Avg input: N tokens (system: A, context: B, user: C)
Avg output: M tokens
Calls/day: D (retry rate: R%)

Current cost: $X/month
Cost at 10× scale: $Y/month (budget threshold: $Z/month ✓/⚠️)

Top cost driver: <driver> (N% of input cost)
Reductions planned: <levers> — projected saving: X%
Post-reduction projection at 10×: $Y'/month

Token samples from: <N representative calls from logs / test data — not estimated>
Stored: cost-audit/<feature>/<date>.md ✓
```

## Why This Matters

LLM API costs are invisible until they aren't. A feature that costs $200/month at launch costs $20,000/month after a growth event. The audit takes two hours. The surprise does not.
