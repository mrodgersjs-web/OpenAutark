---
name: proof-packet
description: Assemble the evidence for a claim in one packet that a stranger can reproduce.
metadata:
  modes: [manager, general]
---

# Proof packet

I read this when a piece of work leaves the team: a delivery, a release, a claim about results,
or anything the person will have to defend without me in the room.

## The packet

```
CLAIM        one sentence, falsifiable
DATE         when the observation was made
COMMANDS     exactly what was run, in order, copy-pasteable
OUTPUT       verbatim, not summarised
ARTIFACTS    paths or URLs to the thing itself
COVERAGE     what this does NOT prove
VERDICT      PASS | PARTIAL | DEFERRED
```

## Steps

1. Write the claim first. Then collect only the evidence that bears on it.
2. Keep output verbatim, including the ugly lines. A cleaned-up log is not evidence.
3. List what is not covered. "Tested on macOS only", "happy path only", "one customer's data".
4. Store it next to the work, dated: `proof/<YYYY-MM-DD>-<slug>.md`.
5. Link it from the deliverable so the next reader finds it without asking.

## Guardrails

- No secrets, no customer names, no personal data in a packet. Redact and say you redacted.
- A packet cannot be longer than the thing it proves. If it is, the work is not understood yet.
