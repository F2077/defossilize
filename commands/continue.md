---
description: Pick up the trail. See in-flight work and pick up where you left off. Run when you come back and don't remember where a run stopped.
---

# continue: resume in-flight work

List every unit that isn't finished (by progress) and let the user pick one to continue. Read-only; it touches no artifacts.

## Workflow

1. Scan: read `docs/defossilize/**/.progress.md` and summarize into a table (area, unit, command, last milestone, updated, git drift).
2. Drift hint: compare each `.progress.md`'s `git_ref` to the current HEAD; if they differ, flag "code changed since checkpoint" and remind the user to look at what changed before resuming.
3. List checkpoints and handoffs: show `source: catalog` manual checkpoints first; also list handoffs in `docs/defossilize/handoffs/` with `status: open`.
4. Re-orient: once the user picks a unit, read its "Context (for resuming)" section to rebuild the understanding, present it, and state the next step (from the "Next" section).

## Constraints

- Read-only: writes no progress, changes no artifacts.
- If there's no `.progress.md`, say plainly "no in-flight work"; don't invent.
