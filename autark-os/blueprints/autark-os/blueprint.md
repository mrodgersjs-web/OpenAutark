# Blueprint: Autark OS — an operating layer for OpenAutark

Status: draft for build. Track: additive markdown + shell (no app code changes).
Upstream: `teydra/OpenAutark` @ `7fa9df4` (fork `mrodgersjs-web/OpenAutark`), Apache-2.0.
Author: RIG (Jake/Aside). Date: 2026-11-23.

## Shape

Autark ships an agent runtime and a set of skill templates. What it does not ship is a
*company operating system*: who routes work, which specialists exist, what each one must
produce, which gates hold an action, and how the team proves a claim. This layer adds that
as data the app already knows how to read — `agents/<id>/SYSTEM.md`, `skills/<name>/SKILL.md`,
`memory/**` — plus the human-facing contract.

Hard boundary: **nothing under `apps/` is edited.** The layer is installable into any Autark
data folder and removable without touching the app. That keeps upstream merges clean and
keeps the app's own boundary rules (runtime never imports electron; UI only speaks RPC) intact.

## Steps

### Step 1 — Layer layout
WHEN `sh autark-os/scripts/check.sh layout` runs THE SYSTEM SHALL exit 0 only if the layer's
folders (`agents/`, `skills/`, `memory/`, `orchestrator/`, `gtm/`, `blueprints/`, `scripts/`,
`docs/`) and its entry files (`README.md`, `ORCHESTRATOR.md`) exist.
Verify: `sh autark-os/scripts/check.sh layout`

### Step 2 — Agent definitions are installable
WHEN `sh autark-os/scripts/check.sh agents` runs THE SYSTEM SHALL exit 0 only if every
`agents/*.md` carries front matter with `name`, `role`, `description`, `mode`, and every value
in `skills:` names a folder that exists under `autark-os/skills/`.
Verify: `sh autark-os/scripts/check.sh agents`

### Step 3 — Skills match the app's own format
WHEN `sh autark-os/scripts/check.sh skills` runs THE SYSTEM SHALL exit 0 only if every
`skills/<name>/SKILL.md` has front matter with `name` equal to its folder, a one-line
`description`, a `metadata.modes` list drawn from the app's shipped modes, and no
`TODO`/`NEEDS CLARIFICATION` marker.
Verify: `sh autark-os/scripts/check.sh skills`

### Step 4 — Routing table is complete and closed
WHEN `sh autark-os/scripts/check.sh router` runs THE SYSTEM SHALL exit 0 only if
`orchestrator/router.json` parses, every `agent` and `skills[]` value resolves to a file in
this layer, and every route names one gate from `orchestrator/gates.md`.
Verify: `sh autark-os/scripts/check.sh router`

### Step 5 — Evidence and docs resolve
WHEN `sh autark-os/scripts/check.sh docs` runs THE SYSTEM SHALL exit 0 only if every relative
markdown link inside `autark-os/` and `research/` resolves to an existing path, every
screenshot named in `research/what-great-looks-like/benchmark.md` exists, and no file matches
the secret patterns (provider token prefixes, cloud key prefixes, private-key headers).
Verify: `sh autark-os/scripts/check.sh docs`

### Step 6 — Install is reversible and fails closed
WHEN `sh autark-os/scripts/install.sh` runs without `--write` THE SYSTEM SHALL print every write it
would make (skills, agents, memory seed) and exit 0 without touching the data folder. With
`--write` it SHALL create agents through the running app (`wf call agents.create`) rather than by
dropping folders, and SHALL record one manifest line per write (SHA-256 for files, agent id for
agents). `--uninstall` without `--write` SHALL refuse with a non-zero exit; with both flags it
SHALL delete a file only while its recorded hash still matches, keep and report any edited file,
and archive installed agents through the app.
Verify: `sh autark-os/scripts/install.sh` (dry run exits 0) and `sh autark-os/scripts/install.sh --uninstall` (exits 2 by design)

### Step 7 — One command for the whole gate
WHEN `sh autark-os/scripts/check.sh all` runs THE SYSTEM SHALL run steps 1-5 in order and exit
non-zero at the first failure, printing the failing check name.
Verify: `sh autark-os/scripts/check.sh all`

## Out of scope (explicit)

- No changes to the desktop app, Android app, website or services.
- No publishing to `library.openautark.com`; new entries stay local until the owner asks.
- No credentials, no spend, no outward send: the GTM skills stop at an approved draft.
