---
name: manage-entities
description: Create or update lightweight People and Organization entity notes in Matt's Obsidian vault. Use when a person, company, institution, or group needs a `Cowork/People/` or `Cowork/Organizations/` page, or when an existing entity page needs factual context or contact detail updates.
---

1. Determine whether the entity is a person or organization. Ask only when the category or identity is genuinely unclear.
2. Search the matching entity directory first to avoid duplicates. Use the full name for People and the common name for Organizations.
3. Read the matching style guide before editing:
   - People: `Cowork/Skills/bio-style-guide.md`
   - Organizations: `Cowork/Skills/org-style-guide.md`
4. Record only facts supported by the vault or user-provided context. Ask before researching external contact or organization details.
5. Keep each page lightweight:
   - People: frontmatter, body wikilinks, two-sentence About section, known contact details, and the standard Dataview Mentioned In query.
   - Organizations: frontmatter, topic wikilinks, an optional two-sentence About section, and the standard Dataview Mentioned In query.
6. Keep relationship history, active job-search detail, and other rich context in `Cowork/memory/`; update its index when adding a file.

Use body wikilinks for graph edges. Do not add a `links:` frontmatter field.
