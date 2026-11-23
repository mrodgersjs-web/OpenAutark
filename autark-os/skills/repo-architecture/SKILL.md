---
name: repo-architecture
description: Inspect a codebase before designing, map boundaries and debt with evidence, then emit a blueprint whose verify commands are the done-tests.
metadata:
  modes: [general, manager]
---

# Repo architecture

I read this before any change to a codebase I did not write, and before any new repo is created.

## Mode 0 - scan (default)

One compact note: the layers, the entry points, who owns state, the data, the two flows that
matter, the boundary rules the project states about itself (read its own ARCHITECTURE.md and
agent rules first).

Promote to a full pass only with a named trigger (multi-module change, a boundary that leaks,
a migration, a performance cliff) and a stated risk.

## The four failures to look for

1. **Two jobs in one module** - a file that both fetches and decides, or both renders and stores.
2. **A flow that runs both ways** - A calls B and B calls A; the fix is a third thing both use.
3. **A core that imports a vendor** - the database or the framework leaking into the model.
4. **An environment baked in** - a path, a hostname or a credential constant in logic.

## Steps

1. Inventory: top files by size and change frequency, the import graph, tests, deploy config.
2. Mark every statement **Direct** (path + line), **Inferred** (labelled), or **Not observed**.
3. Score the S.U.P.E.R letters 0-5 with evidence: single purpose, unidirectional flow, ports over
   implementation, environment-agnostic, replaceable parts.
4. List debt as: severity, location, what breaks, smallest safe correction, blast radius.
5. Emit the blueprint: steps with EARS criteria and one verify command each, ordered so each
   step leaves the repo green.
6. Stop for confirmation before writing code if the change is not reversible.

## Output

`docs/architecture/<area>.md` and `blueprints/<slug>/blueprint.md`.

## Guardrails

- Never edit production code in the same pass as the assessment.
- A verify command that already passes is not describing new work. Fix the step, not the check.
