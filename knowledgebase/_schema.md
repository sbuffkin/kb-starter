---
author: kb-bot
created: 2026-04-09
modified: 2026-09-17
type: meta
---

# KB Schema

This file is the core specification for this knowledge base. Media-specific frontmatter (source-note `media:` blocks, `media-description` notes) lives in `_schema-media.md` and is loaded only when a source actually carries media; otherwise this file is sufficient. Any agent — LLM, script, or human — should be able to manage the non-media portion of this KB by reading this file alone, with no prior training on this system.

---

## What This KB Is

A personal knowledge base that ingests sources (URLs, PDFs, transcripts, etc.) and synthesises them into a human-readable wiki. Notes are written to be useful without any AI assistant present. The structure is also optimised for LLM navigation: agents read compressed summaries first and dive deeper only when needed, keeping context windows efficient.

It also preserves personal project context: code navigation, decisions, verified
observations and resumable session handoffs. Project work does not require an
external source, research topic or ingestion queue. A separate team KB
may have its own collaborative contract; this starter does not authorize copying
private work content or personal capture machinery between different KBs.

This KB is **LLM-agnostic**. All conventions are plain English. No model-specific syntax is used anywhere. Any capable LLM can act as an agent over this KB by following this schema.

---

## Safety Rule — Read Before Writing Anything

**You must never create or modify a file that already exists and does not have `author: kb-bot` in its YAML frontmatter.**

- If a file exists and lacks `author: kb-bot` → do not touch it. It belongs to the human.
- If a file does not yet exist → you may create it, and you must include `author: kb-bot` in its frontmatter.
- The clippings input exception in Rule 23 permits reading human-authored files
  in `clippings/`, not modifying them. Processing state belongs in kb-bot logs
  and checkpoints; existing user tags do not grant write authority.
- Raw binary source files under `_library/books/` or `_library/docs/` are custody files, not Markdown notes. They are exempt from frontmatter because PDFs/EPUBs cannot carry KB YAML, but every agent-created Markdown control file in `_library/` still requires `author: kb-bot`.
- When in doubt, do not write.

---

## Folder Layout

```
knowledgebase/
  _schema.md          ← this file; the contract for all agents
  _templates/         ← reusable file templates for catalog, summary, etc. (see Rule 26)
  _index.md           ← navigation map listing all topics and projects
  _rules.md           ← behavioural rules for agents operating in this KB
  _checkpoint.md      ← written during long operations; used for resume after interruption
  _log.md             ← append-only activity log of all operations across the KB
  _dive-queue.md      ← generated/read-only cross-topic dashboard derived from topic Auto-approved queues and research-ideas files
  _todo.md            ← KB system development tasks (infrastructure, skills, tooling); not for research topics
  _tools/
    fetch-workarounds.md ← flagged unrecoverable fetches awaiting an automated workaround (Rule 35c)
  ideas/
    _backlog.md       ← durable parking lot for broad side-project/inspiration ideas that are not yet topics or projects
  _media/             ← captured source media, stored with human-readable filenames and hash metadata
    _README.md        ← media capture policy, licensing posture, and path conventions
    images/           ← images stored as images/YYYY/MM/<date>-<description>-<short-hash>.<ext>
    videos/           ← videos stored as videos/YYYY/MM/<date>-<description>-<short-hash>.<ext>
    audio/            ← audio stored as audio/YYYY/MM/<date>-<description>-<short-hash>.<ext>
  _library/           ← raw source custody; not a topic and not a citation surface
    _README.md        ← source custody policy and path conventions
    source-custody-index.md ← maps raw files to canonical custody paths + relocation history
    books/            ← local books, EPUBs, scanned books, and long-form PDFs grouped by source cluster or subject
      _ledger.md      ← book acquisition lifecycle: Wanted → Proposed → Acquired → Ingested (Rule 34)
    docs/             ← non-book source PDFs/reports/reference documents grouped by topic or project
  readinglist/
    Links.md          ← global URL inbox: dump URLs here without a topic; agent assigns and processes
    topics.md         ← broad topic interests without specific sources yet; triaged into topic reading-lists / research-ideas
  topics/
    <topic-slug>/
      _summary.md     ← compressed overview of this topic (read this first)
      _discussion.md  ← append-only log of corrections and conversations
      _prospects.md   ← optional; project ideas, todos, and experiment seeds for this topic
      research-ideas.md ← optional; prose-only rabbit holes and research questions that do not yet have exact source URLs
      sources/        ← one note per ingested source; immutable after initial write
      notes/
        concepts/     ← one article per concept
        entities/     ← people, organisations, tools (one file per entity)
        media/        ← OCR, transcripts, visual descriptions, and analysis for captured media
        syntheses/    ← cross-cutting analyses spanning multiple concepts
      reading-list.md ← queue of URLs/files pending ingestion for this topic; `## Auto-approved` is the headless-only lane
  projects/
    <project-slug>/
      _summary.md     ← two sections: LLM orientation + user research direction
      _todos.md       ← kanban task board; human + agent editable (see Rule 28)
      notes/
```

**Naming conventions:**
- Topic and project slugs: lowercase, hyphen-separated (e.g. `large-language-models`, `kb-bot`)
- All system-generated files prefixed with `_`. Do not prefix user-created files with `_`.
- Source notes: `sources/YYYY-MM-DD-<slug>.md` or `sources/<author>-<year>-<short-title>.md` for academic papers
- Concept notes: `notes/concepts/<concept-slug>.md`
- Entity notes: `notes/entities/<entity-slug>.md`
- Media-description notes: `notes/media/<sha256-or-short-slug>.md`

---

## Frontmatter Schema

**Tooling evidence exception:** `_tools/evidence/<sha256>.json` is an immutable
extraction-evidence envelope, not a source note or wiki citation surface. It
uses JSON `author: "kb-bot"` and `version: 1`, not YAML frontmatter. Only
`kb-retain-evidence.py` creates it; the content/envelope hashes and required
provenance fields are documented in `_tools/README.md`. This narrow exception
does not authorize editing arbitrary non-kb-bot files or changing source bodies.

`_tools/reviews/<sha256>.json` is likewise an immutable tooling artifact with
JSON `author: "kb-bot"` and integer `version: 1`, created by
`kb-review-receipt.py`. It binds the exact candidate path/UTF-8 hash, queue path
and primary locator to a review disposition, coverage/omissions, retention
limits, evidence references and distinct writer/reviewer references. Its schema
is validated by that helper and documented in `_tools/README.md`. It is not a
source note, a factual-truth certificate or a substitute for source approval.
Do not retrofit review fields into immutable source frontmatter.

`_tools/successors/<sha256>.json` is a canonical immutable, author-owned
version-1 operation manifest created by `kb-source-successor.py`. It names
one exact predecessor and replacement, their origins and hashes, the old
body/immutable-frontmatter hashes, the approved queue row, canonical independent
review, reason and checkpoint ID. A manifest is an intended operation, not
proof it completed: verify actual source, lifecycle and queue post-state.
Only a validated completed manifest may project a governed successor in source
lookup. This exception neither changes arbitrary URL aliases nor authorizes
source-body edits, longer version chains or cross-topic moves.

Every Markdown note or control file created by an agent must include this YAML
frontmatter block. Explicitly specified custody/tooling artifacts use their own
formats; those exceptions do not relax the existing-file authorship guard.

Approved binary media may be staged under `_tools/staging/media/` by
`kb-media-capture.py`; these hash-named binary intermediates have no YAML and
are not notes, citation surfaces or completed captures. New staging writes must
stay in that area. Finalization may read an explicitly selected existing staging
input elsewhere, but never modifies or deletes it. Staging cleanup remains a
separate scoped operation; files are not automatically disposable after failure.
The staging area's `.gitignore` excludes these raw binaries from normal Git
staging; retention permission does not imply permission to publish them.

The `--temporary-inspection` capture mode is the only shared custody exception
for a finite, interactive, user-authorized image/MP4/WebM review. Its exact
transport and approval guard lives in Rule 29 and the CLI contract; its media
status, receipt and cleanup representation lives in `_schema-media.md`. Staged
bytes remain non-canonical and are not automatically disposable after failure.

```yaml
---
author: kb-bot
created: <ISO-8601 date>
modified: <ISO-8601 date, updated on every edit>
type: <see types below>
topic: <topic-slug or project-slug>
title: <human-readable title, matches the H1 heading>
description: <one sentence — what this note is about; shown in KB Browser>
status: draft | review | final | deprecated   # omit on meta/index/summary files; `deprecated` is the canonical end-state per Rule 10 and Rule 11, always paired with `superseded_by:` when a successor exists
tags: []
sources: []       # wikilinks [[knowledgebase/topics/<topic>/sources/...]] this note draws from
related: []       # wikilinks to related notes in the KB
origin: ""        # source notes only: original URL or file path
ingest_status: succeeded | failed   # source notes only: omit or use succeeded for normal ingests; use failed for attempted fetch records that must not count as already ingested
media: []         # source notes only: captured or discovered media items; see Media Schema
---
```

**`type` values:**
| Type | Used for |
|---|---|
| `source` | One ingested source (URL, PDF, transcript, etc.) |
| `concept` | A synthesised wiki article on a concept |
| `entity` | A person, organisation, or tool |
| `media-description` | OCR, transcript, visual description, and analysis for a captured or discovered image, video, or audio item |
| `synthesis` | Cross-cutting analysis spanning multiple concepts or sources |
| `output` | Filed answer to a user query |
| `summary` | A `_summary.md` folder overview |
| `index` | `_index.md` |
| `prospects` | `_prospects.md` per topic — ideas, todos, experiment seeds, and project promotion records |
| `research-ideas` | `research-ideas.md` per topic — prose-only rabbit holes, research questions, and investigation prompts with no exact source URL yet |
| `catalog` | Living inventory of a project's instances (cards, creatures, mechanics, levels, etc.) — tracks what's implemented, what needs work, and what's on the wishlist. Named `catalog-<entity-type>.md` in `projects/<slug>/notes/`. See Rule 26. |
| `todos` | Kanban task board for a project (`_todos.md` at the project root). Four sections: Backlog, In Progress, Testing/Review, Done. Status markers: `[ ]` `[~]` `[?]` `[x]` `[!]`. See Rule 28 and template at `_templates/project-todos.md`. |
| `meta` | `_schema.md`, `_rules.md`, `_checkpoint.md`, `_log.md`, `_discussion.md`, `reading-list.md`, `_dive-queue.md`, `ideas/_backlog.md`, project context/decision/session records |

---

## Exact URL aliases (optional tooling registry)

`_url-aliases.json` is a reviewed identity registry for legacy sources whose
address changed. It is a tooling JSON exception to YAML frontmatter, with exactly
`author: "kb-bot"`, integer `version: 1`, and `entries`. Each entry has exactly
`alias` (absolute HTTP(S) URL without fragment/credentials or nonstandard port), `source_note`
(`topics/<topic>/sources/<note>.md`), `evidence` (nonempty single-line verification
record/reference), and `verified` (YYYY-MM-DD). The target must be an existing
kb-bot successful, non-deprecated source with an HTTP(S) origin.
All shared HTTP(S) identity boundaries reject malformed and nonstandard ports,
including lookup, review binding, publication and queue completion—not only
aliases. Explicit HTTPS port 443 and HTTP port 80 retain their existing default
identity. The inherited normalizer does not preserve other ports; supporting
them needs a separately reviewed normalizer change, not silent address broadening.
An unsupported historical origin or mirror stops the authoritative index scan;
do not treat the error as unseen or rewrite immutable source metadata to pass it.

Absent registry means no extra aliases. Invalid registry/targets and collisions
stop matching; do not discard errors and proceed as unseen. Matching uses the
shared normalizer, including its existing tracking-parameter handling. This is
not a domain-wide rewrite, redirect crawler or arbitrary equivalence graph.
No source body or historical frontmatter is edited. `mirror:` remains transport
provenance. A changed document revision is not an alias: use a separately scoped
revision/supersession workflow. A verification date records the maintainer's
observation, not automatic freshness or proof of identical content today.

Add/change entries only as reviewed, checkpointed maintenance after confirming
the exact source identity; the lookup tools do not create registry entries.
Historical direct-origin collisions remain repair findings, not silently
resolved by this registry. See `_tools/README.md` for cache and caller behavior.

## Topic Reading Lists

Topic reading lists are the canonical writable queues for source candidates. Every ingestion item lives under one of **five canonical level-2 sections** — the *section ladder*. Ad-hoc ingestion headings (`## Queue`, `## Approved Exact URL Queue`, `## Original Source Targets`, `## Future / not yet fetched`, project/batch headings, etc.) are **not permitted**; `_tools/kb-lint.py` flags any non-canonical ingestion heading. This is a cross-agent contract: all LLMs and all `kb-*` skills follow the same ladder.

| Section | Meaning | Who may process it |
|---|---|---|
| `## Pending` | Captured but **not yet vetted**. Needs a human (or interactive agent) to confirm it is worth ingesting. | Triage / review only — not an ingestion lane |
| `## Approved` | Vetted and good; will be ingested **interactively** (`/kb-queue`, `/kb-ingest`, human present). | Interactive agents after Rule 4 approval |
| `## Auto-approved` | `## Approved` **and** explicitly cleared for **unattended headless** ingestion (`/kb-auto`, kb-feed trusted lane). A strict subset of Approved. | `/kb-auto` and other headless agents |
| `## Processed` | Historical/archive terminal section for already-ingested rows. Current tooling normally marks items `[x]` in place in their original section with date + source-note path, preserving intake provenance. | Terminal |
| `## Failed — Retry` | Fetch/ingest failed; awaiting manual retry (Rule 18). | Interactive |

**Promotion is upward and explicit:** `Pending → Approved → Auto-approved`. Move an unchecked item between sections when promoting/demoting — never duplicate the same URL across sections. Perform the move with `_tools/kb-promote.py` (shared write-lock, atomic; the sanctioned "move" verb, distinct from `kb-checkoff.py` which only flips the mark in place) — never hand-edit the section. Processing normally uses `_tools/kb-checkoff.py` to mark the original row `[x]` in place; do not manually relocate processed rows to `## Processed` unless a future shared-lock tool explicitly supports that archival move.

**One queue item maps to one source note.** Batch processing means an agent may process many rows in one run; it does **not** mean those rows may be collapsed into one source note. Each independent URL-first or local-file checklist row that is fetched gets its own `type: source` note and its own checkoff target. Do not group unrelated social posts, web pages, PDFs, or product pages into a date/topic "batch source note." If a source points to companion material, capture the companion as its own reading-list row unless it is merely a transport mirror of the same underlying source.

New topic source checkoffs include a tool-generated `validated-source [[knowledgebase/topics/<topic>/sources/<note>]] sha256:<hash>` annotation. The hash identifies the exact validated note bytes. It is queue provenance, not new source frontmatter or proof of factual accuracy. See Rule 38 for required validation, warning review, and partial-write handling. Historical completed rows without receipts remain historical records, not retrospectively validated records.

New completion also requires a matching review artifact and appends
`review-receipt sha256:<digest>`. A previously unchecked historical source needs
a current review before a new completion; existing completed rows are not
automatically rewritten or retrospectively certified.

**The `## Auto-approved` gate.** Only the user, an interactive agent after explicit approval, or kb-feed under Rule 31's trusted-lane policy may place items here. Promote to `## Auto-approved` (rather than leaving in `## Approved`) only when the item is safe to fetch with **no human watching**: text-first, not paywalled, needs no interactive capture (OCR/video/figure selection/Wikipedia citation discovery), and comes from a trusted source. Everything else that is vetted stays in `## Approved` for interactive ingestion. `/kb-auto` and other unattended agents scan **only** `## Auto-approved`, stop at the next level-2 heading, and process only unchecked URL-first or local-PDF lines. Prose-only queue entries without a primary URL or local PDF never belong in `## Auto-approved`; this does not exclude text-first source documents.

Sub-grouping within a canonical section uses level-3 (`###`) headings (e.g. `### Foundational papers` under `## Pending`), which keeps the level-2 ladder intact for tooling. Non-ingestion material (prose rabbit holes, research questions) belongs in `research-ideas.md`, not the reading list.

Approval-sensitive tools use `_tools/kb-queue-parse.py` for the same definition
of a real queue row and section. Frontmatter, fenced examples, HTML comments,
blockquotes and indented code do not grant approval. Ambiguous approval headings
or unterminated example blocks stop publication instead of guessing. Capture
and promotion also require an unambiguous insertion section. This changes how
tools recognize existing approval, not who may grant it.
The supported format permits zero through three leading spaces on headings or
rows; four or more spaces (or leading tab indentation) are treated as code.
Raw HTML blocks are unsupported in active queue operations. A noncanonical
level-two heading ends the preceding section; it never inherits approval.
Malformed/duplicate approval headings block publication, while insertion also
rejects malformed/duplicate non-approval canonical headings. Other structural
problems remain lint findings rather than automatic authority to repair a queue.

Example:

```markdown
## Pending

- [ ] https://example.com/needs-triage — captured via #unfiltered, topic unconfirmed

## Approved

- [ ] https://example.com/paywalled-pdf — vetted; ingest interactively (needs login capture)

## Auto-approved

- [ ] https://example.com/source.pdf — vetted and headless-safe; next unattended `/kb-auto` pass

## Processed

## Failed — Retry
```

---

## Research Ideas

`topics/<topic>/research-ideas.md` stores prose-only rabbit holes and research questions that do not yet have an exact source URL or local source file. It is a mutable topic meta file with normal kb-bot frontmatter:

```yaml
---
author: kb-bot
created: <ISO-8601 date>
modified: <ISO-8601 date>
type: research-ideas
topic: <topic-slug>
title: "<Topic Title> — Research Ideas"
description: "Prose-only rabbit holes and research questions for the <topic-slug> topic."
---
```

Body format:

```markdown
# <Topic Title> — Research Ideas

Prose-only rabbit holes and research questions. Add exact URLs to `reading-list.md` instead.

## Ideas

- [ ] <idea> — <why it is worth investigating>
```

The root `_dive-queue.md` is generated from every topic's `## Auto-approved` section and `research-ideas.md`. Agents and scripts must not use `_dive-queue.md` as a writable queue.

---

## Media Schema → see `_schema-media.md`

The media-frontmatter spec for source notes and the `type: media-description` note format have moved to `_schema-media.md`. Load that file only when a source carries (or might carry) media. The note types `media-description` and the source-note `media:` field are valid kb-bot constructs — their full structural definition lives in `_schema-media.md`.

---

## Navigation Protocol

Agents must follow this order to use context efficiently:

1. Read `_index.md` — find the relevant topic(s) or project(s)
2. Read the matching `_summary.md` — decide which detail is relevant
3. For research, read topic notes as needed and source notes only when tracing
   a specific claim. For project/code work, read `_todos.md`, linked decisions
   and handoffs, then targeted code/evidence (Rule 22)
4. Do not scan the global inbox, clippings or dive queue for a project-only
   request. A matching checkpoint can resume the work; an unrelated checkpoint
   must not replace the user's scope or be overwritten (Rule 5)

**Never load all notes in a folder upfront.** The summary and index exist so you don't have to.

---

## Project Context and Code-State Evidence

`projects/<slug>/_summary.md` and `_todos.md` remain the required entrypoints.
Keep the summary under 300 body words; link detailed evidence and handoffs in
`notes/`. Templates are `_templates/project-summary.md`,
`_templates/project-context.md`, `_templates/project-handoff.md` and
`_templates/project-todos.md`. Non-code projects may omit a code location.
For code projects, retain the machine-readable body marker
`**Code location:**` followed by the exact absolute local repository path in
backticks. Legacy `Live app location`, `Vault project location` and
`Code / paper location` labels are also recognized. Ambiguous or unavailable
locations are unresolved, not silently guessed.

Use `type: meta` for new project context, decision and session records, with
optional `context_role: current | decision | session`. These are not external
source notes. Current views may be maintained under Rule 22; dated decisions
and sessions keep their history and append corrections. Do not retrofit source
metadata or use this role to rewrite research syntheses.

The following optional flat frontmatter record stores an actual Git observation:

| Field | Meaning |
|---|---|
| `code_state_repo_id` | Absolute resolved Git common-directory identity on this machine; not a public URL or credential |
| `code_state_commit` | Full observed HEAD object ID (40 or 64 hexadecimal characters), not a moving branch name |
| `code_state_dirty` | YAML boolean observed from successful status; unknown is not `false` |
| `code_state_observed_at` | Actual observation time, ISO 8601 with timezone, not the document edit date |
| `code_state_scope` | Exactly `repository-git-metadata`; does not mean code review, tests or deployment |

The record is optional as a whole. Older summaries without it have unknown
observation status, not fabricated verification or mandatory migration. When
present, all five fields must be valid; incomplete, future-dated or failed
observations must not qualify as verified. The read-only project-status helper
emits the record and compares recorded/current metadata; the agent saves it
only after an actual observation and normal write gates. Git dirtiness is a
boolean, not a content fingerprint: two dirty observations need not contain the
same edits. A matching commit is not implementation freshness. Local repository
identities are private metadata; omit them from public exports and shared KBs.

In the body distinguish **Observed**, **Planned**, and **Externally verified**
(default: not verified). Code claims need repository/commit/path and inspection
scope; tests need exact command, date/result and an inspectable artifact when
available; deployed claims need environment-specific observation. Decisions
need date/rationale and a recorded user/team decision, not an inferred approval.
A useful handoff states branch/working-tree limitations, checked artifacts,
open tasks, blockers/owner and the next safe action. Git state and recent
`modified` dates cannot substitute for any of this evidence. External claims
still use normal source-ingestion/citation rules.

---

## Topic Placement and Promotion

When a rabbit hole concept or entity is first captured, file it in the **best-fit existing topic**, not a new one. Create a new topic slug only when:
- No existing topic is a plausible fit, **and**
- You have (or expect to have) 3+ sources for the new topic

Notes that may eventually belong to their own topic should be tagged `rabbit-hole` and flagged in their frontmatter as `promotion-candidate: true`. When a promotion-candidate note has 2+ sources and would benefit from its own topic, raise this with the user before restructuring.

---

## Page Creation Threshold

- **Stub** (`status: draft`, frontmatter + source-grounded definition + source backlink): eligible with **1 source**, when useful under Rule 17.
- **Full article** (`status: draft` → `review` → `final`): eligible with **2+ sources** and enough distinct, supported substance. Multiple copies or reports of the same claim do not provide independent corroboration. Length follows the topic's needs; 500–1,500 words is guidance, not a quota or reason to pad a note.
- **Never leave a wikilink pointing to a non-existent page.** Create an approved useful stub first, or leave the term as plain text. Source counts alone do not require creating a page.

---

## Link Conventions

All cross-references use Obsidian wikilinks:

| Link type | Format | When to use |
|---|---|---|
| Source citation | `[[knowledgebase/topics/<topic>/sources/2026-04-09-some-article]]` | Citing the origin of a claim |
| Concept link (same topic) | `[[knowledgebase/topics/<topic>/notes/concepts/concept-slug]]` | Linking to a concept note in the same topic |
| Entity link (same topic) | `[[knowledgebase/topics/<topic>/notes/entities/entity-slug]]` | Linking to an entity note |
| Cross-topic link | `[[knowledgebase/topics/other-topic/notes/concepts/concept]]` | Canonical concept in another topic |
| Cross-project link | `[[knowledgebase/projects/project-name/_summary]]` | Reference to a project |

**All wikilink paths must be vault-relative** — they start from the vault root (`knowledgebase/...`). Never use relative paths with `../`. Relative paths do not resolve correctly in Obsidian wikilinks and produce broken links.

- Wrong: `[[../../celestial-spheres/notes/concepts/florentine-neoplatonism]]`
- Correct: `[[knowledgebase/topics/celestial-spheres/notes/concepts/florentine-neoplatonism]]`

**Rules:**
- External-source factual claims in research wiki notes require source citations;
  project observations/decisions use the project evidence contract above (Rule 3)
- Link only the first occurrence of a concept per section
- Do not duplicate content — link to the canonical note instead
- Bold key terms on first use in each article

---

## Note Format

Concept notes (`type: concept`) follow this structure:

```markdown
---
[frontmatter]
---

# Concept Title

One or two sentences establishing what this concept is and why it matters.

## [Section heading]

Prose, not bullet dumps. Written for a knowledgeable reader.
Wikilinks to related notes: [[knowledgebase/topics/<topic>/notes/concepts/related-concept]].
Source citations inline: [[knowledgebase/topics/<topic>/sources/2026-04-09-origin]].

## See Also

- [[knowledgebase/topics/<topic>/notes/concepts/related-a]] — brief reason for the link
- [[knowledgebase/topics/<topic>/notes/entities/person-name]] — brief reason
```

**One central concept per note.** If a note covers two distinct concepts, split it.

---

## LaTeX Conventions

Mathematical and symbolic content must use LaTeX:

- Inline: `$f(x) = \sum_{i=0}^{n} x_i$`
- Block: `$$\nabla \cdot \mathbf{E} = \frac{\rho}{\varepsilon_0}$$`

LaTeX renders in Obsidian via the built-in MathJax renderer. Use standard LaTeX notation.

---

## Activity Log Format

`_log.md` is an append-only record of every operation. Append a new entry after authorized durable operations. Read-only queries and
checks do not themselves authorize log or checkpoint writes. Never edit or delete existing entries.

```markdown
## [YYYY-MM-DD] <operation-type> | <brief description>

- Created: <file paths>
- Updated: <file paths>
- Errors: <any failures>
```

---

## What Agents Should Not Do

- Do not write to files outside `knowledgebase/`
- Do not modify files lacking `author: kb-bot` frontmatter
- Source-note body is immutable after initial write. Only the lifecycle-metadata exceptions defined in Rule 11 are permitted.
- Do not fetch URLs or external content without explicit user approval — subject to the sanctioned carve-outs: Rule 4 (headless-mode items pre-approved by membership in a topic reading-list's `## Auto-approved` section), Rule 29 headless exception (auto-capture of contextually-relevant media in `/kb-auto`), the finite interactive Rule 29 temporary-inspection exception (exact listed image/MP4/WebM URLs only), and Rule 30 (automatic transport-level rewrite to documented public mirrors for hosts that gate anonymous requests; the canonical URL is still the user-approved identifier). The temporary-inspection exception is never headless, never a rights clearance, and never permission to use an unbounded URL/video analyzer.
- Do not delete notes — mark them deprecated with `status: deprecated` in frontmatter instead
- Do not duplicate content across notes — link to canonical notes
- Do not use bullet-point dumps as the primary content of wiki notes
- Do not invent frontmatter fields not defined in this schema
- Always include `title` (matching the H1 heading) and `description` (one sentence) in every content note (`type: concept`, `entity`, `synthesis`, `source`)
