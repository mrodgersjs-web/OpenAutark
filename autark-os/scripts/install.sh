#!/bin/sh
# Autark OS installer. Additive and reversible. Dry run unless --write is given.
#
#   sh scripts/install.sh                 preview every write, change nothing
#   sh scripts/install.sh --write         install skills, agents (through the running app) and memory
#   sh scripts/install.sh --write --skills-only    skills only, no agents, no app needed
#   sh scripts/install.sh --write --uninstall      remove only what this script installed
#
# Agents are created through the app (agents.create), not by dropping folders: the app's own
# roster decides what exists, and a folder it does not know is skipped.
set -eu

HERE=$(cd "$(dirname "$0")" && pwd)
L=$(cd "$HERE/.." && pwd)

WRITE=0; UNINSTALL=0; SKILLS_ONLY=0; AGENTS_ONLY=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) WRITE=0 ;;
    --write) WRITE=1 ;;
    --skills-only) SKILLS_ONLY=1 ;;
    --agents-only) AGENTS_ONLY=1 ;;
    --uninstall) UNINSTALL=1 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done
if [ "$UNINSTALL" = 1 ] && [ "$WRITE" = 0 ]; then
  echo "Refusing to delete: --uninstall also requires --write." >&2
  echo "Preview first: sh scripts/install.sh --uninstall" >&2
  echo "Second step : sh scripts/install.sh --uninstall --write" >&2
  exit 2
fi

if [ -n "${AUTARK_DATA:-}" ]; then DATA="$AUTARK_DATA"
elif [ "$(uname -s)" = "Darwin" ]; then DATA="$HOME/Library/Application Support/Autark"
elif [ -n "${APPDATA:-}" ]; then DATA="$APPDATA/Autark"
else DATA="${XDG_CONFIG_HOME:-$HOME/.config}/Autark"; fi
if [ -n "${AUTARK_WORKSPACE:-}" ]; then
  WORKSPACE="$AUTARK_WORKSPACE"
elif [ -n "${AUTARK_DATA:-}" ]; then
  # A company chosen with AUTARK_DATA keeps its own workspace (<data>/workspace), not the first
  # company's ~/Workforce - the app's own rule for companies after the first.
  WORKSPACE="$DATA/workspace"
else
  WORKSPACE="$HOME/Workforce"
fi
MANIFEST="$DATA/autark-os.manifest"
WF="$DATA/bin/wf"
say() { printf '%s\n' "$*"; }

[ -d "$DATA" ] || { say "No Autark data folder at: $DATA"; say "Install the app once, or set AUTARK_DATA."; exit 1; }

# ---------- uninstall ----------
if [ "$UNINSTALL" = 1 ]; then
  [ -f "$MANIFEST" ] || { say "Nothing recorded at $MANIFEST - nothing to remove."; exit 0; }
  say "Removing only what this script installed, and only where the file is unchanged:"
  while IFS=' ' read -r kind a b; do
    [ -n "${kind:-}" ] || continue
    if [ "$kind" = "file" ]; then
      sum=$a; path=$b
      case "$path" in "$DATA"/*|"$WORKSPACE"/*) ;; *) say "  skipped (outside roots): $path"; continue ;; esac
      if [ ! -e "$path" ]; then say "  gone already: $path"; continue; fi
      now=$(shasum -a 256 "$path" | awk '{print $1}')
      if [ "$now" = "$sum" ]; then
        rm -f "$path"; say "  removed $path"
      else
        say "  KEPT (edited since install): $path"
      fi
    elif [ "$kind" = "agent" ]; then
      id=$a; name=$b
      if [ -x "$WF" ]; then
        if AUTARK_DATA="$DATA" "$WF" call agents.archive "{\"id\":\"$id\"}" >/dev/null 2>&1; then
          say "  archived agent $name ($id)"
        else
          say "  could not archive $name ($id) - archive it in the app"
        fi
      else
        say "  app not running, archive $name ($id) in the app"
      fi
    fi
  done < "$MANIFEST"
  rm -f "$MANIFEST"
  say "Done. Skills and memory folders that are now empty can be removed by hand."
  exit 0
fi

# ---------- plan ----------
AGENTS=""
for f in "$L"/agents/*.md; do AGENTS="$AGENTS $(basename "$f" .md)"; done

if [ "$WRITE" = 0 ]; then
  say "Dry run. Data folder: $DATA"
  say "Workspace:          $WORKSPACE"
  say ""
  say "Skills (copied to $WORKSPACE/skills/<name>/SKILL.md, existing folders never overwritten):"
  for d in "$L"/skills/*/; do say "  $(basename "$d")"; done
  if [ "$SKILLS_ONLY" = 0 ]; then
    say ""
    say "Memory seed (copied to $DATA/memory/company/autark-os/, only if that folder is absent):"
    say "  company/, branches/ ($(find "$L/memory" -type f | wc -l | tr -d ' ') files)"
    say ""
    say "Agents (created through the running app with agents.create, so the roster knows them):"
    for a in $AGENTS; do say "  $a"; done
    if [ ! -x "$WF" ]; then
      say ""
      say "  note: $WF not found - the app must be running for agent install, or use --skills-only"
    fi
  fi
  say ""
  say "Nothing was written. Re-run with --write to install."
  exit 0
fi

# ---------- write ----------
mkdir -p "$WORKSPACE/skills"
TMPM=$(mktemp); trap 'rm -f "$TMPM"' EXIT
[ -f "$MANIFEST" ] && cp "$MANIFEST" "$MANIFEST.prev"

record() { printf '%s\n' "$*" >> "$TMPM"; }

if [ "$AGENTS_ONLY" = 0 ]; then
  for d in "$L"/skills/*/; do
    name=$(basename "$d")
    target="$WORKSPACE/skills/$name"
    if [ -e "$target" ]; then say "exists, skipped: $target"; continue; fi
    mkdir "$target"
    cp "$d/SKILL.md" "$target/SKILL.md"
    record file "$(shasum -a 256 "$target/SKILL.md" | awk '{print $1}')" "$target/SKILL.md"
    say "skill: $name"
  done
fi

if [ "$SKILLS_ONLY" = 0 ]; then
  if [ ! -x "$WF" ]; then
    say ""
    say "Cannot install agents: $WF not found. Start Autark, or run with --skills-only."
    cat "$TMPM" >> "$MANIFEST" 2>/dev/null || : > "$MANIFEST" && cat "$TMPM" >> "$MANIFEST"
    exit 3
  fi
  node -e '
    const fs = require("fs"), path = require("path");
    const L = process.argv[1];
    for (const f of fs.readdirSync(path.join(L, "agents")).filter((x) => x.endsWith(".md"))) {
      const text = fs.readFileSync(path.join(L, "agents", f), "utf8");
      const end = text.indexOf("\n---", 3);
      const fm = text.slice(3, end);
      const body = text.slice(end + 4).trim();
      const get = (k) => (fm.match(new RegExp("^" + k + ":\\\\s*(.+)$", "m")) || [])[1] || "";
      const skills = (fm.match(/^skills:\\s*\\[(.*)\\]/m) || [])[1] || "";
      const out = {
        name: get("name"),
        role: get("role"),
        mode: get("mode"),
        instructions: body,
        skills: skills.split(",").map((s) => s.trim()).filter(Boolean),
      };
      fs.writeFileSync(path.join(process.env.TMPDIR || "/tmp", "autark-os-agent.json"), JSON.stringify(out));
      process.stdout.write(JSON.stringify(out) + "\n");
    }
  ' "$L" > /tmp/autark-os-agents.jsonl

  while IFS= read -r line; do
    [ -n "$line" ] || continue
    name=$(printf '%s' "$line" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>console.log(JSON.parse(s).name))')
    if AUTARK_DATA="$DATA" "$WF" call agents.list 2>/dev/null | grep -q "\"name\":\"$name\""; then
      say "agent exists, skipped: $name"; continue
    fi
    resp=$(printf '%s' "$line" | AUTARK_DATA="$DATA" "$WF" call agents.create - 2>&1) || { say "agent failed: $name -> $resp"; continue; }
    id=$(printf '%s' "$resp" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{console.log(JSON.parse(s).id||"")}catch{console.log("")}})')
    if [ -n "$id" ]; then
      record agent "$id" "$name"
      say "agent: $name ($id)"
    else
      say "agent created but id not read back: $name"
    fi
  done < /tmp/autark-os-agents.jsonl
  rm -f /tmp/autark-os-agents.jsonl

  memdir="$DATA/memory/company/autark-os"
  if [ -e "$memdir" ]; then
    say "memory seed exists, skipped: $memdir"
  else
    mkdir -p "$memdir"
    (cd "$L/memory" && find . -type f) | while IFS= read -r rel; do
      mkdir -p "$memdir/$(dirname "$rel")"
      cp "$L/memory/$rel" "$memdir/$rel"
      record file "$(shasum -a 256 "$memdir/$rel" | awk '{print $1}')" "$memdir/$rel"
    done
    say "memory seed: $memdir"
  fi
fi

{ [ -f "$MANIFEST" ] && cat "$MANIFEST"; cat "$TMPM"; } > "$MANIFEST.new" && mv "$MANIFEST.new" "$MANIFEST"
say ""
say "Installed. Manifest: $MANIFEST"
say "Smoke test: ask the chief of staff for one brief; it should answer with owner, gate and done-test."
