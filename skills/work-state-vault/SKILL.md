---
name: work-state-vault
description: Create or update a work-state entry in ~/vault, graduate its proven facts as they ripen, close out a slice when its branch lands, or retire the page when the owner says so. Invoke on /work-state-vault, "snapshot this to the vault", "record where we left off", "<ticket> landed / the MR landed", or "retire <page>".
---

# Work-state (vault)

The work-state genre is defined in `~/vault/SCHEMA.md` (Page genres →
work-state) — read that first. It governs the frontmatter, the retirement
contract, and the writing rules; this skill is the *method*, not those rules,
so don't restate them. SCHEMA's Multi-ticket features section is the routing
table for every graduation below.

The entry's single job is **resumability**: a fresh-context implementer reads
it and can pick up exactly where the work stood. So capture what code and git
*can't* hand back — not a log of what was done.

**A page is the effort, and an epic is just a page whose task list has more
than one line.** There is no separate epic object to create.

**Three invocations, and the owner's words pick one.** Never infer the mode
from session context. If the invocation doesn't name an effort, ask which one —
don't guess from what the session happens to be doing.

## Updating — the default, nothing is ever deleted

1. **Find the home.** Pick the project folder (`~/vault/<project>/`) and check
   `INDEX.md` for an existing entry. If one exists, **update it in place**.
   Before creating a new page, check whether the effort's spine should absorb
   it — a slice earns its own page only once it has state rather than a
   description. New filenames follow SCHEMA's `<scope>-<subject>` convention.
2. **Gather from the session** — the material that would otherwise die in chat:
   - settled decisions **and the why** behind each (a rule without its
     rationale gets re-litigated);
   - corrections and choices where provenance gates re-opening them — write
     `owner's call (<absolute date>)`;
   - what was tried and rejected (the do-not-retry list), and traps discovered;
   - current state: what's implemented and **verified**, what's still
     uncommitted, the branch and ticket;
   - what's deferred, each with the concrete **trigger** that would revive it;
   - open questions phrased as instructions to the next session ("Confirm with
     the backend team that…").
3. **Write the page** — `genre: work-state` + `tickets:`/`branches:`
   frontmatter, a one-line content summary under the title, body in spec
   voice. Name the **graduation destination** for each durable fact, so the
   page gets emptied rather than left to drift.
4. **A slice that started without a spec — name its branch on its task line.**
   A planned task needs nothing; the branch goes on the line when work starts,
   and close-out matches against it.
5. **Graduate what's ripe.** On "X is done, moving to Y", or whenever writing
   the page turns up a fact that is already proven and already needed beyond
   this slice: move it to its path-scoped rule or reference page now, slim the
   page, and say what moved. Route by audience per SCHEMA — this is not gated
   on any merge, because a proven fact is proven whether or not the MR landed.
   A task that is built but not merged also moves out of the task list and
   into the built-state, with its in-flight branch named: the task list says
   what isn't built, not what hasn't landed. What is never touched here is the
   slice's spec and the page itself — until the merge, the spec is still what
   review judges against.
6. **Index it** — add or update its `INDEX.md` line in the SAME edit, written
   as a `Read when <resuming X / touching Y>: <keyword payload>` trigger,
   tagged `(work-state)`. A vague trigger makes the page invisible.
7. **Sweep the vault** — commit all pending vault changes, `git pull --rebase`,
   push, per the `~/.claude/CLAUDE.md` sweep rule.

## Closing out a slice — "`<ticket or effort>` landed, branch was `<name>`"

Run it when the MR/PR lands, not when it's approved: until then the spec is
still the contract review is judged against, and the task-list line is still
true.

1. **Verify that branch actually landed.** One check on the named branch — the
   pages don't get a vote, so if it didn't land, stop. Beware rebase-then-merge
   repos: commit hashes change on merge, so match commit messages against the
   target branch's log instead of trusting ancestry.
2. **Read the sources:** the page, the slice's spec if one exists, and the
   project's `scratch/` notes.
3. **Propose the plan, then stop.** Fact by fact: which rule or reference page
   it goes to, or the delete bucket. **The default bucket is delete** — if no
   future session acts differently for having it, it goes, and that bucket
   should be the biggest. Ask in the same breath whether the owner wants a
   story of this slice, since the session and the un-deleted page are the
   sources it needs. Nothing is written or deleted before they approve.
4. **On approval, write the destinations first.** Verify each by re-reading
   the destination file, not by remembering having written it. Only then
   delete the slice's spec and its task-list line, and rewrite the spine's
   built-state to current state — a current-state list, never a log of merged
   slices.
5. **Check nothing dangles.** Grep for the deleted spec both as a
   `[[wikilink]]` and as a `~/vault/...` path, run `./lint.sh`, then sweep.
6. **Report what is left on the page.** State it plainly and stop there —
   deleting the page is not this mode's call.

## Retiring the page — "retire `<page>`"

Only ever on the owner's explicit instruction. **Never inferred and never
proposed**, however empty the page looks: only they know whether more slices
are coming, and the deletion is one-way.

Run steps 1–5 above over whatever is left (no branch to verify unless they
name one), then delete the page and its `INDEX.md` line in the same edit.

Invoke only on explicit request.
