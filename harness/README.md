# OpenAutark OS harness

The deterministic half of the operating layer: floors F1-F8 as code, plus a read-only doctor over the live install.
Nothing here runs an agent turn, writes to the data folder, or calls a model except the doctor's single
`models.uses` RPC.

| Piece | What it does | Fails how |
|---|---|---|
| `gates.py` | one function per floor; `selftest` runs 16 adversarial cases | exit 1 HOLD, exit 2 BLOCK |
| `../scripts/doctor.py` | probes the live install and the repository contract | exit 1 on any failing check |
| `../scripts/proof.py` | runs every check and writes `golden/proof.json` | exit 1 and `halt_reason` when a step fails |
| `../routes.yaml` | the nine surfaces, each with its gate command and floors | doctor fails if a route lacks any field |

## Floor map

| Floor | Gate | Check it performs | What it does not prove |
|---|---|---|---|
| F1 outward_needs_gate_d | `requires_gate_d` | payload action class, Principal approver, `sha12` equality, action scope | that the person actually read the text |
| F2 truth_and_style | `truth_and_style` | banned words, em dash in outward copy, empty copy | that a number is true |
| F3 jev_fail_closed | `jev_verdict` | hosted source, non-empty subject, verdict vocabulary | that the rubric is calibrated |
| F4 pc_access_declared | `pc_access` | `profile.pcAccess` or the `security` section, unknown values refused | that the runtime enforces it (see D4) |
| F5 model_routing_declared | `routing_declared` | every route prefix against declared providers plus builtins; decisions not `auto` | that the provider answered |
| F6 external_text_is_data | `external_text` | instruction-override patterns in retrieved text | that every injected variant is known |
| F7 secrets_never_exposed | `credential_shapes`, `credentials_in_settings` | credential shapes in text; non-`secret://` provider values by path | that a rotated value is dead |
| F8 minors_and_client_lanes | `lane_allowed` | minor and client targets need a Principal approval with a text hash | that the lane's own tooling obeys |

## Run

```sh
python3 harness/gates.py selftest                       # 16 cases, all four verdict paths
python3 harness/gates.py check --check routing_declared --settings "$AUTARK_DATA/settings.json"
python3 scripts/doctor.py | python3 -m json.tool | head -40
python3 scripts/proof.py && cat golden/proof.json
```

`AUTARK_DATA` defaults to `~/Library/Application Support/Autark` on macOS. Set it on Windows or Linux, or point it
at a fixture directory in a test.

## Adding a floor

One function returning the `_verdict` shape, one entry in `CHECKS`, one adversarial case in `SELFTEST_CASES`, one
test in `tests/test_gates.py`, one line in `floors.yaml`. A floor without a case that fails today is not a floor.
