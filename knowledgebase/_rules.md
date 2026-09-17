---
author: kb-bot
created: 2026-04-09
modified: 2026-09-17
type: meta
---

# KB Agent Rules

These rules govern how any agent (LLM or script) behaves when operating in this KB. Read `_schema.md` first for the structural specification. These rules cover behaviour and decision-making.

## Agent and model configuration

This contract is provider- and model-independent. Select writing, review and
extraction roles using the user's configured harness, available models, task
quality, permissions and budget. No model family, version floor or effort level
is required by the starter. A separate review pass may be human or agent-based;
review references identify passes, not authenticated identities or proof of truth.
Never silently switch account, provider or billing surface on failure.

An unattended adapter is optional and must be configured and approved locally.
Before enabling it, define allowed queue scope, a finite duration/item budget,
checkpoint location, non-overlap, retry limits, verification and terminal failure
reporting. No scheduler, paid provider, capture lane or background worker is
enabled by installing this starter. An idle run is not a completed ingestion.

Prefer faithful coverage, attribution and useful synthesis over note volume.
Model choice and token price do not replace comparison against actual evidence.

---

## Rule 1 — Authorship Guard (Non-Negotiable)

Before writing anything:

1. Does the file already exist?
   - **Yes:** Check for `author: kb-bot` in its frontmatter. If absent, **abort**. Do not write. Inform the user.
   - **No:** Proceed to create it. Add `author: kb-bot` and all required frontmatter fields.
2. Is the target path inside `knowledgebase/`?
   - **No:** **Abort**. Do not write outside the KB root under any circumstances.

**Clippings are read-only inputs:** Files in `knowledgebase/clippings/` may be
read as user-owned source material without kb-bot frontmatter. Do not edit,
extend, move, delete or tag those originals. Record processing and the source
destination in the kb-bot checkpoint/log instead. Existing human processing
tags may be read but are not authority to modify the file. This matches the
schema and preserves the authorship guard.

This contract grants no authority to write outside these bounds. Follow the
active instruction hierarchy and stop for a specifically scoped maintenance
exception when required; do not infer broad write authority from task urgency.

---

## Rule 2 — Scoped Navigation

First determine whether the request is topic research or project/code context.
If the optional `kb-search` index is available, use it for focused discovery;
verify selected files and their dates because the cache may be stale. Otherwise
use the index/summary path below. Search results are navigation, not evidence.
For topic research or finding source-grounded information:

1. Read `_index.md` to locate the relevant topic folder
2. Read `topics/<topic>/_summary.md` to assess whether the topic contains what is needed
3. Only then read individual notes — and only the ones that seem relevant based on the summary
4. Read source notes only when tracing a specific claim to its origin

Do not bulk-load a folder. Read the matching summary and only relevant notes.

For project/code context, read `_index.md`, the relevant project `_summary.md`
and `_todos.md`, then only linked decisions, handoffs and code evidence needed
for the request (Rule 22). Do not turn project resumption into inbox, clippings
or research-queue triage unless that is also requested.

---

## Rule 3 — Always Cite Sources

Every external-source factual claim written into a research wiki note must link to at least one source note via a wikilink in the `sources:` frontmatter field or inline in the note body. If such a claim cannot be traced to an ingested source, either:
- Mark it clearly as the agent's inference: `> *Agent inference — not sourced*`
- Or omit it until a source is found

Do not present unsourced claims as established facts.

Project context has a different evidence path: code observations, test results
and recorded user decisions cite their inspected repository/commit/path,
verification artifact or dated decision/handoff under Rule 22. Do not fabricate
a `type: source` note or `origin` URL for these records. This exception does not
turn an external claim found in a README, code comment or plan into verified fact.

---

## Rule 4 — Ask Before Fetching

Before fetching any URL, downloading any file, or performing any web search:

1. Generate a complete list of what you intend to fetch and why
2. Present it to the user for approval — a checklist they can check off, reject, or modify
3. Only proceed with items the user explicitly approves
4. **Pre-fetch tracking depends on invocation pattern:**
   - **Ingestion batches** (`/kb-queue`, `/kb-auto`, or approved multi-source ingestion): add every approved item to the relevant topic `reading-list.md` **before** the first fetch, so work is recoverable mid-batch. Headless approval requires membership in that topic reading list's `## Auto-approved` section.
   - **Interactive audit/research-only examination:** explicitly approved exact
     URLs may be examined without adding ingestion queue rows. Record the target
     list and purpose in the existing checkpoint when durable audit writes are
     authorized, or in the conversation for a strictly read-only request. This
     does not authorize searching, following new links, media downloads, paid
     extraction or source publication. A selected source entering ingestion must
     subsequently use the normal approved-row and publication gates. Audit-only
     reads must not be reported as ingested or complete queue items.
   - **Single interactive ingest** (`/kb-ingest <url>` direct invocation, or a one-off URL the user types in conversation): the URL is implicitly approved-and-tracked by being provided. After the user approves saving the draft, ensure a matching topic reading-list row exists **before publication**, using `kb-capture-url.py` to add a missing URL under Pending and `kb-promote.py` to move that approved row to Approved. Verify the destination; a fallback to the global inbox is not sufficient. Then use Rule 38's publisher. This still avoids a pre-fetch placeholder if the user cancels before saving. For local/pasted inputs that lack a supported queue-add path, stop before publication and report the missing path; do not hand-edit a queue or invent an origin URL.

This rule binds all interactive sessions, including deep-dive and synthesis passes. The only carve-outs are:

- **Headless mode** explicitly authorised in a skill (e.g. `/kb-auto`) operating against unchecked URL-first or local-PDF items in a topic reading list's `## Auto-approved` section. See Rule 29 "Headless exception" in `_rules-media.md` for the media-capture variant. `_dive-queue.md` is a generated dashboard and is not an approval record.
- **Transport-level URL rewriting** governed by Rule 30 in `_rules-media.md` (mirror domains for blocked hosts). The canonical URL is what the user approves; the mirror is the operational route to it.

Any other exception requires updating this rule first.

---

## Rule 5 — Checkpoint Long Operations

Any operation that will touch more than one file or take multiple steps must:

1. Write `_checkpoint.md` at the start, recording what will be done and in what order
2. Update `_checkpoint.md` after completing each step (mark item done, note next item)
3. On completion, update checkpoint status to `complete`

At the start of any session, check whether `_checkpoint.md` exists and has status
`in-progress` or `resumable`. Resume it only when it matches the current request.
Surface a mismatched active checkpoint without resuming or overwriting it; for
authorized independent work, use a named scoped run record and cross-reference
it in the handoff. A read-only question does not authorize checkpoint writes.

---

## Rule 6 — Note Quality Standards

When writing wiki notes:

- **One concept per note.** If a note covers two distinct concepts, split it.
- **Prose, not bullets.** Notes are for humans to read. Use paragraphs with logical flow. Reserve bullet lists for enumerable items only (e.g. "three properties of X").
- **Link heavily.** Every concept that has its own note should be linked. Every source claim should cite its source note.
- **No duplication.** If a concept already has a canonical note, link to it — do not restate it.
- **LaTeX for all maths.** Inline `$...$` for expressions within text, block `$$...$$` for standalone equations.
- **Human-readable headings.** Headings should be meaningful to a reader who has never seen the KB before.

---

## Rule 7 — Corrections and Discussions

When a user flags an error or adds nuance during a conversation:

1. Locate the relevant note(s)
2. Apply the correction (checking authorship guard before writing)
3. Append the exchange to `topics/<topic>/_discussion.md` with a timestamp:

```markdown
## 2026-04-09 — Correction

**User:** [what the user said]
**Change made:** [what was updated and in which note]
```

Never overwrite `_discussion.md` — always append. The discussion log is a permanent record.

---

## Rule 8 — Uncertainty and Conflicts

When sources contradict each other:

1. Do not silently pick one. Note the conflict explicitly in the relevant wiki note:

```markdown
> **Conflict:** [[knowledgebase/topics/<topic>/sources/source-a]] claims X, while [[knowledgebase/topics/<topic>/sources/source-b]] claims Y.
> Resolution pending user input.
```

2. Add a note to `_discussion.md` flagging the conflict for the user to resolve.

When uncertain about where to place a note or what tags to assign, prefer the most specific existing topic/tag over creating a new one. If genuinely ambiguous, ask the user before writing.

---

## Rule 9 — Updating Summaries, Index, and Log

After writing or modifying any note in a topic folder:

1. Regenerate `topics/<topic>/_summary.md` to reflect the current state of the topic
2. If a new topic folder was created, update `_index.md` to include it
3. Append an entry to `_log.md` recording what operation was performed, what was created/updated, and any errors
4. Keep topic and project summaries compressed — each body must stay under 300 whitespace-delimited words, excluding frontmatter. Convey purpose, key supported findings or recorded project state, gaps and links to detail. An agent should be able to decide in one pass whether to dive deeper. Preserve useful historical detail in linked notes before compressing; a navigation refresh does not certify current source truth or live project implementation.

Summaries are navigation, not running activity logs. Keep the current purpose,
key findings, uncertainties, and links to detail; put dated history, exhaustive
media lists, and inventories in linked mutable notes or the append-only log.
When shortening an existing summary, preserve still-useful detail in a linked
note before removing it from the summary. Summary compression is not source
editing and must not change what the underlying evidence establishes.

A project summary's `modified` date is document freshness only. Keep observed
code state and the scope/date of implementation or runtime checks separate,
using the project-context contract in `_schema.md`. Do not refresh an old
observation timestamp merely because the summary was edited.

## Rule 11 — Source Notes Are Immutable (Body) — Mutable Lifecycle Metadata

Source-note body content is frozen at first write and must never be edited. It is a faithful record of what was ingested at a point in time.

The following narrow lifecycle changes are permitted after first write:

1. **Frontmatter:** add or toggle `status: deprecated` and add a `superseded_by:` wikilink. No other frontmatter fields may be edited after first write.
2. **Top-of-file banner:** insert a single blockquote immediately below the H1:
   ```markdown
   > ⚠️ **Deprecated <YYYY-MM-DD>:** <one-sentence reason>. Superseded by [[knowledgebase/topics/<topic>/sources/<replacement>]].
   ```
3. **Citing wiki notes:** update mutable wiki notes that cite the deprecated source so they reflect the correction. Those edits follow the normal authorship guard.

Deletion remains forbidden under Rule 10. The `media:` block on a source note remains frozen under Rule 29 (in `_rules-media.md`).

**Governed successor flow:** for an explicitly scoped replacement of a dated
source, use `_tools/kb-source-successor.py` with its exact manifest and independent
review receipt. It publishes the replacement without overwriting, completes the
approved queue row and applies only the lifecycle changes above. These phases
are not cross-file atomic; inspect every terminal result and resume with the
same manifest/bytes after a partial result. Ordinary publication still rejects
duplicate source identities; warning acceptance is not a successor bypass.
Version 1 is deliberately one predecessor and one replacement in the same
topic. Further lineage or rehoming requires its own reviewed flow.

**Rehoming exception:** A source note may be moved from one topic folder to a better-fit topic folder when its original topic placement was wrong or a new topic has been explicitly approved. The source-note body must remain unchanged. The only permitted edits during rehoming are path movement, `topic:` frontmatter correction, vault-rooted wikilink updates that point to the moved note or its topic-local catalog, and log/index/summary updates needed to preserve navigation. Rehoming must be checkpointed and logged, and the old path must not be left as a broken wikilink target.

**Mechanical internal-link repair exception:** A source note may have a broken, short, or stale internal wikilink target replaced only through `_tools/kb-repair-source-wikilinks.py`. The replacement must be an unambiguous vault-rooted wikilink to an existing KB note, must not alter surrounding prose, claims, quotes, source text, or media blocks, and must be checkpointed, logged, and verified with lint. This exception exists to repair navigation defects created during ingestion, not to revise source-note content.

## Rule 12 — Incremental Compilation

When integrating a new source into existing wiki notes, **append or extend** — do not rewrite from scratch. Existing content represents accumulated knowledge; overwriting it destroys that history. Additions go at the end of relevant sections or in a new section. Contradictions are flagged with ⚠️ inline, not resolved by silently replacing existing text.

Maintained project summaries, task boards and explicitly marked current-context
notes follow Rule 22's narrow maintenance flow. That is not an exception to
source immutability or permission to replace accumulated source syntheses.

---

## Rule 10 — Do Not Delete

Do not delete notes. If a note is superseded or incorrect:

- Set `status: deprecated` in its frontmatter (same canonical format as Rule 11 source-note deprecation)
- Add `superseded_by: "[[knowledgebase/topics/<topic>/.../<replacement>]]"` to its frontmatter when a successor exists
- Add a top-of-file banner blockquote explaining what superseded it and linking to the replacement, e.g.:

  ```markdown
  > ⚠️ **Deprecated <YYYY-MM-DD>:** <one-sentence reason>. Superseded by [[knowledgebase/topics/<topic>/.../<replacement>]].
  ```

Deletion destroys provenance. The note's existence — even if wrong — is part of the knowledge record.

For **source notes** specifically, Rule 11 is the authoritative spec: only `status` and `superseded_by` frontmatter changes plus the banner blockquote are permitted; the source-note body is otherwise immutable.

**Corrective deletion exception for invalid agent-created records.** Rule 10 protects valid KB provenance from casual cleanup; it is not a shield for agent-created notes that violated the schema at creation time. With explicit user approval, an agent may delete a malformed `author: kb-bot` note when all of the following are true: the note was created by an agent in violation of the KB contract, replacement provenance has been created or the original queue items have been restored for re-ingestion, inbound citations have been repaired or intentionally removed, the action is checkpointed and logged, and lint is run afterward. This exception must not be used for ordinary supersession, stale notes, or judgment calls where deprecation would preserve valid provenance.

**Independent queue URL invariant.** Every fetched URL-first or local-file reading-list row maps to one source note. Agents may process multiple rows in a batch, but they must not create date/topic batch source notes that combine independent queue rows. If lint reports multiple completed reading-list rows pointing to one source note, treat it as a repair item unless the rows are true duplicates of the same underlying source.

---

## Rule 13 — Maintain Follow-Up Queues

Whenever a rabbit hole, follow-up idea, or "worth reading" source is identified during an ingestion session:

1. Add URL-first or local-file source candidates to `topics/<topic>/reading-list.md` as unchecked items under the appropriate canonical section ladder heading — `## Pending` if not yet vetted, `## Approved` if vetted for interactive ingestion (see the section-ladder spec in `_schema.md`; only these five level-2 headings are permitted: Pending, Approved, Auto-approved, Processed, Failed — Retry). Do not also write them to `_dive-queue.md`.
2. Add prose-only rabbit holes, research questions, and investigation ideas with no exact source URL to `topics/<topic>/research-ideas.md`.
3. Tag the note (if one exists) with `rabbit-hole`.
4. Treat `_dive-queue.md` as generated/read-only output from `_tools/kb-derive-dive-queue.py`; agents and scripts must not append to it directly.

When the user asks for a list of topics for further study, read the derived `_dive-queue.md` and present its unchecked items grouped by topic. If adding a new prose idea during that session, write it to the relevant topic's `research-ideas.md`, not `_dive-queue.md`.

When a reading-list item is ingested, mark the original row `[x]` in the topic `reading-list.md` with the date and source note path using `_tools/kb-checkoff.py`, directly or through `_tools/kb-commit-source.py`. Rule 38's source-evidence gate applies; holding the lock alone is not sufficient. This is an in-place provenance-preserving mark; do not manually move the row to `## Processed`.

Marking and moving are distinct verbs over the shared write lock: `_tools/kb-checkoff.py` flips a line's checkbox **in place** (`[ ]`→`[x]/[!]/[~]/[?]`); `_tools/kb-promote.py` **moves** a `- [ ]` line between canonical ladder sections (`--from`/`--to`, e.g. `Pending → Approved → Auto-approved`). Use `kb-promote.py` for all section moves — never hand-edit the markdown to relocate an item. See `_tools/README.md` for the full endpoint reference.

---

## Rule 14 — Topic Placement and Promotion

When creating notes for concepts identified as rabbit holes or not yet fully developed:

1. **File in the best-fit existing topic** — do not create a new topic slug for a concept that fits reasonably within an existing one
2. **Flag promotion candidates** — if a note clearly *belongs* to a topic that doesn't exist yet, add `promotion-candidate: true` to its frontmatter and tag it `rabbit-hole`
3. **Promote when warranted** — when a promotion-candidate note has 2+ sources and sufficient material for its own topic, raise the reorganisation with the user before moving files
4. **Never create a new topic unilaterally** for a single-source concept — start with the best available home and revisit

This prevents topic sprawl while preserving the signal that certain areas deserve their own topic when research matures.

---

## Rule 14A — Durable Ideas Backlog

Broad side-project and inspiration-capture ideas that are not yet source-grounded research topics or active projects belong in `ideas/_backlog.md`. This file is a durable parking lot, not an ingestion queue: agents must not auto-fetch, auto-ingest, or auto-promote items from it.

When an item in `readinglist/topics.md` is checked off as routed to ideas/backlog, the original item must also be appended to `ideas/_backlog.md` under the shared KB write lock. Use `_tools/kb-checkoff.py --route-ideas-backlog` for future routed checkoffs. Do not mark a topic-interest item as "routed to ideas-backlog" unless the backlog append succeeds.

When an ideas-backlog item gains enough shape, promote it into the appropriate durable home:

1. Implementation/product ideas → `projects/<slug>/_summary.md` and `_todos.md`
2. Research domains → `topics/<slug>/research-ideas.md` or exact URLs in `topics/<slug>/reading-list.md`
3. Rejected ideas → keep the backlog item and mark it with a dated skip note

---

## Rule 16 — Check the URL Inbox

`readinglist/Links.md` is the global URL inbox. At the start of a research-ingestion or explicit inbox-triage session (not a
project-only task or unrelated read-only question):

1. Read `readinglist/Links.md` and check for unchecked items (`- [ ]`)
2. If any exist, surface them to the user:
   > "There are N unprocessed URLs in the inbox. Want to assign them to topics now, or process one?"
3. When assigning an inbox URL to a topic:
   - Add it to `topics/<topic>/reading-list.md`
   - Move it into `## Auto-approved` only when the user or an interactive agent has explicitly approved unattended headless ingestion
   - Mark it done in the inbox: `- [x] <url> — assigned to <topic> <date>`
4. Do not process (fetch/ingest) inbox items without user approval — assignment and ingestion are separate steps

Files in `readinglist/` that lack `author: kb-bot` frontmatter are user-owned — read them to surface their content, but never edit them.

---

## Rule 15 — Link Format (Non-Negotiable)

Two types of links exist and must never be confused:

- **Internal wikilinks** (cross-note navigation within the KB): `[[knowledgebase/topics/celestial-spheres/notes/concepts/ptolemaic-cosmology]]` or with display text `[[knowledgebase/topics/celestial-spheres/notes/concepts/ptolemaic-cosmology|Ptolemaic Cosmology]]`
- **External URL links** (links to the web): `[display text](https://example.com)`

**Never write `[[https://...]]` or `[[https://...|display text]]`.** Obsidian interprets this as an attempt to create a note whose filename is the URL, which produces broken links and errors.

**Never use relative paths (`../`) in wikilinks.** Relative paths do not resolve correctly in Obsidian wikilinks and produce broken links. Always use vault-relative paths beginning from the vault root:

- Wrong: `[[../../celestial-spheres/notes/concepts/florentine-neoplatonism]]`
- Correct: `[[knowledgebase/topics/celestial-spheres/notes/concepts/florentine-neoplatonism]]`

This applies everywhere — frontmatter `related:` fields, inline links, and `See Also` sections. Cross-topic links always start with `knowledgebase/topics/<topic>/` or `knowledgebase/projects/<project>/`.

Rule of thumb: if it starts with `http`, use `[text](url)`. If it is a path within the KB, use `[[knowledgebase/...]]`.

---

## Rule 17 — Relevant, Source-Grounded Stubs

Create a concept/entity stub when it helps the user navigate a material idea,
answer an identified question, or connect relevant sources. A passing name or
search-result mention alone is not enough. Include proposed new stubs in the
ingestion/synthesis write plan; source-count thresholds establish eligibility,
not a duty to create a page.

Check for an existing canonical note first. Link that note instead of creating
a duplicate or a cross-topic placeholder with no additional value. For a new
stub, preserve a source-grounded definition and source backlink; otherwise keep
the unresolved name in the source record or research ideas. Do not create a
wikilink until its target exists. List only orientation-worthy stubs in the
summary. Exact follow-up URLs use the reading list; unresolved leads use
research-ideas.md. Never write directly to the generated `_dive-queue.md`.

---

## Rule 18 — Log Failed Fetches in the Relevant Source Note and Reading List

**Before recording any fetch as failed, work the recovery ladder in Rule 35** (soft-paywall DOM extraction, Wayback Machine for dead links, flag-for-workaround). Only the cases Rule 35 cannot recover fall through to the handling below.

When a URL fetch fails (403, blank page, JS-rendered, redirect to wrong domain):

1. Note the failure in the source note of the article being written, under a **Failed sources** section:
   ```
   **Failed source:** https://example.com — reason (403 / JS-rendered / blank). Try browser PDF or direct access.
   ```
2. Add the URL as an unchecked item in the relevant topic's `reading-list.md` with a note explaining the failure and what to try
3. If a standalone source note is written to record an attempted-but-failed fetch, set `ingest_status: failed` in its frontmatter. `kb-seen.py` excludes these failure notes from dedup so the URL remains retryable. The failure paths in `kb-auto`, `kb-ingest`, and `kb-queue` must set this field whenever they create a failure source note.
4. Mark `[!]` only for **permanent** failures, where retrying the same URL is not expected to ever succeed. Examples:
   - All known mirrors have failed (per Rule 30's failure mode)
   - The page is hard-paywalled and no archival alternative exists
   - The URL returns 404/410/451 (dead, gone, or legally unavailable)
   - The host is dead (domain expired, server offline long-term)

   **Temporary** failures (transient 5xx, JS-rendering, intermittent blank responses, soft paywalls that may have an archival alternative) remain as `- [ ]` with a retry note — they are retry targets, not dead links.

This ensures failed fetches are never silently lost — they become retry targets when transient, and `[!]`-marked permanent failures when truly dead.

---

## Rule 20 — Capture KB-Ask Answers as Synthesis Notes

When a `/kb-ask` session produces useful new cross-cutting analysis, offer to save it as a synthesis note. A question or read-only query does not itself authorize durable writes. Proceed only when saving is part of the user's request or the user approves the proposed note and linked updates.

Process:
1. After answering, identify whether the answer contains novel cross-cutting analysis not already captured in any existing note
2. If yes: propose a synthesis note path (`topics/<topic>/notes/syntheses/<slug>.md`) and draft it
3. The synthesis note should stand alone — readable without the conversation that prompted it
4. Link it from the `## See Also` section of all directly relevant concept notes (append only)
5. Update `topics/<topic>/_summary.md` to include the new synthesis

The goal is to preserve useful analysis by choice, without turning every answer into duplicate KB content.

---

## Rule 19 — Outbound Vault Links (Read-Only Cross-References)

KB notes MAY contain wikilinks pointing to any file anywhere in the vault, not just within `knowledgebase/`.

**Allowed:** `[[personal-project/notes/example-character]]` inside a KB note
**Never allowed:** kb-bot writing to or modifying any file outside `knowledgebase/` (Rule 1 unchanged)

**Where to put vault references:**
- Add a `vault_refs` field to the note's frontmatter listing any outbound vault wikilinks
- Also link inline where the referenced file is mentioned (e.g. in a project-reference section)
- For entity notes with a direct counterpart in another vault folder, always add the link

**Format:**
```yaml
vault_refs: ["[[personal-project/notes/example-character]]"]
```

These are read-only pointers — navigation aids for the user browsing the vault in Obsidian. They do not grant kb-bot any write permissions over the linked files.

---

## Rule 21 — Active Cross-Topic Linking

When writing or updating any KB note, actively identify and create wikilinks to relevant notes in **other topics**, not just within the current topic.

**When to cross-link:**
- A concept in topic A has a counterpart, precursor, or descendant in topic B
- An entity appears in multiple topics (e.g. a person who spans several fields)
- A source in topic A explicitly references a concept whose canonical note is in topic B
- A synthesis note draws on material from multiple topics

**How to apply:**
1. In the `related:` frontmatter, include cross-topic wikilinks using full vault-rooted paths: `[[knowledgebase/topics/<other-topic>/notes/concepts/<slug>]]`
2. In the note body, link on first mention: `[[knowledgebase/topics/<other-topic>/notes/concepts/slug|Display Name]]`
3. If a concept note in topic A is the canonical home for something that appears in topic B, link directly to it. Create a local cross-reference note only if it adds useful topic-specific context under Rule 17; do not duplicate content.
4. When writing a synthesis note that spans topics, list all relevant topics in the frontmatter `tags` and link explicitly to notes in each

The goal: the KB is a graph, not a filing system. Cross-topic links are the edges that make it navigable as a whole rather than a collection of isolated silos.

---

## Rule 22 — Load Project Context Before Synthesis or Deep Work

Before any synthesis, deep `/kb-ask` session, or significant KB operation, **scan the Projects table in `_index.md` and load the `_summary.md` of any project that is semantically related to the topic or question at hand**.

**Why this matters:** Project summaries contain critical context that topic notes do not — recorded implementation state, design decisions, technology and remaining gaps. Read the linked evidence and its date before treating that recorded state as current. Skipping project context leads to redundant work, missed connections, and recommendations that contradict existing decisions or implementations.

**When to load a project summary:**
- The topic involves tools, plugins, or software that a project implements
- The topic involves a world, setting, or system that a project manages
- A synthesis note will produce recommendations or feature ideas that could be acted on within a project
- The user's question references a project by name or implies knowledge of one

**How to apply:**
1. After reading `_index.md`, scan the Projects table — use the Brief column (or read `_summary.md` if the brief is absent) to assess relevance
2. Read the `_summary.md` of any project with semantic overlap before beginning Phase 1 source reading
3. Treat project summaries as KB context, not as sources — cite them with `[[knowledgebase/projects/<name>/_summary]]` links, not as `[[knowledgebase/topics/<topic>/sources/...]]` entries
4. If a synthesis note produces implementation-ready ideas for a project, note it explicitly in the synthesis under a "Related Projects" section

**Project/code context is a first-class workflow.** For resumption, inspect the
project summary, active/blocked tasks and relevant dated decision or handoff.
Use `_tools/kb-project-status.py <slug>` for read-only Git metadata when a code
location exists. Its default does not execute project environments or inspect
service state; `--runtime-checks` is an explicit additional diagnostic, never
implied by a context scan. Read only the code/artifacts needed for the question.

Keep three states distinct: what was observed (with repository, commit, paths,
date and check scope), what is planned, and what is externally/deployment
verified. Missing evidence means **not verified**, not absent or complete.
Git metadata alone proves neither semantic implementation nor passing tests;
local checks prove neither deployment nor an unchanged dirty working tree.
Retain exact check outcomes, limitations and the next safe step in a linked
handoff when they matter. Record decisions with date, rationale, alternatives
and unresolved owner/gates; do not invent a decision from an old proposal.

Project summaries and task boards are maintained views. A project note marked
`context_role: current` may also receive focused current-state corrections with
dated evidence and a change explanation. Preserve useful prior decisions and
evidence in place or in a linked dated history before removing outdated detail;
do not silently erase conflicts, rewrite whole notes or delete inbound targets.
Dated `decision` and `session` records preserve history: append corrections and
supersession links. All writes retain the authorship guard; source bodies,
source-synthesis integration, `_log.md` and `_discussion.md` keep their own
immutability/append-only rules. The schema and project templates specify the
small reusable record; agent-local skills only orchestrate this shared flow.

---

## Rule 23 — Clippings Folder (Unsorted Web Sources)

`knowledgebase/clippings/` contains articles saved directly from the web by the user via Obsidian Web Clipper. These are **unsorted sources** — they have full content but have not been assigned to a topic or processed into source notes yet.

**Clipping frontmatter format** (written by Web Clipper, not by kb-bot):
```yaml
title: "Article Title"
source: "https://..."
author:
  - "Author Name"
published: YYYY-MM-DD
created: YYYY-MM-DD
tags:
  - "clippings"
```

**For ingestion or explicit inbox-triage requests**, after checking `_checkpoint.md`, check `clippings/` for unprocessed items:
1. `ls knowledgebase/clippings/` — list any files present
2. If files exist, surface them to the user:
   > "Clippings inbox: N unprocessed articles. Assign topics now, or process later?"

**Processing a clipping** means:
1. **Assign a topic** — identify the best-fit existing topic (or propose a new one)
2. **Write a source note** — create `topics/<topic>/sources/<YYYY-MM-DD-slug>.md` using the clipping's content; use the clipping's `source:` URL as the `origin:` field
3. **Update topic metadata** — `_summary.md`, `reading-list.md` (mark as processed), `_log.md`
4. **Record processing separately** — log the original clipping path and target
   source path in kb-bot `_checkpoint.md`/`_log.md`. Leave the original untouched.
   Source dedup and the processing log establish prior ingestion, not a new tag
   written into a human-owned clipping.

**Authorship note:** Human clippings are read-only under Rule 1. Normal source
validation and publication still apply; a missing supported queue-add path for
a local clipping is a stop before publication, not permission to hand-edit a queue.

---

## Rule 24 — Keep `_writing-prompts.md` in Sync

`knowledgebase/_writing-prompts.md` is the consolidated writing prompt dashboard. Whenever a `## Writing Prompts` section is added or modified in any KB note, **also update `_writing-prompts.md`** in the same operation.

**How to apply:**
1. After adding a `## Writing Prompts` section to any source note or project file, immediately open `_writing-prompts.md`
2. Add each new prompt as a bullet under the relevant theme section, in the format:
   ```
   - **[[essays/slug]]** — one sentence describing what to write
   ```
3. If no matching theme section exists, add one
4. Prompts in `_writing-prompts.md` should link to the source note they came from using the format: `**From [[knowledgebase/topics/topic/sources/note|Source Title]]:**`

This rule applies to all kb-bot operations that add writing prompts. The dashboard is only useful if it is complete — a prompt buried in a source note that does not appear in the dashboard is effectively invisible.

---

## Rule 25 — Prospects and Project Seeds

`knowledgebase/topics/<topic>/_prospects.md` is the ideas notebook for a topic — a lightweight file for collecting experiments, things to build, game ideas, todos, and anything that might eventually spin off into a full project.

**Item format:**
```
- [ ] **Idea title** — one-sentence description and reason it's worth doing
- [>] **Promoted idea** → [[knowledgebase/projects/<slug>/_summary]] — promoted YYYY-MM-DD
- [x] **Deferred/dropped idea** — brief reason
```

**Agent behaviour:**

1. **Adding an idea:** When the user mentions an experiment, thing to build, or "would be cool to" idea tied to a topic, offer to add it to that topic's `_prospects.md`. Create the file if it does not exist, using this template:

```markdown
---
author: kb-bot
created: <ISO-8601>
modified: <ISO-8601>
type: prospects
topic: <topic-slug>
---

# <Topic> — Prospects & Ideas

Ideas for projects, experiments, and things to build related to this topic.
To promote an idea to a full project, ask the KB bot — it will create the project summary and link it here.

## Ideas

## Promoted

## Deferred
```

2. **Surfacing prospects:** When working in a topic that has `_prospects.md`, surface open items (`- [ ]`) at the start of the session alongside clippings and reading-list items.

3. **Promoting a prospect to a project:**
   a. Create `knowledgebase/projects/<slug>/_summary.md` with `status: prospect` in frontmatter
   b. Mark the item in `_prospects.md`: change `[ ]` → `[>]` and append `→ [[knowledgebase/projects/<slug>/_summary]] — promoted <date>`
   c. Add the new project to the `## Projects` table in `_index.md` (note status as "Prospect" in the Brief column)
   d. Append to `_log.md`

4. **Visibility:** `_index.md` maintains a `## Prospects` section listing all topics that have `_prospects.md` files with at least one open item.

---

## Rule 26 — Catalog Files

Catalog files (`type: catalog`) are living inventories of a project's content instances — cards, creatures, mechanics, levels, items, abilities, or any other enumerable game/software entity. They complement entity spec notes (which define the data contract) by capturing the full set of instances in natural language, organised by implementation status.

**When to create a catalog:** When a project has 5+ instances of a recurring entity type (cards, creatures, items, levels), create a catalog for that type.

**File location and naming:** `projects/<slug>/notes/catalogs/catalog-<entity-type>.md`  
Use the canonical template at `knowledgebase/_templates/catalog.md`.

**Required sections (in order):**

1. `## ✅ Implemented` — entries that exist in the codebase/seed data and function correctly.
2. `## ⚠️ Needs Adjustment` — entries that exist but have known bugs, balance problems, missing features, or design gaps.
3. `## 💡 Ideas — To Add` — a free-form jotting area for future content.

**Entry format:** Each entry is a level-3 heading with the entity name. Include its ID in backticks, one-line natural language summary, and any design notes worth capturing. Do not just repeat field values — explain what the entity *does* and how it *feels* to play against or use.

**Maintenance:** Update catalog files whenever entities are added, changed, or removed.

**Template:** `knowledgebase/_templates/catalog.md`

---

## Rule 27 — Project Notes Subfolder Convention

When a project's `notes/` folder grows beyond approximately 10 files, reorganise into semantic subfolders rather than leaving it flat.

**Standard subfolders for game/software projects:**

| Subfolder | Contents | Naming convention |
|---|---|---|
| `entities/` | Data contract specs for named entity types | `entity-<name>.md` |
| `catalogs/` | Living inventories of content instances | `catalog-<entity-type>.md` |
| `impl/` | Technical implementation notes, architecture sketches, integration details | any |
| `design/` | Design documents, phase plans, roadmaps, todo lists | any |

Not all subfolders are required for every project. Create a subfolder only when it will hold 3+ files. A flat `notes/` folder is correct for projects with fewer than ~10 notes.

**When adding subfolders:**
1. Move files into the appropriate subfolder
2. Update all wikilinks in `_summary.md` and every note that references moved files
3. Update any external files (e.g. `CLAUDE.md` paths) that reference the old note paths
4. Append an entry to `_log.md` recording what was reorganised and why

---

## Rule 28 — Project Task Boards (`_todos.md`)

Every project folder (`projects/<slug>/`) must contain a `_todos.md` at its root. This is the canonical, human-editable task board for the project.

**File location:** `projects/<slug>/_todos.md`  
**Template:** `knowledgebase/_templates/project-todos.md`

**Structure:**

```
## 🗂️ Backlog        — not started; subdivided by Features / Bugs / Design Decisions / UX & Polish / Infrastructure
## 🔄 In Progress    — actively being worked on; each item should have a brief status note
## 🧪 Testing/Review — implemented but not yet verified end-to-end
## ✅ Done           — completed; keep entries with dates for project history
```

**Status markers (used inline in list items):**
- `[ ]` = backlog
- `[~]` = in progress
- `[?]` = needs testing or review
- `[x]` = done (include completion date in parens)
- `[!]` = blocked (include the blocker inline)

**Agent behaviour:**

1. **On project init** (`/kb-project-init`): create `_todos.md` from the template. Seed obvious backlog items from the project brief.
2. **On task completion** (KB update at session end): move the relevant item to `## ✅ Done` with today's date. Do not delete Done entries.
3. **On discovery of new work**: add it to the appropriate Backlog category immediately.
4. **On project summary scan**: surface any `[~]` (in progress) and `[!]` (blocked) items alongside the `_summary.md` content.
5. **Do not** move items to Done unless the user or a confirmed implementation verifies the work is actually complete.

Link the relevant dated handoff/check artifact when completion depends on code
verification. A recent summary date, clean Git status or completed plan is not
completion evidence. Section headings may use the template's `Testing / Review`
spacing and emoji; the four semantic sections and status markers are canonical.

**Note for users:** `_todos.md` is also yours to edit directly. The agent will respect your edits and never overwrite content you have added.

---

## Rules 29 & 30 — Media and Web Host Mirroring → see `_rules-media.md`

Rule 29 (Media Capture and Enrichment) and Rule 30 (Web Host Mirroring) have moved to `_rules-media.md`. Load that file only when a source carries (or might carry) media, or when fetching from a host that needs mirroring (e.g. `x.com`). This keeps the startup-prelude reads for core ingestion skills lean.

---

## Rule 31 — Telegram-Origin Capture Entries

kb-feed may write capture entries submitted through the user's configured Telegram group into KB queue files, provided all of these conditions are true:

1. The message came from the configured allowed chat and an allowlisted Telegram user.
2. The target lane was resolved from a persisted `message_thread_id -> topic_slug` mapping.
3. Any URL passed kb-feed validation and normalization before being written.
4. Every written line carries the standard Telegram annotation:

```markdown
- [ ] <item> — (via Telegram #<thread>, YYYY-MM-DD)
```

When the Telegram message includes both a URL and surrounding note text, kb-feed may preserve that note in the queue line:

```markdown
- [ ] <url> — <note text> — (via Telegram #<thread>, YYYY-MM-DD)
```

Lane behaviour:

1. **Mapped topic URL:** Append the URL to `topics/<topic>/reading-list.md` only. By default, append under `## Pending`; do not automatically mirror ordinary topic URLs into `_dive-queue.md`.
2. **Mapped topic URL with trusted-lane auto-approval:** kb-feed may append the URL under `## Auto-approved` only when the lane configuration explicitly sets `auto_approve = true`, the message came from the configured allowed chat and an allowlisted Telegram user, the message thread maps to the topic, the normalized item is URL-first, and URL validation/normalization succeeded. Text-only items are never auto-approved. Default lane behaviour is `auto_approve = false`.
3. **Mapped topic text without a URL:** Append the text to `topics/<topic>/research-ideas.md` under that topic as a research idea, follow-up, or project seed. This creates an investigation target, not a fetched source.
4. **`unfiltered` URL:** Append the URL to `readinglist/Links.md`, the global URL inbox. This is for URLs that do not yet have a confident topic assignment.
5. **`inspiration-capture` text:** Append the text to `readinglist/topics.md`, the broad topic-interest inbox. Later triage may propose one or more topic-specific research ideas, but the capture itself stays broad.
6. **Unmapped thread:** Do not append anything to KB markdown. kb-feed may record the event in its own local SQLite state and reply asking for a mapping.

This rule does not authorize fetching Telegram URLs, searching the web, downloading attachments, or processing non-text attachments. It also does not relax Rule 1: kb-feed may only write files with `author: kb-bot` frontmatter. A Telegram-origin item becomes pre-approved for headless ingestion only when it is intentionally placed in a topic reading list's `## Auto-approved` section under the trusted-lane rule above; ordinary topic reading-list entries and global inbox entries still follow the normal assignment and ingestion rules.

---

## Rule 31A — Capture-to-Triage Precedence

Capture and triage are separate decisions. A capture preserves the user's
original text, any URL, lane/thread provenance, and surrounding intent. It does
not by itself assert relevance, topic or project ownership, source quality,
fetch approval, ingestion approval, or synthesis readiness. Rule 31's explicit
trusted-lane Auto-approved exception remains unchanged. An embedded URL remains a
lead; retaining it is not permission to fetch, search, or download.

When a captured item is later reviewed for relevance, apply this precedence:

1. **Existing topic first.** Route to the best-fit existing topic whenever one
   is reasonably plausible. Propose a new topic only when no existing topic is
   a plausible home and there are (or are expected to be) 3+ sources, as in the
   schema's topic-placement threshold. New-topic creation and any rehoming
   remain explicit review decisions; do not create a topic merely because a
   capture is interesting.
2. **Classify the prose intent.** A question, research lead, or unresolved
   investigation belongs in `topics/<topic>/research-ideas.md`. A broad or
   still-unshaped idea belongs in `ideas/_backlog.md`. An experimental project
   seed belongs in the topic's `_prospects.md` under Rule 25. An approved,
   concrete project belongs in the existing project's `_summary.md` and
   `_todos.md`, or in a newly approved project's corresponding records. Do not
   promote a broad idea or an experimental seed to a project without the
   corresponding review and scope decision.
3. **Preserve URL context and queue separately.** Keep the original capture text
   as context/annotation when an embedded URL is routed. If the URL is a source
   candidate, deduplicate it first, then add it to the chosen topic's
   `reading-list.md` under `## Pending` with `kb-capture-url.py`; use
   `kb-promote.py` for an existing row that is being advanced. Rule 16's global
   inbox assignment uses the same guarded queue tools and checkoff path. These
   routing writes do not fetch the URL or promote it to `Approved` or
   `Auto-approved` implicitly.
4. **Keep source gates separate.** Relevance routing is not source approval.
   Pending items still require the normal interactive approval before fetch and
   publication; `Approved` and `Auto-approved` retain their distinct
   interactive/headless meanings. A routed idea or URL is never an ingested
   source until the Rule 4, section-ladder, validation, and publication gates
   succeed.
5. **Use a manual handoff until a machine ledger exists.** After source
   publication and its guarded queue receipt, record the topic, source-note
   path/hash, and whether synthesis remains pending in the operation checkpoint
   and log. Source-and-queue completion, or a checked-off row, does not mean
   synthesis is complete; invoke `/kb-synthesise` separately and apply its plan
   approval and action-disposition rules. This subsection governs reviewed
   triage only and does not add capture-lane behavior not specified in Rule 31.

---

## Rule 32 — Long-Form Source Library

`knowledgebase/_library/books/` is the canonical custody area for raw long-form source files such as local PDFs, EPUBs, scanned books, and article-length dumps that are intentionally brought into the KB workflow. `knowledgebase/_library/docs/` is the equivalent custody area for non-book PDFs, reports, schedules, reference documents, and similar local source files.

Raw files in `_library/books/` and `_library/docs/` are not source notes and are not themselves the citation surface for synthesized KB claims. Topic source notes remain Markdown files under `topics/<topic>/sources/`; they should cite the original URL or local file path in `origin:` and summarize only the portion that was actually ingested for that topic. If a book or document supports multiple topics, keep one raw custody file in `_library/` and create separate topic-specific source notes or extract notes as needed.

Binary files under `_library/books/` and `_library/docs/` are exempt from `author: kb-bot` frontmatter because they cannot carry YAML. **Raw text-extraction dumps of those binaries — OCR output (`*.ocr.md`), `pdftotext`/`markitdown` dumps, and similar machine-generated extraction payload — are likewise exempt: they are the text equivalent of the custody binary, not notes or control files.** The distinguishing convention is the `_` prefix: only `_`-prefixed Markdown **control** files in `_library/` (`_README.md`, `_ledger.md`, and the root `source-custody-index.md`) require normal kb-bot frontmatter; non-`_`-prefixed Markdown under `_library/books/` and `_library/docs/` is custody payload. `_tools/kb-lint.py` enforces this split. Do not duplicate raw sources into topic folders or `_media/`; `_media/` is for captured images, video, and audio attached to source notes.

Agents must preserve custody history when moving files into `_library/`: record the prior path when known, update queues/catalogs to the canonical KB path when those files are mutable, and keep extraction status separate from custody status. A source being stored in `_library/` means "available for pipeline use," not "fully ingested."

**Retention of spent extraction dumps.** Raw text-extraction dumps (`*.ocr.md` and similar OCR / `pdftotext` / `markitdown` output) are disposable intermediates, **not** durable KB content — the durable products are the extracted Markdown source notes under `topics/<topic>/sources/` and the retained binary in `_library/`. Once a dump's content has been extracted into source notes (and any quality-driven re-OCR refresh is complete), the dump **may be deleted** to control bloat. This is an explicit carve-out from Rule 10 (which protects notes, not payload): deleting a spent extraction dump destroys no provenance, because the binary remains for re-OCR and the extracted notes remain as the citation surface. When deleting one, update the relevant `source-custody-index.md` row from "extraction pending" to the extracted source-note link, and note the dump was removed as a spent intermediate. Do not delete a dump whose extraction is still in progress (further batches planned) or whose binary is not retained.

Raw books, licensed PDFs, and private source documents are local KB contents. They must not be added to GitHub forks, public starter/skeleton repositories, or GitLab mirrors unless the user explicitly approves a sanitized subset and redistribution is lawful. Derived Markdown source notes, extraction notes, syntheses, schemas, and tooling may be pushed when otherwise appropriate. The raw payload directories under `_library/books/` and `_library/docs/` should be pushed unpopulated: keep README placeholders and directory conventions, but do not track private source files.

---

## Rule 33 — Referenced-Source Discovery

When ingesting a source, the agent must look past the source itself for the **primary material it points to**, and turn those pointers into ingestion candidates. This applies to all sources, but is especially load-bearing for short social posts (tweets) that gesture at studies, papers, or institutions without linking them. References arrive in three forms:

1. **Linked references** — the source contains an actual URL to external material (an NIH page, a journal article, a dataset, a "methodology"/"download" control). These are handled by the existing companion-page / same-context expansion in `kb-ingest` and `kb-queue`. No change.
2. **Named-but-unlinked references** — the source *names* a study, paper, author + year, journal, dataset, institution, or report in prose but does not link it.
3. **Image-borne references** — the source carries an **image of** a journal page, abstract, paper, figure, table, or cover. Use the media OCR + vision pipeline (Rule 29) that already ran on the captured image to extract identifying metadata: title, author(s), journal, and especially **publisher**. Publisher identification is an explicit aid to resolution. Treat the extracted citation as a named reference.

**Resolution.** Reference-resolution web search is itself a **Rule 4 action**, not a free discovery pass: first present the list of detected references to the user and get approval to resolve them (headless agents skip resolution entirely — see below). For each approved reference, search for a canonical URL in this preference order: an **open-access / freely-readable** canonical copy → DOI / publisher landing page → PubMed / PMC → arXiv or other preprint → an authoritative author or institutional copy → a reputable secondary host. **Queue the most freely-readable canonical candidate** as the reading-list entry; when the canonical record is paywalled, queue the open-access copy and keep the DOI/publisher URL beside it as the citation anchor. If two candidates rank equally, queue the open-access one and annotate the alternative. **Fetching** the resolved source is a separate Rule 4 approval via the normal reading-list flow.

**Deduplicate and cap (explosion guard).** Before adding any resolved candidate, dedup it: run `_tools/kb-seen.py --check <url>` for URLs, and check the target reading-list / ledger for an existing title or author + year match; skip anything already ingested or already queued. Cap discovery per source at a sane volume (default: the **20 most relevant** references). If a source's bibliography exceeds the cap, queue the top-N and record the remainder as a single `research-ideas.md` note ("N further references in `<source>` — expand on request") rather than flooding `## Pending`.

**Routing of results:**

- Article / paper / dataset / report → the topic `reading-list.md` `## Pending` section, annotated `— referenced by [[<source note>]] (resolved via search YYYY-MM-DD)`.
- **Book** → the book ledger (Rule 34) `## Wanted` (or `## Proposed` once a URL is found), **not** the reading list.
- A reference that cannot be resolved to a URL after a reasonable search → a prose entry in `topics/<topic>/research-ideas.md` ("references `<citation>`; could not resolve to a URL"), so the lead is preserved rather than lost.

**Headless mode.** `/kb-auto` and other unattended agents must **not** run resolution searches (Rule 4 no-expansion). Preserve named-but-unlinked article/paper references in `research-ideas.md`, and books in the ledger `## Wanted` (Rule 34), annotated `— unresolved reference, needs interactive resolution`. Already exposed exact URLs may be captured to `reading-list.md` `## Pending` through the shared tool without fetching them. They never web-search headlessly, and the same dedup/cap applies.

**Tooling.** Reference resolution should be performed through `_tools/kb-resolve-reference.py` (web search → ranked candidate URLs with a primary/secondary/low-value label) so the judgment is reproducible across agents rather than re-encoded in each skill's prose.

---

## Rule 34 — Book Acquisition Ledger

Books referenced by sources (or surfaced during research) are tracked through an explicit acquisition **lifecycle**, separate from raw custody. The lifecycle ledger is `_library/books/_ledger.md` (`type: meta`, `author: kb-bot`). It is distinct from `_library/source-custody-index.md`, which remains the record of **file paths and relocation history**; the two cross-link. The ledger has four canonical sections:

| Section | Meaning |
|---|---|
| `## Wanted` | Referenced or research-identified; not yet in hand. No legitimate source URL found yet. |
| `## Proposed` | One or more legitimate candidate source URLs found; awaiting the user's approval to download. |
| `## Acquired` | File downloaded into `_library/books/<cluster>/`; extraction into source notes pending. |
| `## Ingested` | Extracted / synthesized into the KB; links to the topic source note(s). |

Entry format (Wanted / Proposed):

```markdown
- [ ] **<Title>** — <Author(s)>, <year>. Referenced by [[knowledgebase/topics/<topic>/sources/<note>]].
      Proposed: [Publisher](https://...) · [archive.org](https://...) · [Open access](https://...)
```

**Acquisition workflow — search and propose, never auto-pull from shadow libraries:**

1. A book reference is detected (Rule 33) → **dedup first** (match by title and author + year against all four ledger sections); if the book is already tracked, append the new referencing source to the existing entry rather than creating a duplicate. Otherwise add it to `## Wanted` with bibliographic metadata and which source referenced it.
2. The agent web-searches for a **legitimate** source — publisher store/sample, `archive.org`, an open-access PDF, or a library — records the clickable candidate URL(s), and moves the entry to `## Proposed`.
3. **Approval protocol (explicit, single-candidate).** The user approves exactly one source per book — either by running `_tools/kb-book-ledger.py --approve "<title>" --url <chosen-url>` or through an installed UI that explicitly supports the same approval contract. The agent then downloads **only the approved URL** into `_library/books/<cluster>/`, moves the entry to `## Acquired`, and records the file in `source-custody-index.md` per Rule 32. The agent never downloads without an explicit per-book source selection. `<cluster>` is a deterministic subject slug: reuse an existing `_library/books/<cluster>/` grouping when one fits, otherwise use the referencing topic's slug.
4. After extraction / synthesis → move the entry to `## Ingested` with links to the resulting source note(s).

Shadow libraries (z-lib and equivalents) must **never** be auto-pulled; the agent may surface such a link only if the user explicitly asks. Any pre-existing shadow-library copy in custody is grandfathered and is not a precedent.

**Tooling.** Mutate the ledger only through `_tools/kb-book-ledger.py` (holds `.kb-write.lock`, atomic write, add / move-between-sections) — the same contract pattern as `kb-checkoff.py` / `kb-promote.py`. Do not hand-edit the ledger.

The proposed URLs are reviewable links in the ledger. Dashboard support is
optional; do not claim a dashboard action is available unless the installed
version implements it. The ledger helper records approval but does not download.

---

## Rule 35 — Gated and Dead-Source Recovery

This rule extends Rule 18 with approved alternate-host or archive recovery and
interactive reading through the active harness's available browser. Browser tools
are optional; do not install another harness or change accounts to force recovery.
Unavailable recovery is a recorded limitation, not permission to evade access controls.

**35a — Soft-paywall / masked content (DOM extraction).** When the article text is **present in the rendered DOM** but hidden behind a *client-side* mask — an overlay, a reader-gate, a truncation-with-fade, a "subscribe to continue" div layered over full text — extract the underlying text from the rendered DOM (reader-mode / document-text extraction via the headed browser) before declaring a paywall failure. This recovers content the server already delivered to the browser. It does **not** extend to defeating *server-side* access control, authentication, or content the server withholds until payment: those are genuine paywalls — stop and ask the user for a PDF or pasted text (Rule 18 behavior unchanged). **When in doubt whether a gate is client-side or server-side, treat it as server-side and stop.** Every 35a extraction must be **user-auditable**: log it to `_log.md` with the URL and gate type. It is never applied silently in headless mode (see the headless clause).

**35b — Dead link → Wayback Machine.** When a URL is dead (404 / 410 / 451 / dead host / domain expired), query the Wayback Machine (`web.archive.org`) for a snapshot. If a usable snapshot exists:

- Create the source note **for the original (dead) URL** — `origin:` is the dead URL, so dedup and provenance stay anchored to what the source actually cited.
- Populate the note body from the **Wayback snapshot** content.
- Record the snapshot: insert a banner blockquote immediately below the H1 — `> ♻️ **Recovered <YYYY-MM-DD>:** original URL is dead; content recovered from the Wayback Machine snapshot at <wayback-url> (captured <snapshot-date>).` — and keep the Wayback URL in the body for reference.
- This is a **successful** ingest: set `ingest_status: succeeded`. It is not a Rule 18 failure.

If no snapshot exists, fall through to Rule 18's permanent-failure (`[!]`) path.

**35c — Flag for workaround.** Any other situation where the desired content does not return — a novel block type, a JS-only data view, a captcha wall, an anti-bot interstitial with no archive — must be **flagged for an automated workaround to be designed**, not silently dropped. Append an entry to `_tools/fetch-workarounds.md` (`type: meta`, `author: kb-bot`) recording the URL, the symptom, what was already tried, and the date. Each flag carries a **status**: `open` → `resolved` (a later recovery succeeded — close the flag and link the source note) or `wontfix` (ruled out by the user — the reading-list item then becomes a Rule 18 `[!]` permanent failure). When a later interactive 35a/35b recovery succeeds for a flagged URL, **close its flag** (cross-clean). Flags that stay `open` longer than 90 days are surfaced as stale for a keep/wontfix decision. The dashboard surfaces open and stale flags. The source remains a retry target (`- [ ]`) in its reading list, not a permanent `[!]`, while its flag is `open`.

**Headless mode.** `/kb-auto` may use 35b (Wayback) automatically for dead links and may write 35c flags, but must **not** attempt 35a soft-paywall DOM extraction unattended (interactive-only) — it records such cases as 35c flags instead.

---

## Rule 36 — Wikipedia and Citation-Index Sources

This rule was previously encoded only in the `kb-ingest` / `kb-queue` / `kb-auto` skills. It is lifted into the contract so that **any** agent operating from `_rules.md` alone — including non-Claude LLMs with no skill tree — applies it identically.

**Wikipedia articles are citation indexes, not sources of record.** When a Wikipedia URL is to be ingested:

1. Fetch the article **only** to extract its references, external links, and cited-source bibliography.
2. Dedupe the cited URLs and **label each by validity**: prefer **primary sources** (DOI / journal / primary documents / official data); accept reputable secondary sources; **flag blog / SEO / low-authority sources as low-value**; when authority is genuinely undeterminable, label the citation `uncertain` and still present it. Mark dead or paywalled-with-no-archive citations for Rule 35 recovery rather than discarding them. Annotate each queued cited source `— via Wikipedia <article-url> (discovered YYYY-MM-DD)` so the discovery chain is reproducible without writing a Wikipedia source note.
3. Present the labeled list for approval (Rule 4) before fetching any cited source. For heavily-cited articles, surface the **top ~20 by prominence** first with a "show all" option rather than dumping a 200-entry bibliography; the same Rule 33 dedup/cap applies.
4. Ingest approved cited sources as ordinary source notes. Preserve non-fetchable bibliographic citations in `research-ideas.md`; books route to the Rule 34 ledger. Do not put prose-only citations in URL/file ingestion queues.
5. Do **not** create a source note for the Wikipedia article itself unless the user explicitly asks. Keep the Wikipedia URL only as discovery provenance or a reading-list parent.

`/kb-auto` and other headless agents defer Wikipedia URLs in `## Auto-approved` (mark `[?]` with note "Wikipedia citation discovery needs interactive review") — citation discovery and validity labeling are interactive tasks. This is not a permanent fetch failure. A later approved interactive retry may restore `[ ]` through `kb-checkoff.py --from-mark '?' --repair-uncheck` before processing.

This same "citation index, not source of record" posture applies to any aggregator page whose value is its bibliography rather than its own prose.

---

## Rule 37 — Defensive AI Red-Team Sources

Sources about jailbreaks, prompt obfuscation, guardrail bypasses, exploit payloads, or adversarial model behavior may be ingested when they improve the user's defensive understanding, but they must be handled as **defensive evaluation material**, not as operational bypass playbooks.

When ingesting or synthesizing these sources:

1. Capture the high-level finding, threat model, tool category, and defensive implication.
2. Avoid preserving unnecessary step-by-step bypass payloads, exploit strings, or instructions for evading third-party safeguards.
3. If exact prompts or transformed payloads are needed, store them only as scoped eval fixtures for user-owned systems, local harnesses, private skills, or explicitly authorized security targets.
4. Queue linked red-team tools or payload generators as companion sources for interactive review before fetching, installing, or exercising them.
5. State the safe operationalization plainly: run controlled tests, record traces, patch the scaffold/guardrail/tool policy, and rerun the eval.

This rule does not block legitimate security research. It keeps the KB useful for improving prompts, skills, harnesses, and tool policies while avoiding a durable repository of instructions for attacking unrelated systems.

---

## Rule 38 — Pre-Write Validation and Evidence-Safety Gate

Before committing a new source note or media-description note, agents must run `_tools/kb-validate-source-candidate.py` on the staged candidate. The validator is read-only and exists to catch structural/provenance defects before a source note becomes immutable under Rule 11. Validate the intended destination with `--staged-text` and `--candidate-path`; validating a temporary file alone does not establish permission to write the destination.

Blocking validator findings abort writes in both interactive and headless runs. Checkpoint/log the item and leave it incomplete. Review warnings and record a source-specific acceptance reason before proceeding; do not use blanket warning acceptance. `_tools/kb-seen.py` remains the required dedup gate before fetch.

For a new approved topic source, use `_tools/kb-commit-source.py` to publish the validated staged note without overwriting an existing source, then complete its queue row through the guarded checkoff. It does not fetch, run a model, update summaries/index/log, or commit to Git. `SOURCE_AND_QUEUE_COMPLETE` describes only those two artifacts, not completion of the whole ingestion workflow. `SOURCE_WRITTEN_QUEUE_PENDING` requires reconciliation or an identical-file retry; never assume a rollback or overwrite the note.

**Recorded review gate.** Publication and direct topic-source completion both
require `--review-receipt` pointing to a canonical immutable artifact created
by `kb-review-receipt.py`. The shared completion gate checks exact draft bytes,
candidate path, queue path and primary locator, verifies retained evidence
references, and requires a publish disposition with distinct writer/reviewer
references. Revalidate before publication and under the write lock. Pasted
receipt text, warning acceptance and an existing source wikilink cannot replace
the artifact. Writer/reviewer references are operator assertions of separate
review passes, not authenticated identities or independent proof of truth.

Coverage and retention are separate: a useful partial record needs explicit
covered material, omissions and an evidence boundary. Privacy/copyright limits
may prevent retention; record that limitation and do not claim a reproducible
snapshot. Never store restricted material merely to satisfy this gate. A
reproducible extraction is not automatically a complete source. Existing
completed rows remain historical; any new completion requires review, including
an older source being checked off now. Repair-uncheck remains available without
a review and removes completion annotations; it cannot create completion.

Topic reading-list `[x]` checkoffs require an existing, valid, non-deprecated successful source whose canonical `origin:` matches the row's primary locator, directly or through the schema's governed exact URL-alias registry. Supply `--source-note` or one canonical source wikilink in `--note`; warnings require `--accept-source-warnings` with the reviewed reason. The checkoff records a source path and SHA-256 hash. This receipt proves the checked file's structural validity and locator identity at that time, not factual fidelity, complete coverage, or human approval. Global inbox routing and idea-backlog checkoffs are not source-ingestion completion and do not require this receipt.

The staged validator parses YAML frontmatter structurally (including nested `media:` lists), requires canonical `origin:` plus transport `mirror:` where Rule 30 applies, and blocks generic social metadata, source-note agent inference, missing source/evidence sections, and incomplete source-media mappings. Every source-media item must carry `id`, `kind`, `status`, `origin_url`, and `license`; captured entries additionally require a path, capture date, and media-description link, while intentionally skipped entries require a reason. Health candidates require an explicit, source-specific boundary saying what clinical or practical conclusion the material does not establish.

**Source-quality review before publication.** Compare the draft with the actual
retrieved material, not with another agent's summary. Check material claims,
numbers/units, methods, qualifiers and limitations; preserve the difference
between author claims, direct evidence and KB inference. Use `## Content Map`
for dense/multipart sources to account for substantive sections, including
deliberate omissions and their reasons. A short source needs a proportionate
record, not padding. Every successful source needs `## Source-scoped Record`
and `## Evidence Boundary`. Missing central text, figures or transcript makes
coverage partial: identify the missing channel and do not infer its contents
from a caption, thumbnail, OCR fragment or page title. If the missing channel
prevents a useful faithful record, defer publication.

For structured X/FxTwitter retrievals, inventory the full returned payload with
`_tools/kb-fxtwitter-extract.py` before drafting or reviewing. Inspect its root,
same-author continuation, quote, nested-article, media and link channels; an
empty `text` field is not an empty source. Missing, empty and malformed are
different states. Do not merge other authors or quoted material into the focal
author's claims, and do not infer complete thread coverage from the returned
entry count. The inventory is an extraction aid, not a fetch or retention grant,
and does not replace comparison with the actual returned material.

The integrated fetch path is `kb-tweet-fetch.py <approved-locator> --inventory
status` or the explicitly selected `--inventory thread`; it invokes that parser
before compaction. Its legacy compact output is convenience-only, and `--out`
is retired. One selected response, its digest and channel inventory do not
establish full-thread coverage, durable raw-byte custody or canonical source
approval. Existing preflight, retention and retry limits still apply.

Weak or disputed claims can be relevant source records when faithfully
attributed and clearly bounded. Lack of independent proof alone is not a
reason to erase an approved capture or mislabel it inaccessible. Defer when
missing central material prevents a useful record; route established topic
relevance separately from evidential strength and project readiness.

Inspect relevant exposed links and named citations under Rules 33/36. Record
whether deeper examination is necessary to understand the claim, useful as a
companion, or irrelevant; queue or record the lead in its correct destination.
Discovery is not permission to fetch it. Put the source author's content in the
source record; put user-specific relevance, proposed actions and agent
inference in mutable wiki/project notes or the review handoff. For fidelity
trials, give an independent reviewer the retrieved material and draft, then
record concrete discrepancies and their disposition before publishing.

For reproducible fidelity trials, retain the exact permitted extraction through
`_tools/kb-retain-evidence.py` and record its returned path/digest in the mutable
review record. Give the same artifact to writer and reviewer. Preserve origin,
transport, retrieval time, evidence channel, extraction scope and omissions.
Retain only content whose privacy/copyright posture permits storage; the tool's
approval flag is an assertion of actual authority, not new permission. If exact
evidence cannot be retained, state that limitation and do not claim reproducible
snapshot review. A new retrieval is a new observation, not recovery of an old
snapshot. Hash verification establishes byte identity, not source truth or full
coverage. Do not retrofit new metadata into immutable historical source notes.

Synthesis and mutable wiki-note work must also follow the evidence-safety guidance in `_rules-synthesis.md`: source-scope claims, cite source notes, mark KB inference explicitly, and apply domain-specific safety boundaries. Load `_rules-synthesis.md` before `/kb-synthesise`-style work or any health, financial/trading, atmospheric/forecasting, home-improvement, or model-routing synthesis.

Correcting a bad immutable source note remains governed by Rule 10 and Rule 11 — this rule grants no new edit or override authority over source-note bodies. The purpose of this gate is prevention: block a bad immutable note before it is written, so correction is rarely needed. When correction is unavoidable, prefer in order: (a) `status: deprecated` plus `superseded_by:` and the deprecation banner under Rule 11; (b) a companion media-description note, successor source note, or mutable wiki note that records the corrected interpretation; (c) the mechanical repair tools already named in this contract, such as `_tools/kb-repair-source-wikilinks.py`, or Rule 10's corrective-deletion exception for malformed `author: kb-bot` notes. Any repair is checkpointed, logged, minimal, re-linted, and must never alter source prose, claims, quotes, or `media:` blocks. A user-approved repair of a specific agent-created structural/provenance defect authorizes only the narrow mechanisms above; it does not create a general power to edit source-note bodies.
