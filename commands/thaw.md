---
description: Thaw out half-fossilized understanding. Re-grasp your own code you can no longer read. Run on demand when rusty; session-scoped, no persistence by default.
argument-hint: <feature>
---

# thaw: re-read your own half-fossilized code

For code you wrote but can no longer read, recover the understanding in this session. Unlike revive (which targets a fully unfamiliar unit via predict/reveal/check), thaw is your own code: you re-activate the fuzzy memory (记忆) through retelling and probing. Session-scoped by default: it writes nothing and records no progress.

## Prep

1. Pick the object: turn `<feature>` into `<area>/<unit>`. If a specimen.md exists, read it first.

## Workflow

1. Load existing leads: read the unit's understanding card (specimen.md) and the signs in the code, and lean on them to orient rather than starting from scratch.
2. Coarse locate: in one sentence, say which part of the code this thread lives in and what it does overall. If you can't, the leads are broken; go to the next step.
3. Rebuild understanding (pick one to force it out): Feynman retelling (have the user explain it as if teaching someone; where they stall is the gap), deconstruction (split into responsibilities and confirm each), or reductio (assume a premise is false, see what breaks, work backward to why it must be this way).
4. Score understanding (0-100%) and say what's still missing.
5. Handle gaps: if you find a "there should be a sign here but isn't" gap, suggest preserve to pin it down, so the understanding doesn't slip away again.

## Output

None by default; rebuilding happens in-session. Only if the user explicitly asks to keep it, write an understanding card (specimen.md, provenance = revive, a later rebuild).

## Constraints

- Session-scoped by default: writes nothing, records no progress.
- Mark uncertainty as unknown; don't invent.
- Don't fix bugs: if you find a real code bug, write a handoff (per preserve); don't fix it in this task.
