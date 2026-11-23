"""Parse every YAML and JSON control-plane file. A file that does not parse is a configuration failure."""
import json
import pathlib
import sys

import yaml

REPO = pathlib.Path(__file__).resolve().parents[1]
SKIP = {".git", "node_modules", "app", "dist", "__pycache__", ".pytest_cache"}
errors = []
checked = 0

for path in REPO.rglob("*"):
    if any(part in SKIP for part in path.parts):
        continue
    if not path.is_file() or path.is_symlink():
        continue
    if path.suffix in {".yaml", ".yml"}:
        checked += 1
        try:
            yaml.safe_load(path.read_text())
        except Exception as error:
            errors.append(f"{path.relative_to(REPO)}: {type(error).__name__}: {error}")
    elif path.suffix == ".json":
        checked += 1
        try:
            json.loads(path.read_text())
        except Exception as error:
            errors.append(f"{path.relative_to(REPO)}: {type(error).__name__}: {error}")

print(json.dumps({"checked": checked, "errors": errors}, indent=2))
sys.exit(1 if errors else 0)
