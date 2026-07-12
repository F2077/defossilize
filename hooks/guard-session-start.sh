#!/usr/bin/env bash
set -euo pipefail
# defossilize guard (understanding-watch), SessionStart hook.
# Inject the guard rule only when enabled. Opt-in; default off.
# Precedence: DEFOSILIZE_UNDERSTANDING_WATCH env > .claude/defossilize.local.md > off.

state="off"
case "${DEFOSILIZE_UNDERSTANDING_WATCH:-}" in
  on|ON) state="on" ;;
  off|OFF) state="off" ;;
esac

if [ "$state" = "off" ] && [ -n "${CLAUDE_PROJECT_DIR:-}" ] && [ -f "$CLAUDE_PROJECT_DIR/.claude/defossilize.local.md" ]; then
  if grep -qE '^understanding-watch:[[:space:]]*on' "$CLAUDE_PROJECT_DIR/.claude/defossilize.local.md"; then
    state="on"
  fi
fi

if [ "$state" = "on" ] && [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -f "$CLAUDE_PLUGIN_ROOT/hooks/guard-rule.md" ]; then
  cat "$CLAUDE_PLUGIN_ROOT/hooks/guard-rule.md"
fi
exit 0
