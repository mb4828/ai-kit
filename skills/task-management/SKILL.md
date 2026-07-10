---
name: task-management
description: Manage Matt's shared markdown task list at `Cowork/TASKS.md`. Use when asked about tasks, commitments, priorities, reminders, follow-ups, waiting items, or when adding, completing, rescheduling, or triaging work.
---

Tasks are tracked only in `Cowork/TASKS.md`; preserve its frontmatter and headings: Active, Waiting On, Someday, and Done. The existing dashboard reads this file, so never create a second task list or edit `dashboard.html`.

1. Read `Cowork/TASKS.md` before summarizing or modifying tasks. Highlight active, waiting, overdue, and urgent work when asked for a task review.
2. Add confirmed tasks as `- [ ] **Title** - context`, including the person, project, due date, or relevant link when known. Put delegated or external dependencies in Waiting On and long-horizon ideas in Someday.
3. When completing a task, change it to `- [x] ~~**Title**~~ - context (YYYY-MM-DD)` and move it to Done. Preserve meaningful context.
4. Keep Done recent; ask before removing historical completed tasks. Flag stale Active tasks, missing context, and long-waiting dependencies for triage rather than silently moving them.
5. When a meeting or conversation surfaces commitments, offer the extracted tasks and ask for confirmation before adding them. Never auto-add inferred tasks.

Use short, concrete titles and retain the current task-list format.
