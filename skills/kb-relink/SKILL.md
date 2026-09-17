---
name: kb-relink
description: Find missing, explicitly authorized wikilink and tag enrichment in a configured KB. Default to a read-only dry run; apply only to scoped, mutable kb-bot notes after guard checks. Do not use for source-note or broad semantic rewriting.
---

# KB Relink

This skill runs the committed deterministic driver for two narrow passes:
missing wikilinks to existing curated anchors, and missing tags from curated
rules. It does not infer new concepts, edit source notes, or expand the
semantic-linking algorithm.

## Scope and safety

Read this package's references/kb-core.md and resolve KB_ROOT
fail-closed. If this package is installed alone, use an explicit --kb-root
argument. Never print config contents.

The default is dry-run. A report-only run may write a report only when its
destination is inside KB_ROOT and the user explicitly requested a durable
report. Applying edits requires all of the following:

- the user explicitly requested --mode apply;
- scope is an unambiguous topic, subdirectory, or file inside KB_ROOT;
- every target is a regular file (not a symlink), inside KB_ROOT, and has
  author: kb-bot;
- no target is a source note, structural file, queue, generated dashboard,
  media byte, or machine-managed path;
- the driver and curated alias/tag rule files are the committed package files;
- the run passes the driver's YAML, mtime, and no-self-link checks.

If the shared guard cannot establish these conditions, disable apply with a
clear migration/dependency error and leave the run dry-run/report-only. Do not
claim the pass is safe merely because a proposal looks plausible.

## Arguments

The driver accepts:

- optional topic slug, relative directory, or file scope;
- --mode dry-run (default), apply, or report-only;
- --kb-root PATH;
- --max-per-section N;
- --links-only, --tags-only, and other driver-supported narrow passes;
- --report-path PATH for an explicitly requested report.

Use --dry-run language in user-facing instructions even though the driver flag
is --mode dry-run. Do not pass an implicit apply mode.

## Driver

Locate relink.py relative to this installed skill package when possible, or use
the source checkout's skills/kb-relink/relink.py. Invoke it with an explicit
KB_ROOT:

  python3 <installed-skill>/relink.py <scope> --kb-root <KB_ROOT> --mode dry-run

For an explicitly approved, guard-verified apply:

  python3 <installed-skill>/relink.py <topic> --kb-root <KB_ROOT> --mode apply

Use a report-only run to persist a requested report. Keep aliases.yaml and
tag-rules.yaml as the only curation surface; do not add ad-hoc mappings to the
prompt. The driver must never call an external provider or choose a model.

## Review

Before returning, report scope, mode, proposal counts, skipped unsafe targets,
and any guard/migration error. Re-run the dry run after accepted rule changes.
After apply, run scoped KB lint and inspect changed paths. Any source or human
owned file, symlink, outside-root path, concurrent mtime change, malformed YAML,
or missing shared guard is a stop condition.

The operation may update a matching progress sidecar only under KB_ROOT and
after authorship checks. Never overwrite an unrelated checkpoint. Internal
links are vault-rooted wikilinks; external URLs are Markdown links.
