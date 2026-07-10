---
name: update
description: Triage the shared task list and shared memory, identifying stale tasks, missing context, and candidate updates. Use when asked to update, sync, review, refresh, clean up, or comprehensively scan tasks and memory; support `--comprehensive` when explicitly requested.
---

Run against `Cowork/TASKS.md` and `Cowork/memory/`. This is a review-and-confirm workflow: never add, complete, remove, or materially change a task or memory record without Matt's confirmation.

## Default mode

1. Read the current task list and memory index. If either is missing, explain the gap and offer to initialize the relevant file instead.
2. Compare tasks with user-provided or connected task sources when available. In the local vault, use relevant recent work notes only; do not inspect therapy or journal content.
3. Flag overdue tasks, Active tasks with no date or context, items inactive for 30+ days, waiting items needing follow-up, and externally completed work that may be ready to close.
4. Decode every meaningful person, project, acronym, organization, and link in the task list through shared memory. Group unknowns and ask concise questions to fill them.
5. Propose a clear diff: task additions or closures, triage choices, memory gaps, and enrichment candidates. Apply only the changes Matt approves, then report the result.

## Comprehensive mode

When explicitly invoked with `--comprehensive`, perform default mode plus a deeper scan of sources Matt has connected or explicitly authorizes: recent meetings, calendar, email, chat, documents, or project trackers. Extract possible missed commitments and candidate people, projects, and terminology; preserve source links when available.

Present findings grouped by confidence. Never treat a mention as a task or durable memory automatically, and do not include sensitive personal material in the scan or report unless Matt explicitly scopes it in.
