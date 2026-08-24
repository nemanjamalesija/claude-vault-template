---
name: story-vault
description: Write a post-implementation, first-principles story of shipped work into ~/vault/stories/ for the owner's personal learning — or quiz them on an existing story. Invoke on /story-vault, "write the story of X", or "quiz me on X".
---

# Story (vault)

The story genre is defined in `~/vault/SCHEMA.md` (Page genres → story) — read
that first. The shape every story follows: each section starts from a problem,
shows the naive solution, breaks it, derives the real one; real bugs kept in;
extracted principles at the end. If the vault already holds a story, read the
most recent one before writing and match its shape — the first story you write
becomes the exemplar the rest follow. Written for the owner the learner, not
for Claude's retrieval.

## Writing ("write the story of X")

1. Gather the real history:
   - the current session itself, if the work happened in it — the discussions,
     dead ends, corrections, and bugs hit are the richest material (the
     failure is where the understanding lives);
   - the spec or design doc if one existed;
   - git log/diffs of the shipped work;
   - the work-state page — live if this runs during its trim-and-graduate
     pass, otherwise from vault git history — and the raw/ research topic if
     one fed the design.
2. Draft the narrative. Plain-language rules from `~/vault/me/how-i-work.md`
   apply.
   - **Calibrate depth to the owner's distance from the domain.** Dense
     shorthand works for their daily stack. For domains outside it (build
     tooling, deploys, ops, unfamiliar infrastructure), "first principles"
     includes the primitives themselves: derive what a hash, a symlink, a
     cache layer, or an atomic operation IS before using it in an argument.
     Name-dropping a primitive they don't own reads as assumed knowledge and
     breaks the derivation chain. Flow test: each section's problem should be
     created by the previous section's solution, stated explicitly at the seam.
3. Save as `~/vault/stories/<feature>-story.md` with `genre: story`
   frontmatter. Do NOT add it to INDEX.md — stories are unindexed by design.
4. Commit and push the vault per the sweep rule.

## Quizzing ("quiz me on X")

Read the named story, then ask questions one at a time — aimed at the
principles and the failure modes, not trivia. Grade honestly; where the owner
misses, point them to the section rather than just giving the answer.

Outside these explicit invocations, never read, edit, or lint story files.
