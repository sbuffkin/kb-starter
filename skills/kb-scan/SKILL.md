---
name: kb-scan
description: Read-only orientation for a configured knowledge base. Uses the indexed kb-search flow when available, then selectively loads relevant summaries and evidence for a project or topic without writing to the vault.
---

You are performing a focused, read-only KB scan to orient yourself before
starting work. Do not turn this scan into ingestion, publication, queue
promotion, or project implementation.

## Configuration

At startup, read `references/kb-core.md` and resolve `KB_ROOT` using the
portable order described there. `VAULT_NAME` is optional and is needed only for
Obsidian deep links. Do not print config contents. If no root is available, ask
the user for an explicit root or config path.

**Task / topic:** $ARGUMENTS

---

## Scan Procedure

### Step 1 — Search by keyword (primary)

Run the indexed `kb-search` command with keywords from the task description
when it is installed:

```bash
kb-search --query "$ARGUMENTS" --limit 10
```

If `$ARGUMENTS` contains a recognizable KB topic slug (for example, the
topic named in the request), also run a topic filter:

```bash
kb-search --topic "<slug>" --limit 10
```

`kb-search` reads only the frontmatter cache (`_kb-index.json`) — it does NOT open note files. The compact output (title + tags + description) is enough to judge relevance without loading full content.

Pass the resolved root through the command's supported `--kb-root` option (or
the `KB_ROOT` environment variable) when the runtime needs an explicit path.
If `kb-search` is unavailable or its index cannot be used, fall back to a
narrow `rg`/filesystem lookup under the resolved root; do not bulk-read the
vault or invent a replacement index. Report that the fallback was used.

### Step 2 — Selective deep-read (1-3 files max)

From the results, pick the 1-3 notes with the highest relevance. Read ONLY those full files. Prefer:
- `_summary.md` of a matching topic or project (for broad context)
- A specific `notes/impl/plan-*.md` or `notes/concepts/*.md` that directly addresses the task
- Skip notes you already have in context this session

### Step 3 — Check project impl-plans (if project-relevant)

If the task relates to a project, run the indexed lookup:

```bash
kb-search --topic "<project-slug>" --type impl-plan --limit 5
```

Read the most relevant impl-plan if one exists.

---

## Output Format

Produce a terse oriented briefing. Do not pad or narrate the scan. Format:

**Relevant topics:** [comma list, or "none"]

**Relevant projects:** [comma list, or "none"]

Then for each match, a short block:

> **[Topic or Project name]**
> - Key facts or constraints directly applicable to the task
> - Open questions or prior decisions that matter
> - Any notes worth reading (title + path)

**From the research queue:** only check `_dive-queue.md` for exploratory research tasks, not implementation.

If nothing in the KB is relevant, say so plainly: "No KB entries relevant to this task."

## Project evidence boundary

For project/code work, separate:

- **Observed:** repository/code evidence actually inspected, including the
  repository identity, commit, paths, and checks that were run.
- **Planned:** intended work or next steps from project records.
- **Externally verified:** deployment/runtime or other outside-state evidence;
  use `not verified` when it was not observed.

Do not present a Git snapshot, a project summary, or a passing test as proof of
deployment or runtime behavior. Do not create a `type: source` note or an
external `origin:` for repository observations. A project-only scan skips the
global inbox and generated dive queue unless the user explicitly asks for
research context.

---

## Token cost vs old approach

Old approach: `_index.md` (2 KB) + 2-3 `_summary.md` files (3-5 KB each) = ~15 KB minimum.
New approach: `kb-search` output (~2 KB) + 1-3 targeted file reads = ~7 KB typical.
Savings: ~50% token reduction on KB navigation overhead.

---

## Read-only boundary

Do not write to any file during this scan. This skill is read-only.
