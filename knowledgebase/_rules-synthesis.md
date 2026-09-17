---
author: kb-bot
created: 2026-07-14
modified: 2026-09-17
type: meta
---

# KB Synthesis Rules

This file extends `_rules.md` for synthesis work. Load it before creating or updating `type: concept`, `type: entity`, `type: synthesis`, or substantive `type: output` notes. It does not replace `_rules.md`; it adds evidence and safety discipline for higher-level claims.

## Synthesis Evidence Discipline

Every factual claim in a wiki note must cite an ingested source note inline or through the note's `sources:` frontmatter. Claims derived by the agent across sources must be marked clearly, using the existing convention:

```markdown
> *Agent inference — not sourced*
```

Prefer source-scoped phrasing when a claim comes from a social post, product page, marketing claim, self-experiment, partial citation, video demo, or generated summary. Do not promote source rhetoric into KB conclusions without primary evidence or a synthesis note that explicitly grades the evidence.

When sources conflict, preserve the conflict instead of resolving it silently. When a source is incomplete, failed, repaired later through a companion media note, or lower-quality than the claim it gestures toward, state that boundary in the mutable wiki note.

## Domain Boundaries

**Health and medical-adjacent notes:** Use evidence-grade language. Do not write dosing, treatment, diagnosis, protocol, or supplement-stack guidance unless the KB has ingested appropriate primary or guideline evidence and the note is explicitly scoped as research, not medical advice. Social, affiliate, self-experiment, preclinical, or partial-citation sources remain claim maps and future-ingest leads.

**Prediction markets, trading, and finance-adjacent notes:** Separate mechanism demos, product-surface screenshots, analogy videos, workflow patterns, and marketing claims from performance validation. Do not state profit, edge, Sharpe, hit-rate, or P&L claims as verified unless the KB has ingested independent performance evidence or the note clearly marks them as the source's unverified claim.

**Atmospheric, solar, geomagnetic, seismic, and forecasting notes:** Keep data availability, plausible physical mechanism, and demonstrated forecast skill as separate evidence grades. A dataset being available or a mechanism being physically plausible does not establish forecast improvement without a baseline, target variable, time window, lag handling, multiple-testing control, and out-of-sample verification.

**Home-improvement and practical safety notes:** Keep electrical, gas/combustion, mold, roofing/fall, structural/deck, foundation, excavation, sewage, and permit-sensitive work at the triage/planning/safety-boundary level unless a source and local constraints justify more detail. Local code, permits, manufacturer instructions, and licensed trades override generalized online guidance.

**Model-routing, agent-workflow, and AI-literacy notes:** Distinguish observed model behavior, provider/tool documentation, benchmark/eval evidence, social claims, and KB inference. When recommending a model route, record task fit, cost/latency/usage constraints, available tools, and whether the recommendation is evidence-backed or experimental.

## Review Expectations

For high-impact synthesis in health, finance/trading, safety, or speculative science, run a read-only adversarial review before closing the checkpoint when practical. The reviewer should look for uncited claims, overpromotion of weak sources, missing evidence-grade caveats, safety advice leakage, and broken wikilinks.

## Actionable Recommendation Lifecycle

Synthesis must not lose source-derived operational payload. During source reading, capture every candidate recommendation, follow-up, implementation idea, package/tool suggestion, workflow upgrade, exact source lead, book lead, experiment seed, or project task in an in-memory action inventory before filtering it out. Each inventory item must include:

- Stable ID and human-readable title.
- Normalized recommendation plus a short trigger/evidence summary.
- Source-note citations, or the explicit label `agent-inference` when the candidate is an agent inference rather than a source claim.
- Action kind and scope.
- Evidence grade.
- Existing durable destination and required write method.
- Review or approval gate.
- Exactly one disposition: `persist`, `approval-needed`, `defer`, or `reject`.
- Reason for every non-`persist` disposition.

Disposition semantics:

| Disposition | Meaning |
|---|---|
| `persist` | The candidate is eligible and planned for a durable record if the user approves the Phase 3 plan and the write succeeds. |
| `approval-needed` | The recommendation is plausible and worth surfacing, but the underlying next step requires explicit approval, project/global scope choice, package/config review, fetching, installation, or another gated action. Persist only a review task when that review task itself is listed in the Phase 3 plan and approved; the underlying action remains gated. |
| `defer` | The candidate may be useful later but lacks enough evidence, destination clarity, timing, or project grounding for a durable write. Do not write it; report the reason. |
| `reject` | The candidate is unsafe, duplicate, unsupported, contradicted, out of scope, or not worth preserving. Do not write it; report the reason. |

`persist`, `approval-needed`, `defer`, and `reject` are the only dispositions. `persisted`, `unpersisted`, and `blocked` are final write-status annotations for a candidate row, not extra dispositions, categories, or plan-table values. The final report must separately record the actual write status after approved writes run.

Route action candidates only to existing homes:

| Candidate type | Durable destination | Required method |
|---|---|---|
| Exact URL source lead | `topics/<topic>/reading-list.md` `## Pending` | Use `_tools/kb-capture-url.py --topic <topic>` for new URL ADDs after mandatory dedupe, or the matching lock-safe promotion tool for existing URL rows; never hand-edit queue Markdown or `_dive-queue.md`. Preflight: if the tool reports falling back to `readinglist/Links.md` because the topic reading list is missing, treat that as a failed write — mark the candidate `blocked`, report the mismatch, and do not accept the fallback destination. |
| Exact local-file source lead | no write until tooling exists | No lock-safe local-file ADD tool exists; this narrows Rule 13's "add local-file candidates to the reading list" for synthesis action routing — mark `approval-needed` or `defer`, report the missing tool as the gate/reason, and do not hand-edit or claim persistence. |
| Prose research lead with no exact source locator | `topics/<topic>/research-ideas.md` | Append under the file's existing contract after authorship check. |
| Experiment or project seed; NEW unassigned skill candidate | `topics/<topic>/_prospects.md` | Append/create under Rule 25 after authorship check. |
| Skill, package, or config change to an EXISTING live skill/tool/config | root `_todo.md` | Append a review task after authorship check. When scope (project vs global) or destination is ambiguous, write nothing and mark `approval-needed` — never split one candidate across two destinations. |
| Existing-project implementation work | `projects/<project>/_todos.md` | Load `projects/<project>/_summary.md` first, use `_tools/kb-project-status.py` when useful, then append to the task board under Rule 28 after authorship check. |
| KB-system, tooling, live-skill, or config review work | root `_todo.md` | Append a review task after authorship check. |
| Book acquisition or reading lead | `_library/books/_ledger.md` | Use `_tools/kb-book-ledger.py`; never hand-edit the ledger. |
| Unsafe, duplicate, unsupported, uncited, or insufficient candidate | no write | Mark `defer` or `reject` and report explicitly. |

Skill, package, and config recommendations require extra gates before any durable task is persisted: provenance/package review covering source trust, required permissions, package contents and validation, a project-vs-global scope decision, a measured pilot or eval against current behavior, and rollback planning. Synthesis may persist a review task to an approved existing destination, but it must never install packages, edit live skills, edit config, change credentials, or widen global scope.

Apply Rule 22 before routing actions: scan `_index.md`, load semantically related project summaries, and use project status when it helps decide whether a recommendation belongs in a project `_todos.md`, a topic `_prospects.md`, or root `_todo.md`. Project summaries are context, not source evidence.

The Phase 3 synthesis plan must include an `Action recommendations to route or disposition` table with candidate, kind, sources, destination, proposed disposition, and gate/reason. Approval authorizes only the listed durable records; it does not authorize fetching, installing, changing config, or executing implementation work.

The checkpoint for synthesis must make every action entry resumable. Each action checkpoint entry must include the stable ID, title or recommendation, source citations or `agent-inference`, destination, write method/tool, exact approved durable-record text or a no-write reason, proposed disposition, and gate/reason. Approved action writes run after wiki notes, media/backlinks, and normal note updates. Log every action disposition, durable destination, and final write status in `_log.md`.

The final report must include an `Action recommendations` section with one row per candidate carrying two separate columns: `Disposition` (`persist`, `approval-needed`, `defer`, or `reject`) and `Write status` (`persisted`, `unpersisted`, or `blocked`; use `unpersisted` for candidates never planned for a write). For a zero-action run, one concise sentence is sufficient, such as `Action recommendations: none found in the reviewed sources.` Include citations, destinations, blockers, and next approval needed where relevant.

Stop conditions operate at two levels. Candidate level: when a single candidate lacks evidence, a clear destination after project grounding, or an unambiguous project/global scope, do not write that candidate — mark it `defer` or `approval-needed` and continue the run. Run level: abort the synthesis pass and report when a destination file lacks `author: kb-bot`, a required lock-safe tool is missing or fails mid-write, an approved write cannot be completed as approved, or completing the work would require inventing a new queue, schema field, or helper script. A recommendation that would require an install, config, credential, or billing change is candidate-level: persist at most a gated review task.
