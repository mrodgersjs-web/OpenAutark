# Blueprint — skill packs for the Autark OS layer

Brownfield pass (`/architect-brownfield`), 2026-11-23. Repo map and assessment:
`docs/architecture/autark-repo-map.md`. This blueprint covers the work that remains after the
catalog, the installer and the offline fixture test landed; every step's verify command **fails
today**, which is what makes it a plan and not a status report.

## Decision

Twenty public packs are catalogued, 8 vendorable and 12 reference-only. A pack is installed into the
workspace as `<pack>--<name>`, never into the repo, so the layer stays additive and the license line
stays visible. What is missing is the join between a pack and the agent that should use it, the
ability to see and undo what was installed, and a check that catches a catalog rot.

## Steps

### 1 — Agent to pack map
WHEN `sources/agent-packs.json` is read THE SYSTEM SHALL name, for each of the 15 agents, the
skills it should have from packs versus our own, so installing a pack is a decision with an owner
and not a bulk copy.
Verify: `node -e 'const m=require("./sources/agent-packs.json");const a=require("fs").readdirSync("./agents").filter(f=>f.endsWith(".md")).map(f=>f.slice(0,-3));const miss=a.filter(x=>!m.agents[x]);process.exit(miss.length?1:0)'` — fails today (file absent).

### 2 — List what came from where
WHEN `sh autark-os/scripts/add-pack.sh --list` runs THE SYSTEM SHALL print every installed pack with
its license, source URL and the skill folders it created, read from the manifest.
Verify: `sh autark-os/scripts/add-pack.sh --list | head -1` exits 0 and prints a header — fails today (no `--list`).

### 3 — Undo a pack
WHEN `sh autark-os/scripts/add-pack.sh superpowers --remove --write` runs THE SYSTEM SHALL delete
only files whose SHA-256 still matches the manifest, keep edited ones and say which.
Verify: install the fixture, remove it, and require the folder to be gone and an edited copy to
survive — `sh autark-os/tests/pack-remove.sh` — fails today (test absent).

### 4 — Docs check covers the new areas
WHEN `check.sh docs` runs THE SYSTEM SHALL resolve links in `sources/` and `docs/architecture/` as
well as the two roots it already covers.
Verify: add a link to a missing file in `sources/README.md` and require `check.sh docs` to exit 1.

### 5 — Prove the hash portability claim on two OSes
WHEN CI runs THE SYSTEM SHALL execute `check.sh all` on both `ubuntu-latest` and `macos-latest`,
because `shasum` exists on BSD and `sha256sum` on GNU and the layer claims both.
Verify: `.github/workflows/autark-os-check.yml` contains a `matrix:` with both runners and the run is
green on both.

### 6 — Catch catalog rot
WHEN `sh autark-os/scripts/verify-packs.sh` runs THE SYSTEM SHALL re-open every pack's `take` path
through the GitHub API and print `ok <id>` or `DRIFT <id> <reason>`, exiting 1 on any drift.
Verify: run it; it prints 20 lines and exits 0 — fails today (script absent).

### 7 — Apply the first five packs to the agents that should have them
WHEN the map from step 1 exists THE SYSTEM SHALL install the five highest-leverage packs for the
agents named in the map, record the result in `sources/applied.json`, and leave every other agent
untouched.
Verify: `node -e 'const a=require("./sources/applied.json");process.exit(a.applied.length>=5?0:1)'`
— fails today.

### 8 — Proof packet for the change
WHEN the steps above are done THE SYSTEM SHALL carry one proof packet: the check output, the
fixture transcript, the file counts and the commit sha, per `skills/proof-packet`.
Verify: `sh autark-os/scripts/check.sh all && test -f autark-os/sources/proof/autark-skill-packs.md`

## Status, 2026-11-23

All eight steps are green: the map exists for all 15 agents, `--list` and `--remove` work and are
tested, the docs check covers the new roots, CI runs on Ubuntu and macOS, the catalog re-check found
0 drift in 20 packs, five packs (28 skills) are installed and recorded with their commit shas, and
the proof packet is `sources/proof/autark-skill-packs.md`. From here the verify commands are frozen.

## What this blueprint does not do

- It does not install anything into the live app. That is a person's decision, one pack at a time.
- It does not copy files from a `reference` pack. Those stay links until someone reads the license.
- It does not touch `apps/`, and every step above lives in `autark-os/`.

## Frozen checks (architect-loop)

The commands in steps 1-8 are the frozen checks: once a step is green, its command must keep
exiting 0 in every later commit, or the change that broke it is reverted. `tasks.json` carries them
as machine-readable entries with `status`, `acceptance`, `verify` and `depends_on`.
