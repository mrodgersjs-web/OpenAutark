# Metrics

Four numbers decide whether the GTM branch works. Each has a source and a threshold set before the
first reading; a number without both is decoration.

| Metric | Source | Threshold (set by the person) | Read |
|---|---|---|---|
| Positive reply rate | the sent log + the reply threads | _unset_ | weekly |
| Meetings from signal-triggered touches | calendar entries tagged with the sequence | _unset_ | weekly |
| Citations in AI answers | the monthly 20-question probe | _unset_ | monthly |
| Days from signal to first touch | signal date vs sent date | _unset_ | weekly |

Inputs (sends, posts, comments) are recorded but never reported as results.

Not measured yet: everything in this table. The first reading is what sets the thresholds, and it
is written into `memory/company/scorecards/` on the day it is taken.
