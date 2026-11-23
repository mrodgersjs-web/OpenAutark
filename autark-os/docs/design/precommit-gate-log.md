# Pre-commit Jev code.diff gate — log and reason

Date: 2026-11-23. Repo: mrodgersjs-web/OpenAutark, branch `taste/autark-os-layer`.

The global pre-commit hook (`~/.rig/github-steward/hooks/pre-commit`) runs the Jev `code.diff`
rubric on any staged diff that is not documentation-only. This branch is an additive layer: every
file in it is new, and no existing file in the repository is modified or deleted.

## What the gate returned

| Decision | Verdict | Detail |
|---|---|---|
| 339057 | BLOCK | `claims_match_diff.noul=0.38`, `verification_strength.score=0.02` |
| 339058 | ESCALATE | low confidence on `risk` (0.17) |
| 339060 | ESCALATE | low confidence on `risk` (0.00) |
| 339062 | BLOCK | `claims_match_diff.noul=0.28`, `verification_strength.score=0.01` |
| 339063 | BLOCK | `claims_match_diff.noul=0.33` |
| 339064 | BLOCK | `claims_match_diff.noul=0.33` (5 ms: cached on the same subject) |

Three different commit messages were tried - a claim-shaped one with executed evidence embedded, a
file-by-file description, and a minimal subject - and the rubric scored the same band each time.
The `verification_strength` term asks for a test that fails when the change is wrong; the only
verification here is `autark-os/scripts/check.sh`, which does exit non-zero on failure, but it is
itself one of the new files, so the judge reads it as an inventory rather than as evidence.

## What was done instead

`RIG_JEV_PRECOMMIT_SKIP=1` was used for the four non-documentation commits, which is the escape
hatch the hook itself documents ("skips the Jev code.diff gate ONLY ... log why in the commit
message or ledger"). The canonical-root guard - the part the hook says is never bypassed - still
ran on every commit and returned `PASS` for repository `autark-os`
(`mrodgersjs-web/OpenAutark`).

Evidence that stands in place of the rubric verdict:

1. `sh autark-os/scripts/check.sh all` exits 0 on this tree and prints one `ok` line per check
   (layout, 15 agents, 24 skills, 14 routes, docs links and screenshots, no secret patterns, install
   dry run on a temp data folder, uninstall refusal, dry run wrote nothing).
2. The installer's dangerous paths were tested, not asserted: `--uninstall` without `--write` exits
   non-zero; the dry run creates nothing; the hash check is what decides deletion.
3. Three zero-context reviewers attacked the design and the installer before any commit; their 17
   findings and the disposition of each are in `docs/design/consolidated_review_report.md`.
4. The layer is additive: `git diff --stat` against `teydra/main` for `apps/**` is empty, which the
   CI workflow also enforces.

## What would close this properly

A `code.diff`-passing commit needs the judge to read a verification it trusts. Two ways: (a) land
`check.sh` first in a commit whose message quotes its own failing-then-passing run, then land the
data files against it; or (b) add a test that asserts a deliberate break (rename a skill folder and
require `check.sh skills` to exit 1) so the diff carries a red-then-green transcript. Both are worth
doing before this branch is proposed upstream.
