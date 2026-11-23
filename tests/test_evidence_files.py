"""The captured evidence must stay checkable: fixed shape, counts present, and no credential value inside.

A captured file that silently drifts (a renamed key, an embedded token) would make docs/ARCHITECTURE-NOTES.md
quote numbers that no longer exist. These tests are the contract for research/architecture/evidence/.
"""
import json
import re
from pathlib import Path

EVIDENCE = Path(__file__).resolve().parents[1] / "research" / "architecture" / "evidence"
TOKEN_SHAPE = re.compile(r"(?:Bearer\s+\S{20,}|sk-[A-Za-z0-9_-]{24,}|gh[pousr]_[A-Za-z0-9]{20,})")


def load(name: str) -> dict:
    return json.loads((EVIDENCE / name).read_text())


def test_install_facts_shape():
    facts = load("install-facts.json")
    assert facts["agents"] > 0
    assert facts["agents_with_SYSTEM_md"] <= facts["agents"]
    assert facts["db_tables"] > 0
    assert facts["memory_md"] > 0


def test_runtime_probe_is_redacted():
    probe = load("runtime-probe.json")
    assert isinstance(probe["port"], int)
    uses = [item["use"] for item in probe["uses"]]
    for required in ("work", "decision"):
        assert required in uses
    assert not TOKEN_SHAPE.search(json.dumps(probe))


def test_settings_audit_reports_locations_not_values():
    audit = load("settings-audit.json")
    assert audit["library_publish"] is False
    assert audit["provider_count"] == len(audit["providers"])
    for location in audit["raw_credential_locations"]:
        assert location.startswith("providers.")
        assert " " not in location, "a value leaked into the location field"
    assert not TOKEN_SHAPE.search(json.dumps(audit))


def test_layer_measurements_are_five_rows():
    rows = [line for line in (EVIDENCE / "loc-layers.txt").read_text().splitlines() if line.startswith("src/")]
    assert len(rows) == 5
    assert all(part.isdigit() for row in rows for part in row.split()[1:])
