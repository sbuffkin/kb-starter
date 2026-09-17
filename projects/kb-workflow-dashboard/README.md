# KB Workflow Dashboard

Optional local web dashboard for the user's KB workflow.

The original MVP was read-only, but the current server includes command and
network-probe endpoints. Binding to `127.0.0.1` is not an authorization boundary.
Inspect the enabled routes before use and do not expose it to an untrusted
network. Mutations must use the guarded shared KB tools; a dashboard click does
not override source-review, ownership or approval requirements. The starter's
LAN directory contains only itself; add private services locally, not in PRs.

## Run

```bash
python3 server.py
```

Open `http://127.0.0.1:8787`.

The dashboard header links to `http://127.0.0.1:8787/getting-started.html`, which explains the KB workflow, safe future operations, external skill-artifact review, and source-cluster-to-skill promotion path.

Optional flags:

```bash
python3 server.py --kb-root /path/to/vault/knowledgebase --port 8787
```

The server refuses non-loopback hosts unless `--allow-non-loopback` is set. Keep the default unless you deliberately want to expose local KB metadata to another machine.

## API

- `GET /api/status` returns dashboard summaries, short queue previews, and kb-feed read-only state.
- `GET /api/queue?path=<relative-kb-path>` returns full checkbox items for an allowlisted queue path only.

## Panels

- Active checkpoint
- Global URL inbox
- Inspiration / ideas backlog as a parking lot, not an ingestion queue
- Topic reading-list queue counts
- Generated research dive view counts
- Needs Attention triage cards for failed, active, review, open, stale, and kb-feed signals
- Queue item previews with source path and line numbers
- `[?]` testing/review checkbox rows counted separately from blocked rows
- Topic queue filters and sortable topic/project tables
- kb-feed SQLite state summary
- Recent KB log entries
- Light/dark theme toggle

## Future Write Actions

Audit command execution separately before enabling it for a live KB. The
shared-tool hardening does not certify every dashboard endpoint. External skill
artifacts stay review candidates until package validation, KB comparison, task
testing and explicit installation approval are complete.
