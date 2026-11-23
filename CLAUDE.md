Read `AGENTS.md`, then `OWNERS.yaml`, `floors.yaml` and `HARNESS.md` before touching this repository.

Short form: upstream code in `apps/`, `services/`, `library/` is frozen; the governance layer in the root contract
files, `harness/`, `scripts/`, `tests/`, `blueprints/`, `docs/`, `research/` is ours; the live install under
`~/Library/Application Support/Autark` is data and is read-only unless the Principal asks for a change; exit `0`
pass, `1` hold, `2` block; outward actions need exact-text Gate-D approval; Jev unreachable means `HOLD`.

Verify with `npm test`, `python3 scripts/yaml_lint.py`, `python3 scripts/secret_scan.py`,
`python3 scripts/doctor.py`.
