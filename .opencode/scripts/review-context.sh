#!/bin/sh
# Prints compact, read-only git context for the /review* commands.
# It is injected into the command prompt, so the model does not have to
# figure out the scope (staged/unstaged/untracked, base branch, merge-base) itself.
#
# Usage:
#   review-context.sh local           uncommitted work: staged + unstaged + untracked
#   review-context.sh branch [base]   feature branch vs base branch, plus uncommitted summary

root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "ERROR: not inside a git repository."
  exit 0
}
cd "$root" || exit 0

# Runs a git command limited to reviewable files: skips this reviewer's own
# .opencode folder and lockfiles (huge and not reviewable).
scoped() {
  "$@" -- . \
    ':(exclude).opencode' \
    ':(exclude,glob)**/package-lock.json' \
    ':(exclude,glob)**/pnpm-lock.yaml' \
    ':(exclude,glob)**/yarn.lock' 2>&1
}

diff_files() {
  scoped git --no-pager diff --no-color --no-ext-diff "$@"
}

untracked_files() {
  scoped git ls-files --others --exclude-standard
}

status_short() {
  scoped git status --short --untracked-files=all
}

count_lines() {
  grep -c . || true
}

print_or_none() {
  output=$(cat)
  if [ -n "$output" ]; then echo "$output"; else echo "(none)"; fi
}

local_context() {
  echo "Staged files: $(diff_files --cached --name-only | count_lines)"
  echo "Unstaged files: $(diff_files --name-only | count_lines)"
  echo "Untracked files: $(untracked_files | count_lines)"
  echo
  echo "git status --short --untracked-files=all:"
  status_short | print_or_none
  echo
  echo "Tracked changes vs HEAD, staged + unstaged (git diff HEAD --stat):"
  diff_files HEAD --stat | print_or_none
  echo
  echo "Untracked files (not in git diff, read them in full):"
  untracked_files | print_or_none
}

# Picks the branch the current one diverged from most recently: the candidate
# with the fewest commits between its merge-base and HEAD. This follows the
# repository history instead of branch names, so a feature started from develop
# is compared with develop even when origin/HEAD points to master.
detect_base() {
  current=$1
  best=""
  best_count=""
  best_merge_base=""
  rivals=""
  seen=""
  candidates="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null) master main develop origin/master origin/main origin/develop"
  for candidate in $candidates; do
    case " $seen " in *" $candidate "*) continue ;; esac
    seen="$seen $candidate"
    [ "$candidate" = "$current" ] && continue
    git rev-parse --verify --quiet "$candidate^{commit}" >/dev/null || continue
    merge_base=$(git merge-base HEAD "$candidate" 2>/dev/null) || continue
    commits=$(git rev-list --count "$merge_base..HEAD")
    echo "  candidate $candidate: $commits commits since merge-base" >&2
    if [ -z "$best_count" ] || [ "$commits" -lt "$best_count" ]; then
      best=$candidate
      best_count=$commits
      best_merge_base=$merge_base
      rivals=""
    elif [ "$commits" -eq "$best_count" ] && [ "$merge_base" != "$best_merge_base" ]; then
      rivals="$rivals $candidate"
    fi
  done
  # Equal distance with the same merge-base gives the same diff, so it is not ambiguous.
  if [ -n "$rivals" ]; then
    echo "WARNING: ambiguous base branch. $best and$rivals are equally close but have different merge-bases. Picked $best. If that is wrong, run /review-deep <base-branch>." >&2
  fi
  echo "$best"
}

branch_context() {
  base=$1
  candidates_log=""
  current=$(git rev-parse --abbrev-ref HEAD)

  if [ -n "$base" ]; then
    how="given by the user"
  else
    how="auto-detected: the candidate with the fewest commits since merge-base"
    candidates_log=$(mktemp)
    base=$(detect_base "$current" 2>"$candidates_log")
  fi

  if [ -z "$base" ] || ! git rev-parse --verify --quiet "$base^{commit}" >/dev/null; then
    echo "ERROR: base branch not found${base:+: $base}. Ask the user to run /review-deep <base-branch>."
    [ -n "$candidates_log" ] && rm -f "$candidates_log"
    return
  fi

  merge_base=$(git merge-base HEAD "$base" 2>/dev/null) || {
    echo "ERROR: $base and the current branch $current have no common history (no merge-base). Ask the user to run /review-deep <base-branch> with the correct base."
    [ -n "$candidates_log" ] && rm -f "$candidates_log"
    return
  }

  echo "Current branch: $current"
  echo "Base branch: $base ($how)"
  if [ -n "$candidates_log" ]; then
    cat "$candidates_log"
    rm -f "$candidates_log"
  fi
  echo "Merge base: $(git log -1 --format='%h %s' "$merge_base")"
  echo "Diff range: $base...HEAD"
  echo "Commits in feature: $(git rev-list --count "$merge_base..HEAD")"
  echo "Changed files: $(diff_files --name-only "$merge_base" HEAD | count_lines)"
  echo "Diff command: git diff $merge_base HEAD"
  echo
  echo "Commits, oldest first:"
  git log --reverse --format='%h %s' "$merge_base..HEAD" | print_or_none
  echo
  echo "Changed files (git diff --stat $merge_base HEAD):"
  diff_files --stat "$merge_base" HEAD | print_or_none
  echo
  echo "Uncommitted changes, NOT part of the feature diff (git status --short):"
  status_short | print_or_none
}

case "$1" in
  local) local_context ;;
  branch) branch_context "$2" ;;
  *) echo "Usage: review-context.sh local | branch [base]" ;;
esac
