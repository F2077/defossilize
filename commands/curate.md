---
description: Keep the record honest. Before a refactor or release, reconcile comments/docs/specs/signs with the code. After confirmation, fix only the artifacts, not the logic.
argument-hint: [scope]
---

# curate: reconcile intent with code

Over time, comments, docs, specs, ADRs, and understanding cards drift from the code. curate does one pass: pull out each divergence, classify it, and after confirmation fix only the artifacts, not the code logic (unless it's a bug).

## Prep

1. Pick the object: scope is user-given (default: all of `docs/defossilize/`). Scan the understanding cards (specimen.md), signs, and related comments, docs, specs, and ADRs in that scope. This command is rerun anytime; it writes no progress.

## Workflow

1. Compare each: take every intent artifact against the current code and find all mismatches.
2. Classify (check the artifact's `provenance` first):
   - A Behavioral drift: the artifact's description contradicts what the code now does. Fix the artifact to match the code.
   - B Invariant violated: the artifact states an invariant the code breaks. This is a bug, not a doc problem. Don't change the artifact; write a handoff.
   - C Stale reference: the artifact names a file, symbol, or path that no longer exists. Fix the artifact.
   - D Out of scope: not in this run's target. Report only, don't touch.
   - E Reconstruction error: a provenance=revive artifact conflicts with the code (the rebuild was wrong). Send it back to revive for that point.
   A conflict with a preserve artifact counts as A (the artifact is stale); a conflict with a revive artifact counts as E (the artifact may be wrong). Same surface conflict, opposite handling by origin.
3. Confirm before acting: show the user the classification, then fix A/C and route B/E. Don't batch-edit without confirmation.
4. Output the report: give the drift report in conversation by default; only write curate-report.md to disk if the user asks.

## Output

Drift report (on demand) `docs/defossilize/<area>/curate-report.md`:

```markdown
# Drift report: <area> (<date>)

| class | location | finding | disposition |
|---|---|---|---|
| A | <file:line> | <artifact contradicts code> | artifact fixed |
| B | <file:line> | <invariant broken> | to handoff HNNN |
| C | <…> | <stale reference> | fixed |
| D | <…> | <out of scope> | reported only |
| E | <…> | <reconstruction wrong> | to revive |
```

## Constraints

- Touch only artifacts, not code logic. B is a bug; route to a handoff, don't fix it here.
- Provenance-aware: always check provenance before classifying.
- A newly found code bug (not drift) also goes to a handoff (per preserve).
