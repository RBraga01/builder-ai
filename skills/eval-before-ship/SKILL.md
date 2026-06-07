---
name: eval-before-ship
description: Blocks any LLM feature from shipping without documented eval results showing pass rate and failure modes.
---

# Eval Before Ship

## The Law

No LLM-powered feature ships without an eval run. "It looks good" is not an eval.

## When to Use

Trigger before:
- Merging any PR that adds or modifies a prompt
- Releasing a new model version
- Changing retrieval logic in a RAG pipeline
- Updating system prompts or few-shot examples
- A/B testing a new generation strategy

## What Counts as an Eval

An eval must have:
- **A named test suite** — not ad hoc testing in a chat window
- **A defined metric** — accuracy, faithfulness, BLEU, LLM-as-judge score, or task-specific
- **A pass threshold** — explicit minimum (e.g., ≥ 85% accuracy on held-out set)
- **A failure analysis** — at least 5 failure cases examined and categorised
- **A baseline comparison** — current version vs. previous version or control

## The Process

1. Define the eval suite before writing the prompt (test-first)
2. Run eval on the dev version — record raw results
3. Identify failure modes: hallucination, refusal, format violation, factual error
4. Compare against baseline
5. If pass threshold met → document results in `evals/` with date and version
6. If below threshold → fix and re-run before opening PR

## Verification Checklist

Before marking done:
- [ ] Eval suite named and stored in `evals/`
- [ ] Pass rate documented with exact numbers
- [ ] Failure cases listed (minimum 5)
- [ ] Baseline comparison included
- [ ] Threshold explicitly defined and met
- [ ] Eval run is reproducible (seed, temperature, model version logged)
