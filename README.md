# kb-starter

A self-contained starter kit for a personal knowledge base built on [Obsidian](https://obsidian.md) and operated by LLMs or local tooling. Clone this repo to get the Obsidian plugin, KB skills, reusable workflow tools, optional Telegram capture bot, optional local workflow dashboard, and a blank-but-seeded knowledgebase ready to use.

The shared KB is **LLM-agnostic**: any capable agent can operate it by reading
`knowledgebase/_schema.md`, `_rules.md`, and `_tools/README.md`. Writing and review
models are chosen in your own harness; the starter imposes no model family,
version floor, or effort level. Claude and Codex skill installation are supported,
and other runtimes can use a custom destination. The optional Obsidian plugin is
an **Anthropic API adapter**, not a prerequisite or a universal-provider client.
Optional extraction and application adapters may have user-overridable model
defaults. These are not requirements for writing or reviewing KB notes, and do
not authorize automatic model downloads or provider fallback.

---

## What's included

| Folder | Contents |
|---|---|
| `plugin/` | `kb-bot` — Obsidian plugin source. Adds an in-vault ask command backed by a configured LLM API. |
| `skills/` | KB skills that operate the KB from an agent CLI. |
| `knowledgebase/` | Blank starter KB with schema, rules, shared `_tools/`, ideas backlog, and the `obsidian` topic pre-seeded. Copy this into your Obsidian vault. |
| `projects/kb-feed/` | Optional Telegram capture bot that routes mobile-shared URLs and notes into KB queues. |
| `projects/kb-workflow-dashboard/` | Optional local workflow dashboard; includes command endpoints, so it is not a read-only security boundary. |

---

## Prerequisites

- [Obsidian](https://obsidian.md) (any recent version)
- An agent CLI capable of reading local files and running shell commands
- A current Node.js LTS release and npm (only for the optional plugin)
- Python 3.12+ for shared tooling; install its isolated dependencies below
- `pdftotext` for PDF ingestion:
  ```bash
  sudo apt-get install poppler-utils   # WSL2 / Debian/Ubuntu
  brew install poppler                  # macOS
  ```

---

## Quick start

### 1. Optional: build and install the Anthropic plugin

```bash
cd plugin
npm install
npm run build          # produces main.js
```

Copy the plugin into your Obsidian vault:

```bash
mkdir -p /path/to/your/vault/.obsidian/plugins/kb-bot
cp main.js manifest.json /path/to/your/vault/.obsidian/plugins/kb-bot/
```

In Obsidian: **Settings → Community Plugins → KB Bot → Enable**. Then select an
available model ID and add your Anthropic API key in the plugin settings. No
model is preselected for new installations. Existing saved model settings are
preserved. If you use only an agent CLI, skip this step: no Anthropic account is
needed for the shared KB or skills. API billing is separate from CLI subscriptions.

> **Vault folder name:** The plugin's authorship guard expects the KB to live at `knowledgebase/` relative to your vault root. This name is hardcoded in `plugin/src/guard.ts`. If you want a different folder name, edit `KB_ROOT` in that file before building.

### 2. Install the skills

```bash
bash skills/install.sh --agent claude
# Or:
bash skills/install.sh --agent codex
# Another runtime:
bash skills/install.sh --agent custom --destination /path/to/skills --config /path/to/kb-config.md
```

The installer uses the selected runtime's skill directory and creates a config
template. Existing packages require `--force` to update; existing config is kept
unless `--force-config` is explicitly supplied. Config contents are never printed.
No model, provider credential, background job or installed application is changed.

### 3. Configure your KB path

Edit the config created by the installer (`~/.claude/kb-config.md` for Claude,
`${CODEX_HOME:-~/.codex}/kb-config.md` for Codex, or your custom `--config` path):

```
KB_ROOT: /path/to/your/vault/knowledgebase
VAULT_NAME: your-vault-name
```

- `KB_ROOT` — absolute path to the `knowledgebase/` folder inside your Obsidian vault
- `VAULT_NAME` — the name of your Obsidian vault (used in `obsidian://` deep links)

All KB skills resolve the same settings at startup. An explicit `KB_ROOT`
environment variable takes precedence; `KB_CONFIG` can select a custom config.
For a custom install, set `KB_CONFIG` to the path passed to `--config`.
The legacy Claude config remains supported. Missing explicit configuration is an
error, not permission to select a different vault.

For the optional indexed command-line helpers, use `KB_AGENT=claude` or
`KB_AGENT=codex` when both runtime configs exist, or set `KB_ROOT`/`KB_CONFIG`
explicitly. Keep `scripts/kb_config.py` alongside these helpers. Build an index
explicitly with `python3 scripts/kb-index`; `python3 scripts/kb-search --query
<text>` only reads it and does not create one during a lookup. Skills fall back
to scoped filesystem reads when the optional index is unavailable.

### 4. Copy the starter KB

This step is for a **new, empty destination only**. For an existing KB, review
and update the shared tools, contracts and skills together; never overwrite its
notes, indexes, queues, logs, checkpoints or custody records with starter seeds.

```bash
cp -r knowledgebase/ /path/to/your/vault/knowledgebase
```

The `knowledgebase/` folder includes:
- `_schema.md` — the full structural specification any agent reads to orient itself
- `_rules.md` — behavioural rules (authorship guard, navigation protocol, citation standards, etc.)
- `_index.md` — navigation index (starts with just the `obsidian` topic)
- Blank stubs for `_log.md`, `_checkpoint.md`, `_dive-queue.md`, `_todo.md`
- `_tools/` — shared scripts for linting, dedup, queue checkoff, derived dive-queue regeneration, media capture, tweet/video extraction, and prep checks
- `ideas/_backlog.md` — durable parking lot for broad ideas that are not yet topics or projects
- `readinglist/Links.md` — global URL inbox
- `topics/obsidian/` — pre-seeded topic documenting the Obsidian ecosystem (useful reference for any KB operating in Obsidian)
- `projects/kb-feed/` and `projects/kb-workflow-dashboard/` — KB-native project records for the optional workflow tools in this repo

### 5. Verify

Install shared tool dependencies in a local virtual environment:

```bash
python3 -m venv knowledgebase/_tools/.venv
knowledgebase/_tools/.venv/bin/pip install -r knowledgebase/_tools/requirements-dev.txt
knowledgebase/_tools/.venv/bin/python -m pytest knowledgebase/_tools/tests scripts/tests -q
```

Tools accept `--kb-root` where applicable; invoke them with that environment's
Python. OCR/browser/video dependencies are optional and documented separately.
No test requires live provider calls or private source material.

In an agent CLI session, run:

```
/kb-ask
```

The skill should resolve your config and answer or orient without modifying the
vault. Invocation syntax depends on the runtime; explicit instructions to read
the skill work even when slash-command discovery is unavailable.

---

## Skills reference

| Skill | What it does |
|---|---|
| `/kb-ask [question]` | Start a scoped KB session. Browse topics, query content, or ask a natural language question. Generates `obsidian://` citations. |
| `/kb-ingest <url\|path>` | Ingest a single source interactively. Fetches, discusses, assigns topic, writes source note. Full checkpoint support. |
| `/kb-queue [topic]` | Batch process a topic's reading list. Per-item approval checklist with pause/resume for overnight runs. |
| `/kb-synthesise [topic]` | Generate concept/entity/synthesis notes from accumulated sources. Presents an approval plan before writing. |
| `/kb-lint [topic]` | Health check: broken wikilinks, orphan pages, missing stubs, incomplete frontmatter, contradictions, stale sources. |
| `/kb-auto [topic]` | Headless autonomous ingestion from topic reading-list `## Auto-approved` sections. `_dive-queue.md` is generated/read-only. |
| `/kb-scan` | Read-only, project-scoped context discovery; optional indexed search with filesystem fallback. |
| `/kb-project-init` | Create approved project navigation and task records without fabricating source notes. |
| `/kb-wrap` | Preserve dated outcomes, decisions, evidence limits and resumable next steps. |

---

## Optional workflow tools

### kb-feed

`projects/kb-feed/` is a Python Telegram capture bot. It does not ingest sources. It validates messages, maps Telegram topic threads to KB topic slugs, writes queue entries, and keeps runtime state in SQLite outside the repo.

```bash
cd projects/kb-feed
python3 -m venv .venv
.venv/bin/pip install -e '.[dev]'
mkdir -p ~/.config/kb-feed ~/.local/state/kb-feed
cp credentials.env.example ~/.config/kb-feed/credentials.env
cp config.example.toml ~/.config/kb-feed/kb-feed.toml
```

Read `projects/kb-feed/README.md` before enabling live writes.

### KB workflow dashboard

`projects/kb-workflow-dashboard/` is an optional local web dashboard. Review its
README and enabled endpoints before use; it is not a sandbox or an authorization
grant. The LAN directory ships with only the dashboard itself, not a maintainer's
private services. Its optional Claude-usage view is provider-specific and does
not make Claude a requirement for the KB.

```bash
python3 projects/kb-workflow-dashboard/server.py --kb-root /path/to/your/vault/knowledgebase
```

Open `http://127.0.0.1:8787`.

---

## Plugin settings

After enabling the plugin in Obsidian, configure it via **Settings → KB Bot**:

| Setting | Default | Notes |
|---|---|---|
| API Key | *(empty)* | Your Anthropic API key — required |
| Model | *(empty)* | An available Anthropic model ID chosen by you; no automatic fallback |
| Max tokens | `1024` | Response length cap for in-vault queries |

Settings persist to `.obsidian/plugins/kb-bot/data.json` (gitignored).

---

## KB conventions

The full structural specification lives in `knowledgebase/_schema.md` and the behavioural rules in `knowledgebase/_rules.md`. Key points:

- **Authorship guard:** The agent only writes to files it created (`author: kb-bot` in frontmatter). It will never touch user-created notes.
- **Navigation:** Use optional indexed search or `_index.md` → matching `_summary.md`, then only relevant notes. Project tasks do not trigger inbox processing.
- **Page creation threshold:** One source can support a useful stub; two or more may support a fuller article. Relevance and evidence matter more than quotas. No empty pages solely to silence broken links.
- **Source notes are immutable** after initial write — provenance is always traceable.
- **Publication:** Validate the staged draft and its destination, review it against
  actual retrieved material, record a hash-bound review, then use
  `kb-commit-source.py`. This does not commit to Git. Partial source/queue results
  need reconciliation; a checked queue is not completed synthesis.
- **Context:** Keep observed code, planned work and externally verified runtime
  separate. Preserve useful history before shortening summaries.
- **LaTeX** throughout for mathematical content (`$...$` inline, `$$...$$` block).

---

## Adding a new topic

Run `/kb-ingest <url>` and the skill will propose a topic assignment. To create a topic manually:

1. Create `knowledgebase/topics/<your-topic>/` with subfolders `sources/`, `notes/concepts/`, `notes/entities/`, `notes/syntheses/`
2. Create `knowledgebase/topics/<your-topic>/_summary.md` (use an existing `_summary.md` as a template)
3. Add the topic to `knowledgebase/_index.md`
4. Add sources to `knowledgebase/topics/<your-topic>/reading-list.md`
5. Run `/kb-queue <your-topic>` to begin ingestion

---

## License

MIT

## Contributing reusable improvements

See [portable hardening](docs/portable-hardening.md) for scope, migration and
verification. `scripts/sync-from-live.sh --kb-root <root>` is now a read-only
comparison planner. It never copies a live `_tools/` tree, logs, queues, receipts,
raw media, account settings or populated custody indexes. Port reviewed files
explicitly; do not recursively sync a private vault into this repository.

Before publishing, run `python3 scripts/check-starter-privacy.py`, review the
diff and outgoing history, and use only synthetic/public-safe fixtures. The
scanner reports categories and locations without printing possible secrets;
it is a guardrail, not proof that arbitrary content is safe to share.
