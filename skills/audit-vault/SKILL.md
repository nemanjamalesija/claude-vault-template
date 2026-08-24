---
name: audit-vault
description: Audit the knowledge-vault system's current state against its own rules and grounded industry practice; report what holds, what drifted, what to act on now, and what waits on a named condition. Invoke on /audit-vault or "run an audit on the vault". Distinct from lint-vault: lint is the internal health check; audit compares against external baselines and suggests improvements.
---

# Audit (vault)

1. **Inventory with real numbers:** run `~/vault/lint.sh`; count pages and
   lines per folder; check vault git state; check the always-loaded surface's
   size (the managed block in `~/.claude/CLAUDE.md` plus everything it
   imports) — that surface is paid on every prompt, so it is the first place
   bloat hurts.
2. **Baseline:** current published practice on agent memory and context
   management (context-window degradation with size, curated versus
   auto-generated memory, instruction-file size guidance). If the vault has a
   filed research page on this topic, prefer it and refresh with a web check
   only where it is stale; otherwise do a focused web pass and cite what you
   find — an audit against remembered folklore is not an audit.
3. **Compare and report:** what holds, what drifted, actionable-today items,
   and conditional-future items — each future item with a named trigger.
   Suggestions must be grounded in the owner's actual observed needs; never
   suggest for the sake of suggesting.
4. Apply approved quick fixes directly; anything larger is a proposal for the
   owner to decide.
