---
name: lint-vault
description: Health-check the knowledge vault (~/vault) and the governing docs around it. Invoke on /lint-vault, "lint the vault", "check the vault for garbage", or similar. Distinct from audit-vault: lint is the internal health check; audit compares against external baselines.
---

# Lint the vault

The authoritative checklist lives in `~/vault/SCHEMA.md`, section "When Claude
writes" → the lint bullet. Do not duplicate it here — read it, then:

1. Run `~/vault/lint.sh` (free, mechanical tier) and report its findings.
2. Run the judgment sweep it defines, across the full governing surface it
   lists. A cheaper-model subagent may do the reading and report back.
3. Apply safe fixes directly; propose deletions/merges for approval.
4. Stamp `date +%F > ~/vault/.last-lint`, then commit and push the vault per
   the sweep rule in `~/.claude/CLAUDE.md`.

Report: fixed / flagged-for-approval / clean, in plain language.
