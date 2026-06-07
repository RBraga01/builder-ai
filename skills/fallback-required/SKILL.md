---
name: fallback-required
description: Use before merging any PR that adds an LLM API call. Every call must handle timeout, malformed output, low confidence, and refusal — with a defined, user-safe fallback for each. Blocks "add error handling later" completions.
---

# Fallback Required

## The Law

```
LLM CALLS WITHOUT FALLBACKS ARE TICKING FAILURES.
Every model times out. Every model returns garbage sometimes.
"The model is reliable" is a claim about averages — users experience tails.
A defined, tested fallback path for each failure mode IS reliability.
```

## When to Use

Trigger on every PR that:
- Adds a new LLM API call
- Changes existing error handling on a model call
- Adds streaming or async generation
- Introduces tool use or agentic function calls

## When NOT to Use

- Offline batch jobs where failures can be retried with human review and no user is waiting
- Exploratory prototypes not going to production

## The Four Failure Modes

Every LLM call must handle all four:

| Failure Mode | What Happens | Required Response |
|---|---|---|
| Timeout / API error | Network down, provider outage, slow response | Retry with exponential backoff (max 3), then graceful degradation |
| Malformed output | Wrong format, truncated JSON, schema violation | Schema validation → fallback to rule-based default |
| Low confidence | Model expresses uncertainty, output score below threshold | Route to fallback model, simpler rule, or human review |
| Refusal | Model declines to answer, content filter triggered | Detect refusal pattern → user-friendly error, do not surface raw refusal |

## The Process

### Step 1 — Define the Fallback Before Writing the Call

Before writing the LLM call, answer: *what does this feature return when the model fails?*

The fallback must be:
- **User-safe** — no error stack traces, no raw model output
- **Defined** — not "we'll figure it out" but a concrete response or behaviour
- **Logged** — every fallback invocation records the reason

### Step 2 — Implement All Four Handlers

```python
async def call_llm(prompt: str) -> Result:
    for attempt in range(MAX_RETRIES):
        try:
            response = await llm.complete(
                prompt, timeout=TIMEOUT_SECONDS
            )
            parsed = parse_and_validate(response)   # raises OutputParseError on bad schema
            if parsed.confidence < CONFIDENCE_THRESHOLD:
                log_fallback("low_confidence", attempt)
                return fallback_result(reason="low_confidence")
            return parsed
        except TimeoutError:
            if attempt == MAX_RETRIES - 1:
                log_fallback("timeout", attempt)
                return fallback_result(reason="timeout")
            await backoff(attempt)
        except OutputParseError:
            log_fallback("malformed_output", attempt)
            return fallback_result(reason="malformed_output")
        except RefusalError:
            log_fallback("refused", attempt)
            return fallback_result(reason="refused")
    return fallback_result(reason="max_retries_exceeded")
```

### Step 3 — Write Tests for Each Failure Mode

```python
def test_returns_fallback_on_timeout():
    with mock_llm_timeout():
        result = call_llm("...")
    assert result.is_fallback is True
    assert result.reason == "timeout"

def test_returns_fallback_on_malformed_output():
    with mock_llm_response("not valid json{{{"):
        result = call_llm("...")
    assert result.is_fallback is True
```

A fallback without a test is a promise, not an implementation.

### Step 4 — Configure Alerting

Set an alert if fallback rate exceeds threshold (e.g., > 5% of calls in 5 min). High fallback rates signal prompt regressions, provider incidents, or input distribution shifts — none of which should be silent.

## Rationalization Red Flags

These thoughts mean fallback handling is incomplete — stop:

- *"The model is reliable enough"* — p99 reliability at 100 calls/day is 3.65 failures/year; at 10,000 calls/day it is 365
- *"We can add error handling after launch"* — you will add it at 2am after the first incident
- *"It's an internal tool, nobody will notice"* — internal users file bugs when things fail silently
- *"The API has its own retry logic"* — provider retries don't produce your application's fallback response
- *"The model almost never refuses"* — "almost never" is a production incident waiting for volume

## Completion Statement Format

When fallback-required is satisfied, state it like this:

```
Fallbacks implemented.
Timeout/API error: retry (max N, backoff Xs–Ys), then fallback_result("timeout") ✓
Malformed output: schema validation → fallback_result("malformed_output") ✓
Low confidence: threshold = X → fallback_result("low_confidence") ✓
Refusal: refusal pattern detection → fallback_result("refused") ✓
Tests: 4 failure-mode tests passing ✓
Fallback logging: reason field → <log destination> ✓
Alert: fallback rate > N% triggers <alert channel> ✓
```

All four modes required. A partially-handled call is an unhandled call.

## Why This Matters

LLM products fail differently than deterministic software. Timeouts spike under load. Output schemas break when models update. Confidence degrades on edge-case inputs. The fallback IS the product's reliability — the model is just the happy path.
