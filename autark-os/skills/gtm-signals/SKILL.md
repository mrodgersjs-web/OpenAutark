---
name: gtm-signals
description: Find and rank buying signals by intent strength, and route each one inside its speed window.
metadata:
  modes: [research, manager]
---

# Signals

I read this before building a prospect list. Lists are cheap; timing is the moat.

## Tiers

**Tier 1 — active intent.** Pricing page or comparison pages viewed, a review-site visit, an
RFP or vendor-evaluation notice, a job post naming the exact problem we solve.

**Tier 2 — organisational change.** A new leader in the buying function, funding with a stated
use, a hiring surge in the department, M&A or a consolidation.

**Tier 3 — technographic and behavioural.** Stack changes, conference talks on the adjacent
problem, content engagement, contract renewal windows when discoverable.

## Steps

1. Pick two tiers to work. Most teams can only service Tier 1 and Tier 2 well.
2. For each signal, name: where it is observable, how fresh it must be, and who acts on it.
3. Rank by intent, not by company size. A perfect-fit company with no trigger waits.
4. Attach the observation to the record: the URL, the date, the sentence that triggered it.
5. Write the decay rule: after N days the signal is stale and the record goes back to nurture.

## Output

`gtm/signals.md` — the tier table with sources, freshness window, owner and decay.

## Guardrails

- A signal a human cannot verify is a rumour. Link it.
- Never scrape a source that forbids it, and never store personal data you do not need.
