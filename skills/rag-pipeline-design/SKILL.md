---
name: rag-pipeline-design
description: Use when designing or auditing a retrieval-augmented generation pipeline. Requires data audit and query audit before any design decision. Blocks "I'll use the standard setup" completions.
---

# RAG Pipeline Design

## The Law

```
YOU CANNOT DESIGN A RAG PIPELINE WITHOUT FIRST AUDITING THE DATA AND THE QUERIES.
"Standard chunking" fails on structured documents.
"The embedding model worked for someone else" is not a validation.
A data audit + query audit + stage-by-stage decision log IS a design.
```

## When to Use

Trigger when:
- Starting a new RAG feature from scratch
- Debugging retrieval quality issues (hallucination, missed context, low recall)
- Upgrading an embedding model or retrieval strategy
- Adding or removing a reranker
- Changing chunk size, overlap, or ingestion strategy

## The Process

A RAG pipeline has five stages. Design each explicitly — do not accept defaults.

### Step 0 — Audit Before Designing

Answer both audits before making any pipeline decision:

**Data Audit:**
- Source format: PDF / HTML / JSON / code / mixed?
- Average document length (tokens)?
- Is document structure (headings, sections, tables) load-bearing for meaning?
- How frequently does content change?
- Any formatting that will survive chunking (tables, numbered lists, code blocks)?

**Query Audit:**
- Dominant query type: lookup / comparison / synthesis / aggregation?
- Expected answer length: short fact / paragraph / multi-section?
- Does the user need source attribution?
- Is multi-hop reasoning required (answer requires combining facts across documents)?

Every design decision below flows from these two audits.

### Step 1 — Chunking

| Document Type | Strategy | Chunk Size | Overlap |
|---|---|---|---|
| Prose / narrative | Sentence boundary | 256–400 tokens | 15% |
| Structured (headings, sections) | Section boundary | 512–800 tokens | 10% |
| Code | Function / class boundary | Variable | None |
| Tables / CSV | Row or row-group | 128–256 tokens | None |

Always attach metadata to every chunk: `source`, `date`, `section`, `page`, `chunk_index`.

### Step 2 — Embedding

Choose based on domain, not on general benchmark:
1. Select 3 candidate models
2. Build a 20-example similarity test set from your actual corpus (10 similar pairs, 10 dissimilar)
3. Run all 3 candidates against the test set
4. Pick the model with the highest correct rank correlation on your domain

Do not skip the validation. General benchmarks do not predict domain-specific performance.

### Step 3 — Retrieval Strategy

| Query Type | Strategy | Why |
|---|---|---|
| Semantic similarity | Dense only | Query and documents share conceptual vocabulary |
| Keyword / exact match | Sparse (BM25) | Overlap in exact terms matters more than semantics |
| General / mixed | Hybrid (dense + BM25 via RRF) | Covers both; best default |

Set `top_k` to 5 as the starting point. Increase only if recall@5 is below threshold.

### Step 4 — Reranking

Add a reranker when:
- `top_k > 5` AND the context window is constrained
- Precision matters more than latency
- Query diversity is high

Cross-encoder for maximum precision. Cohere Rerank for cost/speed balance.

Do not add a reranker first and tune top_k later. Set top_k, measure recall, add reranker only if needed.

### Step 5 — Generation

- Inject chunks in relevance order (most relevant first — primacy effect)
- Set a hard context budget: context injected ≤ 40% of model context window
- Require the model to cite chunk IDs: *"Based on [chunk-3]..."*
- Add a faithfulness check: post-process to detect claims not grounded in retrieved chunks

## Rationalization Red Flags

These thoughts mean the pipeline was not designed — stop:

- *"I'll use the standard chunking"* — structured documents chunked at prose boundaries lose table context; the model retrieves fragment rows, can't reconcile them, and produces hallucinated answers that cite real source pages
- *"The embedding model worked for another project"* — embedding quality is domain-specific; validate it on your corpus
- *"top_k=10 is fine"* — 10 chunks × average 400 tokens = 4000 tokens of context before the query; measure, don't assume
- *"I'll add a reranker and see if it helps"* — add it only after measuring recall without it
- *"We don't need citations"* — without citations, faithfulness cannot be audited

## Completion Statement Format

When rag-pipeline-design is satisfied, state it like this:

```
RAG pipeline designed.
Data audit: rag-audit/<feature>/data-audit-<date>.md ✓
  Format: <format>, avg length: <N tokens>, structure-bearing: yes/no
Query audit: <dominant type>, attribution needed: yes/no

Chunking: <strategy>, <chunk size> tokens, <overlap>%, metadata: source/date/section ✓
Embedding: <model>, validated on <N>-example domain similarity test (rank correlation: X) ✓
Retrieval: <dense/sparse/hybrid>, top_k=N, similarity threshold=X ✓
Reranking: <model or "none — top_k ≤ 5"> ✓
Generation: context budget ≤ 40%, citations required, faithfulness check ✓

Retrieval recall@k baseline: <to be measured / X%> 
```

## Why This Matters

Generic RAG pipelines are built for generic data and generic queries. Production systems have specific documents and specific query patterns. Every mismatch between the pipeline design and the actual data/query distribution surfaces as hallucination, missed context, or high latency — at a cost that scales with volume.
