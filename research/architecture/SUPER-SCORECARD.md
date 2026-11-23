# S.U.P.E.R scorecard: OpenAutark

Scale 0-5 per letter, file-path evidence, findings labelled PROPOSED. Reviewed 2026-11-23 against the fork
(`apps/desktop` upstream `0.3.19` source) and the running install (`0.3.14`). Source of the method:
`vendor/spec_driven_develop` (SUPER-Architecture-Principles, MIT).

Applied to the **change** this repository makes (a governance layer over the app) as well as to the app's own
structure, because the method judges a change, not a codebase in the abstract.

| Letter | Score | What earns it (evidence) |
|---|---|---|
| **S** Single Purpose | 4/5 | Every source file must carry an `Owns:` / `Never:` leading comment or `npm run boundaries` fails (`apps/desktop/scripts/check-boundaries.mjs:1-40`). One settings table owns every key, value and comment (`src/runtime/settings/schema.ts`). Runtime owns all state and behaviour (`docs/ARCHITECTURE.md` §2). Deduction: 1113 runtime files / 151k LOC means purpose is per-file, not per-module; there is no per-domain budget. |
| **U** Unidirectional Flow | 5/5 | The layer rules are machine-enforced, not documented hope: `shared → shared`, `runtime → shared`, `main/preload → shared (+electron)`, `ui → shared`; `runtime` may not import `electron` and `ui` may not import `node:` (`check-boundaries.mjs` `allowed`/`forbiddenPackages`). The UI speaks RPC only (`src/ui/lib/rpc.ts`). The turn flow is one direction: RPC in, engine out, tools, events back. |
| **P** Ports over Implementation | 4/5 | Three host implementations behind one port: `src/runtime/host.ts` with `host-electron.ts` and `host-node.ts` (headless, used by CI and worker PCs). Engines are replaceable behind one contract (plan CLIs, API keys, local servers). Deduction: runtime calls SQLite and the data-folder file contracts directly; there is no storage port, so a test that wants another store must fake at a lower level (`test/unit/fakes.ts`). |
| **E** Environment-Agnostic | 4/5 | `--data <dir>` and `WORKFORCE_TEST_DATA` for headless runs; companies are folders, not globals; Windows/macOS/Linux packaging scripts in `scripts/desktop-release/`. Deduction: the doctor in this repository defaults to a macOS path (`scripts/doctor.py` `DATA`), and `apps/desktop` has OS-specific branches (`main/updates/mac-self-update.ts`, `resources/broker/install.ps1`). |
| **R** Replaceable Parts | 5/5 | Providers and models are data (`settings.json` `providers` + `routing`, 25 providers live). Prompts, modes and themes are overridable from the data folder (`prompts/`, `modes/`, `theme.css`). Skills are folders with `SKILL.md`. Agents are folders with `SYSTEM.md`. Nothing in the runtime hardcodes a vendor. |

**Weighted read: 4.4 / 5.** The app is structurally disciplined. The governance layer inherits that and adds no
runtime module (`AGENTS.md` rule 2, `docs/ARCHITECTURE-NOTES.md` §4).

## Findings from the 10-check review

Checks from the upstream list, applied to this change:

| # | Check | Result | Evidence / why |
|---|---|---|---|
| 1 | One purpose per unit | PASS | Nine routes, one surface each (`routes.yaml`); one gate function per floor (`harness/gates.py` `CHECKS`). |
| 2 | Dependencies point one way | PASS | `apps/desktop` boundary checker untouched and re-run in CI; this layer reads the app, the app never reads this layer. |
| 3 | Ports, not implementations | PARTIAL | `harness/gates.py` is a library plus a CLI, so tests call functions and CI calls the CLI (one port, two adapters). `scripts/doctor.py` talks HTTP directly with no client interface: PROPOSED, a `RuntimeClient` class if a second caller appears. |
| 4 | No hardcoded environment | PARTIAL | `AUTARK_DATA` overrides the data folder and the tests use it; `runtime.json` port and token are read, never hardcoded. Deduction: the default path is macOS-only (D8). |
| 5 | Replaceable parts | PASS | Every gate is a function in a dict: a new floor is one function plus one test. No gate knows about another. |
| 6 | Explicit failure | PASS | Exit 0/1/2; a probe that throws becomes a named failing check, never a green run (`doctor.py:check`); `gates.py main()` catches and returns HOLD. |
| 7 | No hidden mutation | PASS | Doctor is read-only (SQLite `mode=ro`, no writes, no turn). Verified by `tests/test_doctor_contract.py::test_doctor_never_prints_the_owner_token` and by the absence of any write call in `scripts/doctor.py`. |
| 8 | Tests at the seams | PASS | 9 Node ownership tests, 14 pytest contract tests, a 16-case gate selftest. The doctor's seam is tested with a fixture folder, not the live install. |
| 9 | Documented truth | PASS | `docs/ARCHITECTURE-NOTES.md` labels Direct / Inferred / Not observed; every number is re-measurable from section 9. |
| 10 | Reversible | PASS | Everything here is additive; deleting the files in this layer leaves the app runnable. No settings were written by this pass. |

Verdict: **0 fail, 2 partial**. Fix the two partials before the layer grows a second consumer; neither blocks the
setup.

## One contradiction check, as asked

The `autark-os/` layer (agents, skills, memory written in the app's own format) does **not** change the runtime
boundary: the runtime reads `agents/<id>/SYSTEM.md`, `agents/<id>/skills/<name>/SKILL.md` and `memory/**.md` as data
(`docs/ARCHITECTURE.md` §3), and the files are not imported by any module. `runtime` still never imports `electron`,
and `ui` still speaks RPC only. No contradiction with `npm run boundaries`. One caveat worth naming: memory files are
loaded into context, so anything written into them is read by agents as content (F6). The screen for that is
`harness/gates.py:external_text`.
