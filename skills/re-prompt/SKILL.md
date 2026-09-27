---
name: re-prompt
description: Pre-clear handoff. Audit the current session for knowledge that has not landed in the vault, write what leaked, then emit the paste-ready prompt that starts the next fresh-context session without information loss. Invoke on /re-prompt, "give me the prompt for the next session", "prepare the handoff before I clear", or any ask for a resume/continuation prompt to use after clearing context.
---

# Re-prompt (pre-clear handoff)

The owner is about to clear this context window. Whatever this session knows and the vault does not is lost the moment they do. The skill has two steps, strictly in order: make the vault complete and current first, then emit the prompt. A great prompt pointing at an incomplete vault still loses information, and one pointing at a stale vault sends the next session down a road that closed.

## Step 1 — leak audit

Scan the WHOLE session, not just the recent turns, for each category below. For each hit, verify the fact actually landed in its home — open the page and look, don't trust that an earlier vault update covered it. A vault update mid-session proves nothing about what came after it.

- Settled decisions and the why behind each. Home: the effort's work-state page.
- Corrections the owner made (rejected approaches, re-explanations, style calls). Home: the relevant vault page, rule, or `me/` page.
- Traps and non-obvious quirks discovered while working. Home: a path-scoped rule when the paths are nameable, otherwise the relevant vault page.
- Do-not-retry items: things tried and abandoned, with the reason. Home: the work-state page.
- In-flight repo state: branch, uncommitted files, unpushed commits. Home: `scratch/<project>.md`.
- Open questions and who owes what. Home: the work-state page, phrased as instructions to the next session.

Write what leaked following the existing rules (`~/vault/SCHEMA.md`, the CLAUDE.md vault section) — this skill adds no writing rules of its own. If nothing leaked, say so and move on; do not invent updates to look thorough.

### Then prune the scratch page

The leak audit only adds. This part removes, and it is not optional: `scratch/<project>.md` is the first file the next session reads, so a stale bullet there does not sit quietly, it gets acted on. SCHEMA already sets these rules; the reason they need repeating here is that writing a bullet is cheap during a session and deleting one needs a check, so the deleting is what gets skipped.

- Delete every bullet whose work has committed or shipped. Git history keeps it.
- Replace a superseded bullet with its conclusion instead of stacking a newer one on top. Two bullets disagreeing about the same state is the failure mode. Newest-wins is a convention this session knows and a fresh one does not.
- Before cutting a bullet, grep the work-state page for anything durable inside it. If the fact is only in scratch, move it in the same change. Do not assume an earlier write covered it.
- What survives is the current branch and commit state, what is uncommitted and why, and what the next task needs settled before any code gets written.

Then read the pruned page as if you were the next session with no memory of this one. Every remaining bullet has to be true and actionable on its own.

Finish with the vault sweep (commit all, pull --rebase, push).

## Step 2 — emit the prompt

Output one paste-ready fenced block. Shape:

```
Continuing <effort> (<project>). Read <file list> before doing anything. Then <next action>.
```

Rules for the block:

- The read-list is only what the next session's first step depends on: the project's scratch file, the effort's work-state page, and any repo files INDEX cannot route to (docs, specs, exercise files). Everything else the standing CLAUDE.md spine and INDEX triggers already cover.
- The next action is the actual known next task. When the next task is not known (waiting on a reviewer, a decision), end with "Then wait for my next instruction" plus where the task will come from.
- The prompt carries pointers, never facts. If a fact feels like it must ride inside the prompt to survive, that is a step-1 leak: write it into the vault, then point.
- Keep it a few lines. The next session's context budget is the whole point of clearing; a bloated resume prompt spends what the clear just bought.

After the block, add one line stating what step 1 wrote, or that nothing had leaked, so the owner knows the handoff is safe before they clear.
