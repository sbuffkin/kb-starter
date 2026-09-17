---
name: kb-wrap
description: Update a configured knowledge base at a natural stopping point after a feature, investigation, research thread, or project session. Preserve dated outcomes, decisions, evidence, state, and next steps without new research or fabricated source records.
---

# KB Wrap

Use this skill to close out work that already happened. Do not use it to start
research, ingest sources, or replace an unrelated operation.

## Startup and scope

1. Read references/kb-core.md and resolve KB_ROOT fail-closed.
2. Read KB_ROOT/_checkpoint.md; continue only a matching authorized wrap.
   Surface a mismatched active checkpoint and do not overwrite it.
3. Read KB_ROOT/_schema.md, _rules.md, _tools/README.md, and _index.md.
4. Classify the wrap as project/code or topic/research. For project/code,
   target only the named project/repository; skip unrelated inboxes, clippings,
   and the generated dive queue.

For project/code scope, read its _summary.md, _todos.md, and relevant dated
decision/session/handoff records. A metadata-only project status helper may
ground repository facts, but does not verify implementation, tests, runtime, or
deployment.

## Evidence boundary

Keep three lanes separate in summaries, handoffs, and logs:

- Observed: repository identity, full commit, paths, and checks actually
  inspected or run.
- Planned: intended work, open tasks, and next safe steps.
- Externally verified: deployment/runtime or other outside-state evidence; use
  not verified when absent.

Never create a type: source note or invent an external origin for repository
observations. Preserve dated prior decisions and explain focused corrections.

## Procedure

1. Run the KB's read-only lint gate before writing:
   KB_ROOT/_tools/kb-lint.py --kb-root KB_ROOT --all
   Surface findings that affect target files; do not run an unavailable fixer or
   treat unrelated historical warnings as target success.
2. Read each affected project/topic summary and existing handoff.
3. Write a matching checkpoint if this wrap touches multiple files; never
   replace unrelated active work.
4. Apply surgical, authorship-checked updates:
   - project summaries/current context use shared templates when supplied;
   - todos move only truly completed work and retain remaining acceptance checks;
   - topic summaries stay compressed and link detail;
   - topic notes are changed only for new reusable knowledge;
   - corrections/discussion entries are appended under their existing contract;
   - exact URL follow-ups use the lock-safe capture tool and land in Pending;
     prose-only leads go to research-ideas; never write _dive-queue.md;
   - project/code observations stay in owned project records.
5. Update _index.md when counts or navigation changed and append _log.md with
   files, outcomes, verification, and remaining uncertainty.
6. Run scoped lint/checks. Complete only the matching checkpoint and leave
   unrelated root/controller records unchanged.

Do not fetch new URLs unless explicitly asked. Do not rewrite stable prose for
style, install packages, edit credentials/config, or claim runtime state from
local tests alone.

## Authorship and report

Before every write, target paths must be inside KB_ROOT and existing files must
have author: kb-bot unless _rules.md explicitly permits that infrastructure
file. Source notes remain immutable. Report changed files, evidence lanes,
checks run, unresolved findings, and the next safe step.
