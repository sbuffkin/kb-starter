# Portable KB hardening

## Scope and release gates

This update ports reusable source-fidelity, publication, queue, synthesis and
project-context safeguards into the starter. It is based on the upstream default
branch, preserving indexed search and optional applications. Allowed changes are
shared contract/templates, deterministic tools and synthetic tests, skill setup,
privacy-safe examples, export safeguards and their documentation.

Release branch: `feat/portable-kb-hardening-2026-09-17`. The target is the
upstream starter's `master` branch through a fork PR, not a live vault branch.

Do not export live notes, media, reading lists, logs, checkpoints, source caches,
review/evidence receipts, account configuration, scheduler state or personal
model-routing policy. No installed skill, service, credential or live vault is
changed by this contribution. Provider integrations remain optional; no model
version or effort is prescribed for source writing or review. Optional extraction
and application adapters may provide user-overridable model defaults; those are
not KB-wide requirements. Selecting an adapter does not authorize automatic
model downloads, credential changes or another provider as a fallback.
A configured review pass can use a human or a
capable model available in the user's chosen harness.

Verification before publication: offline shared-tool tests, isolated installer
and export/privacy tests, existing optional-application tests where available,
skill package validation, diff/whitespace checks and independent review of
source-completion, model portability and privacy boundaries. Stop publication
for unresolved privacy findings, regressions or missing dependencies. Push only
this branch's reviewed code/docs to the contributor fork and open an upstream
PR; merging is a maintainer decision.

## Compatibility and migration

Existing source notes and completed queue rows remain historical. They are not
rewritten or retrospectively certified. New source publication and completion
require the shared validator and a review receipt bound to the exact candidate,
locator and queue. Receipt validation proves consistency, not factual accuracy.
Read the retrieved material during review, including substantive embedded text,
quoted material and missing-media limitations.

Project context does not require source ingestion. Preserve observed code,
planned work and externally verified deployment as different states. Maintain
small summaries; keep useful history in linked dated records before shortening.

An unattended scheduler is not included or enabled by this port. Configure one
locally only after defining finite budgets, approval rechecks, non-overlap,
failure receipts and bounded retries. The interactive skills and deterministic
tools do not require a specific provider or scheduler.

## Privacy boundary

The export helper is a read-only comparison planner, not a vault backup or a
recursive sync. Its reviewed paths are listed in `scripts/starter-export-paths.txt`.
It rejects symlinked inputs and never emits file contents. Review and sanitize each selected artifact before applying a
patch. The publication scanner is a regression guard, not a guarantee that an
arbitrary private vault is safe to publish. Inspect both the diff and outgoing
Git history; removing text from a new revision does not erase earlier history.
Never print suspected credential values in review output.

## Verification results

Verified on 2026-09-17 in an isolated development environment:

- Shared tools and setup/export tests: **862 passed**, with networking disabled.
- Optional feed application: **178 passed**, with networking disabled.
- Optional plugin: **74 passed**; TypeScript checks and production build passed.
- All **13** discoverable skill packages passed package validation.
- Tracked/nonignored-file privacy scan: **0 findings**, including additional
  local-only identifier checks. Whitespace/diff checks passed.
- Independent reviews covered source publication and evidence boundaries,
  privacy/export safety, configurable agent setup, and scoped query, ingestion
  and synthesis handoffs. Filesystem edge-case findings received regression tests.

These checks do not exercise live provider APIs, OCR engines, Obsidian, cloud
deployments or unattended operation. No live vault, installed skill, credential
or service was changed. Existing upstream Git history is not rewritten or
certified by the current-tree privacy scan.
