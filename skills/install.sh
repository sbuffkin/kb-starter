#!/usr/bin/env bash
# Install the portable KB skills for Claude, Codex, or another agent runtime.
#
# The installer is deliberately conservative: existing skill packages are not
# replaced unless --force is supplied, and an existing config is never shown or
# replaced unless --force-config is supplied.
set -euo pipefail

SKILLS_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENT="claude"
DESTINATION=""
CONFIG_FILE=""
FORCE_SKILLS=0
FORCE_CONFIG=0

usage() {
  cat <<'EOF'
Usage: install.sh [options]

Install the KB skills without changing the source checkout.

Options:
  --agent claude|codex|custom  Select the default runtime destination (default: claude)
  --destination DIR, --dest DIR
                              Skill root to install into (overrides the agent default)
  --config FILE               KB config path (created only when absent)
  --force                     Replace existing skill packages
  --force-config              Replace an existing config with the template
  -h, --help                  Show this help

The config contains a KB_ROOT placeholder and optional VAULT_NAME. Set KB_ROOT
in the environment to override the config at runtime. No config values are
printed by this script.
EOF
}

die() {
  echo "error: $*" >&2
  exit 2
}

reject_symlink_components() {
  local path="$1"
  local saved_ifs="$IFS"
  [[ "$path" == /* ]] || path="$PWD/$path"
  IFS=/ read -ra path_parts <<< "${path#/}"
  IFS="$saved_ifs"
  local cursor="/"
  local part
  for part in "${path_parts[@]}"; do
    [[ -n "$part" ]] || continue
    cursor="$cursor/$part"
    [[ ! -L "$cursor" ]] || die "path must not contain a symlink: $cursor"
  done
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)
      [[ $# -ge 2 ]] || die "--agent requires claude, codex, or custom"
      AGENT="$2"
      shift 2
      ;;
    --destination|--dest)
      [[ $# -ge 2 ]] || die "$1 requires a directory"
      DESTINATION="$2"
      shift 2
      ;;
    --config)
      [[ $# -ge 2 ]] || die "--config requires a file path"
      CONFIG_FILE="$2"
      shift 2
      ;;
    --force)
      FORCE_SKILLS=1
      shift
      ;;
    --force-config)
      FORCE_CONFIG=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1 (use --help)"
      ;;
  esac
done

case "$AGENT" in
  claude)
    AGENT_HOME="${CLAUDE_HOME:-${HOME:?HOME is required for the Claude default}/.claude}"
    ;;
  codex)
    AGENT_HOME="${CODEX_HOME:-${HOME:?HOME is required for the Codex default}/.codex}"
    ;;
  custom)
    [[ -n "$DESTINATION" ]] || die "--agent custom requires --destination DIR"
    AGENT_HOME=""
    ;;
  *)
    die "invalid agent '$AGENT'; choose claude, codex, or custom"
    ;;
esac

if [[ -z "$DESTINATION" ]]; then
  DESTINATION="$AGENT_HOME/skills"
fi
reject_symlink_components "$DESTINATION"
DESTINATION="$(mkdir -p "$DESTINATION" && cd "$DESTINATION" && pwd)"

if [[ -z "$CONFIG_FILE" ]]; then
  if [[ "$AGENT" == "custom" ]]; then
    # For a custom skill root the adjacent config is deterministic and easy to
    # relocate. A caller can use --config when the runtime keeps config elsewhere.
    CONFIG_FILE="$DESTINATION/kb-config.md"
  else
    CONFIG_FILE="$AGENT_HOME/kb-config.md"
  fi
fi
reject_symlink_components "$CONFIG_FILE"
CONFIG_FILE="$(mkdir -p "$(dirname "$CONFIG_FILE")" && cd "$(dirname "$CONFIG_FILE")" && pwd)/$(basename "$CONFIG_FILE")"
if [[ -e "$CONFIG_FILE" && ! -f "$CONFIG_FILE" ]]; then
  die "config path is not a regular file: $CONFIG_FILE"
fi

# Discover package directories before making any changes. The starter's
# discoverable KB packages are kb-* directories containing SKILL.md; unrelated
# profiles and skills remain untouched. This glob/array form works on the Bash
# versions commonly shipped by Linux and macOS.
SKILL_PATHS=()
for skill_path in "$SKILLS_DIR"/kb-*; do
  [[ -d "$skill_path" && ! -L "$skill_path" && -f "$skill_path/SKILL.md" ]] || continue
  SKILL_PATHS+=("$skill_path")
done
[[ ${#SKILL_PATHS[@]} -gt 0 ]] || die "no kb-* skill packages found in $SKILLS_DIR"

# Preflight all skill targets so a missing --force cannot cause a partial run.
if [[ "$FORCE_SKILLS" -eq 0 ]]; then
  for skill_path in "${SKILL_PATHS[@]}"; do
    target="$DESTINATION/$(basename "$skill_path")"
    [[ ! -L "$target" ]] || die "skill target is a symlink: $target"
    [[ ! -e "$target" ]] || die "skill already exists: $target (use --force to replace it)"
  done
else
  for skill_path in "${SKILL_PATHS[@]}"; do
    target="$DESTINATION/$(basename "$skill_path")"
    [[ ! -L "$target" ]] || die "refusing to follow symlink skill target: $target"
    [[ ! -e "$target" || -d "$target" ]] || die "skill target is not a directory: $target"
  done
fi

mkdir -p "$DESTINATION"
for skill_path in "${SKILL_PATHS[@]}"; do
  skill="$(basename "$skill_path")"
  target="$DESTINATION/$skill"
  mkdir -p "$target"
  # cp's merge behavior preserves unrelated files in an existing package;
  # only package files supplied by this starter are replaced.
  cp -a "$skill_path"/. "$target"/
  echo "installed $skill"
done

CONFIG_TEMPLATE='# KB Config
# Set KB_ROOT to the knowledgebase directory used by this agent.
# VAULT_NAME is optional and is used only for Obsidian deep links.

KB_ROOT: /path/to/your/vault/knowledgebase
VAULT_NAME: your-vault-name
'

if [[ -e "$CONFIG_FILE" && "$FORCE_CONFIG" -eq 0 ]]; then
  echo "preserved existing config: $CONFIG_FILE (contents not displayed)"
else
  if [[ -e "$CONFIG_FILE" && "$FORCE_CONFIG" -eq 1 ]]; then
    echo "replacing config: $CONFIG_FILE"
  else
    echo "created config template: $CONFIG_FILE"
  fi
  printf '%s' "$CONFIG_TEMPLATE" > "$CONFIG_FILE"
fi

echo "KB skills installed for agent '$AGENT' at $DESTINATION"
if [[ "$AGENT" == "custom" ]]; then
  echo "Set KB_CONFIG to $CONFIG_FILE (or set KB_ROOT) before use."
else
  echo "Set KB_ROOT in the environment or edit the config file before use."
fi
