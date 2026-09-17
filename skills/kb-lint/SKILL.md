---
name: kb-lint
description: Audit a configured knowledge base for structural problems. Use when asked to lint, validate, health-check, or review a topic or the whole KB; report findings and propose safe, scoped fixes without silently mutating notes.
---

# KB Lint

Use this skill to check KB structure and report actionable issues.

## Startup

1. Read references/kb-core.md and resolve KB_ROOT fail-closed.
2. Read KB_ROOT/_checkpoint.md; surface matching active work before starting a
   new write-capable lint operation.
3. Read KB_ROOT/_schema.md, _rules.md, _tools/README.md, and _index.md.
4. Determine scope from the argument: a topic slug, all, or one concise
   clarification. A lint report is read-only unless the user explicitly asks
   for a durable report or repair.

## Mechanical lint

Run the KB-provided helper, passing the resolved root and requested scope:

  KB_ROOT/_tools/kb-lint.py --kb-root KB_ROOT --topic <topic>
  KB_ROOT/_tools/kb-lint.py --kb-root KB_ROOT --all

Use the helper output as authoritative for authorship, frontmatter, wikilinks,
queue ladder, source immutability, and media integrity. If the helper is
missing, report the dependency and do not substitute an unreviewed mutator.

## Human review layer

For a full health check, inspect only the requested scope for orphan mutable
notes, missing useful navigation targets, contradictions, stale derivative
notes, research gaps, and task drift. A project/code finding must distinguish
Observed repository evidence, Planned work, and Externally verified runtime or
deployment state; missing outside evidence is not verified.

When Obsidian CLI support exists, its graph-health/tasks output is supplementary
and never overrides the KB lint contract.

## Reporting and optional fixes

Lead with severity, file paths, line numbers, and uncertainty. If clean, mention
residual checks not performed. Before any multi-file fix or lint report, write a
matching checkpoint and verify authorship on every existing target. Only use
the KB's documented lock-safe and repair tools; never delete notes/media,
rewrite immutable source bodies, hand-edit queues, or write _dive-queue.md.
If a source validator, review receipt, or guarded publisher is required for a
repair and unavailable, stop and report it.

A lint report belongs under the topic's synthesis notes only when explicitly
requested, follows the KB schema, and is then included in summary/index/log
updates. Run scoped lint after approved changes and complete only the matching
checkpoint.
