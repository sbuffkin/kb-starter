---
name: kb-auto
description: Headless autonomous KB ingestion for explicitly authorized runs. Processes URL-first items under ## Auto-approved (never the generated dive queue), deduplicates before fetch, checkpoints each item, and stops resumably before context limits.
---

# KB Auto

Use this skill only for a bounded, explicitly authorized unattended scope.
Invocation does not install or enable a scheduler, change credentials, select a
provider, or widen permissions. The caller must supply an operation-scoped
checkpoint for scheduled work; manual runs use only a matching authorized
checkpoint.

## Headless safety gate

1. Work only from unchecked URL-first rows under `## Auto-approved` in the
   relevant topic reading list. Ignore all other sections and
   `_dive-queue.md`.
2. A scheduled worker must verify its supplied queue path, exact locator, and
   unchanged approval row. If any changed or missing, stop without selecting
   replacement work. A manual batch may scan the requested topic scope.
3. Before every fetch, run `<KB_ROOT>/_tools/kb-prep-item.py --url "<url>"`
   and parse dedup/transport output. A `seen` path is identity, not
   completion: validate the existing note and obtain the required independent
   review receipt before checkoff. If that path, validator, or review is
   unavailable, leave the row unresolved and report it.
4. Do not follow citations, resolve references, or fetch companions headlessly.
   Capture exact discovered URLs to `## Pending` with the lock-safe ADD tool when
   available; route prose leads to research-ideas and books to the ledger. If
   the required tool is absent, report the follow-up rather than hand-editing a
   queue.
5. Queue marks must use the lock-safe contract in
   `<KB_ROOT>/_tools/README.md`. Mark `[x]` only after guarded source
   publication and review; use `[!]` only for a genuinely permanent failure.
6. Reconcile only the topic reading list. Never write the generated
   `_dive-queue.md`.
7. For defensive red-team material (jailbreaks, prompt obfuscation, bypasses,
   exploit payloads, adversarial model behavior), preserve only high-level
   findings and mitigations. Do not persist exact bypass recipes or exercise
   linked tools in headless mode.

## Startup

1. Read `references/kb-core.md`, then resolve `KB_ROOT` fail-closed.
2. Read `<KB_ROOT>/_checkpoint.md`, `_schema.md`, `_rules.md`,
   `_tools/README.md`, `_index.md`. Load media rules only when media is
   present.
3. Manual runs may report (but do not assign) unchecked global inbox rows.
   Scheduled workers skip the global inbox.
4. Build only the requested Auto-approved scope. Do not read the generated
   dive queue. An empty approved scope exits cleanly.
5. Read relevant topic summaries and report the bounded item count and resume
   point.

## Fidelity and publication gate

Keep retrieval separate from interpretation. Inventory headings, claims,
methods, qualifiers, limitations, and meaningful figures; compare the staged
draft against that inventory; preserve source scope and mark inference. A
successful source includes `## Source-scoped Record` and `## Evidence Boundary`
(and `## Content Map` for dense material).

Stage source and media-description candidates outside final paths. Run
`<KB_ROOT>/_tools/kb-validate-source-candidate.py` against each logical final
path; blocking findings stop publication and warnings need source-specific
accept/revise decisions. Obtain an independent exact-draft review receipt.
Publish only through `kb-commit-source.py` as documented in
`<KB_ROOT>/_tools/README.md`. If validator, review receipt, or publisher is
missing, stop the publication path; do not direct-write an immutable source.

## Per-item loop

For each selected item:

1. Update the operation-scoped checkpoint with topic, URL, timestamp, and
   pending steps. Never overwrite an unrelated interactive/controller record.
2. Run the required prep/dedup check before transport. Preserve canonical
   `origin:` when using an approved mirror.
3. Fetch only the approved item. PDFs may use the available text extractor.
   Wikipedia/citation-index pages are interactive-only discovery and do not
   become source notes in headless mode.
4. Discover/capture media only within the Rule 29 limit and supported tool flow.
   Load media contracts lazily. Captured image descriptions require
   `## OCR` and `## Vision Description`; incomplete capture stays
   discovered/not-captured or is deferred.
5. Stage, validate, review, and publish via the guarded source publisher. Handle
   terminal results explicitly: source+queue complete covers only those two
   artifacts; queue-pending requires inspection and identical-byte retry; STOP
   requires inspection and no assumed rollback.
6. Create only relevance-gated concept/entity/media notes, then update summary,
   index, log, and scoped lint. Record publication, queue, media, and navigation
   state separately in the checkpoint.
7. If context grows, an ambiguity requires a user, or repeated failures hit the
   runbook cap, mark this operation resumable and stop.

## Finish

Complete only this operation's checkpoint after every selected item has a
terminal, verified outcome. Report processed, skipped/duplicate, deferred,
created-note, media, and error counts. A scheduler, agent, provider, or model
choice remains outside this skill's scope.
