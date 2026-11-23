#!/bin/sh
# Re-open every catalog entry upstream and report drift. Needs an authenticated gh; it is a
# verification you run on purpose, not part of the offline check suite.
set -eu
PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
export PATH
HERE=$(cd "$(dirname "$0")" && pwd); L=$(cd "$HERE/.." && pwd)

command -v gh >/dev/null 2>&1 || { echo "gh is not installed: cannot verify the twenty online"; exit 2; }
gh auth status >/dev/null 2>&1 || { echo "gh is not authenticated: cannot verify the twenty online"; exit 2; }

DRIFT=0
node -e 'for (const p of require(process.argv[1]).packs) console.log([p.id, p.repo, p.take].join("\t"))' "$L/sources/catalog.json" > /tmp/packs.$$.tsv
while IFS="$(printf '\t')" read -r id repo take; do
  [ -n "${id:-}" ] || continue
  if gh api "repos/$repo/contents/$take" >/dev/null 2>&1; then
    printf 'ok     %s  (%s/%s)\n' "$id" "$repo" "$take"
  else
    printf 'DRIFT  %s  (%s/%s no longer exists)\n' "$id" "$repo" "$take"
    DRIFT=1
  fi
done < /tmp/packs.$$.tsv
rm -f /tmp/packs.$$.tsv
[ "$DRIFT" = 0 ] && echo "PASS packs: 20 of 20 paths still resolve" || echo "FAIL packs: drift above"
exit "$DRIFT"
