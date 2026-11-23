---
name: done-claim-verification
description: Verify a "done" from a different path than the one that did the work, and report partial or deferred honestly.
metadata:
  modes: [manager, general, research]
---

# Verifying a done claim

I read this whenever anyone - including me - is about to say a thing is finished, fixed,
installed, deployed or working.

## The rule

**The doer never supplies the proof.** Evidence must come from a path the doer did not use.

| The claim | Cheap honest check |
|---|---|
| "I wrote the file" | read the file back; count its sections |
| "The test passes" | re-run it yourself, exit code and output |
| "It is deployed" | fetch the URL, read the version string or the changed copy |
| "The agent fixed it" | reproduce the original failure; it must now be gone |
| "I sent it" | the receipt in the sent folder, with the timestamp |
| "The check is green" | the check's own output, plus what it does not cover |

## Steps

1. Restate the claim as a falsifiable sentence.
2. Choose the observation that would break it most cheaply.
3. Run it, and keep the verbatim output.
4. Compare with the claim. Three verdicts only: **PASS** (observed), **PARTIAL** (some observed,
   some not - say which), **DEFERRED** (cannot check - say why, never default to PASS).
5. Write the evidence into the packet (`proof-packet`).

## Anti-patterns

- A screenshot of a green test written by the author.
- "No errors in the log" as proof that behaviour is correct.
- A summary of what the code should do, instead of what was observed.
- Re-reading the plan and calling it verification.
