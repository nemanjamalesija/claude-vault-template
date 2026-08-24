#!/usr/bin/env bash
# Wires the vault into Claude Code:
#   - makes sure the vault is reachable at ~/vault (symlink if cloned elsewhere)
#   - symlinks skills/, agents/, hooks/ into ~/.claude/
#   - adds the always-loaded import block to ~/.claude/CLAUDE.md
# Idempotent: safe to re-run after a git pull.
set -euo pipefail

VAULT="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"

# --- 1. the vault must answer at ~/vault (every path in SCHEMA, the skills
# --- and lint.sh assumes it; a symlink satisfies that when the clone lives elsewhere)
if [ ! -e "$HOME/vault" ]; then
  if [ "$VAULT" != "$HOME/vault" ]; then
    ln -s "$VAULT" "$HOME/vault"
    echo "linked ~/vault -> $VAULT"
  fi
elif [ "$(cd "$HOME/vault" && pwd -P)" != "$(cd "$VAULT" && pwd -P)" ]; then
  echo "ERROR: ~/vault already exists and is not this checkout." >&2
  echo "Move it aside or merge manually, then re-run." >&2
  exit 1
fi

mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents" "$CLAUDE_DIR/hooks"

# --- 2. skills (real files live in the vault so edits ride its git)
for d in "$VAULT"/skills/*/; do
  name=$(basename "$d")
  target="$CLAUDE_DIR/skills/$name"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "SKIP skill '$name': $target exists and is not a symlink"
  else
    ln -sfn "${d%/}" "$target"
    echo "skill  $name"
  fi
done

# --- 3. agents (per-file, so existing personal agents are untouched)
for f in "$VAULT"/agents/*.md; do
  [ -e "$f" ] || continue
  name=$(basename "$f")
  target="$CLAUDE_DIR/agents/$name"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "SKIP agent '$name': $target exists and is not a symlink"
  else
    ln -sfn "$f" "$target"
    echo "agent  $name"
  fi
done

# --- 4. hook scripts (registration in settings.json is done by /vault-init, with consent)
for f in "$VAULT"/hooks/*.sh; do
  [ -e "$f" ] || continue
  ln -sfn "$f" "$CLAUDE_DIR/hooks/$(basename "$f")"
  chmod +x "$f"
  echo "hook   $(basename "$f")"
done
chmod +x "$VAULT/lint.sh"

# --- 5. the always-loaded block in ~/.claude/CLAUDE.md, kept between markers.
# --- An existing block is stripped first, then the fresh one is appended, so
# --- re-running after a template update refreshes it.
BEGIN="<!-- vault-template:begin (managed by ~/vault/install.sh) -->"
END="<!-- vault-template:end -->"

touch "$CLAUDE_MD"
if grep -qF "$BEGIN" "$CLAUDE_MD"; then
  awk -v begin="$BEGIN" -v end="$END" '
    index($0, begin) { skipping = 1; next }
    index($0, end)   { skipping = 0; next }
    !skipping        { print }
  ' "$CLAUDE_MD" > "$CLAUDE_MD.tmp" && mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
  echo "refreshed managed block in ~/.claude/CLAUDE.md"
else
  echo "added managed block to ~/.claude/CLAUDE.md"
fi

cat <<EOF >> "$CLAUDE_MD"

$BEGIN
# Knowledge vault

I keep a personal knowledge vault at \`~/vault/\` (plain markdown, git, viewable
in Obsidian). My conventions (\`me/how-i-work.md\`) and the vault catalog
(\`INDEX.md\`) are imported at the bottom of this block, so they load every
session automatically.

- Open other vault pages on demand, following INDEX's \`Read when…\` trigger
  lines: before acting in an area a line names, open that page first. Never
  sweep the whole folder.
- When you learn something durable (I correct you, you hit a non-obvious quirk,
  a decision gets settled), write it into the vault following
  \`~/vault/SCHEMA.md\`. For codebase-area knowledge, prefer path-scoped rules
  in that repo's \`.claude/rules/\` whenever the paths are nameable — a rule
  loads on its own when a matching file is touched.
- Session-bridging state (current branch, in-flight uncommitted work) goes to
  \`~/vault/scratch/<project>.md\` (rules in \`~/vault/SCHEMA.md\`). Never
  write to \`~/.claude/projects/*/memory/\`.
- **Never commit or push in project repos on your own initiative.** The vault
  is the exception — the sweep rule below stands.
- After writing to the vault: commit ALL pending vault changes (\`git add -A\`
  — my manual edits ride along; they are authoritative, never revert them),
  then \`git pull --rebase\`, then push. If the commit contains changes you
  didn't make, keep the message generic.

@$HOME/vault/me/how-i-work.md
@$HOME/vault/INDEX.md
$END
EOF

cat <<'EOF'

Done. Next steps:
  1. Keep this repo PRIVATE — it will hold your work knowledge.
  2. Start Claude Code anywhere and run:  /vault-init
     The interview sets up your profile, your projects, and the hooks.
EOF
