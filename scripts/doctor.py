"""Read-only health probe for the OpenAutark OS layer and the live Autark install.

Never writes, never starts an agent turn, never prints a secret value. Contact depends on the local runtime
answering on 127.0.0.1 with the owner token in <data>/runtime.json.

Exit: 0 every check passed (warnings allowed), 1 at least one failure. Doctor is health, not a gate verdict;
floor verdicts come from harness/gates.py and hosted Jev.
"""

from __future__ import annotations

import json
import os
import pathlib
import shutil
import sqlite3
import sys
import urllib.request

import yaml

REPO = pathlib.Path(__file__).resolve().parents[1]
DATA = pathlib.Path(
    os.environ.get("AUTARK_DATA") or pathlib.Path.home() / "Library" / "Application Support" / "Autark"
)

CHECKS: list[dict] = []


def check(name: str, level: str, fn) -> None:
    try:
        detail = fn()
        CHECKS.append({"name": name, "level": "pass", "detail": detail})
    except Exception as error:  # a broken probe is a finding, never a crash
        CHECKS.append({"name": name, "level": level, "detail": f"{type(error).__name__}: {error}"[:240]})


def strip_jsonc(text: str) -> str:
    out, in_string, escaped = [], False, False
    index = 0
    while index < len(text):
        char = text[index]
        if in_string:
            out.append(char)
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            index += 1
            continue
        if char == '"':
            in_string = True
            out.append(char)
            index += 1
            continue
        if text.startswith("//", index):
            while index < len(text) and text[index] != "\n":
                index += 1
            continue
        if text.startswith("/*", index):
            end = text.find("*/", index + 2)
            index = len(text) if end == -1 else end + 2
            continue
        out.append(char)
        index += 1
    joined = "".join(out)
    return joined.replace("\n", "\n").replace("\r", "")


def load_jsonc(path: pathlib.Path):
    import re

    raw = strip_jsonc(path.read_text())
    raw = re.sub(r",(\s*[}\]])", r"\1", raw)
    return json.loads(raw)


def settings() -> dict:
    return load_jsonc(DATA / "settings.json")


def runtime() -> dict:
    return json.loads((DATA / "runtime.json").read_text())


def rpc(method: str, params: dict | None = None, timeout: float = 6.0):
    info = runtime()
    body = json.dumps({"id": 1, "method": method, "params": params or {}}).encode()
    request = urllib.request.Request(
        f"http://127.0.0.1:{int(info['port'])}/rpc",
        data=body,
        headers={"Authorization": f"Bearer {info['token']}", "Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=timeout) as response:
        return json.loads(response.read())


def repo_routes() -> dict:
    data = yaml.safe_load((REPO / "routes.yaml").read_text())
    routes = data["routes"]
    assert data.get("expected_routes") == len(routes), "expected_routes does not match the route count"
    for name, route in routes.items():
        for field in ("surface", "owner", "gate_command", "floors", "evidence", "mode"):
            assert route.get(field), f"route {name} has no {field}"
    return {"routes": len(routes)}


def repo_floors() -> dict:
    data = yaml.safe_load((REPO / "floors.yaml").read_text())
    floors = data["floors"]
    ids = [floor["id"] for floor in floors]
    assert ids == [f"F{n}" for n in range(1, 9)], f"floor ids are {ids}"
    for floor in floors:
        assert floor.get("check"), f"{floor['id']} has no check"
        assert floor.get("on_missing_evidence") == "HOLD", f"{floor['id']} does not fail closed"
    return {"floors": len(floors)}


def repo_owners() -> dict:
    data = json.loads((REPO / "OWNERS.yaml").read_text())
    assert data["version"] == 1
    owners = [rule["owner"] for rule in data["rules"]]
    assert len(owners) == len(set(owners)), "duplicate owner rule"
    patterns = [pattern for rule in data["rules"] for pattern in rule["paths"]]
    assert len(patterns) == len(set(patterns)), "duplicate path pattern"
    return {"owners": len(owners), "patterns": len(patterns)}


def data_dir() -> dict:
    assert DATA.exists(), f"data folder not found: {DATA}"
    return str(DATA)


def runtime_json() -> dict:
    info = runtime()
    assert isinstance(info.get("port"), int) and info["port"] > 0, "no port"
    assert isinstance(info.get("pid"), int), "no pid"
    return {"port": info["port"], "pid": info["pid"]}


def runtime_alive() -> dict:
    result = rpc("models.uses")
    uses = result.get("result")
    assert isinstance(uses, list) and uses, f"unexpected models.uses answer: {str(result)[:120]}"
    work = [u for u in uses if u.get("use") == "work"]
    decision = [u for u in uses if u.get("use") == "decision"]
    assert work and decision, "work or decision model missing"
    return {
        "work": work[0].get("stored"),
        "work_state": work[0].get("state"),
        "decision": decision[0].get("stored"),
        "decision_state": decision[0].get("state"),
    }


def routing_declared() -> dict:
    doc = settings()
    routing = doc.get("routing") or {}
    providers = set((doc.get("providers") or {}).keys())
    builtin = {"auto", "off", "local", "codex", "this-pc"}
    undeclared = []
    for use, value in routing.items():
        if use in {"allowPaidFallback", "costMode"}:
            continue
        prefix = str(value).split(":", 1)[0] if ":" in str(value) else str(value)
        if prefix not in builtin and prefix not in providers:
            undeclared.append(f"{use}={prefix}")
    assert not undeclared, "undeclared route(s): " + ", ".join(sorted(undeclared))
    routed = len([use for use in routing if use not in {"allowPaidFallback", "costMode"}])
    return {"routes": routed, "providers": len(providers)}


def decision_classifier() -> dict:
    value = str((settings().get("routing") or {}).get("decision", ""))
    assert value and not value.startswith("auto"), f"decisions route is {value or 'unset'}"
    return {"decision": value}


def pc_access() -> dict:
    access = (settings().get("profile") or {}).get("pcAccess")
    assert access in {"whole", "careful"}, f"pcAccess is {access!r}"
    security = settings().get("security")
    return {"pcAccess": access, "secure_mode_switches": len(security) if isinstance(security, dict) else "absent"}


def quiet_hours() -> dict:
    hours = (settings().get("notifications") or {}).get("quietHours")
    if not hours:
        raise AssertionError("no quiet hours; pings to the Principal are unbounded")
    return hours


def library_publish() -> dict:
    publish = (settings().get("library") or {}).get("publish")
    assert publish is False, f"library.publish is {publish!r}: skills would leave this PC"
    return {"publish": publish}


def agent_layer() -> dict:
    agents = [p for p in (DATA / "agents").glob("ag_*") if p.is_dir()]
    with_system = [p for p in agents if (p / "SYSTEM.md").is_file()]
    memory = list((DATA / "memory").rglob("*.md")) if (DATA / "memory").is_dir() else []
    return {"agents": len(agents), "agents_with_system_md": len(with_system), "memory_files": len(memory)}


def secrets_catalog() -> dict:
    catalog = DATA / "secrets" / "keys.md"
    assert catalog.is_file(), "no secrets catalog"
    mode = oct(catalog.stat().st_mode & 0o777)
    assert mode in {"0o600", "0o400"}, f"secrets catalog mode is {mode}"
    return {"catalog": str(catalog.relative_to(DATA)), "mode": mode}


def raw_credentials() -> dict:
    doc = settings()
    offenders = []
    for name, provider in (doc.get("providers") or {}).items():
        if not isinstance(provider, dict):
            continue
        key = provider.get("key")
        if isinstance(key, str) and key and not key.startswith("secret://"):
            offenders.append(f"providers.{name}.key")
        for model in provider.get("models") or []:
            for header, value in ((model or {}).get("headers") or {}).items():
                if isinstance(value, str) and not value.startswith("secret://"):
                    offenders.append(f"providers.{name}.models[{(model or {}).get('id')}].headers.{header}")
    assert not offenders, "raw credential location(s): " + ", ".join(offenders)
    return {"raw_credential_locations": [], "count": 0}


def database() -> dict:
    path = DATA / "workforce.db"
    assert path.is_file(), "no workforce.db"
    uri = f"file:{path}?mode=ro"
    with sqlite3.connect(uri, uri=True, timeout=3) as connection:
        tables = connection.execute("SELECT count(*) FROM sqlite_master WHERE type='table'").fetchone()[0]
    return {"db_mb": round(path.stat().st_size / 1_048_576, 1), "tables": tables}


def disk() -> dict:
    usage = shutil.disk_usage(DATA)
    free_gb = round(usage.free / 1_073_741_824, 1)
    assert free_gb >= 10, f"only {free_gb} GB free"
    return {"free_gb": free_gb}


def main() -> int:
    check("repo_routes", "fail", repo_routes)
    check("repo_floors", "fail", repo_floors)
    check("repo_owners", "fail", repo_owners)
    check("data_dir", "fail", data_dir)
    check("runtime_json", "fail", runtime_json)
    check("runtime_models", "fail", runtime_alive)
    check("routing_declared", "fail", routing_declared)
    check("decision_classifier", "warn", decision_classifier)
    check("pc_access", "fail", pc_access)
    check("quiet_hours", "warn", quiet_hours)
    check("library_publish_off", "fail", library_publish)
    check("agent_layer", "warn", agent_layer)
    check("secrets_catalog", "warn", secrets_catalog)
    check("raw_credentials", "fail", raw_credentials)
    check("database", "warn", database)
    check("disk", "fail", disk)
    failures = [c["name"] for c in CHECKS if c["level"] == "fail"]
    report = {
        "at": __import__("datetime").datetime.now().astimezone().isoformat(),
        "data_dir": str(DATA),
        "ok": not failures,
        "failures": failures,
        "warnings": [c["name"] for c in CHECKS if c["level"] == "warn"],
        "checks": CHECKS,
    }
    print(json.dumps(report, indent=2))
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    sys.exit(main())
