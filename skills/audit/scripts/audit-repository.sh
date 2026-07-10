#!/usr/bin/env bash
set -euo pipefail

mode="worktree"
if [ "$#" -gt 1 ] || { [ "$#" -eq 1 ] && [ "$1" != "--staged" ]; }; then
  echo "Usage: $0 [--staged]" >&2
  exit 2
fi
if [ "$#" -eq 1 ]; then
  mode="staged"
fi

failures=0

fail() {
  echo "FAIL: $*" >&2
  failures=$((failures + 1))
}

audit_path() {
  local path="$1"
  local marker

  case "$path" in
    vault/*|.DS_Store)
      fail "local-only path is a commit candidate: $path"
      ;;
    .agents/*)
      if [ "$path" != ".agents/skills" ]; then
        fail "unexpected path under .agents: $path"
      fi
      ;;
  esac

  if [ -L "$path" ]; then
    if [[ "$(readlink "$path")" = /* ]]; then
      fail "absolute symlink target in commit candidate: $path"
    fi
    return
  fi

  if [ ! -f "$path" ]; then
    return
  fi

  for marker in "/""Users/" "iCloud~md~""obsidian" "Library/Mobile"" Documents" "/private/var/""folders/"; do
    if rg -l --fixed-strings "$marker" -- "$path" >/dev/null 2>&1; then
      fail "machine-specific path marker '$marker' found in: $path"
    fi
  done

  if rg -l -i '(api[_-]?key|secret|token|password)[[:space:]]*[:=]' -- "$path" >/dev/null 2>&1; then
    fail "possible credential assignment found in: $path"
  fi

  if rg -l '-----BEGIN (RSA |EC |OPENSSH |PGP )?PRIVATE KEY-----' -- "$path" >/dev/null 2>&1; then
    fail "private key marker found in: $path"
  fi
}

if [ "$mode" = "staged" ]; then
  while IFS= read -r -d '' path; do
    audit_path "$path"
  done < <(git diff --cached --name-only -z)
  git diff --cached --check || failures=$((failures + 1))
else
  while IFS= read -r -d '' path; do
    audit_path "$path"
  done < <(git diff --name-only -z)
  while IFS= read -r -d '' path; do
    audit_path "$path"
  done < <(git ls-files --others --exclude-standard -z)
  git diff --check || failures=$((failures + 1))
fi

if [ "$failures" -gt 0 ]; then
  echo "Audit failed with $failures issue(s)." >&2
  exit 1
fi

echo "Audit passed: no detected private paths, absolute symlinks, or credential markers."
