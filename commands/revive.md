---
description: Bring one fossil hotspot back to understanding via predict, reveal, reconcile. Run on one hotspot, after `excavate` or directly.
argument-hint: <hotspot>
---

# Revive: bring a fossil hotspot back to life

Reverse-rebuild theory where there's none to start from. The code (plus git fossils) is the only ground truth; the user starts with roughly no theory. The protocol has to keep the cognitive labor, reading the code and judging it, on the human side. If it doesn't, this command turns into the passive outsourcing the research warns against, and you might as well not run it. Run it on one hotspot at a time.

## Resume protocol (across sessions)

Before step 1, read `docs/defossilize/<system>/<hotspot>/_progress.md`. If THIS command is in-progress here, report the paused step + next action and ask resume-or-restart (default resume); if a different command is in-progress, flag it. After each step, rewrite it with `command`, `unit`, `status: in-progress`, `step`/`step_name`, `done`, a one-line `next`, and `updated`; delete it on completion. It's workflow state, not a sign (`curate` skips it); `/defossilize:continue` lists in-flight work.

## When to run

After `excavate` selected a hotspot, or directly (degraded) when the user points at one. Not for code you wrote and just forgot: that's `thaw` (signs already exist there).

## Inputs

The hotspot's code; git fossils if any; `excavate`'s `map.md` entry for this hotspot if present; any existing signs (usually none).

## Core protocol: predict then reveal then reconcile (run per non-obvious decision point)

This is the spine of the command. Enforce the ordering. Run it for each non-obvious decision point in the hotspot.

| Phase | Who | What happens |
|---|---|---|
| 1. Predict | User, first | You (the AI) point at a code location and ask a question: "why do you think this exists?" or "what happens on input X?" The user reads the code and commits to a prediction. "I have no idea" is a valid low-confidence prediction; what matters is that they commit before you reveal anything. |
| 2. Reveal | AI, second | You offer your hypothesis: intent, at least one rejected alternative and one negative consequence (ADR-lite discipline), a `confidence` (high/med/low), and the code evidence it rests on. Answer why only; never restate what (anti-paraphrase). If the intent can't be supported by code plus fossils, mark it `unknown` and don't invent. |
| 3. Reconcile | User | The user cites code evidence to confirm, refute, or refine your hypothesis. If their prediction was right, that's high learning; record their insight. If your hypothesis fits the code better, they update their theory (active learning). If neither fits the code, mark it `unknown` and leave it for later or recommend a rewrite. |

## Why this protocol (read before each run)

Self-explanation research works by forcing the learner to commit before feedback. The commit is the moment understanding gets built. If you give your hypothesis first and the user just nods, this turns into the passive outsourcing an Anthropic RCT measured at about -17% on understanding. So the ordering is a hard rule, not a style preference.

The user reads and judges first. Your hypothesis is reconciliation feedback, never a shortcut past their judgment.

If the user can't or won't engage the code (rubber-stamping), pause and say so instead of revealing. A nodded-through hypothesis is worse than no hypothesis, because it feels like understanding without being any. A prediction of "I have no idea" is fine and engages the protocol honestly; silent agreement is not.

## Workflow

### 1. Scope and load the hotspot

Take the hotspot from `map.md` or a user pointer. Restate the scope and confirm. If it's too large, split it into sub-hotspots and revive one at a time. Load any git fossils and existing signs for this hotspot.

### 2. Per-decision predict, reveal, reconcile

Run the core protocol on each non-obvious decision point. Stay bounded: only non-obvious decisions (same threshold as `preserve`). Don't force coverage of every line. The point is understanding, not exhaustive documentation.

### 3. Deconstruct assumptions (carried from `thaw`)

Surface the code's unstated assumptions about external API shapes, input formats, system state, and data volume, and rate each assumption's risk if it fails. These are often where fossils hide their sharpest edges.

### 4. Propose drift-resistant signs (report, don't write yet)

Propose these as a report the user confirms or edits:

- why-comments: inline at each reconciled decision point, English, decision plus key rejected alternative.
- tour entries: appended to the hotspot's reading order.
- characterization tests: for the happy path and key invariants, in the project test dir.

Tag all of them `provenance=revive` with a `confidence`. These are reconstructions, not author intent, and `curate` has to know: a later contradiction is a candidate for Type E, not drift. No silent code edits.

### 5. Apply (minimal, faithful)

Apply the confirmed signs. why-comments are minimal (decision plus rejected alternative plus confidence marker); tour entries point at real code; characterization tests pass.

### 6. understanding-score: how much theory has been rebuilt

Same mechanism as `preserve`, but the semantics differ. This score measures how much theory has been rebuilt, starting near 0. A low score after revive is honest: it maps how much fossil remains, not a failure of the run. Record the score, per-item gaps, and the unknowns (irrecoverable decisions) in `understanding.md`.

### 7. Produce artifacts and hand off

Write `docs/defossilize/<system>/<hotspot>/{intent,decisions,tour,understanding}.md`, all `provenance=revive`. `intent.md` uses the Mozi 故(gù, "reason") / 理(lǐ, "principle") / 类(lèi, "category") schema, but `gu` 故 may legitimately be a reconstructed guess or `unknown`. That's epistemic honesty, not a defect. Use the exact characters 故, 理, 类; don't swap in homophones (故 is "reason", not 鼓 "drum").

Verify signs reference real code and characterization tests pass. Report: N decision points, K unknowns, the score, and how much fossil remains. For sub-areas the map marked `irrecoverable`, recommend a rewrite rather than continued reverse-engineering (tech-debt handoff).

## Guardrails (non-negotiable)

- Prediction first. No rubber-stamping. If the user can't engage the code, pause rather than reveal. "I have no idea" is acceptable; silent agreement is not.
- Anti-paraphrase. Answer why only; never restate what the code does.
- Every hypothesis needs at least one rejected alternative and one negative consequence, or an explicit `unknown`. Never fabricate intent the code plus fossils can't support.
- Report, confirm, apply. No silent code edits.
- Provenance is `revive` with a confidence on every produced record and why-comment. Reconstructions must be marked as such.
- One hotspot per run. Split big hotspots first.
- Never commit, push, add a remote, or open a PR. Edit the working tree only. On `main` or `master`, remind the user to branch first.
