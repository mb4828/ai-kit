---
name: audit
description: Audit pending or staged repository changes for privacy leaks, unsafe paths, secrets, broken adapters, and commit readiness. Use before committing or pushing, or when asked to verify that private vault content has not entered the repository.
---

1. Run `bash scripts/audit-repository.sh` for all pending changes, or add `--staged` after staging.
2. Treat any failure as a blocker. Inspect the named path, remove or redact only the confirmed unsafe content, then rerun the audit.
3. Review the final candidate list and diff. Verify that local vault shortcuts and direct-use adapters remain ignored, while canonical `skills/` packages and relative Claude adapters are tracked as intended.
4. Run `git diff --check` (or `git diff --cached --check` when staged) before committing.

The script is a guardrail, not a substitute for review: it detects machine paths, tracked vault paths, absolute symlinks, common secret markers, and malformed diffs without printing sensitive matched text.
