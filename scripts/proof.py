"""Assemble a hash-chained proof packet for this repository's own verification run.

H=(E,T,C,S,L,V): every command is evidence, its exit code and output hash are recorded, and a non-zero step keeps
the packet at HOLD instead of pretending the run passed. Writes golden/proof.json. Read-only towards the install.
"""
from __future__ import annotations

import datetime
import hashlib
import json
import pathlib
import subprocess
import sys

REPO = pathlib.Path(__file__).resolve().parents[1]
STEPS = (
    ("yaml_lint", [sys.executable, "scripts/yaml_lint.py"]),
    ("secret_scan", [sys.executable, "scripts/secret_scan.py"]),
    ("gate_selftest", [sys.executable, "harness/gates.py", "selftest"]),
    ("ownership_tests", ["node", "--test", "tests/check-owners.test.mjs"]),
    ("contract_tests", [sys.executable, "-m", "pytest", "-q", "tests"]),
    ("install_doctor", [sys.executable, "scripts/doctor.py"]),
)

evidence = []
gates = []
halt = None
now = datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0)

for name, command in STEPS:
    completed = subprocess.run(command, cwd=REPO, capture_output=True, text=True, timeout=300)
    output = completed.stdout + completed.stderr
    evidence.append({
        "kind": "command",
        "name": name,
        "command": " ".join(command),
        "exit": completed.returncode,
        "output_sha256": hashlib.sha256(output.encode()).hexdigest(),
        "output_tail": output.strip().splitlines()[-3:],
    })
    if completed.returncode != 0 and halt is None:
        halt = f"{name} exited {completed.returncode}"

if evidence:
    doctor = next((item for item in evidence if item["name"] == "install_doctor"), None)
    if doctor and doctor["exit"] != 0:
        try:
            report = json.loads(subprocess.run([sys.executable, "scripts/doctor.py"], cwd=REPO, capture_output=True, text=True).stdout)
            for failure in report.get("failures", []):
                gates.append({"id": failure, "verdict": "HOLD"})
        except Exception:
            gates.append({"id": "install_doctor", "verdict": "HOLD"})

jev_path = REPO / "golden" / "jev.json"
if jev_path.is_file():
    jev = json.loads(jev_path.read_text())
    jev_verdict = {k: jev.get(k) for k in ("source", "subject", "verdict", "rubric", "model", "decision_id")}
else:
    jev_verdict = {"source": "pending", "subject": "", "verdict": "HOLD"}

packet = {
    "run_id": f"{now.strftime('%Y-%m-%dT%H:%M:%SZ')}-governance",
    "task": "openautark-os:governance-verification",
    "lane": "RIG",
    "constraints": {
        "owner": "control-plane",
        "floors": ["F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8"],
        "gate_d": "no outward action taken by this run",
    },
    "evidence": evidence,
    "gates": gates,
    "verification": {
        "independent": False,
        "jev": jev_verdict,
        "note": "verdict read from golden/jev.json; an advisory PASS informs and never permits",
    },
    "halt_reason": halt,
}
REPO.joinpath("golden").mkdir(exist_ok=True)
REPO.joinpath("golden", "proof.json").write_text(json.dumps(packet, indent=2) + "\n")
print(json.dumps({"packet": "golden/proof.json", "halt_reason": halt, "steps": len(evidence)}, indent=2))
sys.exit(1 if halt else 0)
