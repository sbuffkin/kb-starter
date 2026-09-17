# KB Contract Entrypoint

This skill is a portable adapter for a Markdown knowledge base. The KB's own
_schema.md, _rules.md, and _tools/README.md are authoritative; this reference
does not copy those contracts or grant additional permissions.

## Resolve KB_ROOT fail-closed

Use the first applicable setting in this order:

1. An explicit caller --kb-root value.
2. A non-empty KB_ROOT environment variable.
3. A non-empty KB_CONFIG or KB_CONFIG_PATH environment variable. Read only its
   KB_ROOT: or KB_ROOT= setting.
4. A selected default config when KB_AGENT is set to claude or codex.
5. One unambiguous default config: CODEX_HOME/kb-config.md (or
   $HOME/.codex/kb-config.md), then CLAUDE_HOME/kb-config.md (or
   $HOME/.claude/kb-config.md).

The Codex installer creates ${CODEX_HOME:-$HOME/.codex}/kb-config.md. The
Claude config remains a backward-compatible location for existing installs.
Custom destinations must pass their config path through KB_CONFIG or
KB_CONFIG_PATH; never guess a vault from a custom skill directory.

An explicit root/config, selected config, or discovered default that is missing,
unreadable, malformed, ambiguous, or points outside a readable directory is a
hard stop. Do not fall through to another vault. If no usable config exists,
ask for an explicit root or config path. Never print config contents or secret
values. VAULT_NAME is optional and is used only for Obsidian deep links.

Before acting, read the resolved KB's _checkpoint.md, _schema.md, _rules.md,
_tools/README.md, and then _index.md plus only relevant summaries. Load media
rules lazily and _rules-synthesis.md for synthesis/action routing when present.

All queue mutations use lock-safe tools. Treat _dive-queue.md as generated and
read-only. Before publishing immutable sources, stage and validate candidates,
obtain the independent source/review receipt, and publish through the guarded
source tool documented by _tools/README.md. If a required guard/helper is
missing, stop; never direct-write or silently fall back.

For project/code context, distinguish Observed repository evidence (commit,
paths, and checks actually run), Planned work, and Externally verified
runtime/deployment state. Use not verified when evidence is absent; never turn
repository observations into external source notes.
