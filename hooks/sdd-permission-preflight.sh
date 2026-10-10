#!/bin/sh
# /sdd startup check 1: refuse to start in a permission mode that would prompt.
# Input: the UserPromptExpansion hook JSON on stdin. Only the hook input carries
# the live permission mode; the model cannot see it.
# auto, bypassPermissions: never prompt -> allow.
# dontAsk: denies instead of prompting, so the run cannot stall -> allow.
# plan: executes nothing -> refuse.
# default (Manual), acceptEdits: prompt -> allow only with the documented allowlist.
input=$(cat)

field() {
  printf '%s' "$input" | tr -d '\n' |
    sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p"
}

mode=$(field permission_mode)
args=$(field command_args)
guide="${CLAUDE_PLUGIN_ROOT}/skills/sdd/permissions.md"

# No slug: /sdd only lists the runnable slugs, unless exactly one exists, which it then runs.
slug=$(printf '%s' "$args" | tr -s '[:space:]' '\n' | grep -v '^--parallel$' | head -n1)
if [ -z "$slug" ]; then
  cwd=$(field cwd)
  runnable=$(cd "${cwd:-.}" 2>/dev/null &&
    ls -d .scratch/*/issues/*.md .scratch/*/map.md 2>/dev/null | cut -d/ -f2 | sort -u | wc -l)
  [ "${runnable:-0}" -eq 1 ] || exit 0
fi

refuse() {
  reason="/sdd refused to start: $1 Restart the session with \`claude --permission-mode auto\` (or press Shift+Tab until auto mode is on), or add the allowlist documented in $guide to the project's .claude/settings.local.json. Nothing was changed."
  reason=$(printf '%s' "$reason" | sed 's/\\/\\\\/g; s/"/\\"/g')
  printf '{"decision":"block","reason":"%s"}\n' "$reason"
  exit 0
}

# Settings files whose permissions.allow apply to this project.
project="${CLAUDE_PROJECT_DIR:-$PWD}"
allowlisted() {
  for f in "$project/.claude/settings.local.json" "$project/.claude/settings.json" "$HOME/.claude/settings.json"; do
    [ -f "$f" ] && grep -qF "$1" "$f" && return 0
  done
  return 1
}

case "$mode" in
  auto|bypassPermissions|dontAsk|"")
    exit 0 ;;
  plan)
    refuse "the session is in plan mode, which runs no edits or commands, so /sdd cannot work unattended." ;;
  default|acceptEdits)
    label=$mode; [ "$mode" = default ] && label="Manual (default)"
    missing=""
    if [ "$mode" = default ]; then
      allowlisted '"Edit"' || missing="$missing Edit"
      allowlisted '"Write"' || missing="$missing Write"
    fi
    allowlisted 'Bash(git commit' || missing="$missing Bash(git commit:*)"
    [ -z "$missing" ] ||
      refuse "the session is in $label mode and the allowlist is missing:$missing, so an unattended run would stall on a permission prompt."
    bash_allowed=$(for f in "$project/.claude/settings.local.json" "$project/.claude/settings.json" "$HOME/.claude/settings.json"; do
      [ -f "$f" ] && grep -oE 'Bash\([^)]*\)' "$f"
    done | sort -u | tr '\n' ' ' | sed 's/\\/\\\\/g; s/"/\\"/g')
    ctx="/sdd permission preflight: the session is in $mode mode and runs on the allowlist. Allowed Bash entries: $bash_allowed"
    printf '{"hookSpecificOutput":{"hookEventName":"UserPromptExpansion","additionalContext":"%s"}}\n' "$ctx"
    exit 0 ;;
  *)
    refuse "the permission mode \"$mode\" is unknown to /sdd." ;;
esac
