---
name: model-benchmarking
description: Use when selecting or comparing LLM models for a specific task — structured benchmarking before committing to a model in production.
---

# Model Benchmarking

## The Law

Never pick a model by reputation or benchmark leaderboard alone. Benchmark on your task, your data, your quality bar. MMLU scores do not predict performance on your invoice extraction pipeline.

## When to Use

- Choosing a model for a new feature
- Considering a switch to a newer or cheaper model
- Validating that a smaller/cheaper model can replace a larger one
- Comparing providers (OpenAI vs. Anthropic vs. Mistral vs. local)

## Benchmarking Framework

### Step 1 — Define the Task Precisely

Write down:
- Exact input format (structured JSON? free text? image?)
- Exact output format (classification label? structured extraction? free prose?)
- Success metric (exact match, BLEU, LLM-as-judge score, human rating)
- Pass threshold (the minimum score to go to production)

### Step 2 — Build a Representative Test Set

- Minimum 50 examples; 200+ preferred
- Include edge cases: short inputs, long inputs, ambiguous cases, adversarial phrasing
- Label ground truth before running any model (prevents anchoring)
- Split: 80% evaluation, 20% held-out validation

### Step 3 — Evaluate Candidates Blind

For each candidate model:
1. Run identical prompt (from prompt-versioning) against the test set
2. Record: accuracy, latency (p50 / p95), cost per 1k calls, failure rate
3. Run 3× to assess variance — LLM outputs are stochastic

Candidate tiers to always compare:
| Tier | Example Models |
|---|---|
| Frontier | GPT-4o, Claude Opus, Gemini 1.5 Pro |
| Mid | GPT-4o-mini, Claude Sonnet, Gemini Flash |
| Efficient | GPT-4o-mini, Claude Haiku, Mistral Small |
| Local | Llama 3.1 8B, Phi-3, Gemma 2B |

Always include one tier below your expected choice — often good enough at 3–10× lower cost.

### Step 4 — Cost-Quality Tradeoff Analysis

Build a table:

| Model | Accuracy | Latency p95 | Cost/1k | Quality/Cost |
|---|---|---|---|---|
| GPT-4o | 94% | 3.2s | $15 | baseline |
| Claude Sonnet | 92% | 1.8s | $9 | +2% value |
| GPT-4o-mini | 87% | 0.9s | $1.5 | evaluate |

Decision: if cheaper model is within 5% of frontier on your metric, prefer cheaper unless latency is a constraint.

### Step 5 — Document and Freeze

Store results in `benchmarks/<feature>/<date>/` with:
- Raw outputs for each model
- Aggregate metrics table
- Decision rationale
- Model version / API snapshot date

## Verification Checklist

- [ ] Task defined precisely with success metric and pass threshold
- [ ] Test set has ≥ 50 labelled examples with edge cases
- [ ] Ground truth labelled before any model run
- [ ] Each candidate run 3× for variance check
- [ ] Latency (p50 / p95) measured, not just accuracy
- [ ] Cost per 1k calls calculated for each candidate
- [ ] One tier below expected choice included
- [ ] Results stored in `benchmarks/` with date and model versions
- [ ] Decision rationale documented
