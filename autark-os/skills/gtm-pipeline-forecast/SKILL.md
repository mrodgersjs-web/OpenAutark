---
name: gtm-pipeline-forecast
description: Run the pipeline as stages with exit criteria so the forecast is arithmetic, and show the coverage gap in public.
metadata:
  modes: [manager, finance]
---

# Pipeline and forecast

I read this before any number about future revenue is said out loud.

## Stages (each with an exit criterion)

| Stage | Exit criterion |
|---|---|
| Signal | a dated observation, linkable, with a person attached |
| Contacted | first touch sent, receipt logged |
| Replied | a human answered, in their words |
| Conversation | a real exchange about the problem, not a calendar link |
| Proposal | scope, price band and start date written, sent |
| Verbal | they said yes to a specific scope and number |
| Signed | signature or PO received |
| Delivered | the work happened and was accepted |

## The arithmetic

```
forecast = Σ (deal value x stage probability)
coverage = open pipeline / remaining target
```

Stage probabilities are **measured from our own history**, not assumed. If we have no history,
the forecast is a range with the assumption written next to it.

## Steps

1. Update stages weekly, with the evidence for each move.
2. Compute coverage. Under target, the answer is more Tier 1 signals, not a better forecast.
3. Age every open deal: days in stage, last human contact. A deal with no contact in 21 days is
   not a deal; it is a hope.
4. Name the three deals that carry the quarter. Everything else is optional.
5. Write the miss early. A forecast revised on the last day is a confession, not a forecast.

## Output

`gtm/pipeline.md`: stage table, forecast range, coverage, three carrying deals, aged stalls.

## Guardrails

- No invented probabilities, no sandbagging, no number that cannot be traced to a stage entry.
