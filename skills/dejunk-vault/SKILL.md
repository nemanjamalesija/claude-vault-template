---
name: dejunk-vault
description: Focused cleanup pass over the knowledge vault (~/vault) — find the junk that slipped into existing pages and cut it, without trimming into superficiality. Invoke on /dejunk-vault, "de-junk the vault", "clean the junk out of the vault". Distinct from lint-vault (broad health check) and audit-vault (external-baseline comparison).
---

# De-junk the vault

Junk, and the over-trimming trap that is worse than it, are defined in
`~/vault/SCHEMA.md` → "The core principle". Read it first, it is authoritative;
don't duplicate it here. This skill is that principle applied as a cleanup pass
on pages that already exist.

## Scope

Indexed project pages and `me/` (genres: reference, work-state, me) — where junk
collects as pages get updated. SKIP `stories/` (their narrative and kept-in bugs
are the value), `raw/` (immutable, never edited), and `specs/` (written fresh,
deleted on ship).

## The pass

1. Read each in-scope page against the core principle and mark two things:
   - **Junk to cut** — who-said-what, "we then corrected", superseded bullets
     stacked instead of replaced by their conclusion, commit hashes as
     narrative, verification dates on settled facts, closing flourishes.
   - **Superficiality to fix** — the opposite failure: a rule missing its why, a
     contract missing an edge case, a gotcha missing its trigger. Fill it or
     flag it; never "fix" it by cutting.
2. Show the proposed cuts and fills per page for the owner to approve before
   anything changes. A cut is a deletion, and their review is the safety net —
   not the ability to recover it from git afterward. When something is not
   clearly junk, keep it and flag the doubt rather than removing it.
3. Apply the approved changes. A cheaper-model subagent may read and draft the
   proposals per page; the main loop makes the final call and applies — junk-vs-
   value is the whole judgment, don't hand it off blind.
4. Commit and push the vault per the sweep rule in `~/.claude/CLAUDE.md`.

Report per page: what was cut, what was flagged (superficial gaps, doubtful
cuts). Plain language.
