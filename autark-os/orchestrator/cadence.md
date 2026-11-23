# Cadence — what runs, when, and what it leaves behind

A cadence without an artifact is theatre. Every line names the output that proves it ran.

## Daily

| Slot | Run | Output (the artifact) |
|---|---|---|
| 06:45 | Morning brief | `memory/company/briefs/YYYY-MM-DD.md`: what moved, what is stuck, the single decision for the day |
| 08:30 | Pipeline sweep | `gtm/pipeline.md` updated: new signals, replies due, drafts staged |
| 12:30 | Reply round | drafted replies attached to each thread, gate marked (G1 or G3) |
| 17:30 | Scorecard | `memory/company/scorecards/YYYY-MM-DD.md`: one RED/GREEN line per lane, no prose |
| 18:00 | Close the day | open cards re-dated or killed; nothing silently carried |

## Weekly

| Day | Run | Output |
|---|---|---|
| Monday | Week plan: three outcomes, one per head | `memory/company/plans/YYYY-Www.md` |
| Wednesday | Council review of the week's most consequential draft | `memory/company/reviews/YYYY-Www.md` |
| Friday | Retro: one process change, named | appended to the week plan, with the check that will show it worked |

## Monthly

- Offer and price review (`gtm-offer`): what sold, what did not, one change.
- Architecture debt pass (`repo-architecture`): the three oldest open debts, with owners.
- Skill audit (`skill-authoring`): skills used zero times in 30 days are candidates for deletion.

## Kill rule

A routine that produced no artifact for 14 days is paused; 28 days, deleted. The date and the
reason are recorded in `memory/company/routines.md`. Routine count is not a virtue.
