---
name: gtm-council-review
description: Run ten opposing perspectives over one artifact and return a revised version with its strongest dissent preserved.
metadata:
  modes: [manager, social]
---

# Council review

I read this before a consequential artifact ships: a launch post, a price, an offer, a public
claim, a proposal.

## The ten seats

1. The buyer who does not care yet.
2. The competitor who will answer it tomorrow.
3. The lawyer reading it for a promise.
4. The operator who has to deliver it.
5. The accountant asking what it costs.
6. The designer asking what the eye does first.
7. The sceptic who assumes it is untrue.
8. The newcomer who lacks the context.
9. The person's future self, reading it in a year.
10. The one who asks "so what".

## Steps

1. Give every seat the artifact and nothing else - not the author's reasoning.
2. Each seat returns one sentence of what is wrong and one of what would make it right.
   Praise is not a valid return.
3. Merge by union, never by vote: one seat's real risk is a risk.
4. Rewrite the artifact against the merged objections.
5. Keep the three strongest surviving objections in the output, with the decision each one needs.

## Output

`memory/company/reviews/<date>-<slug>.md`: revised artifact, objections, the one decision.

## Guardrails

- The council is a reviewer, never the approver. It produces a draft with weaknesses named.
- If all ten seats agree instantly, the artifact is probably too safe to matter; say so.
