---
name: quality-gate
description: Run a typed gate on an artifact before it is called done - pass, escalate or block, with the rubric named.
metadata:
  modes: [manager, general]
---

# Quality gate

I read this before shipping a draft, a diff, a plan, a page or a claim that someone will rely on.

## Steps

1. **Name the subject**: artifact id plus a hash or path, so a later pass can tell which version
   was judged. A gate without a subject cannot be calibrated.
2. **Pick the rubric** for the artifact type: claim truth, public copy, code change, plan
   soundness, design finish, deal quality.
3. **Score the rubric items one by one**, each with the evidence that decided it. A score with
   no evidence is an opinion.
4. **Return one verdict**: PASS, ESCALATE (a human decision is needed - say which), BLOCK (a
   stated rule is broken - name it and the smallest fix).
5. **If the classifier is unreachable, the verdict is DEFERRED.** Never self-certify in place of
   a gate that could not run.

## What blocks immediately

- A claim with no source, or a number that does not match its source.
- Anything outward that has not been approved as exact text.
- A secret, a credential fragment or a private identifier in the artifact.
- A "fixed" without the original failure reproduced and gone.

## Guardrails

- The author does not run the gate on their own consequential work; a fresh pass does.
- A PASS is per artifact and per version. Editing after the gate voids it.
