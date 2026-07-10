#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <skill-name>" >&2
  exit 2
fi

skill_name="$1"
if [[ ! "$skill_name" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "Skill names must use lowercase letters, digits, and hyphens." >&2
  exit 2
fi

repo_root="$(cd "$(dirname "$0")/../../.." && pwd)"
skill_dir="$repo_root/skills/$skill_name"
if [ ! -f "$skill_dir/SKILL.md" ]; then
  echo "Missing canonical skill: $skill_dir/SKILL.md" >&2
  exit 1
fi

ensure_link() {
  local link_path="$1"
  local link_target="$2"
  local canonical_target="$3"

  mkdir -p "$(dirname "$link_path")"
  if [ -L "$link_path" ]; then
    if [ "$(realpath "$link_path")" = "$(realpath "$canonical_target")" ]; then
      return
    fi
    echo "Refusing to replace symlink: $link_path" >&2
    exit 1
  fi
  if [ -e "$link_path" ]; then
    echo "Refusing to replace existing path: $link_path" >&2
    exit 1
  fi
  ln -s "$link_target" "$link_path"
}

if [ "$(basename "$repo_root")" = ".agents" ]; then
  claude_skills_dir="$(dirname "$repo_root")/.claude/skills"
  claude_target="../../.agents/skills/$skill_name"
else
  claude_skills_dir="$repo_root/.claude/skills"
  claude_target="../../skills/$skill_name"
fi

ensure_link "$claude_skills_dir/$skill_name" "$claude_target" "$skill_dir"

vault_root="$repo_root/vault"
if [ -d "$vault_root" ]; then
  ensure_link "$vault_root/.claude/skills/$skill_name" "$skill_dir" "$skill_dir"
fi

echo "Linked $skill_name for Codex and Claude Code."
