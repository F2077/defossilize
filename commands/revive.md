---
description: Bring a fossil hotspot back to life. Per non-obvious decision, runs a predict->reveal->reconcile protocol — YOU read the code and predict intent first, then the AI reveals its hypothesis (intent + rejected alternative + downside + confidence + code evidence, WHY not WHAT), then you reconcile against the code. Lays drift-resistant signs tagged provenance=revive + confidence, and scores how-much-theory-rebuilt (starts near 0; low is honest). Never fabricates — marks irrecoverable intent as unknown. Run on one hotspot at a time, after excavate or directly.
---

# Revive — bring a fossil hotspot back to life, predict→verify

Reverse-rebuild theory where there is none to start from. The code (+ git fossils) is the **only ground truth**; the user holds ~0 theory. The protocol MUST keep the cognitive labor — read code + judge — on the **human** side. If it doesn't, this command degrades into the passive outsourcing the research warns against, and you might as well not run it. **One hotspot per run.**

## When to run

After `excavate` selected a hotspot, or directly (degraded) when the user points at one. **Not** for code you wrote and just forgot — that's `thaw` (signs already exist there).

## Inputs

The hotspot's code; git fossils (if any); `excavate`'s `map.md` entry for this hotspot (if present); any existing signs (usually none).

## Core protocol — predict → reveal → reconcile (run per non-obvious decision point)

This is the spine of the command. **Enforce the ordering.** Run it for each non-obvious decision point in the hotspot.

| Phase | Who | What happens |
|---|---|---|
| **① Predict** | **USER, first** | You (the AI) point at a code location and ask a question: *"why do you think this exists?"* / *"what happens on input X?"*. The user **reads the code and commits to a prediction**. "I have no idea" is a valid low-confidence prediction — what matters is that they commit before you reveal anything. |
| **② Reveal** | **AI, second** | You offer your hypothesis: intent + **≥1 rejected alternative + ≥1 negative consequence** (ADR-lite discipline) + `confidence` (high/med/low) + the **code evidence** it rests on. Answers **WHY only, never restates WHAT** (anti-paraphrase). If the intent cannot be supported by code + fossils → explicitly mark it **`unknown`**; do not invent. |
| **③ Reconcile** | **USER** | The user cites code evidence to **confirm / refute / refine** your hypothesis. User's prediction was right → high learning, record the user's insight. Your hypothesis fits the code better → user updates theory (active learning). Neither fits the code → mark **`unknown`**, leave for later or recommend a rewrite. |

## Why this protocol (load-bearing — read this before every run)

Self-explanation research works by **forcing the learner to commit before feedback** — the commit is the moment understanding gets built. If you (the AI) give the hypothesis first and the user merely nods, this becomes the passive outsourcing the Anthropic RCT measured at roughly -17% on understanding. So the ordering is a hard rule, not a style preference:

**The user reads and judges FIRST. Your hypothesis is reconciliation feedback, never a shortcut past their judgment.**

If the user cannot or will not engage the code (rubber-stamping), **pause and say so** rather than revealing — a nodded-through hypothesis is worse than no hypothesis, because it feels like understanding without being any. A prediction of "I have no idea" is fine and engages the protocol honestly; silent agreement is not.

## Workflow

### 1. Scope + load hotspot
Take the hotspot from `map.md` or a user pointer. Restate the scope and confirm. Too large → split into sub-hotspots; revive one at a time. Load any git fossils and existing signs for this hotspot.

### 2. Per-decision predict → reveal → reconcile
Run the core protocol (above) on each **non-obvious** decision point. **Bounded:** only non-obvious decisions (same threshold as `preserve`) — do not force coverage of every line. The point is understanding, not exhaustive documentation.

### 3. Deconstruct assumptions (carried from `thaw`)
Surface the code's unstated assumptions — about external API shapes, input formats, system state, data volume — and rate each assumption's risk if it fails. These are often where fossils hide their sharpest edges.

### 4. Propose drift-resistant signs — report, do NOT write yet
Propose (as a report the user confirms/edits):
- **why-comments** — inline at each reconciled decision point, English, decision + key rejected alternative.
- **tour entries** — appended to the hotspot's reading order.
- **characterization tests** — for the happy path / key invariants, in the project test dir.

**All tagged `provenance=revive` + `confidence`** — these are reconstructions, not author intent, and `curate` must know (a later contradiction is a candidate for Type E, not drift). **No silent code edits.**

### 5. Apply — minimal, faithful
Apply the confirmed signs. why-comments are minimal (decision + rejected alt + confidence marker); tour entries point at real code; characterization tests pass.

### 6. understanding-score — "how much theory has been rebuilt"
Same mechanism as `preserve`, but the **semantics differ**: this score measures **how much theory has been rebuilt**, starting near 0. **A low score after revive is honest** — it maps how much fossil remains, not a failure of the run. Record score + per-item gaps + the unknowns (irrecoverable decisions) in `understanding.md`.

### 7. Produce artifacts + handoff
Write `docs/defossil/<system>/<hotspot>/{intent,decisions,tour,understanding}.md`, **all `provenance=revive`**. `intent.md` uses the Mozi gu/li/lei schema, but `gu` (the why) may legitimately be "reconstructed guess" or `unknown` — that is epistemic honesty, not a defect. Verify signs reference real code and characterization tests pass. Report: N decision points / K unknowns / score / how-much-fossil-remains. For sub-areas the map marked `irrecoverable`, **recommend rewrite** rather than continued reverse-engineering (tech-debt handoff).

## Guardrails (inline, non-negotiable)

- **Prediction-first.** No rubber-stamping. If the user can't engage the code, pause rather than reveal. "I have no idea" is acceptable; silent agreement is not.
- **Anti-paraphrase.** Answer WHY only; never restate what the code does.
- **Every hypothesis needs ≥1 rejected alternative + ≥1 negative consequence — OR an explicit `unknown`.** Never fabricate intent the code + fossils can't support.
- **Report → confirm → apply.** No silent code edits.
- **Provenance = revive + confidence** on every produced record and why-comment. Reconstructions must be marked as such.
- **One hotspot per run.** Big hotspots are split first.
- **Never commit / push / add remote / open PR.** Edit the working tree only; on `main`/`master`, remind the user to branch first.
