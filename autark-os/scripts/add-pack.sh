#!/bin/sh
# Add one skill pack from sources/catalog.json. Dry run unless --write is given.
#
#   sh autark-os/scripts/add-pack.sh superpowers            # what it would copy
#   sh autark-os/scripts/add-pack.sh superpowers --write    # copy into <workspace>/skills/
#   sh autark-os/scripts/add-pack.sh bmad-method            # reference pack: prints where to read it
set -eu
PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
export PATH

HERE=$(cd "$(dirname "$0")" && pwd)
L=$(cd "$HERE/.." && pwd)
CATALOG="$L/sources/catalog.json"

PACK=${1:-}
WRITE=0
ONLY=""
FROM=""
PIN=""
shift || true
while [ $# -gt 0 ]; do
  case "$1" in
    --write) WRITE=1 ;;
    --only) shift; ONLY=${1:-} ;;
    --from) shift; FROM=${1:-} ;;
    --pin) shift; PIN=${1:-} ;;
    -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done
[ -n "$PACK" ] || { echo "usage: add-pack.sh <pack-id> [--write] [--only a,b]" >&2; echo "packs:" >&2; node -e 'require(process.argv[1]).packs.forEach(p=>console.log("  "+p.id+"  ("+p.mode+")  "+p.repo))' "$CATALOG" >&2; exit 2; }

. "$HERE/lib.sh"
WS=$(resolve_workspace "${AUTARK_DATA:-$HOME/Library/Application Support/Autark}")

INFO=$(node -e '
  const c = require(process.argv[1]); const p = c.packs.find(x => x.id === process.argv[2]);
  if (!p) { console.error("unknown pack: " + process.argv[2]); process.exit(2); }
  console.log([p.repo, p.mode, p.take, p.license].join("\t"));
' "$CATALOG" "$PACK")
REPO=$(printf '%s' "$INFO" | cut -f1); MODE=$(printf '%s' "$INFO" | cut -f2)
TAKE=$(printf '%s' "$INFO" | cut -f3); LIC=$(printf '%s' "$INFO" | cut -f4)
say() { printf '%s\n' "$*"; }

say "pack:   $PACK"
say "repo:   https://github.com/$REPO"
say "license:$LIC   mode: $MODE   take: $TAKE"

if [ "$MODE" = "reference" ]; then
  say ""
  say "Reference pack: nothing is copied. Read it at:"
  if [ "$TAKE" = "." ]; then say "  https://github.com/$REPO"
  else say "  https://github.com/$REPO/tree/main/$TAKE"; fi
  say "  The reasoning for this restriction is in sources/README.md (license policy)."
  exit 0
fi

# Verify the path still exists upstream before touching anything.
if command -v gh >/dev/null 2>&1; then
  if ! gh api "repos/$REPO/contents/$TAKE" >/dev/null 2>&1; then
    say "FAIL: $REPO has no path '$TAKE' any more - the catalog needs updating."
    exit 1
  fi
  say "path:   verified on GitHub just now"
else
  say "path:   not verified (gh not installed)"
fi

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
if [ -n "$FROM" ]; then
  say ""
  say "source: local directory $FROM (offline; used for fixture tests and internal packs)"
  TAKE="."
  mkdir -p "$TMP/src"
  cp -R "$FROM/." "$TMP/src/"
else
  say ""
  say "fetching $REPO (shallow) ..."
  # No symlinks, no host hooks, no tags: a pack is Markdown, and nothing in a checkout should be
  # able to run on this machine before a person has read it.
  GIT_CONFIG_NOSYSTEM=1 git -c core.symlinks=false -c core.hooksPath=/dev/null -c protocol.ext.allow=never \
    clone --quiet --depth 1 --no-tags "https://github.com/$REPO.git" "$TMP/src" || { say "clone failed"; exit 1; }
  COMMIT=$(git -C "$TMP/src" rev-parse HEAD)
  say "commit: $COMMIT"
  if [ -n "$PIN" ] && [ "$PIN" != "$COMMIT" ]; then
    say "FAIL: catalog has no pin and --pin $PIN does not match $COMMIT. Nothing was installed."
    exit 1
  fi
fi

# Plan: every directory under $TAKE that holds a SKILL.md, plus loose agent .md files at its top.
if find "$TMP/src" -type l | head -1 | grep -q .; then
  say "FAIL: this pack contains symlinks. Nothing was installed - a symlink is how a pack reaches outside itself."
  find "$TMP/src" -type l | head -5 | sed 's/^/  /'
  exit 1
fi

PLAN=$(cd "$TMP/src" && node -e '
  const fs = require("fs"), path = require("path");
  const take = process.argv[1], only = (process.argv[2] || "").split(",").filter(Boolean);
  const root = take === "." ? "." : take;
  const out = [];
  const walk = (dir, depth) => {
    if (depth > 3) return;
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
      const p = path.join(dir, e.name);
      if (e.isDirectory()) {
        if (fs.existsSync(path.join(p, "SKILL.md"))) { out.push({ kind: "skill", from: path.resolve(p), name: e.name }); }
        else walk(p, depth + 1);
      } else if (e.isFile() && e.name.endsWith(".md") && depth <= 1 && dir === root) {
        out.push({ kind: "doc", from: path.resolve(p), name: e.name.replace(/\.md$/, "") });
      }
    }
  };
  walk(root, 0);
  const picked = only.length ? out.filter(o => only.includes(o.name)) : out;
  for (const i of picked) {
    if (!/^[A-Za-z0-9._-]+$/.test(i.name) || /[\x00-\x1f]/.test(i.from)) {
      console.error("FAIL: unsafe name in pack: " + JSON.stringify(i.name));
      process.exit(3);
    }
  }
  console.log(JSON.stringify(picked));
' "$TAKE" "$ONLY")

COUNT=$(printf '%s' "$PLAN" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>console.log(JSON.parse(s).length))')
say "found:  $COUNT items with a SKILL.md (or top-level .md files)"
printf '%s' "$PLAN" | node -e '
  let s=""; process.stdin.on("data",d=>s+=d).on("end",()=>{
    for (const item of JSON.parse(s)) console.log("  " + (item.kind === "skill" ? "skill " : "doc   ") + item.name);
  })'

if [ "$WRITE" = 0 ]; then
  say ""
  say "Dry run. Target skills folder: $WS/skills/<pack>--<name>"
  say "Re-run with --write to copy."
  exit 0
fi

mkdir -p "$WS/skills"
MANIFEST="${AUTARK_DATA:+$AUTARK_DATA/autark-os.manifest}"
MANIFEST=${MANIFEST:-"$WS/autark-os.manifest"}
if [ -L "$MANIFEST" ]; then say "FAIL: $MANIFEST is a symlink. Refusing to append."; exit 1; fi
: > "$TMP/manifest"

# The MIT line: the copyright and permission notice travels with the files.
NOTICE_SRC=""
for n in LICENSE LICENSE.md LICENSE.txt COPYING NOTICE NOTICE.md; do
  [ -f "$TMP/src/$n" ] && NOTICE_SRC="$TMP/src/$n" && break
done

printf '%s' "$PLAN" | node -e '
  let s = ""; process.stdin.on("data", d => s += d).on("end", () => {
    for (const i of JSON.parse(s)) console.log([i.kind, i.from, i.name].join("\t"));
  });
' > "$TMP/plan.tsv"

while IFS="$(printf '\t')" read -r kind from name; do
  [ -n "${name:-}" ] || continue
  dest="$WS/skills/$PACK--$name"
  if [ -L "$dest" ]; then say "FAIL: $dest is a symlink. Refusing to write through it."; exit 1; fi
  if [ -e "$dest" ]; then say "exists, skipped: $dest"; continue; fi
  if find "$from" -type l | head -1 | grep -q .; then say "FAIL: $name contains a symlink. Skipped."; continue; fi
  mkdir "$dest"
  if [ "$kind" = "skill" ]; then cp -R "$from/." "$dest/"; else cp "$from" "$dest/SKILL.md"; fi
  # The app resolves a skill by its front-matter name; keep it in step with the folder so two packs
  # that both ship "brainstorming" cannot shadow each other.
  if [ -f "$dest/SKILL.md" ]; then
    awk -v n="$PACK--$name" 'BEGIN{fm=0} /^---$/{fm++; print; next} fm==1 && /^name:/{print "name: " n; next} {print}' \
      "$dest/SKILL.md" > "$dest/SKILL.md.tmp" && mv "$dest/SKILL.md.tmp" "$dest/SKILL.md"
  fi
  find "$dest" -type f | while IFS= read -r f; do
    printf 'file %s %s\n' "$(sha256 "$f")" "$f" >> "$TMP/manifest"
  done
  if [ -n "$NOTICE_SRC" ]; then cp "$NOTICE_SRC" "$dest/UPSTREAM-LICENSE.txt"; fi
  say "copied: $dest"
done < "$TMP/plan.tsv"

if [ -s "$TMP/manifest" ]; then cat "$TMP/manifest" >> "$MANIFEST"; fi
say ""
say "Done. Manifest: $MANIFEST"
say "Installed skills are named <pack>--<name> so they can never overwrite one of ours."
