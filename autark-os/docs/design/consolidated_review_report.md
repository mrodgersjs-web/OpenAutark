# Consolidated review report — Autark OS layer

Date: 2026-11-23. Input: `goldfish_review.md` (three zero-context reviewers, 17 findings).
Merge: union. Every finding gets one disposition: FIXED, CONTESTED (with the reason), or OPEN
(with what would close it).

| # | Finding | Severity | Disposition | What changed |
|---|---|---|---|---|
| 1 | README claimed the gate ladder is runtime-enforced | blocker | **FIXED** | claim rewritten; new "What enforces what" table in `orchestrator/gates.md`: Security settings are runtime-enforced, the ladder is policy plus an audit trail, ApprovalRequest hooks land in the installed build from 0.3.19 (installed: 0.3.14) |
| 2 | Approval bound text only | blocker | **FIXED** | G3 is now action-shaped: text + recipient + sending account + attachments, compared immediately before the action |
| 3 | Uploads, webhooks, public pushes outside G3 | high | **FIXED** | G3 redefined as anything that leaves the machine for another person or a public place, including those three |
| 4 | Uninstall cannot tell edited files from untouched ones | high | **FIXED** | manifest records SHA-256 per file; uninstall deletes only while the hash matches, keeps and reports edits |
| 5 | README and design draft disagreed on how to install | high | **FIXED** | one implementation, documented once: dry run by default, `--write` to install, `--uninstall --write` to remove |
| 6 | "Cannot drift" overclaimed what `check.sh` proves | high | **FIXED** | scope stated: the checks prove the layer's integrity, not that a running app discovered agents or routed a request; a separate named smoke test covers that |
| 7 | WIP cap had no atomic admission | medium | **FIXED** | the app's task board is declared the only queue; the owner slot is reserved before work starts |
| 8 | `--uninstall` deleted without `--write` | critical | **FIXED** | refuses with exit 2 and prints the two-step preview/apply; verified: exit 2 |
| 9 | Recursive delete removed user edits | high | **FIXED** | file-by-file deletion, hash-checked, no `rm -rf` on recorded paths |
| 10 | Manifest truncation orphaned earlier entries | high | **PARTIAL** | the previous manifest is preserved (`autark-os.manifest.prev`) and merged into the new one; a copy that fails halfway can still leave an unrecorded file — accepted risk, documented |
| 11 | Skill collision redirected into `.autark-os` and could overwrite | high | **FIXED** | collisions are skipped and reported; nothing is renamed, nothing overwritten |
| 12 | Dropped agent folders are skipped by the app's roster | high | **FIXED** | agents are created through the running app (`wf call agents.create`), which is how the roster learns them; `--skills-only` exists for machines without the app running |
| 13 | `AUTARK_DATA` still pointed skills at `~/Workforce` | high | **FIXED** | workspace resolves as: `AUTARK_WORKSPACE` → `<data>/workspace` (a company's own workspace) → `~/Workforce` |
| 14 | Preview omitted collisions and skips | medium | **FIXED** | dry run lists skills, memory seed, agents, and states whether `wf` is reachable |
| 15-17 | First-run gaps: where to connect a model, how a task is assigned, which approvals apply on day one | medium | **FIXED** | new "First five minutes" section: connect a model, decide `library.publish` before the first session, install, learn the brake, smoke-test the brief |

## Contested

- **"No mechanism checks a task's gate when a tool executes" (part of #1).** Contested as a
  *blocker for this layer*: the runtime hook is not ours to add without editing `apps/`, which the
  design forbids for upstream-merge reasons. The claim is removed rather than the mechanism faked.
  Closing it properly is a proposal for upstream, filed as UPGRADES row 4 (show the brake) and a
  note in `design_draft.md`.
- **"A path-prefix check does not establish ownership" (#9).** Accepted in principle, contested in
  practice only because the manifest plus hash plus prefix check is the strongest guarantee a shell
  script can give without a database. The residual risk is written down rather than hidden.

## Open

- **No `--write` run has been executed against a live install.** The install on this machine has 429
  agents and a running team; the layer was verified by dry run and by reading the app's own source
  for the roster rule (`agent-core/service.ts:113`) and the `agents.create` contract
  (`shared/api/methods.ts:80`). What would close it: one `--write` on a scratch company folder
  (`AUTARK_DATA` pointed at a copy), then `--uninstall --write`, then a diff of the folder.

## What the review changed in substance

Three claims were removed (runtime enforcement, "cannot drift", text-only approval), two designs
were replaced (folder-drop agents → app-created agents; recursive uninstall → hash-checked file
removal), and one gap in the first screen was filled (first five minutes). The layer is smaller and
more honest than its first draft, which is the point of a review.
