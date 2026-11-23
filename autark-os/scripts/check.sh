#!/bin/sh
# Autark OS checks. Each subcommand exits 0 only when its own rules hold.
# Usage: sh autark-os/scripts/check.sh [layout|agents|skills|router|docs|install|all]
set -eu

HERE=$(cd "$(dirname "$0")" && pwd)
L=$(cd "$HERE/.." && pwd)
ROOT=$(cd "$L/.." && pwd)
FAIL=0

fail() { printf 'FAIL %s: %s\n' "$1" "$2"; FAIL=1; }
ok() { printf 'ok   %s: %s\n' "$1" "$2"; }
between() { awk 'NR==1 && $0!="---"{exit 1} NR>1 && /^---$/{exit} NR>1{print}' "$1"; }

check_layout() {
  for d in agents skills memory orchestrator gtm blueprints scripts docs; do
    [ -d "$L/$d" ] || fail layout "missing folder $d/"
  done
  for f in README.md ORCHESTRATOR.md; do
    [ -s "$L/$f" ] || fail layout "missing $f"
  done
  [ "$FAIL" = 0 ] && ok layout "folders and entry files present"
}

check_agents() {
  n=0
  for f in "$L"/agents/*.md; do
    n=$((n+1))
    fm=$(between "$f") || { fail agents "$(basename "$f"): no front matter"; continue; }
    for key in name role description mode; do
      printf '%s\n' "$fm" | grep -q "^$key:" || fail agents "$(basename "$f"): missing $key"
    done
    mode=$(printf '%s\n' "$fm" | awk '/^mode:/{sub(/^mode:[ ]*/,""); print; exit}')
    case " manager general research web social finance browser computer secretary video " in
      *" $mode "*) : ;;
      *) fail agents "$(basename "$f"): mode '$mode' is not a shipped mode" ;;
    esac
    skills=$(printf '%s\n' "$fm" | awk '/^skills:/{gsub(/[][ ]/,""); sub(/^skills:/,""); gsub(/,/," "); print; exit}')
    for s in $skills; do
      [ -d "$L/skills/$s" ] || fail agents "$(basename "$f"): skill '$s' does not exist"
    done
    [ -n "$skills" ] || fail agents "$(basename "$f"): no skills listed"
  done
  [ "$n" -gt 0 ] || fail agents "no agent files"
  [ "$FAIL" = 0 ] && ok agents "$n agents, front matter and skills resolve"
}

check_skills() {
  n=0
  allowed=" manager general research web social finance browser computer secretary video "
  for d in "$L"/skills/*/; do
    n=$((n+1))
    name=$(basename "$d")
    f="$d/SKILL.md"
    [ -f "$f" ] || { fail skills "$name: no SKILL.md"; continue; }
    fm=$(between "$f") || { fail skills "$name: no front matter"; continue; }
    got=$(printf '%s\n' "$fm" | awk '/^name:/{sub(/^name:[ ]*/,""); print; exit}')
    [ "$got" = "$name" ] || fail skills "$name: front matter name '$got' does not match folder"
    desc=$(printf '%s\n' "$fm" | awk '/^description:/{sub(/^description:[ ]*/,""); print; exit}')
    [ -n "$desc" ] || fail skills "$name: empty description"
    modes=$(printf '%s\n' "$fm" | awk '/modes:/{sub(/.*modes:[ ]*/,""); print; exit}' | tr -d '[]' | tr ',' ' ')
    [ -n "$modes" ] || fail skills "$name: no metadata.modes"
    for m in $modes; do
      case "$allowed" in *" $m "*) : ;; *) fail skills "$name: mode '$m' is not a shipped mode" ;; esac
    done
    grep -qE 'TODO|NEEDS CLARIFICATION' "$f" && fail skills "$name: unfinished marker in file"
  done
  [ "$n" -gt 0 ] || fail skills "no skills"
  [ "$FAIL" = 0 ] && ok skills "$n skills, format and modes valid"
}

check_router() {
  node -e '
    const fs = require("fs"), path = require("path");
    const L = process.argv[1];
    const r = JSON.parse(fs.readFileSync(path.join(L, "orchestrator/router.json"), "utf8"));
    let bad = 0;
    if (!Array.isArray(r.routes) || !r.routes.length) { console.log("FAIL router: no routes"); process.exit(1); }
    for (const route of r.routes) {
      if (!fs.existsSync(path.join(L, "agents", route.agent + ".md"))) { console.log("FAIL router: " + route.id + " agent " + route.agent); bad++; }
      for (const s of route.skills || []) if (!fs.existsSync(path.join(L, "skills", s, "SKILL.md"))) { console.log("FAIL router: " + route.id + " skill " + s); bad++; }
      if (!/^G[0-4]$/.test(route.gate || "")) { console.log("FAIL router: " + route.id + " gate " + route.gate); bad++; }
      for (const k of ["id", "when", "agent", "skills", "gate"]) if (!(k in route)) { console.log("FAIL router: " + route.id + " missing " + k); bad++; }
    }
    const modes = new Set(r.modes || []);
    for (const m of ["manager","general","research","web","social","finance","browser","computer","secretary","video"]) if (!modes.has(m)) { console.log("FAIL router: mode " + m + " missing from modes list"); bad++; }
    if (!bad) console.log("ok   router: " + r.routes.length + " routes, agents, skills and gates resolve");
    process.exit(bad ? 1 : 0);
  ' "$L" || FAIL=1
}

check_docs() {
  node -e '
    const fs = require("fs"), path = require("path");
    const roots = [path.join(process.argv[1]), path.join(process.argv[2])];
    const bad = [];
    const walk = (dir) => fs.readdirSync(dir, { withFileTypes: true }).flatMap((e) => {
      const p = path.join(dir, e.name);
      return e.isDirectory() ? walk(p) : [p];
    });
    for (const root of roots) for (const file of walk(root)) {
      if (!file.endsWith(".md")) continue;
      const text = fs.readFileSync(file, "utf8");
      for (const m of text.matchAll(/\]\(([^)\s]+)\)/g)) {
        const link = m[1];
        if (/^(https?:|mailto:|#)/.test(link)) continue;
        const target = path.resolve(path.dirname(file), link.split("#")[0]);
        if (!fs.existsSync(target)) bad.push(path.relative(process.cwd(), file) + " -> " + link);
      }
      for (const m of text.matchAll(/shots\/([\w.-]+\.(?:jpg|png))/g)) {
        const p = path.join(process.argv[2], "shots", m[1]);
        if (!fs.existsSync(p)) bad.push("missing screenshot " + m[1]);
      }
    }
    if (bad.length) { bad.forEach((b) => console.log("FAIL docs: " + b)); process.exit(1); }
    console.log("ok   docs: relative links and screenshots resolve");
  ' "$L" "$ROOT/research/what-great-looks-like" || FAIL=1
  if grep -rIlnE 'ghp_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY' "$L" "$ROOT/research/what-great-looks-like" 2>/dev/null | grep -v 'check.sh' | head -5 | grep -q .; then
    grep -rIlnE 'ghp_|sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY' "$L" "$ROOT/research/what-great-looks-like" 2>/dev/null | grep -v 'check.sh' | sed 's/^/FAIL docs: secret pattern in /' || true
    FAIL=1
  else
    ok docs "no secret patterns"
  fi
}

check_sources() {
  node -e '
    const fs = require("fs"), path = require("path");
    const L = process.argv[1];
    const cat = JSON.parse(fs.readFileSync(path.join(L, "sources/catalog.json"), "utf8"));
    const md = fs.readFileSync(path.join(L, "sources/catalog.md"), "utf8");
    const allow = new Set(["MIT", "Apache-2.0", "BSD-2-Clause", "BSD-3-Clause", "ISC"]);
    const bad = [];
    const ids = new Set();
    if (!Array.isArray(cat.packs)) { console.log("FAIL sources: no packs array"); process.exit(1); }
    for (const p of cat.packs) {
      const at = "pack " + (p.id || "?");
      if (!/^[a-z0-9]+(-[a-z0-9]+)*$/.test(p.id || "")) bad.push(at + ": bad id");
      if (ids.has(p.id)) bad.push(at + ": duplicate id");
      ids.add(p.id);
      if (!/^[\w.-]+\/[\w.-]+$/.test(p.repo || "")) bad.push(at + ": bad repo slug");
      if (!Number.isInteger(p.stars) || p.stars <= 0) bad.push(at + ": stars not an integer");
      for (const k of ["license", "mode", "take", "why", "risk", "license_note"]) if (!p[k]) bad.push(at + ": missing " + k);
      if (!["vendor", "reference"].includes(p.mode)) bad.push(at + ": mode must be vendor or reference");
      if (p.mode === "vendor" && !allow.has(p.license)) bad.push(at + ": vendor mode with license " + p.license);
      if (!Array.isArray(p.owners) || !p.owners.length) bad.push(at + ": no owners");
      for (const o of p.owners || []) if (!fs.existsSync(path.join(L, "agents", o + ".md"))) bad.push(at + ": owner agent " + o + " does not exist");
      if (!md.includes("| " + p.id + " |")) bad.push(at + ": missing row in sources/catalog.md");
    }
    if (bad.length) { bad.forEach((b) => console.log("FAIL sources: " + b)); process.exit(1); }
    const v = cat.packs.filter((p) => p.mode === "vendor").length;
    console.log("ok   sources: " + cat.packs.length + " packs (" + v + " vendor, " + (cat.packs.length - v) + " reference), ids unique, owners resolve, catalog.md in sync");
  ' "$L" || FAIL=1

  # A pack that carries a symlink must be refused, not followed.
  tmp2=$(mktemp -d)
  cp -R "$L/tests/fixtures/pack" "$tmp2/sym"
  ln -s /etc/hosts "$tmp2/sym/sample/link-out" 2>/dev/null || true
  if [ -L "$tmp2/sym/sample/link-out" ]; then
    if AUTARK_WORKSPACE="$tmp2/ws" sh "$L/scripts/add-pack.sh" superpowers --from "$tmp2/sym" --write >/dev/null 2>&1; then
      fail sources "a pack containing a symlink was installed"
    else
      ok sources "a pack containing a symlink is refused"
    fi
  fi
  rm -rf "$tmp2"

  # Behaviour, not shape: install one skill from the fixture pack and read the result back.
  tmp=$(mktemp -d)
  if AUTARK_WORKSPACE="$tmp/ws" sh "$L/scripts/add-pack.sh" superpowers --from "$L/tests/fixtures/pack" --write --only sample >/dev/null 2>&1 \
     && [ -f "$tmp/ws/skills/superpowers--sample/SKILL.md" ] \
     && grep -q '^name: superpowers--sample$' "$tmp/ws/skills/superpowers--sample/SKILL.md" \
     && grep -q 'superpowers--sample' "$tmp/ws/autark-os.manifest"; then
    ok sources "fixture install: copied, renamed to <pack>--<name>, recorded in the manifest"
  else
    fail sources "fixture install did not produce the expected file, name or manifest line"
  fi
  rm -rf "$tmp"
}

check_install() {
  tmp=$(mktemp -d)
  mkdir -p "$tmp/data"
  if AUTARK_DATA="$tmp/data" AUTARK_WORKSPACE="$tmp/ws" sh "$L/scripts/install.sh" >/dev/null 2>&1; then
    ok install "dry run exits 0 on an empty data folder (temp, nothing written)"
  else
    fail install "dry run failed on an empty data folder"
  fi
  if AUTARK_DATA="$tmp/data" AUTARK_WORKSPACE="$tmp/ws" sh "$L/scripts/install.sh" --uninstall >/dev/null 2>&1; then
    fail install "uninstall without --write did not refuse"
  else
    ok install "uninstall without --write refuses (non-zero exit)"
  fi
  if [ -e "$tmp/ws" ]; then fail install "dry run created files"; else ok install "dry run wrote nothing"; fi
  rm -rf "$tmp"
}

case "${1:-all}" in
  layout) check_layout ;;
  agents) check_agents ;;
  skills) check_skills ;;
  router) check_router ;;
  docs) check_docs ;;
  sources) check_sources ;;
  install) check_install ;;
  all)
    check_layout; check_agents; check_skills; check_router; check_docs; check_sources; check_install
    ;;
  *) echo "unknown check: $1" >&2; exit 2 ;;
esac

[ "$FAIL" = 0 ] || exit 1
printf 'PASS %s\n' "${1:-all}"
