# Design draft — Autark OS layer

Date: 2026-11-23. EGM step: draft. Revision 1.

## Shape

An additive folder at the repo root, `autark-os/`, that the app can read without any code change:

```
autark-os/
  README.md            what it is, install, the team chart, the checks
  ORCHESTRATOR.md      the contract: loop, filter, WIP, gates, truth rules, escalation, cadence
  UPGRADES.md          30 moves, effort and effect, with a verify each
  orchestrator/        router.json (14 routes), gates.md (G0-G4), cadence.md
  agents/              15 agent definitions, app front-matter
  skills/              24 SKILL.md procedures, app front-matter
  memory/              15 seed memory files, company + 6 branches
  gtm/                 signals, channels, sequences, aeo surface, metrics
  blueprints/autark-os/blueprint.md   EARS steps, one verify command each
  scripts/             install.sh (dry-run default, reversible), check.sh (7 checks)
  docs/design/         this brief, this draft, the review, the resolution
```

## The three design decisions that carry the rest

1. **Additive, not invasive.** The app's own architecture states its boundaries (`docs/ARCHITECTURE.md`:
   runtime never imports electron, UI only speaks RPC, shared stays pure). An OS layer that edits the
   app would have to defend those boundaries on every upstream merge. Data does not.
2. **Gates are named, not implied.** Every skill states the highest gate it reaches alone. Nothing in
   the layer reaches G3 or G4 by itself. The ladder is short enough to memorise: read, draft, internal
   write, outward, money.
3. **Every claim has a check.** The blueprint's steps are the check suite's subcommands, so a step
   that is not implemented fails a named check. What `check.sh` proves is the *layer's own*
   integrity - files, front matter, routing closure, links, no secrets. It does not prove that a
   running app discovered the agents or routed a request. That is a separate, named smoke test
   (`install.sh` prints it: one brief from the chief of staff with owner, gate and done-test), and
   it needs a live app plus a person to judge the answer.

## Why the team is this shape

Three layers, because coordination cost is the thing that kills agent teams: one orchestrator, five
heads (GTM, engineering, design, finance-ops, security), and doers that own a method. A doer exists
where the work is steady and specialised (outbound, content, writing, AEO, architecture, review,
research, proof, council). Where the work is a one-off, the orchestrator splits itself instead of
hiring (`skills/agent-team-hiring`).

## What is deliberately missing

- No dashboard: the app has UI, and a second dashboard is a second truth.
- No vector store or index: memory is files the person can read and edit.
- No cron: the cadence is a table a person or the app's own scheduler reads, not a daemon here.
- No model choice: the app routes models; the layer stays model-agnostic on purpose.

## The install path (the risky part)

`install.sh` defaults to a dry run and lists every write. With `--write` it copies skills into the
workspace's shared `skills/` (never overwriting an existing folder), creates agents **through the
running app** (`wf call agents.create`) because a folder the app's roster does not list is skipped,
and seeds memory only into `<data>/memory/company/autark-os/`, which no existing entry occupies. The
manifest records one line per write - SHA-256 plus path for files, agent id plus name for agents -
and `--uninstall --write` deletes a file only while its hash still matches, keeping anything edited
and saying so. This is the part most likely to break on a real, populated install (the one on this
machine has 429 agents), so it is written to fail closed: no app, no agent install; no `--write`, no
deletion.

## Open questions for the reviewers

1. Does a fresh reader know what to do in the first minute?
2. Does the installer damage a live team, and is every write reversible?
3. Is any rule here unenforceable, and therefore decoration?
