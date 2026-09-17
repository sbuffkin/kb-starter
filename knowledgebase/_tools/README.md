---
author: kb-bot
created: 2026-06-21
modified: 2026-09-17
type: meta
title: KB Tools — Workflow & Endpoint Reference
description: Authoritative index of shared KB tools, governed queue/publication state, source research and project-context diagnostics.
---

# KB Tools — Workflow & Endpoint Reference

Examples below run from the KB root, with a Python environment containing
`requirements.txt`. Install `requirements-dev.txt` for the offline tests. Media
inspection additionally uses installed ffmpeg/ffprobe; image operations use
Pillow/ImageHash. ASR is optional and needs an explicitly installed local backend
and already-cached model. No setup command here downloads a model or configures
provider credentials. Choose optional OCR/browser dependencies separately.

The `_tools/` scripts are the KB's **programmatic endpoints** — the only sanctioned
way for any agent (LLM or script) to mutate queues and governed publication,
receipt or lifecycle state. Ordinary mutable notes and project context still
follow the authorship, evidence and checkpoint rules; this is not a ban on
scoped note edits. This file is the
single place to learn *which tool does what* and *which files are authoritative vs
generated*, so no agent has to reverse-engineer the contract. Read `_schema.md`
(structure) and `_rules.md` (behaviour) for the full specification; this is the
operational index that points into them.

## The write-lock contract (non-negotiable)

`kb-write-guard.py` is the shared filesystem boundary used by checkoff, capture,
promotion, log append and source publication. It checks opened lock descriptors
as regular, singly-linked files with no symlink following; no pre-lock `touch`.
Queue reads require canonical paths and unambiguous YAML kb-bot authorship.
Atomic replacement preserves mode and verifies target identity before replacing.
These are cooperative local-writer safeguards, not an independently enforced
sandbox against a hostile process running as the same user.

`kb-lint.py` includes a read-only `topic-summary-too-long` warning when a
canonical topic or project `_summary.md` body reaches 300 whitespace-delimited
words (Rule 9 says **under** 300). Frontmatter does not count. The historical
finding code is retained for compatibility; `--topic` excludes project summaries
and `--all` checks each once. The warning never trims content; preserve useful
detail in linked notes before shortening the summary.

`kb-checkoff.py` validates resolved target containment and YAML authorship
inside the lock for both marking and repair operations. Human-owned files
and paths outside `readinglist/Links.md`, `readinglist/topics.md`,
`topics/<topic>/reading-list.md`, and `ideas/_backlog.md` are rejected.
Atomic replacement preserves the existing file permissions.
Checkoff and text repair select a URL or absolute-PDF row by its entire primary
locator, never a prefix or an annotation URL. Prose substring selectors are
limited to prose-only rows in the global inboxes and ideas backlog; they cannot
select locator-leading rows or topic reading-list entries. Duplicate matches
stop rather than choosing a row. URL normalization/aliases apply only to source
identity validation after row selection.
`kb-queue-parse.py` supplies the shared row/section interpretation for capture,
promotion, preflight, publication and checkoff (including text repair). It keeps
exact row text and line numbers while excluding frontmatter, fenced examples,
HTML comments, blockquotes and indented code. Approval operations reject
ambiguous headings or unterminated example blocks. Capture/promotion use its
safe insertion boundary; capture verifies the proposed new row before writing.
This is a deliberately restricted queue format, not a general Markdown renderer.
Raw HTML blocks are unsupported; see the schema for indentation and heading
rules. Rehome/dedupe and the reading-list/research portions of derive/lint now
use that same parser, with regression fixtures for misleading example rows.
They are not alternative approval paths for publication, and the generated
dive queue is never an approval record. Derivation includes real unchecked
research-question rows under arbitrary research headings, not only `## Ideas`.
Symlink targets, source notes, and `_dive-queue.md` are rejected. Existing
human inbox files remain readable but must not be changed by this tool.
Backlog routing writes the destination before checking off the source, so a
failed destination write leaves the source pending. This is not a general
multi-file transaction. PyYAML is required, as for source validation.

Capture and promotion now perform equivalent lock-held ownership/path checks.
Capture fails closed when dedup fails, passes the requested KB root to dedup,
and rejects an invalid explicit topic rather than falling back to the global
inbox. Both tools match the entire primary URL token, not prefixes or URLs in
annotations. Promotion moves unchecked rows only. Callers relying on substring
selectors or moving completed rows must use an explicitly scoped repair path.

`kb-prep-item.py` returns immediately without media discovery for a seen URL.
Unseen URLs still perform discovery unless `--skip-media` is supplied.

Topic `[x]` marks now require a valid existing source with a matching primary
`origin:`. Pass `--source-note topics/<topic>/sources/<note>.md` or one canonical
source wikilink in `--note`, plus `--review-receipt <canonical-review-path>`.
Reviewed warnings require a specific reason through
`--accept-source-warnings`. The tool records a source link and SHA-256 receipt.
This checks structure and identity, not factual accuracy. Text repair cannot
change checkbox state. Global inbox/backlog routing retains its distinct meaning.

For new approved sources, `kb-commit-source.py --staged-text <draft> --candidate-path
topics/<topic>/sources/<note>.md --queue-file topics/<topic>/reading-list.md --url
<primary-url> --review-receipt <canonical-review-path>` validates and publishes without overwriting, then uses guarded
checkoff. Use `--mode headless` to require `## Auto-approved`; interactive mode
also permits `## Approved`. No fetch, model call, Git commit, or timer operation
occurs. `SOURCE_AND_QUEUE_COMPLETE` covers only the source and queue; callers
must still update summaries/index/log and run the rest of the ingestion checks.
If `SOURCE_WRITTEN_QUEUE_PENDING` occurs, inspect both artifacts and retry with
identical staged content after resolving the queue failure. Do not rewrite the
immutable note. A `STOP` also requires inspecting state; it does not imply rollback.
The publisher rejects another successful source with the same locator, including
deprecated records. An explicitly scoped, independently reviewed replacement
uses the separate `kb-source-successor.py --manifest <prepared-json>` flow;
warning acceptance is not a dedup override. Its manifest binds old/new paths,
origins and hashes, old body/immutable frontmatter, an approved exact queue row,
the canonical review, reason and checkpoint. No-clobber publication, guarded
checkoff, predecessor deprecation and dashboard refresh are separate phases,
not a cross-file transaction. Only the complete terminal state is success;
partial states require inspecting actual files and same-manifest reconciliation.
The version-1 scope is one predecessor/replacement in the same topic, without
changing old modified dates, prose or media. Longer chains are not yet supported.
A same-origin replacement may retain required mirror provenance when the mirror
normalizes to that same old/new primary identity. This does not admit different
old mirror endpoints, a distinct new origin borrowing the old identity, third-party
ownership or alias ambiguity. Ordinary publication still rejects duplicates.

Ordinary publication shares one read-only identity index within each validation
phase: one before the write lock and a fresh one after acquiring it. It never
reuses the pre-lock index under lock or supplies either snapshot to the later
queue checkoff. This removes redundant reads, not the concurrency or review gate;
no persistent identity cache is introduced.

Every mutation of a queue or reading-list file goes through a tool that holds the
shared exclusive lock `<kb-root>/.kb-write.lock`, re-reads the target inside the
lock, and writes atomically (temp file + `os.replace`). This is how interactive
sessions, `/kb-auto`, and kb-feed mutate the same files concurrently without races.
**Never hand-edit queue markdown** to add/move/check items — call the matching tool.

## Source of truth vs generated

| File | Status | Written by |
|---|---|---|
| `topics/<t>/reading-list.md` (the section ladder) | **source of truth** | kb-capture-url (add), kb-promote (move), kb-checkoff (mark) |
| `topics/<t>/research-ideas.md` | source of truth | agents (prose rabbit holes) |
| `readinglist/Links.md` (global URL inbox) | source of truth | kb-capture-url, kb-feed |
| `readinglist/topics.md` (broad-interest inbox) | source of truth | kb-feed, agents |
| `ideas/_backlog.md` | source of truth | kb-checkoff `--route-ideas-backlog`, agents |
| `_dive-queue.md` | **GENERATED — read-only** | kb-derive-dive-queue (never hand-edit) |

`_dive-queue.md` is **not deprecated** — what was deprecated is treating it as a
*writable* queue. It is now strictly a generated cross-topic dashboard derived from
every topic's `## Auto-approved` unchecked items plus `research-ideas.md`. The
queue-mutating tools best-effort regenerate it after a write (so promoting an item
into/out of `## Auto-approved` keeps the dashboard correct), and it is regenerated
on explicit regeneration. The former nightly ingestion launcher is retired;
no nightly regeneration is currently promised. Agents and scripts must not
append to it (Rule 13).

The generator now checks its target and inputs and renders under the shared
lock. In-process feed callers pass the real lock descriptor to
`regenerate(kb_root, lock_fd=...)`; `KB_DIVE_QUEUE_LOCK_HELD` is not a bypass.
The shared guard's no-clobber `atomic_create` supports genuinely new control
files; callers still validate the destination and new kb-bot frontmatter.
Queue consumers must use the matching shared tools and PyYAML. This starter
ships those tools; adapters should not duplicate or silently bypass their guards.

## The section ladder (per-topic reading list)

Five canonical level-2 sections, in order — enforced by `kb-lint.py`:

`## Pending → ## Approved → ## Auto-approved → ## Processed → ## Failed — Retry`

Active unchecked items are distinguished by **section**, not by checkbox mark
(Pending and Approved items are both `- [ ]`). So advancing an unchecked item is a
**move between sections**, and `## Auto-approved` is the only headless-ingestion
lane. Processing normally marks the original row `[x]` in place with
`kb-checkoff.py`; `## Processed` remains a valid historical/archive section, not
the automatic destination for every checkoff. See `_schema.md` → "Topic Reading
Lists" for the full table and the Auto-approved gate.

## The canonical workflow

Capture → relevance triage → topic Pending → explicitly approved execution scope.

`Approved` permits the interactive lane; `Auto-approved` is the separate
headless-safe lane. An interactive ingest does not need promotion to
`Auto-approved`; scheduler enablement is a separate operational decision
(see Personal background ingestion below for current status).

Extraction/channel inventory → faithful staged source → independent byte-bound
review → guarded source publication and queue receipt → relevance-gated synthesis
and action disposition. Finalize any approved captured media before freezing the
source manifest. A partial publication is resumable, not an instruction to repeat
fetches or overwrite a note. A source checkoff is not completion of synthesis or
project implementation.

Prose inspiration goes to an existing research/idea/project home when relevant;
it does not have to become a source or a new project. `_dive-queue.md` remains a
derived view throughout. Reviewed source-version updates use the separate
manifest-driven successor lifecycle, not ordinary publisher overrides.

## Endpoints — queue write verbs (the contract core)

| Tool | Verb | What it does | Use when |
|---|---|---|---|
| `kb-capture-url.py` | **ADD** | Append a *new* URL under a topic's `## Pending` (`--topic`) or to `readinglist/Links.md` (global inbox), with agent/session provenance. Lock-safe. Backs the WebFetch capture hook. | Capturing a freshly-seen URL into the pipeline. |
| `kb-promote.py` | **MOVE** | Move an existing `- [ ]` line between canonical ladder sections (`--from`/`--to`, matched by the exact primary `--url` token; `###` sub-groups roll up to their `##` parent). Lock-safe, atomic, regenerates the dive-queue. `--dry-run` previews; `--json` for programmatic callers. | Advancing an item Pending→Approved→Auto-approved (the only contract-safe section mover). |
| `kb-checkoff.py` | **MARK** | Flip an existing line's checkbox in place (`[ ]`→`[x]/[!]/[~]/[?]`) matched by `--url`. `--route-ideas-backlog` also appends the original to `ideas/_backlog.md`. Repair-only `--repair-uncheck` marks `[x]` back to `[ ]` and strips the standard trailing ingest note; repair-only `--replace-text ... --with-text ...` performs an exact replacement inside one matched queue line. Both repair modes hold the same write lock. Regenerates the dive-queue. | Marking ingested (`[x]`) or permanently failed (`[!]`) per Rule 18; repairing an invalid checkoff or stale queue annotation after explicit user approval. |
| `kb-log-append.py` | **LOG** | Append one activity-log entry under the shared write lock. Its mandatory `--operation-id` marker makes retries idempotent, so a resumed agent cannot duplicate a batch closeout. | Every multi-agent/batch operation that appends `_log.md`; use `--entry-file` for multi-line Markdown. |
| `kb-clean-stale-inbox.py` | **REPAIR** | Dry-run or apply cleanup for unchecked `readinglist/Links.md` rows whose primary URL matches authoritative source/alias lookup. Apply delegates each row to `kb-checkoff.py`; no hand-edited inbox. | Cleaning the global inbox after topic ingestion left already-ingested URLs unchecked. |
| `kb-rehome-url.py` | **REHOME** | Move a unique reading-list row between topic reading lists under the shared lock, preserving the full row text and optionally appending a correction note. Regenerates the dive-queue. `--dry-run`/`--json` supported. | Correcting a URL captured under the wrong topic before or after checkoff, without hand-editing queues. |
| `kb-dedupe.py` | **DEDUPE** | Remove a redundant duplicate row (`--drop <section>`, matched by `--url`) **only when the same URL also exists in another section** — never removes the last copy. `--into <section> --fold-note` folds the dropped row's note into the keeper so no provenance is lost. Lock-safe, atomic, regenerates the dive-queue. `--dry-run`/`--json`. | Collapsing a cross-section duplicate (e.g. a `[!]` fail row + a later re-capture `[ ]`) that trips `reading-list-duplicate-url-across-sections`. |
| `kb-derive-dive-queue.py` | **GENERATE** | Rebuild `_dive-queue.md` from Auto-approved + research-ideas. Dry-run by default; `--write` to persist. | Called by guarded queue writers or explicitly; no scheduler is installed by default. |

## Endpoints — pre-fetch & dedup (read-only)

`kb-seen.py` reads successful source origins/mirrors plus the optional governed
`_url-aliases.json` registry defined in `_schema.md`. Preflight, completion and
publication use that shared identity contract; malformed aliases fail closed.
Malformed/nonstandard URL ports also fail closed at lookup, review, publication
and completion boundaries. Explicit HTTPS 443 and HTTP 80 remain supported.
Unsupported ports in historical origins/mirrors stop the authoritative scan,
not produce an unseen result; resolve those through reviewed identity maintenance,
never an implicit alias or immutable-source edit.
Lint reports invalid registry state and recognizes reviewed aliases when checking
queue identities. A registry mechanism does not approve any particular identity mapping.

Lookup now rescans authoritative records read-only instead of trusting the
optional `_seen-urls.json` cache. This avoids stale results after deleted notes,
registry changes or normalization changes, at the cost of additional local I/O.
`--build` remains an explicit export for legacy consumers; direct cache readers
must not be treated as authoritative or as automatically alias-aware. No broad
cache-consumer migration or unattended execution is enabled by this change.

Source-index reads reject linked/special files and require unambiguous kb-bot
identity fields. Historical unrelated prose metadata can be malformed YAML;
dedup projects only unique top-level scalar `author`, `type`, `origin`, `mirror`
and `ingest_status`, rejecting ambiguous/nested/continued identity values.
This prevents an unrelated bad description from making a known source appear
unseen. It does not certify full frontmatter or source accuracy. Alias targets
and new source publication retain full strict validation. No immutable source
body or historical metadata is rewritten by lookup.

| Tool | What it does | Use when |
|---|---|---|
| `kb-seen.py` | Ingestion-level dedup: is this URL already ingested? (`--check`). | **Before any fetch** — dedup is required by the shared KB contract. |
| `kb-prep-item.py` | Read-only pre-fetch prep: dedup + transport mirror rewrite + media discovery. Writes nothing. | Centralised pre-fetch step for interactive and headless ingest. |
| `kb-validate-source-candidate.py` | Read-only pre-write validation for staged source/media candidates. Exit codes: 0 clean, 1 warnings, 2 blocking findings. | Before committing a new immutable source note or media-description note, especially from media/video ingestion. |
| `kb-commit-source.py` | Validate and publish one staged approved source without overwriting, then validate its queue checkoff. Reports partial source/queue states explicitly. | New source publication; does not replace the full ingestion workflow. |
| `kb-source-successor.py` | Separate exact-manifest lifecycle operation: reviewed replacement, queue completion and narrowly permitted predecessor deprecation. | Approved current-version repair; never a force option for ordinary publication. |
| `kb-ingestion-preflight.py` | Inventory exact unchecked Approved/Auto-approved rows against source-note identities and validated aliases; reject ambiguous identities and unstable snapshots. | Read-only planning before ingestion; never a fetcher, approval grant, or proof of extractability. |
| `kb-source-completion.py` | Read-only shared receipt builder: validates the source note, canonical origin and accepted warnings; hashes its bytes. | Internal source evidence gate used by checkoff and staged publication. |

## Endpoints — fetch & media capture

| Tool | What it does |
|---|---|
| `kb-media-capture.py` | Discover and capture media on a source page (CLI contract in `kb-media-capture.md`). Static discovery distinguishes captions/context/titles, supports posterless and lazy video, and filters unsafe URL shapes; other transports retain documented limits. Supports explicit `--stage-dir` plus guarded `--commit-staged`. All ingest skills call it; none re-implement scraping. |
| `kb-headless-capture.py` | Headless-Chromium fallback for JS-rendered / Cloudflare-gated pages and element screenshots. |
| `kb-tweet-fetch.py` | `--inventory status` or `--inventory thread` fetches one explicitly selected FxTwitter endpoint and passes its complete response through strict identity/channel inventory. Legacy compact output is convenience-only; `--out` is retired. |
| `kb-fxtwitter-extract.py` | Offline inventory of an already retrieved JSON payload: exact focal status, authored continuations, quotes, nested article blocks/entities/covers, media and exposed links with payload paths and ambiguity warnings. No fetching, rendering, writing or completeness claim. |
| `kb-video-analyze.py` | Legacy offline helper library only. Its URL/analyze entrypoint is retired and must fail before network, model, workdir or output I/O; use bounded staged capture plus `kb-media-inspect.py` for new reviews. |
| `kb-media-inspect.py` | Local-only inspection of an explicitly staged, hash-checked image/video file using installed ffmpeg/ffprobe and an existing local ASR cache. Writes private ignored derived scratch and a bot-owned JSON receipt; no network, provider, API or model download. |
| `kb-ocr-enrich.py` | Explicit OCR-only enrichment preview/extraction with guarded note commits; Engine selection must be explicitly configured. Direct vision interpretation is retired; use a configured image-capable reviewer. |
| `kb-link-media-backlinks.py` | Suggest (and optionally apply) See Also backlinks from media to concept/synthesis notes. |
| `kb-repair-source-wikilinks.py` | Rule 11 exception tool for mechanical source-note wikilink target repairs. Dry-run by default; requires an existing vault-rooted replacement target. |
| `kb-repair-media-sections.py` | Add missing `## OCR` / `## Vision Description` placeholders to captured image media-description notes so enrichment tools can fill them. Dry-run by default. |

For an already approved social source, run normal dedup/transport preflight,
then `kb-tweet-fetch.py <approved-locator> --inventory status` (or the explicitly
selected `--inventory thread`). It makes one request with no redirect following,
automatic retry or companion/media fetch. Oversized responses, inconsistent
Content-Length, ambiguous JSON/root identity and unsupported locators stop with
nonzero status. The 8 MiB body limit, depth limits and one-byte overflow probe
are extraction bounds, not evidence of a complete online thread.
The result preserves the decoded envelope, exact channel paths, omissions,
received-body digest/length, observed transport metadata and UTC retrieval time.
It does not retain/reconstruct raw HTTP bytes or establish canonical origin;
use the approved queue identity and separately governed retention/publication.
Compact JSON/Markdown is only a convenience view, never source-review evidence.
Keep the transport/extraction deadline separate from the reader's lifetime.
Once the bounded response and inventory have returned, page the same in-memory
evidence under a separate finite reading budget; do not let a fetch timeout kill
an agent that is still reading an already-retrieved article. A successful request
is not complete reading coverage. Record block ranges, channel coverage and
omissions explicitly, and carry those limits into writer/reviewer handoffs.
Avoid oversized duplicated terminal output by using bounded, channel-aware
projections of the returned inventory, not by discarding the article/media/link
channels. Output truncation is a local coverage failure, not an unseen-source
result or automatic permission to fetch again. Recovery retains the run's
approval/retry limits; in-memory reading does not authorize a raw disk archive.
All `--out` file sinks are retired. See `kb-tweet-fetch.md` and the executable
help for the supported inventory path.

Run `_tools/.venv/bin/python _tools/kb-ingestion-preflight.py --kb-root <root>`
(optionally `--topic <slug>`) for a JSON inventory. It uses a nonblocking shared
lock and rechecks queue/source-identity snapshots; only lock metadata may be
created, never queue rows, notes or the seen cache. `eligible-candidate` means
approved and unseen with unambiguous identity, not ready to publish: extraction,
media needs and evidence quality remain unknown. Local PDFs require manual
identity review; unsupported URL identity forms remain ineligible. Global inbox
items are counted separately and do not become approved. STOP or changed
snapshots expose no eligible candidates; re-run before acting on stale output.
Missing explicitly selected queues, unsafe paths, noncanonical topic directories
and miscapitalized approval headings fail closed rather than implying an empty
inventory. This does not replace full structural lint or fix historical queues.

Media capture writes and staged finalization share checked paths, a nonblocking
lock, no-overwrite publication and byte readback. Downloads happen outside the
lock. Dedup reuses only a unique owned captured description backed by identical
regular bytes; missing or mismatched bytes and conflicting records stop that
item. Unrelated malformed legacy metadata is reported without repairing it.
New `--stage-dir` writes are restricted to `_tools/staging/media/` inside the
selected KB, not arbitrary external directories. Existing staging inputs
elsewhere may still be read by the finalizer, never modified or deleted.

`kb-media-capture.py --temporary-inspection` is the bounded interactive Rule 29
exception. The caller must supply the complete exact, user-approved URL list,
use a fresh staging subdirectory, and keep the invocation budget at or below
25 MiB. The mode accepts only credential-free HTTPS image/MP4/WebM URLs and
refuses redirects, proxies, cookies, login/session access, automatic retries and
unlisted variants. It is not an approval grant, a headless/autonomous route,
or permission to finalize raw bytes into `_media/`; the caller also supplies a
finite wall-clock limit. Pass its hash-checked staged output only to the
local-only `kb-media-inspect.py` route.
Temporary staging waits for the shared lock within the caller's deadline.
Rule 29 permits a separately recorded, hash-pinned same-URL recovery after a
verified local pre-write staging fault; `--expected-media-id` enforces the
prior bytes, not permission to retry or expand a source.

Staged media finalization (`kb-media-capture.py --commit-staged`) requires the
full expected hash, checks bounded regular bytes and canonical `_media` targets,
and publishes under the shared lock without overwrite. Identical retries keep
the staging input; no automatic staging deletion occurs. `--no-write` is a
no-fetch/no-write finalization preview. Capture `--no-write` still fetches but
creates no lock or files. `do-not-redistribute` refuses capture before fetching.
Byte custody is not source/media-note completion. See the owned CLI contract
for partial-publication recovery and exact flags.

`kb-repair-source-wikilinks.py` now holds the shared lock, rechecks strict YAML
ownership and canonical singly-linked source/target paths, and uses the shared
mode-preserving atomic writer. Its narrow repair surface is ordinary body
wikilink targets. Frontmatter (including frozen `media:`), embeds, code and
blockquote regions are preserved. Conservative parsing may leave ambiguous
regions unchanged; a frontmatter-only match is not permission to edit metadata.
Dry-run the exact mapping first and verify the final diff: existing targets and
valid paths do not prove semantic identity or source accuracy. This does not
retroactively harden the other historical media-repair helpers.

## Retained retrieval evidence (offline)

`kb-retain-evidence.py` records an already-approved UTF-8 extraction staged
inside the KB. It performs **no network or model calls** and does not publish
sources or complete queues. Use it for fidelity trials so writer and reviewer
can inspect the same input rather than independently fetching a changing page.

```bash
_tools/.venv/bin/python _tools/kb-retain-evidence.py \
  --input <kb-relative-staged-extraction> --retain-approved \
  --origin https://example.org/article --transport https://example.org/article \
  --retrieved-at 2026-09-06T12:00:00Z --channel excerpt --scope excerpt \
  --limitations 'Selected passage only; images not inspected.' \
  --approval-ref '<actual source/retention approval record>' \
  --retention-basis permitted-excerpt
_tools/.venv/bin/python _tools/kb-retain-evidence.py --verify <returned-path>
```

The approval flag is an operator assertion, not a substitute for permission.
Retention bases: `user-provided`, `open-license`, `public-domain`, and
`permitted-excerpt`; only `permitted-excerpt` requires `excerpt` scope. These are
operator assertions, not verified licenses. In particular, a government URL does
not establish that all embedded material is public domain; record the actual
rights basis and exclusions. Check privacy and copyright before retaining content;
do not retain credentials, unnecessary personal data or restricted payloads.
Channels: `page-text`, `mirror-json`, `ocr`, `transcript`, `excerpt`. Scope is
`excerpt` or `supplied-extraction`, never an automatic claim of full-page coverage.
Record extraction omissions, redactions and transformation details in limitations.
Retrieval time, approval and URLs are operator-supplied, not verified by the tool.

Canonical artifacts are `_tools/evidence/<envelope-sha256>.json`, containing
`author: kb-bot`, version 1, provenance, limits, content, byte count and content
SHA-256. Input is bounded to 2 MiB, no symlink paths, lock-held atomic no-overwrite
publication, identical retries idempotent. `--verify` checks both content and
envelope digests without writing. A hash proves byte identity only; it cannot
prove authenticity, accuracy, completeness or permission. Reference the artifact
path/digest from the mutable trial record, and supply it alongside the draft to
reviewers. Existing trials without retained input are not retroactively verified.
Retained envelopes referenced by a review are verified by the publication and
completion gate. Retention is not mandatory when privacy/copyright prevents it;
the review must explicitly record that limit and cannot claim reproducibility.

## Review receipts — required for source completion

`kb-review-receipt.py` retains an already-written review as immutable canonical
JSON under `_tools/reviews/<receipt-sha256>.json`. It does not perform the review,
run a model, approve a source or change any queue. Both publisher and direct
topic checkoff require the returned path. A changed draft requires a new review;
identical publication retries reuse the same artifact.

The strict version-1 record contains:

- `author: "kb-bot"`, integer `version: 1`;
- `candidate_path`, `candidate_sha256`, `queue_path`, `primary_locator` binding
  exact destination, UTF-8 bytes and the selected queue row;
- `evidence`: records containing canonical `path`, `envelope_sha256` and
  `content_sha256`, checked against the existing evidence store;
- `coverage`: `status` (`complete` or `partial`), nonempty `covered` list and
  `omissions` list (required nonempty for partial coverage);
- boolean `reproducible_snapshot` and nonempty `retention_limitations`;
- distinct nonempty `writer_ref` and `reviewer_ref`, timezone-bearing
  `reviewed_at`, and `disposition` (`publish-with-boundary`, `defer`, `reject`).

Only `publish-with-boundary` may complete a source. Empty retained evidence is
allowed only without a reproducibility claim and with recorded retention limits.
Excerpt retention cannot establish a reproducible full review. Coverage records
what the reviewer examined; retention records what can be checked again later.
Neither a hash nor distinct agent labels proves factual correctness or reviewer
identity. Inspect the actual evidence and resolve material discrepancies first.

```bash
_tools/.venv/bin/python _tools/kb-review-receipt.py --input <kb-relative-review.json>
_tools/.venv/bin/python _tools/kb-review-receipt.py --verify <returned-path>
```

Standalone `--verify` checks artifact/evidence integrity, not publication
readiness. Publisher/checkoff additionally bind the actual candidate and queue
and enforce source validation and approval-section requirements.
The Python `verify_review()` adapter is internal to that call chain: callers
must first validate actual source bytes, queue selection and governed locator
identity. It binds those supplied values to the receipt; it does not duplicate
the publisher's on-disk source/row checks. Evidence envelopes retain their
canonical source origin; a transport URL alone is not companion-source identity.

Missing, stale, mismatched or rejected reviews stop publication/checkoff.
Existing completed rows are not retrofitted. Marking an older unchecked source
complete needs a review too; repair-uncheck needs none and removes both receipt
annotations. Topic text repairs on completed rows must still pass the gate.
Direct new topic completion is limited to `Approved` or `Auto-approved`;
caller-supplied section restrictions may narrow that set, not admit Pending.

## Endpoints — diagnostics (read-only)

`kb-project-status.py <slug>` is the project/code-context entrypoint. Its default
is metadata-only: resolve the documented code location, observe Git identity,
HEAD and dirtiness, and compare the optional saved `code_state_*` record.
It does not write a record, execute discovered environments or check services.
`--runtime-checks` explicitly adds the legacy environment/service diagnostics;
inspect the target and task authority before using it. A snapshot is not code
review, passing tests or deployment evidence. The old summary-date comparison
is a document-age heuristic only. See `_schema.md` and Rule 22 for the evidence
and handoff contract; `kb-lint.py --check projects` checks project structure and
optional recorded evidence without upgrading missing records into verification.
Use `--all --check projects` with the explicit KB root for a project-only report.
Both tools use the shared PyYAML dependency. Lint exits 1 for any reported
finding, including unrelated historical warnings: inspect the report and scope,
and distinguish a valid advisory report from an execution failure.
Git observation forbids lazy fetches and checks HEAD again after the other
metadata reads; failures or changed HEAD produce a partial result, not a match.
This is still not an atomic snapshot. Configured Git clean/process/smudge filters
are neutralized; because that can change normal status semantics, dirtiness
stays unknown whenever configured filters are found. No filter configuration
or project content is changed to make the check pass.

The video helper's historical `--vision` / `--summary` direct-model paths and
its URL/analyze downloader route are retired: the executable must reject them
before re-exec, network, model, workdir or output I/O. Preserve pure offline
helpers only for the bounded local inspector; new work stages exact approved
bytes with `kb-media-capture.py`, then extracts transcript/frames locally and
hands only the reviewed derived packet to the configured image-capable reviewer. Old
helper documentation and dated task records are history, not authority
to launch `yt-dlp`, implicit ASR downloads, Claude, or a cheaper summarizer.

Use the current `kb-video-analyze.md` and `kb-media-inspect.md` contracts;
old direct-provider or downloader examples are not supported.

`kb-ocr-enrich.py` likewise retires its direct Gemini vision route: explicit
`--ocr-only` is required; default/both/vision requests stop before note access.
OCR-only `--dry-run` previews without engine calls or writes. Select an available engine explicitly; configuration is not permission to spend.
OCR note commits now validate canonical owned notes/images, snapshot under the
shared lock, release the lock for extraction, then recheck exact note content
and file identities before an atomic mode-preserving write. Concurrent changes
stop the commit, including under `--force`; stage errors return nonzero.
This is cooperative-writer protection, not protection from a hostile same-user
process swapping the path while an engine reads it. Direct capture, staging and
finalization now have guarded paths above. Unattended ingestion is not enabled
by these patches; evidence review and interpretation remain separate work.
Interpret retained images with the configured image-capable reviewer.

| Tool | What it does |
|---|---|
| `kb-lint.py` | Structural lint: canonical-ladder enforcement, broken wikilinks, frontmatter, stale sources, media integrity, global inbox rows that are already ingested, multi-URL source origins, and multiple completed reading-list rows pointing to one source note. Stale global inbox findings include a lock-safe `cleanup_command` using `kb-checkoff.py`. `--all` for the whole KB. |
| `kb-obsidian-cli.py` | Optional read-only bridge to the Obsidian CLI for diagnostics/search (requires the desktop app running). |
| `kb-project-status.py` | Read-only project Git metadata and recorded-observation comparison; `--all` inventories projects. Runtime environment/service diagnostics are opt-in, not a default context scan. |

## Optional automation

No scheduled worker or provider route is installed by this starter. Configure
finite budgets, approval rechecks, no-overlap and explicit terminal failure
reporting before enabling any local adapter. Model, effort, OCR engine and
billing scope are user choices, not starter defaults.

## What does NOT exist (to prevent re-confusion)

- There is **no generic command runner or arbitrary section editor** — mutations are
  limited to the verbs above (add / move / mark / rehome / dedupe / generate).
- `_dive-queue.md` has **no writer** other than `kb-derive-dive-queue.py`.
- Tests live in `_tools/tests/` (pytest, `tmp_path` fixtures, importlib-loaded
  hyphenated scripts). Run with a pytest-equipped interpreter, e.g.
  `_tools/.venv/bin/python -m pytest _tools/tests/`.
