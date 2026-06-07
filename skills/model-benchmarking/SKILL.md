---
name: model-benchmarking
description: Use when selecting a model for any production feature, or evaluating whether to switch models. Requires task-specific benchmarking — not leaderboard lookup. Blocks "GPT-4 is the best model" decisions.
---

# Model Benchmarking

## The Law

```
A MODEL IS NOT CHOSEN UNTIL IT HAS BEEN TESTED ON YOUR TASK DATA.
Leaderboard scores are averaged over tasks you're not building.
"It's the best model" is a claim about benchmarks someone else ran.
Task data + defined metric + three tested tiers IS a model selection.
```

## When to Use

Trigger when:
- Choosing a model for any new production feature
- Considering a switch to a newer, cheaper, or faster model
- Validating that a smaller model can replace a larger one
- Comparing providers (OpenAI, Anthropic, Mistral, local)

## When NOT to Use

- Initial feasibility exploration (before task definition is stable) — benchmark when you know what you're measuring
- Model compatibility checks (does this model support tool use, JSON mode, etc.) — that's a capability query, not a benchmark
- Leaderboard research to narrow the candidate list — that's input to Stage 3, not a substitute for it

## The Process

Four stages. Do not collapse them.

### Stage 1 — Define the Bar

Before running any model, write down:

| Decision | What to Define |
|---|---|
| Task | Exact input format, exact output format, edge cases |
| Metric | Accuracy, faithfulness score, extraction F1, LLM-as-judge, task pass rate |
| Pass threshold | The minimum score to go to production (e.g., ≥ 88%) |
| Budget constraint | Max cost per 1k calls, max monthly spend |
| Latency constraint | Max acceptable p95 (e.g., ≤ 2.0s) |

If you cannot define the metric and threshold first, the selection criteria are not clear enough to proceed.

### Stage 2 — Build a Representative Test Set

- Minimum 50 examples; 200+ for features used at volume
- **Label ground truth before running any model.** Seeing outputs first contaminates labels.
- Include: easy cases, hard cases, edge cases, adversarial inputs
- Tag each example by difficulty: `easy / medium / hard`
- Store in `benchmarks/<feature>/test-set.jsonl`

### Stage 3 — Benchmark at Least Three Tiers

Always test at least one tier below your expected choice:

| Tier | Example Models | When It Wins |
|---|---|---|
| Frontier | Claude Opus, GPT-4o, Gemini 1.5 Pro | Complex reasoning, nuanced generation |
| Mid | Claude Sonnet, GPT-4o-mini, Gemini Flash | Most production tasks |
| Efficient | Claude Haiku, Mistral Small, Llama 3.1 8B | Classification, extraction, structured output |

For each model:
1. Run all examples through the same prompt (version-controlled via prompt-versioning)
2. Run 3× and average — model outputs are stochastic
3. Record: accuracy, latency p50/p95, cost per 1k input+output tokens

### Stage 4 — Cost-Quality Decision

Build this table:

| Model | Accuracy | p95 Latency | Cost/1k | Notes |
|---|---|---|---|---|
| Claude Opus | 95% | 4.1s | $30.00 | Best quality |
| Claude Sonnet | 91% | 1.9s | $9.00 | **Recommended** |
| Claude Haiku | 84% | 0.7s | $1.50 | Below 88% threshold |

Decision rule: if a cheaper model is within 5% of frontier on your metric AND within the latency constraint → use the cheaper model. The quality difference at 100k calls/month is worth the cost differential analysis.

Document decision in `benchmarks/<feature>/<date>.md`.

## Rationalization Red Flags

These thoughts mean a model was chosen without benchmarking — stop:

- *"GPT-4 is the best model"* — best on MMLU, not necessarily on your invoice extraction pipeline
- *"I tested a few examples and it was good"* — you self-selected; the test set tests the distribution
- *"The new model is clearly better"* — "clearly better" at which task? at which cost?
- *"We don't have time to benchmark"* — you have time to migrate away from the wrong model after launch?
- *"The efficient tier can't do this task"* — you know this from how many labelled examples?
- *"We should use the best model to be safe"* — using a 20× more expensive model when Haiku passes the threshold is not safe, it's wasteful

## Completion Statement Format

When model-benchmarking is satisfied, state it like this:

```
Model selected: <model-id>
Task: <one-line description>
Metric: <metric name>, threshold: ≥ X%
Test set: benchmarks/<feature>/test-set.jsonl — N examples

Results:
  <Frontier model>: A%, p95=Xs, $Y/1k
  <Mid model>:      B%, p95=Xs, $Y/1k ← selected
  <Efficient model>: C%, p95=Xs, $Y/1k (below threshold)

Decision: <mid model> meets threshold (B% ≥ X%) at Z× lower cost than frontier
Stored: benchmarks/<feature>/<date>.md ✓
```

## Why This Matters

A model that underperforms on your task produces silent quality degradation at scale. A model that over-performs costs more than necessary. The benchmark is how you know which you have before 100k calls tell you.
