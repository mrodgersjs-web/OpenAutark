# Signals we watch

Adapted from the signal tiers in `skills/gtm-signals`. Dates: written 2026-11-23; re-read monthly
and delete any source that stopped being observable.

## Tier 1 — active intent

| Signal | Where it is observable | Fresh for | Owner |
|---|---|---|---|
| Pricing / comparison page visit | site analytics or the CRM's own event log | 24 h | outbound |
| Review-site or marketplace comparison | the review site's own listing pages | 48 h | outbound |
| RFP / vendor-evaluation notice | public procurement pages, the buyer's own site | 72 h | head-of-gtm |
| Job post naming the exact problem | the company's job board | 7 d | outbound |

## Tier 2 — organisational change

| Signal | Where | Fresh for |
|---|---|---|
| New leader in the buying function | the company's news page or the person's own profile | 14 d |
| Funding with a stated use | the announcement itself, not the aggregator | 14 d |
| Hiring surge in the department | the job board, counted | 14 d |
| M&A / consolidation | the filing or the press release | 30 d |

## Tier 3 — technographic and behavioural

Stack changes on public pages, talks on the adjacent problem, engagement with our own published
work, renewal windows when a buyer mentions them.

## Decay rule

A signal older than its freshness window goes back to nurture and is never re-dated to look fresh.
The record keeps the original observation date — that is the only honest timestamp.
