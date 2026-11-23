#!/bin/sh
# Behaviour test for --list and --remove: install from the fixture, edit one file, remove the pack,
# and require that the unedited file is gone, the edited one survives, and the manifest is honest.
set -eu
HERE=$(cd "$(dirname "$0")" && pwd); L=$(cd "$HERE/.." && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
export AUTARK_WORKSPACE="$T/ws"

sh "$L/scripts/add-pack.sh" superpowers --from "$L/tests/fixtures/pack" --write --only sample >/dev/null

LIST=$(sh "$L/scripts/add-pack.sh" --list)
echo "$LIST" | grep -q 'superpowers' || { echo "FAIL list: pack not shown"; exit 1; }
echo "$LIST" | grep -q 'MIT' || { echo "FAIL list: licence not shown"; exit 1; }

# second skill so one can be deleted and one kept
mkdir -p "$T/pack2/other"
cp "$L/tests/fixtures/pack/sample/SKILL.md" "$T/pack2/other/SKILL.md"
sh "$L/scripts/add-pack.sh" superpowers --from "$T/pack2" --write --only other >/dev/null
printf '\nedited by a person\n' >> "$T/ws/skills/superpowers--other/SKILL.md"

sh "$L/scripts/add-pack.sh" superpowers --remove >/dev/null 2>&1 && { echo "FAIL remove: dry run exited 0"; exit 1; } || true

sh "$L/scripts/add-pack.sh" superpowers --remove --write >/dev/null
[ ! -d "$T/ws/skills/superpowers--sample" ] || { echo "FAIL remove: unedited skill survived"; exit 1; }
[ -f "$T/ws/skills/superpowers--other/SKILL.md" ] || { echo "FAIL remove: edited skill was deleted"; exit 1; }
grep -q 'superpowers--other' "$T/ws/autark-os.manifest" || { echo "FAIL remove: manifest dropped the kept file"; exit 1; }
grep -q 'superpowers--sample' "$T/ws/autark-os.manifest" && { echo "FAIL remove: manifest still lists a deleted file"; exit 1; } || true
echo "PASS remove: unedited files deleted, edited file kept, manifest updated"
