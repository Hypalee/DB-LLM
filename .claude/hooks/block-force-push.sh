#!/usr/bin/env bash
# .claude/hooks/block-force-push.sh
# PreToolUse hook sur Bash : refuse tout git push --force vers main/master.
# Le hook reçoit sur stdin un JSON avec tool_input.command.

set -euo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')

# Détection d'un push force vers main ou master (variantes : -f, --force,
# --force-with-lease). On couvre aussi les push qui écrivent sur main
# via refspec (HEAD:main).
if printf '%s' "$cmd" | grep -qE 'git[[:space:]]+push.*(--force|--force-with-lease|[[:space:]]-f([[:space:]]|$))' && \
   printf '%s' "$cmd" | grep -qE '(main|master)'; then
  reason="Refusé : git push --force sur main/master est interdit par hook. Utilise une branche ou retire le --force."
  jq -nc --arg r "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
  exit 0
fi

# Autorise le reste.
exit 0
