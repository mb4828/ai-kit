---
name: create-skill
description: Create a new agent-neutral skill for this workspace and expose it to both Codex and Claude Code. Use when asked to add, scaffold, convert, migrate, or package a reusable skill, workflow, prompt, or slash-command equivalent.
---

1. Clarify the workflow, triggers, example requests, and any source instructions or references. Reuse existing vault material instead of duplicating it.
2. Choose a short lowercase hyphenated name. Check `skills/` first and stop on a name collision.
3. Initialize `skills/<name>/` with the system skill-creator `init_skill.py`, including concise OpenAI interface metadata. Create only the resource directories the workflow needs.
4. Write a concise `SKILL.md` with only `name` and `description` frontmatter. Keep durable instructions in the body and place long guides in directly referenced files.
5. Run `bash scripts/link-skill.sh <name>` from this package. It adds the appropriate Claude adapter for either direct use or an `.agents` mount and, when the local `vault` shortcut exists, the vault's Claude adapter. Never copy a skill into another `.agents` directory.
6. Run the skill-creator `quick_validate.py` against the new package and verify every adapter resolves to its `SKILL.md`.
7. Report the explicit invocation forms: `$<name>` in Codex and `/<name>` in Claude Code. Ask the user to start a new session if the new skill is not yet listed.

Use [link-skill.sh](scripts/link-skill.sh) for adapters. It is deliberately idempotent and refuses to replace a different existing path.
