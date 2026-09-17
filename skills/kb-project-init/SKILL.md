---
name: kb-project-init
description: Create a new project entry in a configured knowledge base when no project summary exists. Use bounded source context and the shared templates, preserving Observed, Planned, and Externally verified distinctions without creating source records for code.
---

# KB Project Init

Use this skill when a project needs a first KB home under projects/<slug>/.
It is a scoped scaffold operation, not a research or inbox scan. If the project
already exists, hand off to the project-context or wrap flow instead of
reinitializing it.

## Startup

1. Read references/kb-core.md and resolve KB_ROOT fail-closed.
2. Read KB_ROOT/_checkpoint.md; continue only a matching authorized operation.
   Surface a mismatched checkpoint without replacing it.
3. Read KB_ROOT/_schema.md, _rules.md, _tools/README.md, and _index.md.
4. Skip the global inbox, clippings, and generated dive queue unless the user
   explicitly asks for research context.

## Procedure

1. Derive a lowercase-hyphenated project slug from the brief or supplied
   README. Ask one concise question if the identity is genuinely ambiguous.
2. Confirm _index.md does not list the project and
   projects/<slug>/_summary.md does not exist. If either exists, stop; never
   overwrite or create a duplicate.
3. Gather only bounded context from the named codebase (instructions, README,
   package/config files, and key source folders) or relevant KB summaries,
   todos, decisions, and handoffs. Record repository, commit, paths, and check
   scope. Do not treat local Git/tests as deployment evidence.
4. Write a matching in-progress checkpoint before creating project files. If the
   root checkpoint belongs to unrelated work, use the KB's named scoped record.
5. Create projects/<slug>/_summary.md from
   KB_ROOT/_templates/project-summary.md and projects/<slug>/_todos.md from
   KB_ROOT/_templates/project-todos.md. If a required template is missing,
   stop and report it rather than inventing a competing schema.
6. If a code location exists, use the KB's metadata-only project status helper
   when present. Save only observed results under the normal write gate.
7. Add the project row to _index.md, append _log.md, and run the supported
   project-scoped lint/check. Inspect the report, including target blockers,
   rather than relying only on its exit code.
8. Complete only this operation's checkpoint after target structure and
   authorship checks pass.

## Summary evidence shape

Include:

- What the project is and why it exists.
- Observed: repository, full commit, paths, date, and actual checks.
- Planned: current objective and next safe step linked to _todos.md.
- Externally verified: runtime/deployment evidence, or not verified.
- Constraints, dated decisions, conflicts, gaps, stack, components, and related
  KB topics.

Project summaries and context notes are not external source notes. Do not invent
facts; mark assumptions as Agent inference — not sourced or ask the user.
Only write inside KB_ROOT, and existing targets must carry author: kb-bot except
the infrastructure files explicitly allowed by _rules.md.
