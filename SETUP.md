# OpenAutark OS: what this layer is, how to run it, what is open

A governed operating layer over [OpenAutark](https://github.com/teydra/OpenAutark), built the way job-search-os was:
contract files, one owner map, eight floors as code, a read-only doctor over the live install, and a verified
blueprint. Upstream code (`apps/`, `services/`, `library/`) is untouched so it stays merge-clean.

## What exists

| File | Role |
|---|---|
| `AGENTS.md` / `CLAUDE.md` / `GEMINI.md` | operating instructions for any agent working here |
| `HARNESS.md` | `H=(E,T,C,S,L,V)`, exit 0 pass / 1 hold / 2 block, Gate-D, what the harness does not prove |
| `OWNERS.yaml` | one owner per path, principal `mrodgersjs-web` |
| `floors.yaml` | F1-F8 with the check that enforces each and `on_missing_evidence: HOLD` |
| `routes.yaml` | nine surfaces, each with its gate command and floors |
| `harness/gates.py` | one deterministic gate per floor + a 16-case selftest |
| `scripts/doctor.py` | read-only probe: settings, runtime RPC, routing, agents, memory, secrets, db, disk |
| `scripts/secret_scan.py` | credential scan, in-scope vs upstream-reference accounting |
| `scripts/yaml_lint.py` | every YAML/JSON file parses |
| `scripts/proof.py` | runs everything, writes `golden/proof.json` |
| `tests/` | 9 ownership tests, 14 contract tests |
| `docs/ARCHITECTURE-NOTES.md` | seniorarchitect scan: boundary, module map, debt D1-D8, open questions |
| `research/architecture/SUPER-SCORECARD.md` | S.U.P.E.R 4.4/5 with file evidence + 10-check review |
| `blueprints/openautark-os-architect.json` | 9 nodes, EARS acceptance, `rig-patterns blueprint-verify` ok |
| `golden/proof.json` | the run's evidence, hashes, halt reason and Jev verdict |

## Run it

```sh
npm run verify            # lint + secret scan + gate selftest + node tests + pytest + doctor
python3 scripts/proof.py  # the same, wrapped in a proof packet
~/.local/bin/rig-patterns blueprint-verify --file blueprints/openautark-os-architect.json --json
```

## Status as of 2026-11-23

| Check | Result |
|---|---|
| YAML/JSON parse (37 files) | pass |
| Secret scan (4017 text files) | pass, 0 in-scope findings, 22 upstream reference hits |
| Gate selftest (16 cases) | pass |
| Ownership tests (9) | pass |
| Contract tests (14) | pass |
| Blueprint verify (9 nodes) | pass, 0 errors, 0 warnings |
| Live install doctor | **HOLD: one real finding** (below) |
| Jev `done.claim` | advisory PASS, decision 339049, subject `docs:openautark-os-setup@f0f0a4ebdf53` |
| Commit | **blocked**: this root is not a registered writable root |

## Open items

1. **Raw provider credential (F7).** `settings.json` holds a literal bearer token at
   `providers.aside-gemini.models[google-antigravity/gemini-4-carbon].headers.Authorization` while every other
   credential is a `secret://` reference. Fix: store it in Settings › Secrets, set that header to
   `Bearer secret://<id>` (the app's own contract, `apps/desktop/src/ui/settings/apps-files.ts:88`), then rotate the
   exposed token. It is account material, so it waits for Mike.
2. **Commits are blocked by the estate's repo guard.** `rig-repo-guard check /Users/rig128gb/Developer/autark-os`
   answers `BLOCK: path is outside every registered writable root`. The registry
   (`Developer/rig-intelligence/registry/workstation-repositories.json`) is at its 196 writable ceiling, so adding
   this root is a swap decision plus a registry edit, not a silent append.
3. **Install 0.3.14 vs fork 0.3.19.** Secure mode, the `security` settings section and `ApprovalRequest` are in
   source, not in the running build. F4 is enforced on `profile.pcAccess` only until the update lands.
