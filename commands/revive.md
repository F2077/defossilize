---
description: Dig one fossil back to life. Rebuild understanding of one unit that has gone cold: you predict, the assistant reveals a confidence-rated hypothesis, then you check it against code. One at a time; after excavate or standalone.
argument-hint: <unit>
---

# revive: rebuild one unit's understanding

For a unit whose understanding has been lost, build it back up. The method is a three-turn loop: you predict first, the assistant reveals a confidence-rated hypothesis, then you check it against the code.

## Prep

1. Pick the object: if a map.md exists for this unit, read its scores and cross-cutting themes first. Turn `<unit>` into `<area>/<unit>`; write the card to `docs/defossilize/<area>/<unit>/specimen.md`.

## Workflow

For each decision point in this unit (why it's designed that way), run the loop below.

1. User predicts first: before revealing anything, have the user give their own guess at "why is it written this way." They need to think first so they have an anchor when checking, and aren't led along.
2. Reveal a confidence-rated hypothesis: give a hypothesis with a confidence level and code evidence. high is direct evidence, medium is indirect with inference, low is mostly reasoning, unknown is honestly marked when you can't recover it; don't invent.
3. User checks against code: have the user take the hypothesis back to the code and confirm or refute it. Refutation is normal; rebuilding is iterative.
   [milestone: reveal-cycle-N] after each reveal-and-check round.
4. Macro-summary checkpoint: once all decision points are reconciled, have the user summarize, in one paragraph, what this unit does. A clear summary in their own words means the macro picture landed; a stall or muddle is a gap, so go back to the code. Save their summary into the card's Summary field (their words; polish only with their OK). Optionally, if they ask, also write it as a file-level doc comment.
   [milestone: summarized]
5. Wrap up: write the understanding card (specimen.md) with provenance = revive, each conclusion carrying its confidence.
   [milestone: reconciled]

## Output

Understanding card `docs/defossilize/<area>/<unit>/specimen.md`: same structure as preserve (summary, intent 故/理/类, decisions, reading tour, signs, understanding & open threads), provenance = revive, each conclusion annotated with [confidence].
Progress `.progress.md` (format per preserve; milestones at reveal-cycle-N and reconciled).

## Constraints

- Don't reveal before the user predicts; you want genuine engagement, not a rubber stamp.
- Mark uncertainty as unknown; better fewer conclusions than invented ones.
- provenance=revive conclusions may be wrong: when one conflicts with the code, suspect the rebuild first, not the code.
- Don't fix bugs: if you find a real code bug, write a handoff (per preserve); don't fix it in this task.
