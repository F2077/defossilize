---
description: See in-flight defossilize work and pick up where you left off. Run when you return and don't remember where a run stopped.
---

# Continue: see where you paused, and pick it back up

You switched sessions and forgot where a defossilize run stopped. This command finds every in-flight unit in the target project, tells you the command, the step, and the next action, and points you at the command that resumes it.

Named `continue` (not `resume`) so it doesn't clash with Claude Code's built-in `/resume`, which resumes a whole session.

## What to do

### 1. Find in-flight work

Scan `docs/defossilize/**/_progress.md` in the target project. Each file is one paused run, written by `preserve`, `excavate`, or `revive`. (`thaw` is session-scoped and `curate` is restartable, so neither writes one.)

If the project has no `docs/defossilize/` tree, or no `_progress.md` anywhere, there's nothing to continue. Skip to step 4.

`_progress.md` schema:

```
command: preserve
unit: login-redesign
status: in-progress
step: 4
step_name: Propose drift-resistant signs
done: ["1 scope", "2 declare intent", "3 decision path"]
next: Present proposed why-comments / tour / tests; wait for confirmation.
updated: 2026-07-03
```

### 2. Report

List every in-progress unit, one block each, newest `updated` first:

```
login-redesign  · preserve, step 4/7 (Propose drift-resistant signs)
  next: Present proposed why-comments / tour / tests; wait for confirmation.
```

If only one unit is in flight, default to it. If several, ask which to continue.

### 3. Route

Tell the user exactly which command resumes the run. The target command does the actual resume: when they run it, its resume protocol reads the same `_progress.md` and picks up at the recorded step.

Example: "To continue `login-redesign`, run `/preserve`. It will detect this paused run and resume at step 4."

Don't redo the unit's workflow from this command. `continue` is orientation and routing; the target command owns the resume.

### 4. Nothing to continue

If the scan is empty, say so plainly and suggest an entry point by situation: `/preserve` right after shipping a feature; `/excavate` for a system you inherited or an AI black box (then `/revive` on a hotspot); `/thaw` for your own code you've gone rusty on; `/curate` to fix drifted docs.

## Guardrails (non-negotiable)

- Read only. `continue` does not edit signs, code, or `_progress.md`. It scans and reports.
- `_progress.md` is workflow state, not a sign. Don't audit it, don't paraphrase it, don't treat it as intent.
- Never commit, push, add a remote, or open a PR.
