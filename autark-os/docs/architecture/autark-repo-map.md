# Autark repo map and architecture assessment

Date 2026-11-23. Run in **Scan Mode** (seniorarchitect Rule 0): one compact note, no rewrite
proposals, every statement marked Direct (path), Inferred, or Not observed.

## 1. The upstream system, as it states itself

| Layer | Where | Rule the project states about itself |
|---|---|---|
| Runtime | `apps/desktop/src/runtime/**` | never imports electron; owns state, threads, tools, security (Direct: `docs/ARCHITECTURE.md`) |
| UI | `apps/desktop/src/ui/**` | speaks RPC only; never touches runtime state directly (Direct: same) |
| Shared | `apps/desktop/src/shared/**` | pure types and contracts, no side effects (Direct: same) |
| Data | `<data>/agents/<id>/`, `<data>/memory/`, `<data>/workforce.db`, `<data>/settings.json` | the runtime reads what is on disk and reconciles it (Direct: `agent-core/service.ts:110-125`, `home.ts:1-12`) |
| External surface | `runtime.json` → `{port, token}` at `127.0.0.1/rpc`; `wf` shim in `<data>/bin/` | every outside caller goes through the same RPC (Direct: read of a live install) |

## 2. Where this layer sits

`autark-os/` is **data, not code**: 15 agent files, 24 skills, a routing table, seed memory, a source
catalog and two shell scripts. Nothing in `apps/` imports it, and no file under `apps/` is modified
(`git diff --stat origin/main -- apps` is empty, and CI enforces it).

The only executable surface is `scripts/`, which writes to three places and nowhere else:

```
<workspace>/skills/<name>/SKILL.md                  skills this layer or a pack installs
<data>/agents/ag_autarkos_<slug>/                   agents, created through the app's own RPC
<data>/memory/company/autark-os/                    the seed memory, only if absent
<data>/autark-os.manifest                           one line per write, SHA-256 + path
```

## 3. S.U.P.E.R score for the layer (0-5, evidence attached)

| Letter | Score | Evidence | What would raise it |
|---|---|---|---|
| **S**ingle purpose | 4 | each `skills/*/SKILL.md` states one procedure with one output; `router.json` maps one intent to one agent | two skills overlap on writing (`content-strategist` vs `linkedin-writer`); merge or draw the line |
| **U**nidirectional flow | 4 | intent → router → agent → skill → artifact → proof; no skill calls another skill's owner | `gtm-council-review` is imported by both writing skills; make it a declared step, not an implicit call |
| **P**orts over implementation | 3 | catalog is data; scripts are thin. But `install.sh` and `add-pack.sh` each resolved the workspace themselves until this change | keep `scripts/lib.sh` the only place that knows platform rules |
| **E**nvironment-agnostic | 3 | data folder resolution covers macOS/Linux/Windows; hashing now picks `shasum` or `sha256sum` | `check.sh` docs scan covers two roots only; `gh` is optional, not required |
| **R**eplaceable parts | 4 | pack skills install as `<pack>--<name>`, so any pack can be removed without touching ours; manifest records hashes | a `--list` that shows what came from where |

Total 18/25. The two 3s are honest: the scripts were written fast and duplicated one rule twice.

## 4. Debt, with severity and the smallest safe correction

| # | Finding | Severity | Evidence | Smallest correction |
|---|---|---|---|---|
| D1 | `install.sh` and `add-pack.sh` resolve the workspace independently | high (drift already caused one bug) | both had their own `if AUTARK_WORKSPACE / AUTARK_DATA / ~/Workforce` block | **fixed here**: one `scripts/lib.sh` |
| D2 | `shasum` is BSD-only; the CI runner is Ubuntu | high (install would fail on Linux) | `check.sh` runs on `ubuntu-latest` | **fixed here**: `sha256()` picks `shasum` or `sha256sum` |
| D3 | The pack copy loop had no test; only a catalogue shape check | high (the "verification is did not throw" class) | first fixture run failed on a relative path | **fixed here**: `check.sh sources` runs a real offline install and reads the file back |
| D4 | Pack skills keep their upstream `name:`, which collides with ours | high (silent shadowing) | `brainstorming` exists in two packs | **fixed here**: renamed to `<pack>--<name>` on copy |
| D5 | Catalog `stars` go stale; only the `take` path is verified | low, accepted | `checked_at` field + path verification | re-read stars when a pack is installed, not on a schedule |
| D6 | `docs` check scans two roots, so a broken link elsewhere passes | medium | `check_docs` roots array | add a root per new documentation area, not a recursive scan of `apps/` |
| D7 | Nothing in the layer guards against a pack that ships a malicious script | medium | packs are Markdown today, but a `SKILL.md` can instruct anything | install rule already in `sources/README.md`: vendor mode copies only directories containing `SKILL.md`; no executables are copied |
| D8 | Approval hooks do not exist in the installed build (0.3.14) | medium, external | `docs/ARCHITECTURE-NOTES.md`; source has them from 0.3.19 | state it in the docs (done) and never claim runtime enforcement |

## 5. Blast radius of adding the pack system

Read: `catalog.json`, the pack's public repo. Written: `<workspace>/skills/<pack>--<name>/` and the
manifest. Not touched: `apps/`, the app's database, `settings.json`, any credential, any existing
skill folder that already exists. Undo: delete the manifest lines' files, or `--uninstall` from
`install.sh`.

## 6. Not observed

- The app's own skill loader was read only through source and one live install, not by installing a
  pack into it.
- No pack was installed into the live 429-agent install; that stays a person's decision.
- Windows has no verification at all; the script branches exist but were never run there.
