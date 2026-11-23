---
name: work-intake
description: Turn a rough request into a brief with an outcome, a done-test, a gate and a boundary, before any work begins.
metadata:
  modes: [manager, general]
---

# Work intake

I read this before starting anything that will take more than one turn or touch more than one
file. The brief is the cheapest part of the work and the only part that prevents the expensive
mistake.

## The brief (six lines, no more)

```
OUTCOME   what will be true when this is finished, in one sentence
DONE-TEST the observation that proves it; a command or a read-back
GATE      G0 read | G1 draft | G2 internal write | G3 outward | G4 money
BOUNDARY  what this work may touch, and what it must not
OWNER     one agent
NOT-DOING what I am deliberately leaving out
```

## Steps

1. Write the outcome as a state of the world, not an activity: "the site returns 200 on /pricing"
   not "work on pricing".
2. Write the done-test so it **fails today**. If it already passes, the work is not described.
3. Pick the gate by what the work touches, not by how confident the person sounds.
4. Draw the boundary explicitly. "Do not touch `apps/`" is a boundary; "be careful" is not.
5. Name what is out of scope. Scope creep is invisible until it is listed.
6. If the request cannot produce a done-test after one honest attempt, the request is a
   decision: take it back to the person with the trade-off.

## Guardrails

- No brief for a question or a one-line fix. This skill is for work, not for chat.
- A brief that grows past six lines is hiding a second project. Split it.
- The gate is a floor, not a ceiling: work may stop lower, never higher.
