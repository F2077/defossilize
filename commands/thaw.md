---
description: Rebuild your grasp of a feature you wrote but can no longer read. Run on demand when you're rusty on your own code. Ephemeral by default.
argument-hint: <feature>
---

# Thaw: rebuild the theory from the signs

You wrote this feature once but can no longer read your own code. You know what it is, not why it's written this way. It's half-fossilized: the theory has gone from your head, but the signs `preserve` laid down are still there. Thaw rebuilds the theory in your head (the interpretant) from those signs, and audits the signs for drift while doing it. Ephemeral by default: nothing is written unless you confirm a gap-fill.

## When to run

On demand, when you're rusty on your own code. If no `docs/defossilize/<unit>/` signs exist, fall back to a cold rebuild (purely active, nothing persisted) and offer `preserve` if the user wrote it and just never captured it, or `excavate` + `revive` if it's code they never actually understood. A fossil is not a forgotten feature.

thaw is session-scoped: it doesn't write a `_progress.md`, so the rebuild doesn't carry over to a new session. For a durable rebuild, use `revive`.

## Workflow

### 1. Scope, then load and audit the signs (provenance-aware)

Read `tour.md`, `decisions.md`, `intent.md`, `understanding.md`, the inline why-comments, and the characterization tests. Audit each for drift before trusting it: broken `file:line` links, stale references, failing tests, records that contradict the code. Flag drift; never trust it silently. Broken signs are handed off to `curate` (that's intent debt surfacing).

Read provenance on every sign. For `provenance=revive` signs, say so plainly: this is a reconstruction, and if it contradicts the code the reconstruction may be wrong (a `curate` Type E), not ordinary drift. For `provenance=preserve` signs, a contradiction is ordinary drift (A/C) or a suspected bug (B). This framing changes how contradictions get weighed during the rebuild.

### 2. Coarse orient (one screen, passive)

Entry points, shape, where things live, the happy-path data flow. Just the map, one screen. This is the only deliberately passive step; it gets the user re-situated fast.

### 3. Socratic rebuild (active, adaptive depth; the core)

Have the user explain, predict, and confirm or reject hypotheses. Skip what they're solid on; go deep where they're shaky. Techniques:

- Feynman: the user explains a block in plain language; you compare it to the code and surface divergences as gaps.
- Deconstruction: surface the code's unstated assumptions (about external API shapes, input formats, system state, data volume) and rate each assumption's risk if it fails.
- Reductio (归谬): for each key branch, walk normal, extreme, and failure scenarios and predict behavior.

Never paraphrase the code. Only answer what the code can't: why, what was rejected, invariants, hidden coupling, failure modes. If you catch yourself restating what a loop does, stop. That's the code's job.

### 4. understanding-score

Same mechanism as `preserve`: score the user's plain-language explanations of key decisions, happy path, and invariants by consistency with the code. Record what's solid and what's still a gap. This is the metric that makes the rebuild, and any remaining cognitive debt, visible.

### 5. Ephemeral, with optional preserve-lite

Persist nothing by default. Thaw is a rebuild in conversation. If you find a gap the existing signs didn't cover, propose adding one why-comment (preserve-lite) at that point; the user confirms before anything is written.

### 6. Escape hatch

If the user says "just show me" or is getting frustrated, switch to a passive explanation for the rest of the session and respect their choice. Note that retention is weaker this way: passive reading rebuilds less theory than active self-explanation.

## Guardrails (non-negotiable)

- Anti-paraphrase. Never restate what the code already shows; answer only what it can't.
- Audit signs before trusting them, provenance-aware. Revive-origin signs might be wrong (E), not just drifted; preserve-origin signs are A/B/C.
- Active by default. Socratic, Feynman, and prediction are the default; passive is an escape hatch, not the starting mode.
- Ephemeral by default. Nothing is persisted unless the user confirms a gap-fill.
- Report, then confirm, for any proposed edit.
- Never commit, push, add a remote, or open a PR. Edit the working tree only on confirmed gap-fills. On `main` or `master`, remind the user to branch first.
