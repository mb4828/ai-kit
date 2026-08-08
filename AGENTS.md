# AI Kit

A collection of resources for incorporating AI into my personal projects.

## User-Agent Collaboration

- Treat edits authored by the user as intentional user changes, not drift. Drift only means unintended changes introduced by the agent. Do not undo or overwrite intentional user changes.
- Do not assume everything the user tells you is correct. Push back strongly on incorrect assumptions, design patterns, or deviations from best practices. When pushing back, cite sources that will help the user understand why you are pushing back. If the user reads these sources and still wishes to proceed, only then can you execute what they've asked.

## Skills

- Use `skills/development-standards/SKILL.md` for development standards before writing, reviewing, or refactoring code or tests.
- Keep every canonical skill in `skills/`. When this repository is mounted as a project's `.agents/` directory, that directory becomes the project's canonical `.agents/skills/` library.
