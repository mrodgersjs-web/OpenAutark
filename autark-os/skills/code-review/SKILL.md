---
name: code-review
description: Review a diff for correctness, security and cost with severity and the smallest fix - no rewriting the author's taste.
metadata:
  modes: [general]
---

# Code review

I read this when a diff, a patch or a file is handed over for review, or before a merge.

## Order of attention

1. **Does it do what it claims?** Read the claim, then the code, then the test that would catch
   it being wrong.
2. **The unhandled cases**: empty, huge, concurrent, offline, wrong permission, second run,
   partial failure, clock and timezone, unicode.
3. **Security**: secrets in text or logs, input trusted, capability wider than the job, output
   that can execute, dependencies added for one function.
4. **Data**: a migration that cannot roll back, a write that is not atomic, a schema change with
   no default.
5. **Cost**: a loop that calls the network, a query in a render path, an unbounded retry.
6. **Readability last**, and only where it hides a bug or a future one.

## The finding format

```
[BLOCKER|HIGH|MEDIUM|LOW] path:line - what breaks, under which condition
fix: the smallest change that removes the risk
```

## Steps

1. Read the diff twice: once for intent, once for the cases.
2. Run the project's own checks; if they fail, say so before anything else.
3. Write findings, most severe first, with no praise and no essays.
4. Say what you did not review (generated files, vendor code, parts outside the diff).
5. Do not fix in the same pass. Review and repair are separate so the review stays honest.

## Guardrails

- A style preference is not a finding unless the project states it as a rule.
- No "consider rewriting" without the specific risk it removes.
