---
name: kb-queue
description: Process approved KB reading-list items in a bounded interactive batch. Presents the queue, obtains finite approval, ingests each source with checkpointing and media/fidelity review, and uses guarded publication and lock-safe queue tools.
---

# KB Queue

Use this skill for an explicitly approved finite batch from a topic reading
list or the global inbox. It does not silently add new arrivals, fetch
companions, install tools, or enable unattended scheduling.

## Startup and scope

1. Read references/kb-core.md and resolve KB_ROOT fail-closed.
2. Read KB_ROOT/_checkpoint.md; resume only matching work after the user
   requests continuation. Surface unrelated active work without replacing it.
3. Read _schema.md, _rules.md, _tools/README.md, _index.md, and
   readinglist/Links.md. Load relevant topic summaries; load media rules
   only when a source has media.
4. If a topic slug is supplied, use only its reading list. If inbox is
   supplied, scope to currently listed inbox rows. If no scope is supplied,
   ask one concise clarification.
5. Read the canonical section ladder. Unchecked Pending rows need promotion;
   Approved and Auto-approved are interactive work lanes; Processed and Failed
   — Retry are history/retry state. Never fetch a Pending row directly.

Before fetching a Pending URL, promote it with the lock-safe tool:
  KB_ROOT/_tools/kb-promote.py --file topics/<topic>/reading-list.md
  --url "<url>" --from Pending --to Approved

Present the resulting finite candidate list and wait for explicit approval.
A prior explicit approval for those exact rows may be honored; a lane move does
not authorize another row, companion, media download, paid service, or
publication scope.

For Wikipedia/citation-index rows, fetch only for citation discovery, validity
labels, and follow-up routing; do not publish the index page by default. For
other sites, inspect relevant same-context links and show companions as
follow-ups before any additional fetch. For defensive red-team sources, apply
the KB's defensive-source rule: preserve findings and mitigations, not durable
bypass recipes; route linked tools for scoped review.

## Checkpoint and per-item flow

After approval, write a matching in-progress checkpoint containing every
approved item. For each item:

1. Run KB_ROOT/_tools/kb-prep-item.py --url "<url>" --skip-media before
   transport. A seen path proves identity, not completion. Validate the
   existing source and obtain an independent review receipt before a checkoff;
   if the validator or review path is missing or fails, leave the row
   unresolved.
2. Fetch/extract only the approved item. Do not resolve references without a
   separate approval. Route exact follow-up URLs to Pending with the lock-safe
   ADD tool, books through the ledger when available, and prose-only leads to
   research-ideas. Never hand-edit queue Markdown or _dive-queue.md.
3. Discover media only when relevant. Capture approved bytes through the
   documented media tool and stage media-description notes before publication;
   captured image notes require OCR and Vision Description sections.
4. Inventory retrieved headings, claims, methods, qualifiers, limitations, and
   figures. Compare the staged draft against that inventory. Include
   Source-scoped Record, Evidence Boundary, and (for dense sources) Content
   Map; mark agent inference and preserve conflicts.
5. Stage source/media candidates outside final paths and run
   kb-validate-source-candidate.py at each logical final path. Blocking findings
   stop the item; warnings need a source-specific accept/revise decision.
   Obtain an independent exact-draft review receipt.
6. Publish only through the guarded source publisher documented in
   KB_ROOT/_tools/README.md (normally kb-commit-source.py). If any validator,
   receipt, or publisher helper is absent, stop before immutable publication;
   do not fall back to a direct write.
7. Inspect terminal results. Source+queue complete covers only those artifacts;
   queue-pending requires identical-byte retry after inspection; STOP never
   implies rollback. Only mark a row complete under the documented guarded
   queue contract.
8. Create approved relevance-gated stubs/entities, update summary/index/log,
   run scoped lint, and update the checkpoint. Distinguish publication,
   reconciliation, deferred scope, media, and navigation outcomes.

## Finish and boundaries

Finish only when each approved item has a verified terminal outcome; otherwise
leave a resumable checkpoint and report the blocker. Report created notes,
queue changes, deferred companions/references, media status, errors, and the
next safe action.

The skill writes only within the resolved KB and only after authorship checks.
Source notes are immutable after publication. Internal links are vault-rooted
wikilinks; external URLs use Markdown links. Do not write generated
_dive-queue.md, and do not infer deployment/runtime state from local code or
tests.
