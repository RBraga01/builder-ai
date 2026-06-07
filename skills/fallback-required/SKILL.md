---
name: fallback-required
description: Blocks any LLM call from shipping without a defined fallback path for model errors, timeouts, and low-confidence outputs.
---

# Fallback Required

## The Law

Every LLM call in production must have a fallback. Models fail silently, time out, return malformed output, and hallucinate. Callers that don't handle these cases will fail visibly for users at the worst time.

## When to Use

Trigger on every PR that:
- Adds a new LLM API call
- Changes an existing LLM call's error handling
- Introduces streaming or async generation
- Adds a new agent or tool invocation

## Required Fallback Patterns

Each LLM call must handle all four failure modes:

| Failure Mode | Required Handling |
|---|---|
| API error / timeout | Retry with exponential backoff (max 3 attempts), then graceful degradation |
| Malformed output | Output schema validation + fallback to rule-based default |
| Low confidence | Confidence threshold check — route to human review or simpler model |
| Content filter / refusal | Detect refusal patterns, return user-facing error, do not surface raw refusal |

## Minimum Code Pattern

```python
async def call_llm(prompt: str) -> Result:
    for attempt in range(MAX_RETRIES):
        try:
            response = await llm.complete(prompt, timeout=TIMEOUT_SECONDS)
            parsed = parse_output(response)         # raises on malformed
            if parsed.confidence < CONFIDENCE_THRESHOLD:
                return fallback_result(reason="low_confidence")
            return parsed
        except TimeoutError:
            if attempt == MAX_RETRIES - 1:
                return fallback_result(reason="timeout")
            await backoff(attempt)
        except OutputParseError:
            return fallback_result(reason="malformed_output")
        except RefusalError:
            return fallback_result(reason="refused")
    return fallback_result(reason="max_retries_exceeded")
```

## The Process

1. Before writing the LLM call, define what `fallback_result()` returns for this feature
2. Implement the four failure handlers
3. Write tests for each failure mode — mock the API to force each case
4. Log all fallback invocations with reason and frequency
5. Set up alerts if fallback rate exceeds threshold (e.g., > 5% of calls in 5 min)

## Verification Checklist

- [ ] Timeout and retry logic implemented with exponential backoff
- [ ] Output schema validation present — malformed output does not propagate
- [ ] Confidence threshold defined and checked
- [ ] Refusal / content filter detection implemented
- [ ] Fallback path returns a valid, user-safe response
- [ ] Tests exist for each failure mode
- [ ] Fallback events logged with reason field
- [ ] Alert threshold configured
