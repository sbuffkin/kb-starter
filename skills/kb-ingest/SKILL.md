---
name: kb-ingest
description: Ingest one approved URL, PDF, local file, or pasted source into a configured knowledge base. Discuss the source, preserve evidence boundaries, stage and review the draft, and publish only through the KB's guarded source workflow.
---

# KB Ingest

Use this skill for one source when the user wants discussion and careful filing
rather than silent batch processing. The KB contract and tools, not this skill,
define the note schema.

## Startup

1. Read `references/kb-core.md` and resolve `KB_ROOT` with its fail-closed
   order. Do not print config contents. `VAULT_NAME` is optional.
2. Read `<KB_ROOT>/_checkpoint.md`; resume only matching authorized work.
   Never replace an unrelated checkpoint.
3. Read `<KB_ROOT>/_schema.md`, `_rules.md`, `_tools/README.md`, `_index.md`,
   and the relevant topic summaries. Load media rules only when media exists.
4. Read `<KB_ROOT>/readinglist/Links.md` and report unchecked inbox items
   without assigning them as a side effect.

## Approval and source expansion

A URL/path supplied as the target authorizes fetching that one target; it does
not authorize companions, reference resolution, media downloads, publication,
or installation. A matching finite-batch approval may cover its listed writes.
Ask before any expanded scope.

Before every URL fetch, run:

```bash
<KB_ROOT>/_tools/kb-prep-item.py --url "<url>" --skip-media
```

Parse the result. A `seen` source path proves identity, not completion: validate
the existing note and obtain a new independent review receipt before any
checkoff. If validation or review is unavailable, leave the item unresolved and
report it; do not fetch or mark it complete. Preserve the approved canonical
`origin:` when a transport mirror is used.

For Wikipedia or another citation-index page, use it only to discover and
validity-label references. Do not publish the index page by default. Present
candidates and obtain separate approval before resolving or fetching them.
For other websites, inspect relevant same-context links (methodology, data,
documentation, downloads); show companions as follow-ups and fetch only those
explicitly approved. Route exact URL follow-ups to `## Pending` with the
lock-safe ADD tool, books through the book ledger when supplied by the KB, and
prose-only leads to the topic research-ideas contract. Never hand-edit
`reading-list.md` or `_dive-queue.md`.

For jailbreak, prompt-obfuscation, guardrail-bypass, exploit-payload, or
adversarial-model sources, apply the KB's defensive-source rule: retain the
high-level finding and mitigation, do not preserve durable bypass recipes, and
route linked tools for scoped interactive review.

PDFs may use `markitdown` then `pdftotext`; scanned/image-only files need an
explicit OCR path. Pasted content needs no fetch but still needs a source scope
and publication review.

## Media

When the prep result discovers media, read `_schema-media.md` and
`_rules-media.md` before acting. Discovery downloads no bytes. Apply the
contextual relevance filter: skip covers, adverts, portraits, logos, and social
preview thumbnails; include figures, charts, maps, primary-source screenshots,
and documentary images that support claims.

Capture approved media only with the documented `kb-media-capture.py` flow.
Stage and validate each media-description note before publishing a source that
declares captured bytes. Captured image notes require `## OCR` and `## Vision
Description`; use an honest discovered/not-captured status when capture or
description is incomplete. Do not invent a local path or claim an atomic
source+media transaction.

## Discussion and fidelity gate

Discuss the source before writing: purpose, central argument, key ideas,
connections to existing notes, concepts/entities, companion/reference leads,
and media candidates. Keep a running list of discussion additions, but do not
write during discussion.

Before drafting, inventory retrieved headings, claims, methods, qualifiers,
limitations, and meaningful figures. Compare the draft against that inventory,
preserving source scope and omissions. Every successful source draft includes
`## Source-scoped Record` and `## Evidence Boundary`; add `## Content Map`
for dense material. Mark cross-source synthesis or agent inference explicitly.

## Guarded publication

After the user approves the concrete save plan:

1. Write a matching checkpoint with all pending source, media, queue, summary,
   index, and log obligations. Verify every existing target's `author: kb-bot`.
2. Stage the source and media-description drafts outside their final paths.
3. Run `<KB_ROOT>/_tools/kb-validate-source-candidate.py` against each staged
   candidate at its logical final path. Blocking findings stop publication;
   warnings require a source-specific accept/revise decision.
4. Obtain an independent comparison against the actual retrieved source using
   the KB's review-receipt tool. Record coverage, omissions, retention limits,
   distinct writer/reviewer identities, and exact final draft bytes. Changed
   bytes require a fresh receipt.
5. Publish an immutable source only through the guarded publisher documented in
   `<KB_ROOT>/_tools/README.md` (the expected endpoint is
   `kb-commit-source.py`). If the validator, review receipt, or publisher is
   absent, stop before writing the source; never direct-write it.
6. Inspect the publisher's terminal result. A source-plus-queue result is not
   proof that summaries, indexes, media, or logs completed; a queue-pending or
   STOP result requires inspection and no assumed rollback. Retry only with
   identical staged bytes after resolving the reported issue.
7. Create only approved, relevance-gated concept/entity stubs. Use lock-safe
   tools for queue updates and append prose ideas under their existing
   authorship contract. Never write `_dive-queue.md`.
8. Update the topic summary, `_index.md`, and `_log.md`; run scoped lint and
   verify media/navigation obligations before marking the checkpoint complete.

Local files without a supported queue/publication path stop before an immutable
write and are reported, not hand-added. Source notes are immutable after
publication; corrections use the KB's scoped repair/discussion contract.

## Report

Report the source path, review/validation result, media status, stubs, queue
updates, deferred expansions, errors, and the next safe action. Use an
Obsidian link only when `VAULT_NAME` is configured; otherwise use a
vault-relative path.

## Authorship and links

Before every write, the target must be inside `<KB_ROOT>` and existing files
must carry `author: kb-bot`. Hard-abort on a violation. Use vault-rooted
wikilinks for internal notes and Markdown links for external URLs; never use
`[[https://...]]`.
