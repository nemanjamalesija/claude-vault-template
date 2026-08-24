# INDEX

Catalog of every page. One line each; the line is the retrieval surface — read
this file first, then open only what the task needs. Writing rules: [[SCHEMA]].

Line format: `[[page-name]] — Read when <situation>: <keyword payload>.`
The situation is the trigger (what a session is doing or seeing when it needs
the page); the payload is the searchable summary of what the page holds. A
work-state page's line ends with `(work-state)`.

## me/

- [[how-i-work]] — Read at the start of any substantive session and when
  deciding scope, naming, comments, commits, phrasing, or how far to verify:
  role boundaries, code style, communication, commit boundaries.
- [[reply-style]] — Read (or edit) when Claude's replies drift into dense
  vocabulary or dragging: the exact text a UserPromptSubmit hook injects with
  every prompt. Edit the text here; it applies from the next message.

<!-- /vault-init adds one section per project below this line. Each project
     section opens with the repo path in parentheses and a note that
     codebase-area knowledge lives in that repo's .claude/rules/. -->

## scratch/

Session-bridging state, one file per project (rules in [[SCHEMA]]): the
SessionStart hook injects the matching file automatically at the start of any
session in that repo, so these need no trigger lines.
