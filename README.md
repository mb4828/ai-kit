# AI Kit

Personal, reusable agent guidance and skills for Codex and Claude Code.

## Use this repository

### Direct workspace

Open this repository directly when working with the linked Obsidian vault. Canonical skills live in `skills/`; the local `.agents/skills` adapter makes them discoverable by Codex.

#### Local setup

The `vault` shortcut and the direct-use `.agents/` adapter are intentionally ignored by Git. After cloning this repository for direct use, create them locally:

```bash
mkdir -p .agents
ln -s ../skills .agents/skills
ln -s "/absolute/path/to/your/vault" vault
```

If your vault lives elsewhere, replace the second command's source path with its absolute location. The tracked `.claude/skills/` adapters work once this repository is committed or cloned; the commands above are only for the local Codex adapter and private vault shortcut.

### Project overlay with Git

Add this repository as a Git submodule in a coding project:

```bash
git submodule add git@github.com:mb4828/ai-kit.git .agents
git commit -m "chore: add shared agent kit"
```

The repository's `skills/` directory then becomes the project's `.agents/skills/` library automatically.

Clone a project and its AI kit together:

```bash
git clone --recurse-submodules <project-repository-url>
```

For an existing clone:

```bash
git submodule update --init --recursive
```

To update the kit later, advance the submodule and commit the new pinned revision in the parent project:

```bash
git -C .agents switch main
git -C .agents pull --ff-only
git add .agents
git commit -m "chore: update shared agent kit"
```

## Skills

- Codex: invoke a skill with `$skill-name`.
- Claude Code: invoke the same skill with `/skill-name`.
- Add a new portable skill with `$create-skill`. It creates the canonical package in `skills/`, adds discovery adapters, and validates it.

Keep reusable workflows in `skills/<skill-name>/SKILL.md`. Put detailed, domain-specific guidance in referenced files instead of duplicating it across agents.

## Obsidian vault

The local `vault` shortcut points to the private Obsidian vault and is intentionally ignored by Git. Its shared agent workspace is `Cowork/`; durable context belongs in `Cowork/memory/`, and tasks are tracked in `Cowork/TASKS.md`.

Treat vault content as confidential. The vault's own `AGENTS.md` defines the write policy and note conventions.
