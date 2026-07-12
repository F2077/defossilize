---
description: Watch for code about to fossilize. Toggle defossilize's understanding-watch. On = while coding, the model pauses to capture your understanding when a logic unit grows deep/large; opt-in, persists per project. Also: off, or status.
argument-hint: [on|off]
---

# guard: toggle the understanding-watch

`guard on` turns on the understanding-watch: while you code, the model watches for a bounded logic unit that has grown deep/large and pauses for a quick understanding capture (a one-paragraph summary + 故/理 into the unit's `specimen.md`, then offers full `preserve`). It's off by default; turn it on only in projects where you want it.

## Run

- `<arg>` is `on`:
  1. Write `understanding-watch: on` into the project's `.claude/defossilize.local.md` (YAML frontmatter; create the file and field if missing).
  2. Activate in this session: read `${CLAUDE_PLUGIN_ROOT}/hooks/guard-rule.md` and apply that rule for the rest of this session.
  3. Tell the user it's on and that it persists across sessions (the SessionStart hook re-injects it each session).
- `<arg>` is `off`:
  1. Write `understanding-watch: off` into `.claude/defossilize.local.md`.
  2. Stop applying the rule for the rest of this session.
  3. Tell the user it's off (no more guard triggers).
- no argument (status): read `.claude/defossilize.local.md` and the env var `DEFOSILIZE_UNDERSTANDING_WATCH`; report whether guard is on or off.

Env `DEFOSILIZE_UNDERSTANDING_WATCH=on|off` overrides the file.

## Constraints

- Don't capture code the user has marked to skip (`.defossilizeignore`, or an inline `# defossilize: ignore` marker).
- The quick capture writes the unit's `specimen.md`; it does not replace full `preserve` (offer it).
