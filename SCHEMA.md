# SCHEMA — how this vault is written and maintained

This vault is a compiled knowledge base shared between its owner and Claude.
Claude writes, the owner reviews (in Obsidian or any editor) and prunes. These
rules are what make the writer disciplined. When editing the vault, follow
them exactly.

## The core principle

**Add everything of value, but avoid junk.**

Junk is the history of the work, not its conclusions: who said what, what an
earlier attempt got wrong, "we then corrected", commit hashes as narrative,
verification dates on settled facts. Git holds all of that. State what is true
now, and why.

The opposite trap is easier to fall into while trimming: cutting so hard a note
turns superficial. Sufficiency is the goal, not brevity. A rule without its why
gets re-litigated, a contract missing an edge case gets misused, a gotcha
without its trigger can't be found again — that detail is value, keep it however
long the page gets. A short page is what you get from cutting junk, never from
dropping substance.

## Structure

```
vault/
├── INDEX.md          # catalog: every page, one line each — the only file read blind
├── SCHEMA.md         # this file
├── me/               # how the owner works — preferences, conventions, role
├── raw/              # immutable source material, one folder per research topic
├── stories/          # the owner's bookshelf — post-implementation narratives, unindexed
├── specs/            # implementation specs — flat, ticket-named, unindexed
├── scratch/          # session-bridging state, one file per project — the working-memory layer
├── skills/           # the vault-maintenance skills — REAL files live here;
│                     #  ~/.claude/skills/<name> symlinks in (install.sh wires it),
│                     #  so skill edits ride the vault's git
├── agents/           # custom agents (refuter) — same symlink arrangement
├── hooks/            # hook scripts install.sh symlinks into ~/.claude/hooks
└── <project>/        # one folder per project (created by /vault-init)
                      # each may have rules/ symlinking that repo's .claude/rules,
                      #  so path-scoped rules are browsable in Obsidian; the vault
                      #  tracks only the symlink, the rules live git-excluded in the repo
```

Project folders and `me/` are Claude's retrieval surface: everything in them is
indexed and lint-covered. `raw/`, `stories/`, and `specs/` are non-retrieval
shelves — evidence, personal reading, and implementation hand-offs — reached
only by explicit reference or the owner's ask. A spec is read when the owner
hands it to an implementing session ("implement per specs/X"); delete it once
the work ships (git history keeps it).

**A spec is compiled from the work-state page, never the source of it.** It
carries Goal / Scope / Out of scope / Implementation steps / Defaults and
nothing else. Verified facts, settled decisions, and open questions the
implementer doesn't clear all live upstream — in the work-state page or a
path-scoped rule — so that deleting the spec costs nothing. A durable page that
points at a spec for a contract has the dependency backwards.

There is no archive folder: **git history is the archive.** Deleted and
superseded content stays retrievable via git; live files are only what's
currently true.

**Top-level folders = one per project, plus `me/`. Inside a project folder,
stay FLAT.** Discovery happens through INDEX.md one-liners and wikilinks, not
folder trees. There is deliberately NO `shared/` folder — if two projects
genuinely share knowledge, one project's page owns it and the other links to
it. Restructuring (splitting indexes, nesting folders) happens only when the
owner asks for it, never on Claude's own initiative.

**Page names are `<scope>-<subject>`.** The scope is the narrowest durable
container the page belongs to — a sub-app, a long-running effort, an area — and
it is omitted when the page serves the whole project. A project with a mobile
sub-app has `mobile-design` and `mobile-push-notifications` for that app, while
`deploy-contract` stays bare because it serves the whole project. The prefix is
what makes a cluster readable in a flat folder, and its absence carries
information too. Two constraints:

- **Basenames are unique across the whole vault.** Wikilinks resolve by
  filename, so a duplicate silently resolves to the wrong project's page. A
  concept that recurs in two projects takes each project's own vocabulary
  (`local-dev` in one, `local-dev-env` in the other) rather than one shared
  name.
- **Never encode genre or status in a name.** Genre is frontmatter and lint
  reads it; a name carrying state goes stale.

Codebase-area knowledge does NOT live here — it lives in each repo's
`.claude/rules/*.md` as path-scoped rules, so it loads deterministically when
matching files are touched. Keep that layer git-excluded (via
`.git/info/exclude`) so a rule is exactly as personal as a vault page; sharing
one with the team is a deliberate move into the repo's checked-in docs.

The vault holds what no path can trigger: who the owner is, project
landscape/framework pages, work-state pages, and anything reached from a
symptom or a decision rather than a file (a 502 on the local site, how a parent
repo consumes a build, which stack a file belongs to). **Prefer a rule
whenever the paths are nameable** — a rule cannot be missed, while a vault page
depends on INDEX routing Claude to it.

## Raw sources (`raw/`)

Source material collected during design research — the ground truth that
compiled pages cite. Rules:

- **Immutable.** Claude reads raw files but never edits or rewrites them.
  Deleting a whole topic folder after its synthesis shipped is allowed
  (git history keeps it).
- **One folder per research topic** (`raw/<topic>/`), flat. Contents: saved
  article copies (markdown preferred — Obsidian Web Clipper works), PDFs, or
  at minimum an annotated `sources.md` (URL + date + why it mattered + key
  quote) since URLs rot.
- **Ingest** — when the owner drops sources in (or says "research X before we
  design"), Claude reads them, compiles the takeaways into a synthesis page
  (usually work-state while the design is open), cites the raw paths, and
  indexes the synthesis. The synthesis page is the retrieval surface.
- **Raw is never read during normal retrieval** — only the compiled pages
  are. Raw is reached exclusively through citations: a synthesis page names
  the exact raw paths behind its claims, and Claude opens one only to
  re-verify a challenged claim, to dig deeper than the synthesis when a
  decision needs it, or on direct request.
- **A raw file exists only because a page cites it** (or because its ingest
  is pending). Mid-session web sources get saved only when they are
  load-bearing for a recorded decision. A raw topic folder no page
  references is a lint finding: ingest pending or orphaned.
- Raw files carry no genre frontmatter and are not indexed in INDEX.md
  (the synthesis page links to its topic folder).

## Scratch (`scratch/`)

Session-bridging state — one file per project (`scratch/<project>.md`, named
after the repo folder): the current branch, in-flight uncommitted work, notes
waiting for their real home. This is the working-memory layer that replaces
Claude Code's auto-memory; the SessionStart hook injects the matching file at
the start of any session in that repo. Rules:

- Bullets carry absolute dates. Replace a superseded bullet with its
  conclusion, don't stack.
- Delete a bullet when its work commits or ships — git history keeps it. An
  empty scratch page is healthy.
- Exempt from genre frontmatter and the quality bar; the junk rule still
  applies (state what is true, not the session's story).
- Anything durable discovered along the way moves to its real page in the
  same change — scratch is never a fact's final home.

## Page genres

Every page declares its genre in frontmatter. The genre sets the maintenance
contract:

- **reference** — durable facts about how something works; true until the code
  changes; updated in place, never appended-to. No owner, no retirement plan:
  falsified claims are corrected or removed on discovery, the page deleted
  when its subject stops existing. Other genres distill into it.
- **work-state** — the current state of an ongoing effort: settled decisions,
  open questions, do-not-retry list. Carries a stable key so lint can check
  merge state: `tickets:` (Jira/Linear/issue IDs) where a tracker exists,
  otherwise `branches:` (git branch names). `[]` on both means retirement is
  manual, so avoid that. Also carries its own graduation TODO, destinations
  named in advance and updated as the owner settles them. Status lives in the
  body, never in frontmatter (frontmatter status drifts; lint.sh reads merge
  state from the key instead).
  **At each slice merge:** trim what is now history, graduate what is now
  proven (see Multi-ticket features), then delete that slice's spec and its
  queue line. A completed slice leaves no narrative behind.
  **Retirement is the last graduation, not the moment knowledge leaves.** Most
  facts should already be gone. Whatever remains at ship follows its reader,
  then the page is deleted (git history preserves it). **Deleting it is
  the owner's call alone**, never inferred from an emptied task list — only
  they know whether another slice is coming. **The destination is per
  fact, not per page, so one retirement usually splits several ways** — a rule,
  a reference page and a story out of the same effort is normal, not a sign
  something was filed twice:
  - feature-level rationale and invariants → the area's path-scoped rule
    (personal layer, zero repo footprint);
  - facts true beyond the feature (framework traps, general gotchas) → the
    rule or reference page where someone would actually hit them;
  - the derivation — how the design was arrived at, what broke on the way, the
    principles it taught → a story, whenever the owner asks for one;
  - team-visible homes (checked-in docs, READMEs, AGENTS.md) — only on the
    owner's explicit call, never as a default.

  A story never stands in for the others. Claude doesn't retrieve stories, so
  any fact a future session has to act on needs its rule or reference page too.

  A retirement that reads like a migration plan means graduation stopped
  happening at the slice merges.
- **me** — preferences and working conventions. Updated when feedback
  contradicts or refines them.
- **story** — a post-implementation teaching narrative for the OWNER's
  learning, not Claude's retrieval: problem → naive solution → why it breaks →
  the real derivation; real bugs kept in; principles at the end. **The owner
  decides what earns a story, and the trigger is their ask, not a rule about
  the subject.** Library internals, a bespoke design, a routine feature that
  took non-obvious calls — anything they want to understand rather than just
  remember can get one. Best written at the merge that prompts it, while the
  session, the spec and the un-retired work-state page are all still there; a
  later ask still works, since git history holds the retired page. What
  doesn't work is parking notes in scratch for a story nobody has asked for —
  those pile up unread. Written on request ("write the story of X"). Lives in
  `stories/`, unindexed; Claude never reads, edits, or lints a story unless
  the owner asks ("quiz me on X" uses it as the question source).
  Team-sharing is the owner's explicit call. Work-state pages may wikilink to
  their story.

## Multi-ticket features

A feature spanning several tickets has to get knowledge from ticket N to ticket
N+1 while the effort is still open. Holding everything until the ship event is
what makes a work-state page swell.

**Graduation is continuous, and its trigger is the fact's audience, not the
feature's completion.** Never ask "is the feature done?", ask "who needs this,
and when do they touch it?" Four answers, four homes:

- **Facts about a world the feature didn't create** (an API contract, a DSL
  trap, platform install mechanics) — needed by anyone touching that code, ever.
  Graduate to a path-scoped rule immediately; they were never work-state.
- **Conventions the feature set for itself** (which error channel, which
  component is the reference implementation) — needed by every later ticket in
  the same feature. Graduate as soon as a second ticket has to follow one:
  `.claude/rules/` while provisional, the repo's checked-in docs once the
  owner wants the team on it (their explicit call — those files are shared).
- **Sequencing and blockers** — what's next, who owes what, which gap blocks
  which slice. Never graduates, meaningless after ship. The queue page's job.
- **Live effort state** — what's built, which threads are open. Never
  graduates, dies with the page.

The first two are most of the volume and both can leave early. What can't leave
early is exactly what is worthless later.

Graduating mid-feature is safer than holding. A stale rule gets noticed, because
it loads whenever those files are touched, and it's corrected in one edit; a
stale fact inside a work-state page is never noticed, because nothing loads it
deterministically. Volatility argues for graduating early, not for waiting.

**The cluster.** A multi-ticket feature holds at most: one spine work-state page
(what it is, current built state, live threads, the task list, reuse boundary);
a promoted work-state page per slice that grew its own state; plus any reference
pages the feature revealed, which outlive it. A queue line earns its own page
when it has state rather than a description — blockers owned by someone else, a
mechanism a fresh session must understand before coding, or decisions that will
get re-litigated.

**The spine holds the task list.** Split it into a separate queue page only when
the tasks genuinely crowd out everything else, which the promotion rule above
makes rare: any task substantial enough to bloat the spine has already earned
its own page, so what is left in a queue is thin by construction. Two pages that
each open by pointing at the other are one page with a seam in it.

**The spine never grows a section per merged ticket.** Its built state is a
current-state list, not a log.

**The test: a work-state page gets smaller as its feature progresses.** Early it
is fat, because nothing is proven yet and it's the only place anything can go.
By the later slices most of what it held has moved to surfaces that load by
path. A page that grew across five tickets is the diagnostic that graduation
stopped.

## Writing rules

1. **One topic per page.** If a page needs a second `#` heading, it's two pages.
2. **Update, don't duplicate.** Before creating a page, check INDEX.md for an
   existing home. New facts about an existing topic go into the existing page.
3. **Delete what's wrong.** A falsified claim is removed, not annotated.
   Superseded work-state bullets are replaced by their conclusion, not stacked
   ("supersedes above" chains are forbidden — that's what git history is for).
   A **completed** item is deleted too, not struck through: `~~item~~ — DONE`
   is a stacked bullet in disguise. A do-next list holds only what is left.
3b. **A move is not a copy.** When a fact gets a new home (graduation to the
   team repo, a new skill, a restructure), slimming or deleting the old home
   is part of the SAME change — never left for later. Leftover copies are how
   drift starts.
4. **Facts, not narrative.** Write in spec voice, present tense, as if for a
   fresh reader with zero session context. No "we discovered", "this session",
   "the owner said" — state the rule and its why. (Exception: `owner decided X
   on <date>` is fine in work-state pages where provenance gates re-litigating.)
5. **Two summary lines, two jobs.** Every page starts with a one-line summary
   under the title — content-shaped, for the reader who already opened it
   ("what am I looking at?"). Its INDEX.md line is written separately as the
   trigger — `Read when <situation>: <keyword payload>` — for the reader
   deciding what to open ("when would someone need this page?"). Retrieval
   quality lives in the INDEX line; a vague one makes its page invisible.
   Coupling: whenever a page's scope changes, update its INDEX line in the
   same commit. Different wording, same maintenance moment.
6. **Carry the WHY.** A rule without its rationale gets re-litigated. One
   sentence is enough.
7. **Link related pages** with `[[wikilinks]]` (Obsidian-style, by filename
   without extension). A link to a page that doesn't exist yet is allowed — it
   marks a page worth writing.
8. **Dates are absolute** (2026-07-04, never "yesterday" / "last week").
9. **Code claims decay.** File paths and line numbers are point-in-time —
   verify against current code before acting on them if the page is old.

## The quality bar

Before saving, ask: **would a fresh session act differently for having read
this page?** If not, don't write it. "We fixed X in file Y" fails the bar
(git history records that); "X breaks when Y because Z — do W instead" passes.

## When Claude writes

- **On correction** — when the owner re-explains something or rejects an
  approach, that's proof of a knowledge gap. Update the relevant page in the
  same turn.
- **On discovered quirk** — non-obvious behavior found while working (build
  gotcha, hidden coupling, framework trap) goes into the relevant page or rule
  immediately, unprompted.
- **On session end** — after a significant piece of work wraps, distill
  decisions and discoveries into the relevant pages. Ask before creating whole
  new pages; update existing ones freely.
- **On leaving work in flight** — when a session ends with a branch mid-air
  (uncommitted work, an unpushed rebase, a decision pending), update the
  project's `scratch/` page so the next session resumes without re-deriving.
- **On synthesis worth keeping** — when an answer took real synthesis work
  (research pass, cross-source comparison, architecture analysis) and will
  plausibly be needed again, file it as a page instead of letting it die in
  chat history. The quality bar still applies; cite sources so the page can
  be re-verified.
- **On command ("lint the vault")** — two tiers: run `./lint.sh` first (free,
  mechanical: dead links, genres, INDEX coverage, strays, git state), then a
  judgment sweep for contradictions, duplicates, shipped work-state pages,
  stale scratch bullets, and quality-bar failures. The judgment sweep covers the
  WHOLE governing surface, not just vault pages: `~/.claude/CLAUDE.md`, the
  vault's `skills/`, and each project's `.claude/rules/` + `CLAUDE.local.md` —
  cross-surface duplication is the main drift source. It may run as a
  cheaper-model subagent that reads and reports; fixes are applied by the
  main loop, deletions/merges with approval. Finish by stamping
  `date +%F > .last-lint` so lint.sh can show how long it's been.

## What does NOT belong here

- Anything whose SYMPTOM leads to its answer in under a minute — greppable in
  code/git, or a web search you'd obviously know to run. Store the
  symptom→cause bridge, not the fact: a note earns its place when the symptom
  is silent or misleading (e.g. a build error pointing at an unrelated file),
  because that's when neither grep nor search can find it.
- Team-shareable repo conventions — those belong in the repo's checked-in
  docs (graduate them via PR/MR, then remove from here to avoid drift).
- Session-scoped context (branch state, what's uncommitted right now) in
  INDEXED pages — it lives only in the project's `scratch/` page. Disable
  Claude Code's auto-memory (`autoMemoryEnabled: false` in
  `~/.claude/settings.json`); the vault is the single memory surface.
- Secrets, credentials, other people's private information.
