#!/bin/bash
# Mechanical vault lint — the zero-cost half of "lint the vault".
# Judgment checks (contradictions, quality bar) still need a model pass.
cd "$(dirname "$0")" || exit 1
fail=0
note() { fail=1; echo "  ✗ $1"; }

# Indexed dirs = me/ + project folders. Shelves are exempt from genre/INDEX checks.
is_shelf() { case "$1" in raw|stories|specs|scratch|skills|agents|hooks|templates|assets) return 0;; *) return 1;; esac; }
indexed_dirs=""
for d in $(find . -maxdepth 1 -type d ! -name . ! -name '.*' | sed 's|^\./||'); do
  is_shelf "$d" || indexed_dirs="$indexed_dirs $d"
done

# Maps a vault project folder to its repo checkout, via projects.conf
# (lines of <folder>=<absolute path>, written by /vault-init).
repo_for() { grep -E "^$1=" projects.conf 2>/dev/null | head -1 | cut -d= -f2- | sed "s|^~|$HOME|"; }

echo "== dead wikilinks =="
pages=$(find . -name .git -prune -o -name .obsidian -prune -o -name "*.md" -print | xargs -n1 basename | sed 's/\.md$//')
grep -rhoE '\[\[[^]|]+' --include="*.md" --exclude="README.md" . | sed 's/\[\[//' | sort -u | grep -vxE "wikilinks?" | grep -vx "page-name" | while read -r link; do
  echo "$pages" | grep -qx "$link" || echo "  ✗ [[${link}]] resolves to no page"
done

echo "== dead path references (~/vault/... pointers) =="
grep -rnoE '(~|\$HOME)/vault/[A-Za-z0-9._/-]+' --include="*.md" . | sed 's/[.,;:]*$//' | grep -v '\.last-lint' | sort -u | while IFS=: read -r f ln ref; do
  rel="${ref#*/vault/}"
  # a bare ~/vault/ (a "~/vault/..." placeholder) points at the root, which exists
  [ -z "$rel" ] && continue
  [ -e "$rel" ] || note "${f#./}:$ln $ref resolves to no file"
done

echo "== frontmatter genre =="
find $indexed_dirs -name "*.md" 2>/dev/null | while read -r f; do
  grep -q "^genre:" "$f" || note "$f missing genre"
  if grep -q "^genre: work-state" "$f"; then
    grep -qE "^(tickets|branches):" "$f" \
      || note "$f is work-state without a stable key (tickets: for a tracker, branches: otherwise; [] if neither)"
  fi
done

echo "== INDEX coverage (story pages exempt — personal reading, not indexed) =="
for f in $(find $indexed_dirs -name "*.md" 2>/dev/null); do
  grep -q "^genre: story" "$f" && continue
  name=$(basename "$f" .md)
  grep -q "\[\[$name\]\]" INDEX.md || note "$f not listed in INDEX.md"
done
grep -oE '\[\[[^]]+\]\]' INDEX.md | sed 's/\[\[\(.*\)\]\]/\1/' | grep -v '^SCHEMA$' | grep -v '^page-name$' | while read -r entry; do
  find $indexed_dirs stories -name "$entry.md" 2>/dev/null | grep -q . || note "INDEX lists [[${entry}]] but no page exists"
done

echo "== work-state retirement radar (all ticket or listed branches merged => check due) =="
for f in $(find $indexed_dirs -name "*.md" 2>/dev/null); do
  grep -q "^genre: work-state" "$f" || continue
  project=${f%%/*}
  [ "$project" = "me" ] && continue
  repo=$(repo_for "$project")
  if [ -z "$repo" ] || [ ! -d "$repo" ]; then echo "  - $f: no repo mapping in projects.conf, retirement radar skipped"; continue; fi
  tickets=$(grep "^tickets:" "$f" | cut -d: -f2 | tr -d '[],')
  branches=$(grep "^branches:" "$f" | cut -d: -f2 | tr -d '[],')
  if [ -z "$(echo $tickets)" ] && [ -z "$(echo $branches)" ]; then echo "  - $f: no stable key, retirement is manual"; continue; fi
  base=""
  for b in master main; do git -C "$repo" show-ref -q "refs/remotes/origin/$b" && { base="origin/$b"; break; }; done
  [ -z "$base" ] && continue
  for t in $tickets; do
    unmerged=$(git -C "$repo" branch -r --no-merged "$base" 2>/dev/null | grep -c "$t")
    merged=$(git -C "$repo" branch -r --merged "$base" 2>/dev/null | grep -c "$t")
    if [ "$unmerged" -eq 0 ] && [ "$merged" -gt 0 ]; then
      note "$f: $t branches all merged — shipped? retirement check due"
    fi
  done
  unmerged_branches=""
  for br in $branches; do
    git -C "$repo" branch -r --merged "$base" 2>/dev/null | sed 's/^[* ]*//' | grep -Fqx "origin/$br" || unmerged_branches="$unmerged_branches $br"
  done
  if [ -n "$(echo $branches)" ] && [ -z "$unmerged_branches" ]; then
    note "$f: branches$branches all merged — shipped? retirement check due"
  fi
done

echo "== shipped history in work-state pages (struck-through or DONE/MERGED items belong deleted) =="
find $indexed_dirs -name "*.md" 2>/dev/null | while read -r f; do
  grep -q "^genre: work-state" "$f" || continue
  # Splitting on ** makes the even-numbered fields the bold ones, so a done/merged
  # in plain prose between two bold phrases is not mistaken for a bold marker.
  awk -F'\\*\\*' '
    /~~/ { print FNR " struck-through item, delete it instead of striking it"; next }
    /(^|[^A-Za-z])(DONE|MERGED)([^A-Za-z]|$)/ { print FNR " DONE/MERGED marker, delete the shipped item instead of narrating it"; next }
    { for (i = 2; i <= NF; i += 2) if ($i ~ /(^|[^A-Za-z])([Dd]one|[Mm]erged)([^A-Za-z]|$)/) { print FNR " bold done/merged marker, delete the shipped item instead of narrating it"; break } }
  ' "$f" | while read -r ln reason; do note "$f:$ln $reason"; done
done

echo "== raw topics (each must be cited by some page) =="
for d in raw/*/; do
  [ -d "$d" ] || continue
  topic=$(basename "$d")
  grep -rq "raw/$topic" --include="*.md" $indexed_dirs INDEX.md SCHEMA.md 2>/dev/null \
    || note "raw/$topic referenced by no page — ingest pending or orphaned"
done

echo "== scratch staleness (dated bullets older than 30d: stalled or shipped-but-not-deleted) =="
now=$(date +%s)
for f in scratch/*.md; do
  [ -f "$f" ] || continue
  grep -n "^- " "$f" | while IFS=: read -r ln line; do
    d=$(echo "$line" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
    [ -z "$d" ] && continue
    ts=$(date -j -f %Y-%m-%d "$d" +%s 2>/dev/null || date -d "$d" +%s 2>/dev/null)
    [ -z "$ts" ] && continue
    age=$(( (now - ts) / 86400 ))
    [ "$age" -gt 30 ] && note "$f:$ln bullet dated $d (${age}d old)"
  done
done

echo "== strays (non-md files outside .obsidian, raw/, hooks/) =="
# stories may hold html presentation material cited by a story page
find . -name .git -prune -o -name .obsidian -prune -o -name raw -prune -o -name hooks -prune -o -name assets -prune \
  -o -type f ! -name "*.md" ! -name ".gitignore" ! -name ".gitkeep" ! -name "lint.sh" ! -name "install.sh" \
  ! -name "projects.conf" ! -name "LICENSE" ! -name ".DS_Store" ! -name ".last-lint" \
  ! -path "./stories/*.html" -print | sed 's/^/  ✗ stray: /'

echo "== judgment lint age =="
if [ -f .last-lint ]; then
  last=$(cat .last-lint)
  days=$(( ( $(date +%s) - $(date -j -f %Y-%m-%d "$last" +%s 2>/dev/null || date -d "$last" +%s) ) / 86400 ))
  echo "  last judgment lint: $last (${days}d ago)"
else
  echo "  no judgment lint recorded yet — say 'lint the vault' to run one"
fi

echo "== git state =="
[ -n "$(git status --porcelain 2>/dev/null)" ] && echo "  ✗ uncommitted changes (sweep pending)"
upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)
if [ -n "$upstream" ]; then
  [ -n "$(git log "$upstream"..HEAD --oneline 2>/dev/null)" ] && echo "  ✗ unpushed commits"
else
  echo "  - no upstream configured — set a PRIVATE remote so the vault is backed up"
fi

echo "== done (anything marked ✗ needs attention; silence = clean) =="
