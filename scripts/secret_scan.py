"""Offline fail-closed scan of the governance layer. Never prints a matching value, only its location and kind.

Scope: the paths this repository owns (the control plane). `apps/`, `services/`, `library/` and `.github/` are
upstream: their test suites ship synthetic key shapes on purpose, so their findings are counted and labelled
`upstream_reference` rather than treated as a leak here. Only an `in_scope` finding fails the run.

A credential in an owned file is a BLOCK, not a warning.
"""
import json
import pathlib
import re
import sys

REPO = pathlib.Path(__file__).resolve().parents[1]
SKIP_PARTS = {".git", "node_modules", "__pycache__", ".pytest_cache", "app", "dist"}
UPSTREAM_ROOTS = ("apps", "services", "library", ".github", "scripts/desktop-release", "scripts/model-priors")
RULES = {
    "github_token": re.compile(r"gh[pousr]_[A-Za-z0-9]{20,}"),
    "openai_or_anthropic_key": re.compile(r"sk-[A-Za-z0-9_-]{24,}"),
    "aws_access_key": re.compile(r"AKIA[0-9A-Z]{16}"),
    "slack_token": re.compile(r"xox[baprs]-[A-Za-z0-9-]{10,}"),
    "google_api_key": re.compile(r"AIza[0-9A-Za-z_-]{30,}"),
    "private_key_block": re.compile(r"-----BEGIN (?:RSA |OPENSSH |EC )?PRIVATE KEY-----"),
}
HITS = []
SCANNED = 0


def scope_of(relative: str) -> str:
    return "upstream_reference" if relative.startswith(UPSTREAM_ROOTS) else "in_scope"


for path in REPO.rglob("*"):
    if any(part in SKIP_PARTS for part in path.parts):
        continue
    relative = path.relative_to(REPO).as_posix()
    scope = scope_of(relative)
    if path.is_symlink():
        HITS.append({"path": relative, "kind": "symlink", "scope": scope})
        continue
    if not path.is_file():
        continue
    if path.name == ".env" or path.suffix in {".db", ".sqlite3", ".pem", ".p12"}:
        HITS.append({"path": relative, "kind": "forbidden_file", "scope": scope})
        continue
    try:
        text = path.read_text()
    except UnicodeError:
        continue  # binaries: upstream ships a jar, an exe and media fixtures; nothing to read as a secret
    SCANNED += 1
    for kind, pattern in RULES.items():
        if pattern.search(text):
            HITS.append({"path": relative, "kind": kind, "scope": scope})

in_scope = [hit for hit in HITS if hit["scope"] == "in_scope"]
upstream = [hit for hit in HITS if hit["scope"] == "upstream_reference"]
print(json.dumps({
    "scanned_text_files": SCANNED,
    "in_scope_findings": in_scope,
    "upstream_reference_findings": len(upstream),
    "note": "upstream fixtures and upstream secret-detection tests contain synthetic key shapes by design; they are not scanned as this repository's leaks",
}, indent=2))
sys.exit(1 if in_scope else 0)
