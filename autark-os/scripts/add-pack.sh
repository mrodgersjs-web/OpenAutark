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
if [ "$PACK" = "--list" ]; then LIST=1; else LIST=0; fi
REMOVE=0
WRITE=0
ONLY=""
FROM=""
PIN=""
shift || true
while [ $# -gt 0 ]; do
  case "$1" in
    --write) WRITE=1 ;;
    --remove) REMOVE=1 ;;
    --only) shift; ONLY=${1:-} ;;
    --from) shift; FROM=${1:-} ;;
    --pin) shift; PIN=${1:-} ;;
    -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done
. "$HERE/lib.sh"
WS=$(resolve_workspace "${AUTARK_DATA:-$HOME/Library/Application Support/Autark}")
MANIFEST="${AUTARK_DATA:+$AUTARK_DATA/autark-os.manifest}"
MANIFEST=${MANIFEST:-"$WS/autark-os.manifest"}

if [ "$LIST" = 1 ]; then
  [ -f "$MANIFEST" ] || { say_header="installed packs"; printf '%s\n' "$say_header"; printf 'none: %s does not exist yet\n' "$MANIFEST"; exit 0; }
  node -e '
    const fs = require("fs"), path = require("path");
    const [manifest, catalogFile] = process.argv.slice(1);
    const cat = JSON.parse(fs.readFileSync(catalogFile, "utf8"));
    const byId = Object.fromEntries(cat.packs.map((p) => [p.id, p]));
    const groups = new Map();
    for (const line of fs.readFileSync(manifest, "utf8").split("\n")) {
      const m = line.match(/^file [0-9a-f]{64} (.+)$/);
      if (!m) continue;
      const parts = m[1].split(path.sep + "skills" + path.sep);
      if (parts.length < 2) continue;
      const seg = parts[1].split(path.sep)[0];
      const [pack, ...rest] = seg.split("--");
      const name = rest.join("--");
      if (!groups.has(pack)) groups.set(pack, new Map());
      const g = groups.get(pack);
      g.set(name, (g.get(name) || 0) + 1);
    }
    console.log("installed packs (" + groups.size + "):");
    if (!groups.size) console.log("  none");
    for (const [pack, skills] of groups) {
      const meta = byId[pack] || {};
      console.log("  " + pack.padEnd(22) + (meta.license || "?").padEnd(16) + (meta.repo ? "https://github.com/" + meta.repo : "unknown source"));
      for (const [name, files] of skills) console.log("      " + name + " (" + files + " files)");
    }
  ' "$MANIFEST" "$CATALOG"
  exit 0
fi

if [ "$REMOVE" = 1 ]; then
  [ -n "$PACK" ] || { echo "usage: add-pack.sh <pack-id> --remove --write" >&2; exit 2; }
  [ -L "$MANIFEST" ] && { echo "FAIL: $MANIFEST is a symlink. Refusing." >&2; exit 1; }
  if [ ! -f "$MANIFEST" ]; then echo "nothing installed: $MANIFEST does not exist"; exit 0; fi
  if [ "$WRITE" = 0 ]; then
    node -e '
      const fs = require("fs");
      const [manifest, pack] = process.argv.slice(1);
      const hits = fs.readFileSync(manifest, "utf8").split("\n").filter((l) => l.includes("/skills/" + pack + "--"));
      console.log("would remove " + hits.length + " files from " + pack + " (dry run)");
      for (const h of hits.slice(0, 10)) console.log("  " + h.split(" ").slice(2).join(" "));
      if (hits.length > 10) console.log("  ... " + (hits.length - 10) + " more");
    ' "$MANIFEST" "$PACK"
    echo "Re-run with --write to remove them."
    exit 2
  fi
  MANIFEST_PATH="$MANIFEST" node -e '
    const fs = require("fs"), path = require("path"), cp = require("child_process");
    const [manifest, pack] = process.argv.slice(1);
    const keep = [], removed = [], edited = [];
    for (const line of fs.readFileSync(manifest, "utf8").split("\n")) {
      if (!line.startsWith("file ")) { if (line.trim()) keep.push(line); continue; }
      const [, sha, ...rest] = line.split(" ");
      const file = rest.join(" ");
      if (!file.includes(path.sep + "skills" + path.sep + pack + "--")) { keep.push(line); continue; }
      let current = null;
      try { current = cp.execSync("shasum -a 256 " + JSON.stringify(file) + " 2>/dev/null || sha256sum " + JSON.stringify(file)).toString().split(" ")[0]; } catch (e) {}
      if (current === sha) { try { fs.unlinkSync(file); } catch (e) {} removed.push(file); }
      else { edited.push(file); keep.push(line); }
    }
    fs.writeFileSync(process.env.MANIFEST_PATH, keep.join("\n") + (keep.length ? "\n" : ""));
    console.log("removed " + removed.length + " files");
    if (edited.length) { console.log("kept " + edited.length + " edited files (not deleted):"); edited.slice(0, 10).forEach((f) => console.log("  " + f)); }
    // prune now-empty skill folders for this pack
    const dirs = new Set(removed.map((f) => path.dirname(f)));
    for (const d of dirs) { try { fs.rmdirSync(d); } catch (e) {} }
  ' "$MANIFEST" "$PACK"
  exit 0
fi

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

# Verify the path still exists upstream before touching anything. Only when we are actually going to
# fetch from GitHub: a local --from pack needs no network, and an unauthenticated gh on a CI runner
# must not be read as "the repo moved".
if [ -z "$FROM" ] && command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  if ! gh api "repos/$REPO/contents/$TAKE" >/dev/null 2>&1; then
    say "FAIL: $REPO has no path '$TAKE' any more - the catalog needs updating."
    exit 1
  fi
  say "path:   verified on GitHub just now"
else
  say "path:   not verified (no authenticated gh; the clone below is the check)"
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
        else if (fs.existsSync(path.join(p, "system.md"))) { out.push({ kind: "pattern", from: path.resolve(p), name: e.name }); }
        else walk(p, depth + 1);
      } else if (e.isFile() && e.name.endsWith(".md") && depth <= 2 && !/^(README|LICENSE|CHANGELOG|CONTRIBUTING|CODE_OF_CONDUCT|SECURITY|NOTICE)\.md$/i.test(e.name)) {
        // Agents and prompt patterns ship as one .md per item, up to two folders deep
        // (categories/01-core/backend-developer.md, data/patterns/analyze_claims.md).
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
  if [ "$kind" = "skill" ]; then cp -R "$from/." "$dest/"
  elif [ "$kind" = "pattern" ]; then
    cp -R "$from/." "$dest/"
    node -e '
      const fs = require("fs"), path = require("path");
      const [dir, name] = process.argv.slice(1);
      const read = (f) => { try { return fs.readFileSync(path.join(dir, f), "utf8").trim(); } catch (e) { return ""; } };
      const sys = read("system.md"), usr = read("user.md");
      const lines = sys.split("\n").map((l) => l.trim()).filter((l) => l && !/^#+/.test(l) && !/^[-=*]+$/.test(l));
      const first = (lines[0] || name).slice(0, 160);
      const body = "---\nname: " + name + "\ndescription: " + JSON.stringify(first) +
        "\nmetadata:\n  adapted_from: system.md + user.md\n---\n\n# " + name.split("--").pop() +
        "\n\nUpstream prompts, kept verbatim so the words are not lost. The System half sets the role; the User half is the instruction template.\n\n## System\n\n" + sys +
        "\n\n## User\n\n" + (usr || "(no user.md upstream)") + "\n";
      fs.writeFileSync(path.join(dir, "SKILL.md"), body);
    ' "$dest" "$PACK--$name"
  else cp "$from" "$dest/SKILL.md"; fi
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
