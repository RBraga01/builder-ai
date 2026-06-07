---
name: eval-before-ship
description: Use before merging, deploying, or demo'ing any LLM feature. Requires documented eval results — pass rate, failure analysis, baseline comparison. Blocks "it looked good when I tested it" completions.
---

# Eval Before Ship

## The Law

```
AN LLM FEATURE IS NOT READY UNTIL NUMBERS EXIST.
"It looked good when I tested it" is not an eval.
"I ran a few examples and it worked" is not an eval.
A named suite, a defined metric, a pass rate, a failure analysis,
and a baseline comparison IS an eval. All five. Not four.
```

## When to Use

Trigger before any of these:
- Merging a PR that adds or modifies a prompt
- Deploying an LLM feature to any environment users can reach
- Switching models or providers on an existing feature
- Changing retrieval logic, rerankers, or chunk strategy in a RAG pipeline
- Updating few-shot examples or system prompt structure

## When NOT to Use

- Exploratory prototypes that will not reach users (note it: "eval required before production")
- Config-only changes that cannot affect model output (timeouts, logging, env vars)

## What Counts as an Eval

An eval must have all five components:

| Component | What It Means | What Does NOT Count |
|---|---|---|
| Named test suite | File with labelled examples in `evals/` | "I tested it manually" |
| Defined metric | Accuracy %, faithfulness score, task pass rate | "It seemed accurate" |
| Pass threshold | Explicit minimum (e.g., ≥ 85%) | No threshold = no standard |
| Failure analysis | ≥ 5 failures examined and categorised | "There were a few errors" |
| Baseline comparison | This version vs. previous version or control | First release exempt; all subsequent require it |

## The Process

### Step 1 — Define the Eval Before Writing the Prompt

Answer these before touching the prompt:
- What does a correct output look like for this task?
- What metric will you use to measure it?
- What is the minimum acceptable score for production?

If you cannot answer these before building, the task is not well enough specified to build.

### Step 2 — Build a Representative Test Set

```
evals/
  <feature-name>/
    test-set.jsonl     ← labelled examples, one JSON object per line
    harness.py         ← eval runner
    results-<date>.md  ← documented results
```

`test-set.jsonl` format:
```json
{"id": "001", "input": "...", "expected": "...", "tags": ["edge-case"]}
```

Label ground truth **before** running any model. Seeing outputs first contaminates labels.

Minimum 50 examples; 200+ for features used at volume. Include: edge cases, short inputs, long inputs, ambiguous inputs, adversarial rephrasing.

### Step 3 — Run and Record

```bash
python evals/<feature-name>/harness.py --model <model-id> --seed 42
```

Record: pass rate (X/N = Y%), latency p50/p95, failure category breakdown.

### Step 4 — Analyse Failures

Examine every failing case. Assign each to one category:
- **Format violation** — wrong output structure
- **Factual error** — wrong answer when correct answer was in context
- **Hallucination** — claim not grounded in any provided context
- **Refusal** — model declined a legitimate request
- **Off-topic** — response doesn't address the input

The most common failure category is your next fix.

### Step 5 — Document

```
Suite: evals/email-classifier/test-set.jsonl (200 examples)
Model: claude-sonnet-4-6, temperature: 0.0, seed: 42

Pass rate: 178/200 = 89% (threshold: ≥ 85% ✓)

Failure breakdown:
  - Format violation: 12 (long emails > 2000 tokens)
  - Hallucination: 10 (invented labels not in schema)

Baseline: v1 (82%) → v2 (89%), delta: +7pp ✓
Results: evals/email-classifier/results-2026-06-07.md
```

## Rationalization Red Flags

These thoughts mean you have NOT completed an eval — stop and build one:

- *"I ran it manually and it looked good"* — you tested a sample you chose; an eval tests a sample that represents the distribution
- *"We'll add evals after we ship"* — the regression will be a 2-week cycle: 3 days to notice, 2 days to diagnose with no baseline, 1 week to ship the fix; the eval would have taken a day
- *"The model always does this correctly"* — based on how many labelled examples?
- *"It's only an internal tool"* — internal tools fail the same ways, just with fewer headlines
- *"This is a small prompt change"* — adding a single instruction shifted one team's pass rate from 89% to 72%; "small" has no meaning in output distribution terms
- *"We don't have time to build a test set"* — you have time to diagnose production failures?

## Completion Statement Format

When eval-before-ship is satisfied, state it like this:

```
Eval complete.
Suite: evals/<feature>/test-set.jsonl — N examples
Model: <model-id>, temperature: X, seed: Y
Pass rate: A/N = B% (threshold: ≥ C% ✓)
Top failure mode: <category> (N cases — <root cause>)
Failure analysis: evals/<feature>/failure-analysis-<date>.md ✓
Baseline: <previous> = X% → this version = Y%, delta: +Zpp ✓
  [First release: baseline field may be marked "N/A — initial version"]
Results stored: evals/<feature>/results-<date>.md ✓
```

The pass rate, failure analysis, and baseline comparison are not optional. On the first release, baseline may be marked "N/A — initial version"; for all subsequent releases it is required.

## Why This Matters

LLM outputs are stochastic. A prompt that works on the examples you tried does not predict performance on the next 1000 inputs. Eval suites catch regressions before users do — and they make it possible to improve without guessing.
