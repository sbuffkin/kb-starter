---
name: kb-synthesise
description: Synthesise source notes for a topic into relevance-gated concept, entity, and synthesis notes. Inventory source evidence, media, and actionable recommendations; present an approval plan; then write only approved, cited notes and durable action records under the KB contract.
---

# KB Synthesise

Use this skill after source ingestion to build the browsable wiki. The source
notes remain the evidence layer; synthesis must not silently strengthen claims
or turn every recommendation into an action.

## Startup

1. Read references/kb-core.md and resolve KB_ROOT fail-closed.
2. Read KB_ROOT/_checkpoint.md; resume only matching authorized work after the
   user requests continuation. Never overwrite an unrelated checkpoint.
3. Read KB_ROOT/_schema.md, _rules.md, _tools/README.md, and
   _rules-synthesis.md. Read _index.md and the relevant topic summary.
4. Apply project grounding before routing actions: identify semantically related
   project summaries and read only the relevant todos/decisions/status context.
   Project records are context, not source evidence.
5. If no topic argument is supplied, ask for a topic slug or all.

## Evidence and inventories

Read every source in the selected topic for a whole-topic pass, or only the
explicitly named sources plus relevant canonical notes for an incremental pass.
Record the reviewed set and exclusions. Extract before filtering:

- concepts and entities, with source-note citations and existing-note status;
- captured/discovered media, status, description-note path, and centrality;
- every recommendation, follow-up, implementation idea, package/tool/config
  suggestion, workflow upgrade, exact URL, book lead, experiment seed, or task.

For each factual claim in a wiki note, cite an ingested source note inline or
through sources frontmatter. Mark cross-source conclusions as Agent inference
— not sourced, preserve conflicts, and use source-scoped language for marketing,
social, self-experiment, demo, partial-citation, or generated-summary sources.
Use domain-appropriate caution for health, finance, practical safety, and
speculative forecasting. Do not infer performance, diagnosis, treatment,
safety, or deployment from weak evidence.

## Action inventory and routing

Give every candidate a stable ID and record:

  A<number>: title
  Recommendation: normalized action
  Trigger/evidence: short source-grounded reason
  Sources: source-note citations or agent-inference
  Kind: source-lead | research-lead | experiment | project-task |
    skill-package-config | book | kb-system | other
  Scope: topic | project:<slug> | kb-system | global-review | no-write
  Evidence grade: source-claim | multi-source | project-grounded |
    agent-inference | insufficient | unsafe
  Destination: existing durable destination or no-write
  Write method: required lock-safe tool or authorship-checked append
  Disposition: persist | approval-needed | defer | reject
  Gate/reason: approval, review, dedupe, scope, or rejection reason

Use _rules-synthesis.md as the authoritative lifecycle and route table. Do not
invent a new queue, schema field, or helper.

Route only to existing homes:

- exact URL source lead -> topic reading-list.md Pending via
  kb-capture-url.py after dedupe;
- prose research lead -> topic research-ideas.md under its contract;
- experiment or new unassigned candidate -> topic _prospects.md under its
  contract;
- existing project work -> projects/<project>/_todos.md after project grounding;
- existing live skill/tool/config or KB-system review -> root _todo.md as a
  review task;
- book lead -> _library/books/_ledger.md via the supplied book-ledger tool;
- exact local-file lead -> no write unless a lock-safe local-file ADD tool exists;
- unsafe, duplicate, unsupported, or insufficient candidate -> no write.

Queue mutations use only documented lock-safe tools; never hand-edit a queue or
_dive-queue.md. Skill/package/config recommendations require provenance/package
review, project-vs-global scope choice, measured pilot/eval, and rollback
planning. Synthesis may persist only a gated review task; it never installs
packages, edits live skills/config, changes credentials, or executes
implementation.

Each candidate gets exactly one disposition. A final write status is separate:
persisted, unpersisted, or blocked.

## Approval plan

Before writing, present a plan containing:

- full-article candidates with source count and path;
- concise stubs/entities only where useful, not as a quota;
- cross-topic canonical links instead of duplicates;
- synthesis notes and media to embed/link;
- append-only backlinks;
- an Action recommendations table with ID, kind, sources, destination,
  disposition, and gate/reason.

Approval covers only the listed KB note and durable review-record writes. It does
not authorize fetching, installing, changing config, credential/billing work,
or implementation. Wait for approval when the scope is not already explicitly
covered; honor only the listed scope.

## Checkpoint and writes

Write a matching in-progress checkpoint containing each note and action entry,
source citations, destination, method, exact approved record text or no-write
reason, disposition, and gate. Then:

1. Create/promote full articles, useful stubs, entities, and synthesis notes
   with cited sources, explicit evidence boundaries, and preserved conflicts.
2. Embed central captured media only when bytes and description notes exist;
   link peripheral or discovered/not-captured media without inventing paths.
3. Append backlinks only to existing author: kb-bot notes after checking them.
4. Execute approved action-record writes only at the named destination and via
   the named tool/contract. If a required tool is missing or a destination
   fails authorship checks, stop the run; do not substitute or widen scope.
5. Update topic summary, _index.md, and _log.md; run scoped lint. Mark each
   checkpoint item complete as it is verified.

For source-backed notes, use the shared source scope and evidence-boundary
patterns. Source notes are immutable. Existing project records retain Observed,
Planned, and Externally verified lanes; repository facts are never external
source records.

## Report

Report written notes, backlinks, action candidates, each Disposition and Write
status, destinations, citations, blockers, deferred scope, media status, and
next approval. For zero actions say so explicitly. Leave the checkpoint
resumable when any required obligation is incomplete.

Before every write, verify the target is inside KB_ROOT and existing files carry
author: kb-bot unless the shared rules explicitly permit infrastructure files.
Use vault-rooted wikilinks internally and Markdown links for external URLs.
