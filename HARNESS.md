# Harness contract

`H=(E,T,C,S,L,V)` defines every governed run in this repository, whether it is a check, a scan or an agent task
executed on the live install.

- **E (Evidence):** inspected paths, command output and freshness evidence. Immutable run inputs.
- **T (Task):** the exact surface, route and stage under test (`routes.yaml`).
- **C (Constraints):** owner from `OWNERS.yaml`, floors F1-F8, lane boundaries, Gate-D.
- **S (State):** typed run state; no hidden mutation of the live install.
- **L (Ledger):** deterministic stage history, gate verdicts and halt reason.
- **V (Verification):** independent checks and a proof packet in `golden/`.

Exit semantics are universal: `0` is `PASS`, `1` is `HOLD`, `2` is `BLOCK`. Unknown, absent, stale, errored or
contradictory evidence cannot be self-certified; it produces `HOLD` or `BLOCK`. A proof packet is written for both
successful and halted runs.

## Outward boundary

The outward boundary is Gate-D. It covers `messages.send` to a person outside the company, email, social posting,
publishing (`library.publish`), spending, and any client or minor-lane account. Approval is exact-text `sha12`
scoped; any edit voids the approval. `harness/gates.py` refuses an outward action whose payload hash does not match
an approval record.

## Judge

Hosted Jev (`rig-s1gate` text, `jev-image` visual) judges typed quality calls. The verdict is read from the hosted
response only. Classifier unreachable, timed out, errored, or a missing subject means `HOLD`. This repository never
self-certifies.

## What this harness does not prove

- It does not prove the live install is safe or correct; `scripts/doctor.py` reports observed state, not intent.
- It does not prove upstream app code is free of defects. `apps/desktop` carries its own suite
  (`npm run check`, `npm run test:e2e`, `npm run test:ui`) which this layer does not run.
- It does not prove that an agent followed a floor at runtime. It proves the artifact and the configured state
  matched the floor, and names what a runtime guard would have to enforce.
- A green run is evidence, never the claim.

## Proof packet

```json
{
  "run_id": "YYYY-MM-DDTHH:MM:SSZ-<task>",
  "task": "<route id>",
  "lane": "<lane>",
  "constraints": {"owner": "<owner>", "floors": ["F1"]},
  "evidence": [{"kind": "command", "command": "<cmd>", "exit": 0, "output_sha256": "<sha>"}],
  "gates": [{"id": "F1", "verdict": "PASS"}],
  "verification": {"independent": true, "jev": {"source": "hosted", "subject": "<id:sha12>", "verdict": "PASS"}},
  "halt_reason": null
}
```
