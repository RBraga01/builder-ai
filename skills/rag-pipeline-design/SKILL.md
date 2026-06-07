---
name: rag-pipeline-design
description: Use when designing or auditing a retrieval-augmented generation pipeline — chunking, embedding, retrieval, reranking, and generation stages.
---

# RAG Pipeline Design

## When to Use

- Starting a new RAG feature from scratch
- Debugging retrieval quality issues (hallucination, missed context)
- Upgrading embedding models or retrieval strategies
- Adding a reranker or hybrid search

## Pipeline Stages

A production RAG pipeline has five distinct stages. Design each independently before wiring together.

### 1 — Ingestion

Decisions:
- **Chunking strategy**: fixed-size, sentence, paragraph, semantic, or document-aware
- **Chunk size**: 256–512 tokens typical; larger for context-heavy domains
- **Overlap**: 10–20% overlap prevents context loss at boundaries
- **Metadata**: always attach source, date, section, and page to each chunk

Anti-patterns to avoid:
- Chunking mid-sentence (use sentence boundary detection)
- Stripping all metadata (breaks source attribution)
- Ingesting PDFs without OCR quality check

### 2 — Embedding

Decisions:
- **Model**: match to domain — `text-embedding-3-large` (OpenAI), `voyage-3` (Voyage), `nomic-embed-text` (local)
- **Dimensionality**: higher = better recall, higher cost; quantise if cost-sensitive
- **Normalisation**: always L2-normalise before storing

Validation:
- Run embedding similarity tests on known similar/dissimilar pairs from your domain before committing model choice

### 3 — Retrieval

Strategies (pick based on query type):
- **Dense only**: good for semantic similarity queries
- **Sparse only (BM25)**: good for keyword / exact match queries
- **Hybrid**: combine dense + sparse with RRF (Reciprocal Rank Fusion) — best for general use

Parameters to tune:
- `top_k`: start at 5–10; increase if recall is low
- Similarity threshold: filter chunks below 0.75 cosine similarity (tune per domain)

### 4 — Reranking

Always add a reranker between retrieval and generation when:
- `top_k > 5` and context window is limited
- Query diversity is high
- Precision matters more than latency

Options: cross-encoder (slower, higher quality), Cohere Rerank API, ColBERT.

### 5 — Generation

- **Context injection**: put most relevant chunks first (primacy effect)
- **Citation grounding**: require the model to cite chunk IDs in output
- **Faithfulness check**: post-process to detect claims not supported by retrieved context

## Evaluation

Before shipping a RAG pipeline, measure:
- **Retrieval recall@k**: % of relevant chunks in top-k results
- **Answer faithfulness**: % of claims grounded in retrieved context
- **Answer relevance**: user query answered by the response
- Use RAGAS or a custom LLM-as-judge suite

## Verification Checklist

- [ ] Chunking strategy chosen and justified for the document type
- [ ] Metadata attached to every chunk (source, date, section)
- [ ] Embedding model validated on domain-specific similarity pairs
- [ ] Retrieval strategy selected (dense / sparse / hybrid) with rationale
- [ ] `top_k` and similarity threshold set
- [ ] Reranker added if top_k > 5
- [ ] Context injection order optimised
- [ ] Citation grounding enforced in prompt
- [ ] Faithfulness eval defined and baseline measured
