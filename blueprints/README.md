# OpenAutark OS governance blueprint

Owner: `architect-blueprint` (`OWNERS.yaml -> blueprints/**`).

`blueprints/openautark-os-architect.json` maps the nine governed surfaces in `routes.yaml` to the 36-pattern
catalog in [`mrodgersjs-web/agentic-architectures`](https://github.com/mrodgersjs-web/agentic-architectures).

## Guarantees

- **Mode:** `draft_only`. No stage sends, publishes, spends or edits the live install.
- **Lane isolation:** `lane="RIG"` and `reconcile_owner="RIG"` on every node.
- **Floors:** `hard_floors` names all eight; each node lists the subset it enforces.
- **EARS acceptance:** every node carries `acceptance` statements ("When ..., the system shall ...; If ..., the
  system shall ...") and a `verify` command that fails today if the behaviour is missing.
- **Backends:** RIG LiteLLM (`http://127.0.0.1:18770/v1`, `rig-auto`), the Codex CLI shim, and
  `offline_deterministic` — and in practice every gate here is deterministic and needs no model at all.

## Verify

```sh
rig-patterns blueprint-verify --file blueprints/openautark-os-architect.json --json
python3 -m pytest -q tests && node --test tests/*.test.mjs
```

The validator answered `ok: true`, 9 nodes, 0 errors, 0 warnings on 2026-11-23.
