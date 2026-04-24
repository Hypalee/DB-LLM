#!/usr/bin/env bash
# .claude/hooks/session-status.sh
# SessionStart hook : affiche l'état git au démarrage pour reset rapide
# du contexte (branche, dernier commit, ahead/behind, working tree).

set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 0
fi

branch=$(git branch --show-current 2>/dev/null || echo "detached")
last_commit=$(git log -1 --pretty=format:'%h %s' 2>/dev/null || echo "aucun commit")

dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
tree_status="propre"
[ "$dirty" != "0" ] && tree_status="$dirty changement(s) non committé(s)"

ahead_behind=""
if git rev-parse "@{u}" >/dev/null 2>&1; then
  ahead=$(git rev-list "@{u}..HEAD" --count 2>/dev/null || echo 0)
  behind=$(git rev-list "HEAD..@{u}" --count 2>/dev/null || echo 0)
  if [ "$ahead" != "0" ] || [ "$behind" != "0" ]; then
    ahead_behind=" (↑$ahead ↓$behind vs upstream)"
  fi
fi

msg="📍 Session sur $branch$ahead_behind
   • Dernier commit : $last_commit
   • Working tree : $tree_status"

printf '%s' "$msg" | jq -Rsc '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: .
  }
}'
