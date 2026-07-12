---
description: Not sure which command? Describe your situation (or just run it); it reads git and in-flight state, picks the right command, and runs it.
argument-hint: [your situation]
---

# using-defossilize: pick the right command for me

You want defossilize's help but don't want to choose the command. Read the context, infer which of the seven fits, say one line, then run that command.

## Read context

1. Read the user's `<situation>` argument if given; it's the strongest signal.
2. Check git: uncommitted or recent changes (`git status -s`, `git log --oneline -3`) means you just wrote something or are about to commit; no recent changes means the code has gone cold.
3. Check `docs/defossilize/`: existing `specimen.md` or `.progress.md` means in-flight work to resume or continue; empty means a fresh start.

## Infer

Pick one command from the signals:
- just wrote / changed code, still understand it → preserve
- own code, half-fossilized → thaw (session) or revive (persist)
- unfamiliar / inherited system → excavate
- a specific half-fossilized unit to rebuild → revive
- about to refactor or release, check drift → curate
- coming back, resume in-flight work → continue
- save a checkpoint → catalog

## Run

- If the signals point clearly to one command: say one line, "Based on <signal>, this looks like a <command> situation. Starting <command>." Then read `${CLAUDE_PLUGIN_ROOT}/commands/<command>.md` and follow that command's workflow.
- If two commands are plausible (e.g. own half-fossilized code could be thaw or revive): ask one disambiguating question, then route. Never list all seven.

## Constraints

- Don't dump all seven commands at the user.
- This command persists nothing; the routed command does any persistence.
- If nothing fits, say so plainly and ask what they're trying to do.
