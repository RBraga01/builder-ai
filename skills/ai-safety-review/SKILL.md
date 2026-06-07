---
name: ai-safety-review
description: Use before shipping any LLM feature — reviews for hallucination risk, prompt injection, output misuse, and unsafe generation patterns.
---

# AI Safety Review

## The Law

Every LLM feature that touches users must pass a safety review before it ships. This is not optional and is not covered by functional testing or eval-before-ship.

## When to Use

Trigger before:
- Any PR that exposes LLM outputs to end users
- Any PR that accepts user input fed directly into a prompt
- Any agentic feature that can take actions (write files, call APIs, send messages)
- Any feature that uses user-uploaded content (documents, images, code)

## Review Checklist

### 1 — Prompt Injection

- [ ] User input is never concatenated directly into the system prompt
- [ ] User input is clearly delimited (XML tags, clear role separation)
- [ ] Test: can a user instruct the model to ignore previous instructions? Verify it cannot
- [ ] Test: can a user inject instructions via uploaded documents or tool outputs?

### 2 — Hallucination Risk

- [ ] Model is required to cite retrieved sources for factual claims
- [ ] Outputs are validated against retrieved context (faithfulness check)
- [ ] High-stakes domains (medical, legal, financial) include explicit uncertainty disclaimers
- [ ] User is informed when the model lacks reliable information

### 3 — Output Safety

- [ ] Content moderation applied to user input before entering the prompt
- [ ] Output moderation applied to model responses before rendering
- [ ] Code execution is sandboxed if model can generate executable code
- [ ] URL / link outputs are validated — model should not generate arbitrary URLs
- [ ] PII is not surfaced in model outputs from internal data

### 4 — Agentic Safety (if applicable)

- [ ] Agent cannot take irreversible actions without explicit user confirmation
- [ ] Tool call scope is minimal — agent only has access to tools it needs
- [ ] Agent cannot exfiltrate data (write to external endpoints not in approved list)
- [ ] Multi-step agent flows have a maximum step limit to prevent infinite loops
- [ ] Human-in-the-loop checkpoint exists for any action with blast radius > one record

### 5 — Abuse Resistance

- [ ] Rate limiting applied to LLM endpoints
- [ ] Cost per user session is capped
- [ ] Jailbreak probing: test 10 common jailbreak patterns — document which are blocked
- [ ] Outputs are not used to train models without user consent disclosure

## Threat Model Summary

Document in `safety-reviews/<feature>/<date>.md`:

1. **Attack surfaces**: where can a user influence model behaviour?
2. **Worst-case outputs**: what is the most harmful thing this feature could produce?
3. **Mitigations in place**: what controls prevent the above?
4. **Residual risk**: what risk remains and is it acceptable for this use case?

## Verification Checklist

- [ ] Prompt injection tested and blocked
- [ ] Hallucination controls in place (citations, faithfulness check)
- [ ] Content moderation on input and output
- [ ] Agentic scope minimised and reversibility enforced
- [ ] Rate limiting and cost cap configured
- [ ] Jailbreak probe results documented
- [ ] Safety review stored in `safety-reviews/`
