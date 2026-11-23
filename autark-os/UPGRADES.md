# Thirty moves that make this 1000x

"1000x" is not a bigger feature list. It is the removal of the reasons a person does not start, or
starts and stops. Each row names the move, where it lives, the effort, the expected effect, and how
you would know it worked. Nothing here is a promise about revenue.

Effort: S under a day, M a few days, L a week or more. Effect: the change in a buyer's or an
agent's behaviour, not in the codebase.

## A. Product surface — what a visitor and a new user see (1-12)

| # | Move | Where | Effort | Effect | Verify |
|---|---|---|---|---|---|
| 1 | First screen shows a real artifact the team produced, with the agent that made it | `apps/website` hero | M | highest | screenshot: a named artifact above the fold |
| 2 | Three agents with names, faces and one owned area each | hero + "the team" section | S | high | a stranger can name who does what |
| 3 | One 20-second loop instead of a paragraph: request → routed → artifact → your approval | hero motion | M | high | the loop plays without reading |
| 4 | The brake, shown: a Secure-mode panel with what is closed and what asks | security section | S | high | a visitor can state what the agents cannot do |
| 5 | "What it costs you" section: your own model keys, no subscription from us, price of a plan | pricing section | S | high | a visitor can answer "what will this cost me" |
| 6 | The empty state as a sales tool: a company on day one, three suggested first runs | first-run flow | M | high | new install produces a first artifact in under 10 minutes |
| 7 | Failure states designed: what happens when a model key dies mid-task | UI + site | M | medium | documented recovery in one screen |
| 8 | A named result, or an honest "not measured yet" — never a fabricated logo row | proof section | S | high | every proof line has a source |
| 9 | A downloadable sample company (agents + skills + memory) that works offline | `library/` entry | M | high | a new install imports it and runs one task |
| 10 | Phone shown doing the same task as the desktop, side by side | devices section | S | medium | one screenshot proves the claim |
| 11 | A "compare" page against cloud agents on ownership, cost and capability | `apps/website` | S | medium | page answers the three questions a buyer asks |
| 12 | Changelog written for buyers, not commits: one outcome per release | site + releases | S | medium | a reader can name what changed for them |

## B. Agent OS — what the team does once installed (13-24)

| # | Move | Where | Effort | Effect | Verify |
|---|---|---|---|---|---|
| 13 | The orchestrator contract as an installable agent (`chief-of-staff`) | `autark-os/agents/` | done | high | `check.sh agents` |
| 14 | A routing table the app can read, not a prompt instruction | `orchestrator/router.json` | done | high | `check.sh router` |
| 15 | A gate ladder that separates draft from send by name | `orchestrator/gates.md` | done | highest | every skill states its gate |
| 16 | Fourteen specialists with a method each, not personas | `autark-os/agents/` | done | high | each file names its source |
| 17 | Twenty-four procedures with an output and a guardrail | `autark-os/skills/` | done | high | `check.sh skills` |
| 18 | A proof packet format any stranger can reproduce | `skills/proof-packet` | done | high | a packet exists per delivery |
| 19 | An independent verifier that reads a different path than the doer | `skills/done-claim-verification` | done | highest | a claim fails when the fix is reverted |
| 20 | Memory that stays true: dated claims, one source, corrections reconciled | `skills/memory-hygiene`, `memory/` | done | high | no undated number in the seed |
| 21 | A cadence where every slot names its artifact | `orchestrator/cadence.md` | done | medium | one week of scorecards exists |
| 22 | Hiring that earns its place: head vs doer vs absorb | `skills/agent-team-hiring` | done | medium | new agents produce a surviving artifact in 14 days |
| 23 | A skill format and an audit that deletes unused skills | `skills/skill-authoring` | done | medium | skills unused in 30 days are removed |
| 24 | A self-check the app's own CI can run | `.github/workflows/autark-os-check.yml` | done | high | workflow green on push |

## C. GTM — how the work reaches a buyer (25-30)

| # | Move | Where | Effort | Effect | Verify |
|---|---|---|---|---|---|
| 25 | Signal-triggered outbound with a decay rule, measured in replies | `gtm/signals.md`, `skills/gtm-signals` | done | high | every contacted record has a dated signal |
| 26 | An offer ladder with three bands and an honest risk reversal | `memory/branches/gtm/offer-ladder.md` | S (prices) | high | a buyer can pick a band unaided |
| 27 | Draft-only discipline with one approval per channel | `skills/gtm-draft-only`, `gates.md` | done | highest | zero sends without an approval record |
| 28 | A ten-seat council on anything consequential | `skills/gtm-council-review` | done | medium | the dissent survives into the artifact |
| 29 | An answer-engine surface: 20 questions → 20 pages → citations measured | `gtm/aeo-surface.md` | M | high | monthly citation count has a method |
| 30 | A four-number scorecard that decides whether to continue | `gtm/metrics.md` | S | high | thresholds set before the first reading |

## What "1000x" means here, plainly

Ten times comes from removing the rework: the gates and proof rules stop the same mistake being
made twice. A hundred times comes from the routing and the memory: the team stops re-learning the
business every session. A thousand times is not a claim about output volume - it is what happens
when a person can delegate without checking, because the evidence arrives with the work.
