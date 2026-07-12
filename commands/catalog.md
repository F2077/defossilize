---
description: Log a checkpoint. Save a manual checkpoint. Use it to pause inside any in-flight command, or call standalone bound to a unit.
argument-hint: [note]
---

# catalog: save a checkpoint

When you want to stop, or you hit a node worth recording, save it: log the current progress into a resumable checkpoint.

## Workflow

1. Determine the unit: if catalog is called inside an in-flight command (preserve/excavate/revive), bind to that unit; called standalone, ask the user which `<area>/<unit>` to bind.
2. Write the milestone: append one milestone to that unit's `.progress.md` (`source: catalog`, with the user's note), and update status / git_ref / updated / Next / Context (for resuming). Format per preserve.
3. Feedback: tell the user the checkpoint landed, where, and how to resume with continue.

## Constraints

- Write only one milestone; produce no other artifacts; change no code.
- If there's no context and you can't pin down the unit, ask before writing; don't attach it to the wrong place.
