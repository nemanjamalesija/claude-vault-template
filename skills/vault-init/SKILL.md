---
name: vault-init
description: First-run guided setup for the knowledge vault. Invoke on /vault-init or "set up my vault". Interviews the owner one question at a time, then writes their profile, project folders, INDEX sections, scratch stubs, and wires the optional hooks. Safe to re-run to add a project later.
---

# Vault init

You are setting up a curated knowledge vault for a developer who just cloned
the template. The vault only works if the setup reflects how THEY actually
work, so this is an interview, not a form. Read `~/vault/SCHEMA.md` in full
before asking anything — it is the constitution you are configuring, and
several questions below only make sense if you understand it.

## Preflight

1. Confirm `~/vault` exists and contains `SCHEMA.md` and `INDEX.md`. If not,
   tell the owner to clone the template and run `./install.sh` first, and stop.
2. Confirm the wiring: `~/.claude/skills/vault-init` resolves into the vault,
   and `~/.claude/CLAUDE.md` contains the `vault-template:begin` block. If
   either is missing, offer to run `~/vault/install.sh` and do so on consent.
3. Check whether `me/how-i-work.md` still contains template placeholders. If
   the owner already ran init, switch to add-a-project mode: run only the
   project questions (interview step 2) for the new project.

## The interview

Ask ONE question at a time and wait for the answer. Adapt follow-ups to what
you hear; skip questions the answer already covered. Never fill a gap with a
guess — a wrong convention written into `how-i-work.md` gets applied every
session until noticed.

1. **Role and stack.** What do they build day to day, in which languages and
   frameworks, and what is their role on the team (solo, senior on a team,
   contractor)? This seeds the role section of `how-i-work.md`.
2. **Projects.** Which repos will Claude regularly work in with them? For
   each: absolute path, a short vault folder name (lowercase, no spaces), and
   whether the repo is shared with a team. Verify each path exists before
   accepting it.
3. **Boundaries.** What must Claude never do on its own in those repos?
   Probe concretely: commit or push? touch a layer they don't own (backend,
   infra, generated code)? deploy? The strongest boundary in the template's
   parent setup is "never commit in project repos without an explicit ask" —
   recommend it, and record whatever they decide.
4. **Verification stop-line.** After a change, how far should Claude verify on
   its own — typecheck/build/lint only, run the test suite, or start the app?
   Recommend stopping at typecheck + build + lint for UI work: real QA usually
   needs a live environment, and everything past the stop-line is their job.
5. **Vault commit policy.** The template's sweep rule has Claude commit and
   push the vault automatically after writing to it. Confirm they want that
   (recommend yes — an uncommitted vault silently loses the "git history is
   the archive" property). If no, edit the sweep bullet in the managed
   `~/.claude/CLAUDE.md` block to require an ask.
6. **Communication.** How do they want replies written — language level
   (native English or not), density, tone? Explain the mechanism in one
   breath: `me/reply-style.md` holds the text, and a UserPromptSubmit hook
   injects it with every prompt, so style corrections become edits to that
   file instead of repeated feedback. Offer the hook; rewrite the file's text
   from their answer.
7. **Knowledge pain.** What do they re-explain to Claude, or re-derive
   themselves, most often today? Pick the ONE most valuable item and offer to
   draft it as the first real page (or path-scoped rule, if it is tied to
   nameable files) after setup. Do not backfill more than that — a vault
   fills through work, and pages written from memory in one sitting skip the
   verification that makes pages trustworthy.

## Writes (after a confirming summary)

Show a compact summary of everything you are about to write and get one
go-ahead. Then:

1. **`me/how-i-work.md`** — overwrite the placeholder with their real profile:
   role and scope, boundaries, code style if any surfaced, verification
   stop-line, environment. `genre: me` frontmatter. Write it in SCHEMA's spec
   voice: rules with their why, no interview narrative.
2. **`me/reply-style.md`** — if they opted in, replace the example text with
   their preferences (everything below the frontmatter gets injected, so keep
   the file frontmatter plus reminder text only).
3. **Per project:** create `~/vault/<folder>/`, add an INDEX section headed by
   the repo path, create `scratch/<repo-basename>.md` (empty besides a
   comment naming its job), and append `<folder>=<path>` to
   `~/vault/projects.conf`.
4. **Per repo, on consent:** create `.claude/rules/` in the repo and add
   `.claude/rules/` plus `CLAUDE.local.md` to `.git/info/exclude`, so the
   personal rule layer never shows up in the team's git.
5. **Hooks, each on explicit consent** (edit `~/.claude/settings.json`; make a
   `.bak` copy first; merge, never overwrite existing hooks):
   - UserPromptSubmit → `sed '/^---$/,/^---$/d' ~/vault/me/reply-style.md 2>/dev/null || true`
     (strips frontmatter, injects the rest with every prompt);
   - SessionStart (matcher `startup|resume|clear`) → `~/.claude/hooks/vault-scratch.sh`
     (injects the project's scratch page at session start);
   - set `autoMemoryEnabled: false` — the scratch layer replaces auto-memory,
     and two memory surfaces drift apart.
6. **Clean the template out:** remove the placeholder comment from INDEX.md
   and any remaining template-only text, so lint runs clean.
7. If they named a knowledge-pain item, draft that first page or rule now,
   with them reviewing.

## Close

1. Run `~/vault/lint.sh`; fix anything it flags.
2. Check the vault has a git remote. If not, tell them plainly: create a
   PRIVATE repo and push — the vault will hold employer and project details,
   and a public remote leaks them.
3. Commit everything (per the policy they chose in question 5).
4. Leave them with the operating loop, in a few sentences, not a lecture:
   the vault fills itself through triggers (a correction, a discovered quirk,
   session end — SCHEMA's "When Claude writes" section), not through writing
   sessions; after a week or two of normal work, run `/lint-vault` and prune
   together; `/work-state-vault` snapshots an ongoing effort so the next
   session resumes it.
