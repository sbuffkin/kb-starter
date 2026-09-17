---
author: kb-bot
created: 2026-05-15
modified: 2026-09-17
type: meta
---

# KB Agent Rules — Media

Rules governing media capture, enrichment, and web-host mirroring. Split out of `_rules.md` so that core ingestion skills do not load this material on startup; load this file only when a source carries (or might carry) media, or when fetching from a mirrored host.

Read `_schema-media.md` for the structural media spec; this file covers behaviour and decision-making.

---

## Rule 29 — Media Capture and Enrichment

Media discovered during ingestion is part of the source record. Capture enough provenance to make the media traceable even when the bytes are not downloaded yet.

**Source-note rule:** A source note may include a `media:` frontmatter list at initial write time. After the source note is written, do not edit it just to add OCR, transcripts, descriptions, or analysis. Source notes remain immutable under Rule 11.

**Enrichment rule:** Any later work on the media belongs in a separate `type: media-description` note at `topics/<topic>/notes/media/<sha256-or-slug>.md`. These notes are mutable kb-bot notes and may be updated with OCR, vision descriptions, transcripts, interpretation, and links to concepts.

**Storage rule:** Captured media bytes live under `knowledgebase/_media/`, grouped by kind and capture date with human-readable filenames. Keep the full SHA-256 hash in note metadata, but use only the first 8 characters in the filename. Do not include topic slugs in media paths; topic renames must not break media references.

```text
knowledgebase/_media/images/YYYY/MM/<YYYY-MM-DD>-<source-or-subject>-<description>-<short-hash>.<ext>
knowledgebase/_media/videos/YYYY/MM/<YYYY-MM-DD>-<source-or-subject>-<description>-<short-hash>.<ext>
knowledgebase/_media/audio/YYYY/MM/<YYYY-MM-DD>-<source-or-subject>-<description>-<short-hash>.<ext>
```

Example: `knowledgebase/_media/images/2026/05/2026-05-14-cordaro-forecast-success-graph-6cccb6d1.png`.

**Embed rule:** A captured image should be embedded near the top of its `media-description` note, directly below the H1, using an Obsidian image embed:

```markdown
![[knowledgebase/_media/images/YYYY/MM/<filename>.png|Human-readable caption]]
```

If the media is video or audio, link the local file prominently near the top of the note and include any poster image or transcript when available.

**Source immutability rule:** The source note's `media:` block is frozen at first write. If a source note records media as `status: discovered`, do not edit that source note later when the bytes are captured. Capture state lives in the media-description note's `media_status`.

**Deduplication rule:** Before writing media bytes, compute SHA-256 and search existing `media_id:` values across `topics/*/notes/media/*.md`. If the hash already exists, do not write a duplicate file. Reuse the existing `local_path` and update the relevant kb-bot-authored media-description note with the new source citation, or create a lightweight cross-reference note if the existing media-description note belongs to a different topic.

**Slug rule:** Filename slugs must be lowercase ASCII using only `a-z`, `0-9`, and single hyphens. Cap the descriptive slug at 60 characters. Filenames are frozen after first write; do not rename media just because a better description is found later.

**Fetch approval:** Downloading images, video, audio, thumbnails, transcripts, or metadata from the web counts as fetching external content. Rule 4 applies: list every URL to fetch, explain why, and wait for explicit user approval before fetching.

**Headless exception:** When an agent is running in a documented headless mode (e.g. `/kb-auto`, scheduled batch jobs), it may auto-capture media without per-URL prompting under all of these conditions: (a) the agent's skill explicitly declares headless auto-capture is in effect, (b) the license posture is recorded as `quoted-with-attribution`, (c) total captured bytes per source are bounded (default cap: 25 MB per source), and (d) every captured URL is still listed in `_log.md` and in the relevant media-description note. Interactive modes (`/kb-ingest`, `/kb-queue`) always require explicit per-source approval. This exception does not override the video default below and never enables `--temporary-inspection`.

**Video handling (v1 default):** For HTML5 `<video>` elements, capture the `poster` attribute as a normal image (kind `image`, with a `from_video` field pointing at the video URL in the media-description note). During ordinary or headless discovery, do not download `.mp4`/`.webm` bytes, audio bytes, or embedded-video thumbnails. Embedded video iframes (YouTube, Vimeo, etc.) and audio are recorded as discovered URLs only.

**Temporary inspection exception (v1.1, interactive only):** The user's explicit approval for a finite, named review may authorize temporary inspection of the exact prelisted image/MP4/WebM URLs needed for that review. The caller must pass those URLs as the complete `--capture` list with `--temporary-inspection`, use a fresh private ignored directory under `_tools/staging/media/`, and keep an exact URL → staged-path → SHA-256 manifest. The flag is an implementation guard, not approval. It does not authorize unlisted variants, rendition escalation, playlists/HLS, embedded-iframe resolution, redirects, mirrors, proxies, cookies, login/session access, DRM circumvention, automatic network retries, or access-token workarounds. Use the existing bounded capture budget (at most 25 MiB per invocation) and a finite caller-enforced wall-clock limit; the helper's 30-second socket timeout is only an inactivity bound.

Temporary publication waits for the shared write lock within that same caller
deadline, retaining already-fetched bytes in memory rather than fetching again.
If an earlier successful transfer was lost solely to a verified local staging
fault before any write, a reviewed run may record one operator-invoked recovery
request for the identical URL using `--expected-media-id` and the prior hash.
Preserve both attempts and charge both against the run budget. Changed bytes,
transport failure, ambiguous publication or a failed recovery ends that lane;
this is not a retry ladder for inaccessible sources.

Temporary inspection is never a headless, scheduled, `/kb-auto`, or unattended default. It stages bytes only: do not finalize them into `_media/` or archive them in `_library/` unless a separate retention decision establishes that they may be kept. The local extractor reads the hash-checked staged file and may create ignored frames, audio, and full-transcript scratch plus a bot-owned JSON receipt. Extraction must make no network, provider, API, or model-download calls. The approved native writer and independent reviewer may inspect the same hash-verified, run-manifested inputs and derivatives with native viewing tools before cleanup. Durable output is limited by default to an attributed paraphrase and short necessary excerpts, labelled with sampled coverage and omissions; it must not claim full visual review from sampled frames or reproduce a raw/full OCR or transcript archive.

When the source note is authored after this review, a temporary, non-retained
asset is represented as `status: not-captured` with a descriptive
`not_captured_reason` clearly stating temporary inspection and non-retention
(for example, `"temporarily inspected; not retained"`; not a literal enum). Its known hash,
MIME, byte count, dimensions and duration may be recorded, but it has no
`path` or `captured` date; `description_note` is optional. The source note is
then frozen under the normal immutability rule. If an older source note already
froze `status: discovered`, do not rewrite it merely because a later inspection
occurred; put the later result in the mutable media-description note and receipt.

Cleanup is a separate, explicit operation after review and source disposition
(published, deferred, declined or failed). Publication is not required before
discarding temporary bytes. It may remove only newly created regular files
named in that run's manifest whose hashes still match; it must refuse symlinks,
changed bytes, unrelated paths, broad-directory deletion, and cleanup after an
incomplete review. Failed or interrupted runs remain resumable until separately
dispositioned.

An otherwise completed frame extraction whose only failure is the deterministic
ASR-quality gate may be discarded after a completed independent review and
source disposition. This requires the explicit `--reviewed-disposition
unusable-asr` option and an existing `--review-ref` outside all temporary media
scratch. Record both in the cleanup receipt. The exception concerns unusable
extraction evidence, not an incomplete review; it does not permit cleanup of
decoder failures, timeouts, missing model caches or other interrupted runs.

**Capture process:**
1. Record media listed by a source as `status: discovered` if bytes have not been fetched.
2. For ordinary canonical capture, download to a temporary file, compute
   SHA-256, record MIME type and byte size, and move the file under `_media/`
   using the human-readable filename convention. For the temporary-inspection
   exception, stop at the private staged file and follow its separate custody,
   receipt and cleanup rules instead.
3. Create or update the matching media-description note with provenance and capture status.
4. Append the capture to `_log.md`: origin URL → media id/hash → local path.
5. If fetching fails or is blocked, set the media-description note's `media_status: not-captured` and record the failure there. Do not lose the URL.

**Lint expectations:** KB linting should flag orphan media files, missing embed targets, duplicate `media_id` values, and captured media-description notes whose `local_path` does not exist.

**Copyright and provenance posture:** Always store `origin_url`, capture date when available, and a license posture. Use `quoted-with-attribution` as the default for small web/social-media media captured for private research. Use `unknown` when unsure. `unknown` is not a rights clearance or a redistribution license, but it does not by itself prohibit a private, attributed paraphrase derived from a bounded inspection. Use `do-not-redistribute` when media is paywalled, explicitly restricted, privacy-sensitive, or should not be stored locally; keep the URL and provenance, do not save bytes, and do not inspect where the restriction forbids local processing. No license value authorizes public redistribution, a full raw/OCR/transcript archive, or a legal conclusion.

---

## Rule 30 — Web Host Mirroring

Some hosts gate anonymous requests behind paywalls, auth walls, or JS-only rendering. For those, fetch via a documented public mirror that proxies the underlying content. The canonical URL stays in the source note's `origin:` field as the user-approved identifier; the mirror used to actually retrieve the content goes in a separate `mirror:` field for provenance.

**Known mirrors (2026-05-14):**

| Source host | Mirror (HTML) | Mirror (structured) | Notes |
|---|---|---|---|
| `x.com`, `twitter.com` | `fxtwitter.com` (also `vxtwitter.com`, `fixupx.com`) | `api.fxtwitter.com/2/status/<id>`, `api.fxtwitter.com/2/thread/<id>` | Bypasses HTTP 402 on anonymous fetch. Video-only posts may 302-redirect back to x.com — treat as not-captured. |
| `nitter.*` | (already a mirror) | — | Some instances rate-limit; rotate if blocked. |

**Required behaviour for all agents and tools:**

1. **Automatic rewrite at fetch time.** When the URL host is on the rewrite list above, rewrite to the mirror before the HTTP request. Do not ask the user about the rewrite — they approved the canonical URL; the mirror is a transport detail.
2. **Record both URLs.** In the resulting source note frontmatter:
   - `origin: "<canonical URL the user approved>"`
   - `mirror: "<actual URL fetched>"`
   - If a structured API endpoint was used (e.g. `api.fxtwitter.com/2/thread/...`), prefer it for the mirror value because it returns reliable media URLs.
3. **Media on these sources.** Discovered media URLs typically resolve to CDN hosts (e.g. `pbs.twimg.com`, `video.twimg.com`) and fetch fine without further rewriting. Capture as normal.
4. **Failure mode.** If all mirrors fail, log the canonical URL in `reading-list.md` with `- [!]` and the reason. Do not silently fall back to fetching the canonical host — that just gets you the same 402.
5. **Source-note text.** When the mirror returns text content, every successful source note needs a `## Source-scoped Record` that distinguishes the source's material from KB interpretation. When safe and useful, follow it with `## Mirrored Text` preserving direct mirror output. Threads, articles, transcripts, and other dense material also require a source-attributed `## Content Map`; do not reduce them to a thesis-only note. Do not place agent inference or an editorial `## KB Context` section in the immutable source record.

**Adding mirrors.** If you discover a new host that needs mirroring, update this rule's table with the source host, the mirror, and the date discovered. Mirrors are operational knowledge that must outlive any single session.
