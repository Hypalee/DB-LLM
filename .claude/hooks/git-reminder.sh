#!/usr/bin/env bash
# .claude/hooks/git-reminder.sh
# Stop hook : rappelle l'état git à la fin d'un tour de Claude Code.
# Silencieux si working tree propre et tout pushé.

set -euo pipefail

# Pas dans un repo git → rien à dire.
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 0
fi

dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
branch=$(git branch --show-current 2>/dev/null || echo "")

unpushed=0
if [ -n "$branch" ] && git rev-parse "@{u}" >/dev/null 2>&1; then
  unpushed=$(git rev-list "@{u}..HEAD" --count 2>/dev/null || echo 0)
fi

if [ "$dirty" = "0" ] && [ "$unpushed" = "0" ]; then
  exit 0
fi

msg="Rappel git :"
if [ "$dirty" != "0" ]; then
  msg="$msg $dirty changement(s) non committé(s)"
fi
if [ "$unpushed" != "0" ]; then
  [ "$dirty" != "0" ] && msg="$msg •"
  msg="$msg $unpushed commit(s) non pushé(s) sur $branch"
fi

printf '%s' "$msg" | jq -Rsc '{systemMessage: .}'
