---
name: cswap
description: Manage an explicitly requested account switch through the installed cswap CLI. Use only for listing status or switching to a user-configured alias, account identifier, or slot; never infer or silently toggle accounts.
---

# cswap

This skill is an optional adapter for a local account-switching CLI. It does not
contain account names, email addresses, aliases, credentials, or provider
preferences.

## Explicit configuration

Configure account mappings outside this package. Set CSWAP_ACCOUNT_MAP to a
user-owned file containing one mapping per line:

  alias = exact-cswap-target

The target may be a slot or account identifier accepted by the local cswap
installation. Treat the mapping file as sensitive: read only the requested
alias and never print its contents. If CSWAP_ACCOUNT_MAP is unset, accept only
an exact slot or identifier supplied by the user; do not invent aliases.

## Arguments

- No argument, list, or status: run cswap --list and relay its status without
  exposing tokens or unrelated account details.
- A configured alias: resolve it from CSWAP_ACCOUNT_MAP, show the selected
  alias and target class for confirmation, then run cswap --switch-to <target>
  followed by cswap --list.
- An exact slot or identifier supplied by the user: show the target and ask for
  confirmation before running cswap --switch-to <target>, then list status.
- switch or toggle without an explicit target: refuse and ask for a configured
  alias, slot, or identifier. Never silently select the next account.

Use one shell call per confirmed operation. On switch failure, relay the
non-sensitive error and stop; do not retry or choose a fallback target. A switch
affects only sessions that load the changed account state; do not claim that an
already-running session changed identity.

## Safety boundary

This skill may inspect status and perform only the user-confirmed cswap switch.
It must not create mappings, edit credentials, log in, install packages, change
provider/model settings, or infer account choice from the current project,
working directory, or conversation context.
