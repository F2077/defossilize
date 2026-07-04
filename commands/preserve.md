---
description: Pin a feature's "why" in code while you still understand it, so it doesn't fossilize later. Captures intent (Mozi 故/理/类), the intent-to-code decision path with rejected alternatives, drift-resistant signs (why-comments, a reading tour, characterization tests), and a self-explanation score. Run after `simplify`, one feature at a time.
---

# Preserve: lock in the "why" while it's fresh

This is the best moment to pin a feature's theory: context is fresh, so you capture the signs (intent debt down) and cement the theory in your own head by explaining it (cognitive debt down). Later this costs a `thaw`, or for real fossils an `excavate` + `revive`. Run it on one feature at a time.

## Resume protocol (across sessions)

- Before step 1: read `docs/defossilize/<feature>/_progress.md`. If it shows an in-progress run of THIS command for this feature, tell the user where they paused (step name and next action) and ask whether to resume there or start over; resume is the default. If it shows a different in-progress command for this feature, flag that and suggest finishing it first.
- After each step: rewrite `_progress.md` with `command`, `unit`, `status: in-progress`, the current `step` and `step_name`, the `done` list, and a one-line `next` action, plus the `updated` date.
- On completion: delete `_progress.md`.

`_progress.md` is workflow state, not a sign; `curate` ignores it. Run `/defossilize:continue` to see everything in flight.

## When to run

After `simplify` (feature done, code clean, context fresh), or any moment in development when you understand the code right now. Not for code you've already forgotten: that's `thaw`. Not for code you never understood (legacy or an AI black box): that's `excavate` + `revive`.

## Inputs

The feature's code; `git log` and `git diff` for the feature; the brainstorming spec and writing-plans plan if they exist; recent `simplify` and `code-review` findings. These are the "why" sources that will evaporate, so capture them now while they're complete.

## Workflow

### 1. Scope to one feature

The user points at the feature (name, files, recent diff, or spec). Restate the scope in one sentence and confirm. If it's too large, split it into sub-features and preserve one at a time.

### 2. Declare intent (Mozi 故/理/类), challenged Socratically

Produce an `intent-spec` using the three-layer Mozi schema below. Challenge vague intent with Socratic probing: concept clarification, boundary probing, dependency check, constraint tradeoff. Run a reductio (归谬): "if we do this, what's the worst case at 10x scale?" Record the answer in `risk_analysis`. Write `docs/defossilize/<feature>/intent.md`.

### 3. Record the intent-to-code decision path (ADR-lite)

For each non-obvious decision, write an ADR-lite entry: the decision, at least one rejected alternative, and at least one negative consequence.

Hard rule: an "explanation" with no rejected alternative and no stated downside is marketing, not understanding. Reject the entry and press for both. This rule is the core of the whole plugin. A decision you can't give a downside for is one you don't actually understand.

Write `docs/defossilize/<feature>/decisions.md`.

### 4. Propose drift-resistant signs (report, don't write yet)

Propose these as a report the user confirms or edits. Don't write them silently:

- why-comments: inline at each decision point in the code, English, one line distilling the ADR-lite (the decision plus the key rejected alternative). The code is the drift anchor; the comment moves with it.
- `docs/defossilize/<feature>/tour.md`: an ordered list of `(file:line, what to look at, beacon)` giving the reading order a future-you (or `thaw`) should follow.
- characterization tests: for the happy path and key invariants, in the project's normal test dir (`*_orient_test.*`). They're executable, so they go red the moment behavior changes.

No silent code edits. Present the proposal; the user confirms or edits.

### 5. Apply (minimal, faithful)

Apply the confirmed signs. why-comments are minimal one-liners (decision plus rejected alternative); tour entries point at real code; characterization tests pass.

### 6. Self-explanation checkpoint, then understanding-score

This is the cognitive-debt step. Without letting the user look at the code, ask them to explain 2 to 4 key decisions or data flows in plain language (Feynman). Compare each explanation against the code. Where their explanation diverges from what the code does, that's a gap: surface it and fill it, because the divergence is exactly where their theory is thinner than they thought. Tag user-stuck points as gaps to revisit.

Compute an understanding-score (below). Write `docs/defossilize/<feature>/understanding.md`.

### 7. Verify and summarize

Confirm the signs reference real code and the characterization tests pass. Report: N why-comments, 1 tour, M tests, the understanding-score, K gaps. Optional tech-debt handoff: suggest `simplify` or `code-review` for anything that surfaced.

## intent-spec schema (Mozi 故/理/类)

```
gu   故 (gù, "reason")     why this change (business driver / tech debt / user request)
li   理 (lǐ, "principle")  the approach or pattern (design principle / tech choice)
lei  类 (lèi, "category")  change category (feature / fix / refactor / perf)
constraints:          [ ... ]
acceptance_criteria:  [ ... ]
risk_analysis: { extreme_scenario: ..., fallback: ... }   # from the reductio probe
provenance: preserve
```

Use these exact characters: 故, 理, 类. Pinyin is only a reminder. Do not swap in homophones when you reconstruct; 故 means "reason", not 鼓 ("drum").

Stored as `docs/defossilize/<feature>/intent.md` (markdown; the exact field layout is finalized at run time). The `provenance: preserve` marker is mandatory. It tells `curate` this sign is authoritative: a contradiction later is drift or a bug, never a reconstruction error.

## understanding-score

Quantify "feels understood." Score the user's plain-language explanations of (a) key decisions, (b) the happy-path data flow, and (c) the main invariants, by how consistent they are with the code. Record the score and the per-item gaps in `understanding.md`. This is what makes cognitive debt visible and trackable: the score is the metric, the gaps are the to-revisit list.

## Guardrails (non-negotiable)

- Anti-paraphrase. Never restate what the code already shows. Signs answer only what the code can't: why, what was rejected, invariants, hidden coupling, failure modes.
- Every decision needs at least one rejected alternative and one negative consequence, or the entry is rejected. No exceptions.
- Report, confirm, apply. No silent code edits.
- Drift-resistance. Signs live only in their prescribed locations: standalone records in `docs/defossilize/<feature>/`, why-comments inline in code, characterization tests in the project test dir. Nothing else; no vector store, no parallel index. The only non-sign file allowed is `_progress.md`, workflow state for cross-session resume (see the Resume protocol).
- Provenance is `preserve` on every produced record (intent, decisions, tour, understanding) and every why-comment.
- Active by default. Self-explanation, Socratic, and Feynman are the default; passive is an escape hatch only.
- One feature per run. Split big features first.
- Never commit, push, add a remote, or open a PR. Edit the working tree only. On `main` or `master`, remind the user to branch first.
