"""Doctor contract: read-only, valid JSON even when everything is missing, and it never prints a secret."""
import json
import os
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]


def run_doctor(data_dir: Path):
    environment = dict(os.environ)
    environment["AUTARK_DATA"] = str(data_dir)
    return subprocess.run(
        [sys.executable, str(REPO / "scripts" / "doctor.py")],
        capture_output=True,
        text=True,
        env=environment,
        timeout=120,
    )


def test_repository_checks_pass_without_an_install(tmp_path):
    result = run_doctor(tmp_path)
    payload = json.loads(result.stdout)
    names = {check["name"]: check for check in payload["checks"]}
    for name in ("repo_routes", "repo_floors", "repo_owners"):
        assert names[name]["level"] == "pass", names[name]
    assert payload["ok"] is False
    assert result.returncode == 1


def test_missing_install_is_reported_not_crashed(tmp_path):
    result = run_doctor(tmp_path / "not-installed")
    payload = json.loads(result.stdout)
    assert payload["failures"]
    assert "data_dir" in payload["failures"]
    assert "runtime_json" in payload["failures"]
    assert payload["at"]


def test_doctor_never_prints_the_owner_token(tmp_path):
    marker = "TOKEN_SHOULD_NEVER_APPEAR_9f3a"
    (tmp_path / "runtime.json").write_text(json.dumps({"port": 1, "token": marker, "pid": 1}))
    (tmp_path / "settings.json").write_text(json.dumps({"profile": {"pcAccess": "whole"}, "routing": {}, "providers": {}}))
    result = run_doctor(tmp_path)
    assert marker not in result.stdout
    assert marker not in result.stderr
    payload = json.loads(result.stdout)
    assert payload["ok"] is False
