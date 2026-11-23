---
name: research-report
description: Answer a real question with sourced claims, a claim ledger and an explicit statement of what could not be found.
metadata:
  modes: [research]
---

# Research report

I read this when someone needs an answer they will act on, not a summary of the internet.

## Shape

```
QUESTION   the decision this serves, in one line
ANSWER     three sentences, the answer first
CLAIMS     each claim -> source (path, URL + date read, or a person + date)
TENSIONS   where sources disagree, and which one I trust and why
GAPS       what I could not find, and where I looked
NEXT       the smallest thing that would settle the open question
```

## Steps

1. Write the question, then the decision behind it. If there is no decision, ask why the report
   exists.
2. Collect primaries: the repo, the filing, the page, the person. Secondary sources only to find
   primaries.
3. For every number: open the source, check it says what the summary claims, then quote it with
   the date you read it.
4. Separate observation from inference, and label the inference.
5. Write the answer first, evidence after. The reader may only read the first three sentences.
6. List the gaps honestly. "Not found in X, Y" is a finding.

## Output

`research/<slug>/report.md` plus `sources.md` if there are many.

## Guardrails

- Never quote a number you did not see at its source.
- Never let a confident secondary source stand in for a primary you could open.
