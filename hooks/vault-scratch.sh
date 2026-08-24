#!/usr/bin/env bash
# Loads the project's session-bridging scratch page at session start, so
# branch state and in-flight work are in context without being asked for.
#
# One page per project, named after the repo: ~/vault/scratch/<repo>.md
# A repo with no scratch page prints nothing.

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
repo_name=$(basename "$repo_root")
page="$HOME/vault/scratch/$repo_name.md"

[ -f "$page" ] || exit 0

printf 'Scratch shelf for %s (~/vault/scratch/%s.md) — current branch state and in-flight work:\n\n' \
	"$repo_name" "$repo_name"
cat "$page"
