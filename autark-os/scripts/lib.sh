#!/bin/sh
# Shared helpers for the layer's scripts: one workspace rule, one hash command.
# Sourced, never executed.

sha256() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    echo "no sha256 tool (shasum or sha256sum) on this machine" >&2
    return 1
  fi
}

resolve_workspace() {
  # $1 is the Autark data folder. Same rule the app uses for companies.
  if [ -n "${AUTARK_WORKSPACE:-}" ]; then
    printf '%s\n' "$AUTARK_WORKSPACE"
  elif [ -n "${AUTARK_DATA:-}" ]; then
    printf '%s\n' "$1/workspace"
  else
    printf '%s\n' "$HOME/Workforce"
  fi
}
