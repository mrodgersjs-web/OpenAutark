# Concepts brief — Autark OS

Date: 2026-11-23. Owner: RIG. EGM step: brainstorm → brief.

## The problem, stated without the product

A person can already buy intelligence. What they cannot buy is a company: something that knows the
work, routes it, remembers decisions, stops before it sends something stupid, and shows its work at
the end. Autark ships the machine for that (runtime, agents, chats, tasks, memory, your own PC) but
ships no opinion about how a company should run. Every new install starts as a blank org chart.

## Who has this problem

Someone already paying for one or more AI plans, already working on their own machine, whose output
is bottlenecked by their own checking. Not an enterprise. Not a developer looking for an SDK.

## What good looks like (from the captures)

`research/what-great-looks-like/benchmark.md` — the category leads with a person-shaped promise
(Lindy: "hire"), a working surface above the fold (Manus), or an ownership claim (OpenHands,
Dyad). Autark has the strongest category argument of the set and the weakest product presence above
the fold. The OS layer cannot fix the website; it can make the installed product deliver the promise
the website already makes.

## Options considered

1. **A prompt pack.** Cheap, sells once, rots. Rejected: prompts are not procedures, and a pack
   cannot enforce a gate.
2. **A patch to the app** (a new first-run wizard, built-in team templates). Highest reach, but it
   forks the app, breaks upstream merges and puts us inside someone else's boundary decisions.
   Rejected for now, kept as a proposal (UPGRADES rows 1-12).
3. **An additive operating layer** — agents, skills, memory, routing, gates, checks, in the format
   the app already reads. Reversible, upstream-safe, shippable today. **Chosen.**

## What we will not do

- No changes under `apps/`.
- No publishing to the public library.
- No credential handling, no spend, no outward send.

## Success, stated as a test

A new install of Autark, with this layer installed, produces three artifacts a stranger can evaluate
(brief, draft, proof packet) in one working session, and every claim in those artifacts carries a
source. If a claim cannot carry a source, the layer failed.

## Open questions (for the review)

1. Is 15 agents too many for a first install? Does the routing table justify each one?
2. Does `install.sh` write into a data folder that already has a live team without damaging it?
3. Is the gate ladder enforceable enough to be believed, or is it a policy document with a shell
   script attached?
