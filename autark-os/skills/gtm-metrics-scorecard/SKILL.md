---
name: gtm-metrics-scorecard
description: One daily page of RED/GREEN per lane, with the number, its source and the one action it triggers.
metadata:
  modes: [manager, finance, research]
---

# Scorecard

I read this at the end of a day or the start of a week, to answer one question: is the machine
working, and what do we change?

## The page

```
DATE            2026-11-23
PIPELINE        signals found / contacted / replies / meetings
CONTENT         published / drafts waiting / top post by replies
VISIBILITY      citations / impressions / qualified visits
DELIVERY        work shipped / open cards / blocked cards
MONEY           invoiced / collected / committed spend
ONE ACTION      the single change for tomorrow
```

Each line: the number, its source, and RED or GREEN against a threshold that was set in advance.

## Rules

1. A metric with no threshold is decoration. Set the threshold before the first reading.
2. Fewer lines, honestly measured, beat a dashboard nobody reads.
3. One action per day. A scorecard that produces five actions produces none.
4. A RED is information, not an emergency: say what it means and what you will try.
5. Never report activity as result. "20 sent" is an input; "3 replies" is a result.

## Output

`memory/company/scorecards/YYYY-MM-DD.md`, one page.

## Guardrails

- No number without a source path or command.
- If a number could not be measured, write "not measured" and why. Do not estimate silently.
