# GTM branch — what lives here

The operating side of go-to-market, in files an agent can run. The *hypotheses* (who, what we
sell, at what band) live in `memory/branches/gtm/` because they change with evidence. This folder
holds the machinery that does not change every week.

| File | What it is |
|---|---|
| `signals.md` | the signal tiers we actually watch, with sources and decay rules |
| `channels.md` | one row per channel: what it is good for, the cadence, the gate |
| `sequences/` | one file per sequence, written against a signal, never against a template |
| `aeo-surface.md` | the question → page map that makes us the cited answer |
| `metrics.md` | the four numbers that decide whether any of this works |

## The one rule

Everything here produces drafts. Nothing here sends. The approval of the exact text is the
person's, per channel, batched (gate G3). A GTM system that can send on its own is a liability
with a pipeline.
