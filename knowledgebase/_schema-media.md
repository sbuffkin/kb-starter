---
author: kb-bot
created: 2026-05-15
modified: 2026-09-17
type: meta
---

# KB Schema — Media

Structural specification for media frontmatter on source notes and for `type: media-description` notes. Split out of `_schema.md` so that core ingestion skills do not load this material on startup; load this file only when a source carries (or might carry) media.

Read `_rules-media.md` for the behavioural rules (Rule 29 capture/enrichment, Rule 30 host mirroring).

---

## Media Schema

Source notes may include a `media:` frontmatter list. This list records media discovered during source capture. The source note remains immutable after initial write; later OCR, vision descriptions, transcripts, and interpretation live in `type: media-description` notes under `topics/<topic>/notes/media/`.

```yaml
media:
  - id: "<sha256-of-bytes-or-stable-placeholder>"
    kind: image | video | audio
    status: captured | discovered | not-captured
    path: "knowledgebase/_media/images/YYYY/MM/<YYYY-MM-DD>-<description>-<short-hash>.<ext>"
    origin_url: "https://example.com/media.png"
    captured: <ISO-8601 date or empty>
    mime: "image/png"
    bytes: 41234
    width: 493
    height: 299
    duration_seconds: 12.4
    license: public-domain | cc-by | cc-by-sa | cc0 | quoted-with-attribution | unknown | do-not-redistribute
    description_note: "[[knowledgebase/topics/<topic>/notes/media/<sha256-or-slug>]]"
```

**Field rules:**
- `id`, `kind`, `status`, `origin_url`, and `license` are required for every media item.
- `description_note` is required when `status: captured` (a media-description note exists for it). For `status: discovered` and `status: not-captured`, `description_note` may be `null` or omitted — no description note has been written.
- `path`, `captured`, `mime`, `bytes`, `width`, `height`, and `duration_seconds` are filled only when known (typically populated at capture time).
- Use `status: discovered` when the source references media but bytes have not yet been fetched (no decision made yet).
- Use `status: not-captured` when a fetch was attempted but blocked, failed, declined by user, or intentionally skipped as contextually-irrelevant per the contextual relevance filter. Record a `not_captured_reason` field with a short explanation.
- Use `status: captured` only after bytes are stored under `_media/` and a corresponding `media-description` note has been written.
- Media paths are vault-relative and must begin with `knowledgebase/_media/`.
- Media filenames should be human-readable: `<YYYY-MM-DD>-<source-or-subject>-<description>-<8-char-hash>.<ext>`.
- Store topic in note metadata, not in the media file path. Topic renames must not break media paths.
- Keep the full SHA-256 in `id` for integrity and deduplication; do not make the full hash the visible filename unless there is no human-readable context.
- The 8-character hash suffix is cosmetic; the full `id` is authoritative.

### Temporary inspection state

The behavioural and transport guard for `--temporary-inspection` is defined in
Rule 29 and the CLI contract. Structurally, it is a staged, non-canonical
inspection rather than a completed capture. When the source note is authored
after inspection, represent a non-retained asset as `status: not-captured` with
a descriptive `not_captured_reason`, for example `"temporarily inspected; not
retained"` (not a literal enum). Its known hash,
MIME, byte count, dimensions and duration may be recorded; do not give it a
`path` or `captured` date. `description_note` remains optional. Do not use
`--commit-staged` unless a separate retention decision permits canonical
`_media/` custody.

If an older source note already froze `status: discovered`, do not rewrite it
just to reflect a later inspection; record the result in the mutable
media-description note and receipt. For a derived note with no retained bytes,
use `media_status: not-captured`, omit `local_path`, and state the exact URL,
receipt digest, sampled coverage, omissions and non-retention in the Capture
Status section (`## Capture Status`).

The local inspector consumes only a hash-checked staged file. Its frames,
audio, and full transcript are private ignored scratch, not source-note or
media-description content. A bot-owned JSON receipt is required and must
record the run and asset identifiers, exact URL, staged path, media hash and
byte count, bounded extraction settings, local engine/cache identifiers,
output paths and hashes, coverage/omissions, and cleanup disposition. The
receipt is an operation record, not a source record, citation, raw-media
archive, or claim of complete visual review. It must not contain raw media or
full transcript/OCR payloads.

Inspection cleanup is explicit and separate from capture/finalization. After
review and source disposition (published, deferred, declined or failed), it
may remove only newly created regular files named in that run's
receipt/manifest whose hashes still match. It must refuse symlinks, changed or
unrelated files, broad directories, and cleanup after an incomplete review;
failed/interrupted scratch remains for separate disposition.

For an otherwise completed frame extraction rejected only by the deterministic
ASR-quality gate, a completed independent review may authorize the narrow
`unusable-asr` cleanup disposition. Its receipt records
`cleanup.reviewed_disposition` and `cleanup.review_ref`; the latter identifies
an existing review record outside all temporary media scratch. This does not
waive complete review, exact-file integrity or refusal of other failed and
interrupted extractions. The shared rule and CLI contract govern this exception.

Media-description notes use this frontmatter:

```yaml
---
author: kb-bot
created: <ISO-8601 date>
modified: <ISO-8601 date>
type: media-description
topic: <topic-slug>
title: <human-readable title>
description: <one sentence describing the media item and source context>
status: draft | review | final
tags: []
sources: ["[[knowledgebase/topics/<topic>/sources/<source-note>]]"]
related: []
media_id: "<sha256-or-stable-placeholder>"
media_kind: image | video | audio
media_status: captured | discovered | not-captured
origin_url: "https://example.com/media.png"
local_path: "knowledgebase/_media/images/YYYY/MM/<YYYY-MM-DD>-<description>-<short-hash>.<ext>"
---
```

For a `media-description` note, `local_path` is required only when
`media_status: captured`; omit it for `discovered` and `not-captured`, including
assets inspected temporarily and then removed. `media_status: captured` still
requires canonical `_media/` bytes plus the description note, not merely a
staged file or a receipt. `license: unknown` records unresolved rights: it is
not clearance to retain or redistribute bytes, but it does not by itself block
a private, attributed paraphrase with explicit inspection limits.

Recommended sections for media-description notes. **For `media_status: captured` image notes, the `## OCR` and `## Vision Description` sections are REQUIRED** — always write them, using `*Pending.*` when not yet enriched. Explicit OCR-only tooling fills the OCR section; an explicitly configured image-capable reviewer interprets retained images for Vision Description. Engine/model availability and permission must be verified locally. A placeholder establishes neither image availability nor completed analysis. `kb-lint` reports a captured image note missing `## OCR` as `media-missing-ocr`. (`## Transcript` is required for captured video/audio; an inspection-only note may instead record a bounded excerpt or `*Not retained; see receipt.*`.)

```markdown
# <Title>

![[knowledgebase/_media/images/YYYY/MM/<YYYY-MM-DD>-<description>-<short-hash>.<ext>|Human-readable caption]]

## Provenance

## Capture Status

## OCR

## OCR Raw

## Vision Description

## Transcript

## Interpretation Notes
```

`## OCR Raw` is optional for historical notes and is written by new OCR
enrichment alongside the derived `## OCR` display. Preserve each engine-labelled
attempt's exposed text before cleanup, its character length and UTF-8 digest,
and the local media reference. Use dynamically sized fences so OCR headings or
backticks cannot become note structure. Subprocess text is decoded stdout;
hosted-provider text is the exposed page-markdown channel, not an HTTP response
archive. Raw output may itself be wrong. Its preservation establishes neither
visual interpretation, complete extraction nor permission to retain restricted
material; do not retrofit it by rewriting immutable source-note bodies. For a
temporary inspection, keep raw OCR, audio and full transcripts only in ignored
scratch; a durable note may contain only a bounded necessary excerpt or an
explicit non-retention statement with the receipt digest.
