---
description: Pin a just-shipped feature's theory while context is fresh — declare intent (gu/li/lei), record the intent-to-code decision path, lay drift-resistant signs (why-comments + tour + characterization tests, provenance=preserve), and run a self-explanation checkpoint that scores understanding. Prevents fossilization. Run after simplify, on one feature at a time.
---

# Preserve — lock in the "why" while it's fresh (prevent fossilization)

Reduce **both** debts in the single highest-leverage moment: while context is fresh, create the signs (reduce intent debt) AND cement the theory in your head with self-explanation (reduce cognitive debt). This is the moment theory is cheapest to pin — later it costs a `thaw`, or for true fossils, an `excavate`+`revive`. **One feature per run.**

## When to run

After `simplify` (feature done, code clean, context fresh), or any "I understand this right now" moment in development. **Not** for code you've already forgotten — that's `thaw`. **Not** for code you never understood (legacy / AI black-box) — that's `excavate` + `revive`.

## Inputs

The feature's code; `git log` / `git diff` for the feature; the brainstorming spec and writing-plans plan if they exist; recent `simplify` / `code-review` findings. (These are the "why" sources that will evaporate — capture them now, while they're complete.)

## Workflow

### 1. Scope — one feature
The user points at the feature (name / files / recent diff / spec). Restate the scope in one sentence and confirm. Too large → split into sub-features; preserve one at a time.

### 2. Declare intent — Mozi gu/li/lei, challenged Socratically
Produce an `intent-spec` using the three-layer Mozi schema (below). Challenge vague intent with Socratic probing: concept clarification, boundary probing, dependency check, constraint tradeoff. Run **reductio** (归谬): "if we do this, what's the worst case at 10× scale?" → record the answer in `risk_analysis`. Write `docs/defossil/<feature>/intent.md`.

### 3. Record the intent→code decision path — ADR-lite
For each **non-obvious** decision, produce an **ADR-lite** entry: the decision + **≥1 rejected alternative** + **≥1 negative consequence**.

**Hard rule:** an "explanation" with no rejected alternative and no stated downside is marketing, not understanding — reject the entry and press for both. (This is the spine of the whole plugin: a decision you can't articulate a downside for is one you don't actually understand.)

Write `docs/defossil/<feature>/decisions.md`.

### 4. Propose drift-resistant signs — report, do NOT write yet
Propose (as a report the user confirms/edits), don't silently write:
- **why-comments** — inline at each decision point in the code, English, one-line distillation of the ADR-lite (the decision + the key rejected alternative). The code is the drift-anchor; the comment moves with it.
- **`docs/defossil/<feature>/tour.md`** — an ordered list of `(file:line, what to look at, beacon)` giving the reading order a future-you (or `thaw`) should follow.
- **characterization tests** — for the happy path / key invariants, in the project's normal test dir (`*_orient_test.*`). Executable → they go red the moment behavior changes.

**No silent code edits.** Present the proposal; the user confirms or edits.

### 5. Apply — minimal, faithful
Apply the confirmed signs. why-comments are minimal one-liners (decision + rejected alt); the tour entries point at real code; the characterization tests pass.

### 6. Self-explanation checkpoint → understanding-score
**The cognitive-debt step.** Without the user looking at the code, ask them to explain — in plain language (Feynman) — 2–4 key decisions or data flows. Compare each explanation against the code. Where their explanation diverges from what the code actually does, that is a **gap** — surface it and fill it (the divergence is exactly where their theory is thinner than they thought). User-stuck points are tagged as gaps to revisit later.

Compute an **understanding-score** (below). Write `docs/defossil/<feature>/understanding.md`.

### 7. Verify & summarize
Confirm the signs reference real code and the characterization tests pass. Report: N why-comments / 1 tour / M tests / understanding-score / K gaps. Optional tech-debt handoff: suggest running `simplify` / `code-review` for anything that surfaced.

## intent-spec schema (Mozi gu/li/lei)

```
gu (故 / why):     why this change (business driver / tech debt / user request)
li (理 / how):     principle or approach (pattern / design principle / tech choice)
lei (类 / scope):  change category (feature / fix / refactor / perf)
constraints:          [ ... ]
acceptance_criteria:  [ ... ]
risk_analysis: { extreme_scenario: ..., fallback: ... }   # from the reductio probe
provenance: preserve
```

Stored as `docs/defossil/<feature>/intent.md` (markdown; the exact field layout is finalized at run time). The `provenance: preserve` marker is mandatory — it tells `curate` this sign is **authoritative** (a contradiction later is drift/bug, never a reconstruction error).

## understanding-score

Quantify "feels understood": score the user's plain-language explanations of (a) key decisions, (b) the happy-path data flow, (c) the main invariants, by their consistency with the code. Record the score and the per-item gaps in `understanding.md`. This is what makes cognitive debt **visible and trackable** — the score is the metric, the gaps are the to-revisit list.

## Guardrails (inline, non-negotiable)

- **Anti-paraphrase.** Never restate what the code already shows. Signs answer only what the code can't: why, what was rejected, invariants, hidden coupling, failure modes.
- **Every decision needs ≥1 rejected alternative + ≥1 negative consequence** — or the entry is rejected. No exceptions.
- **Report → confirm → apply.** No silent code edits (carried from doc-sweep discipline).
- **Drift-resistance.** Signs live only in their prescribed locations: standalone records in `docs/defossil/<feature>/`, why-comments inline in code, characterization tests in the project test dir. Nothing else; no vector store, no parallel index.
- **Provenance = preserve** on every produced record (intent / decisions / tour / understanding) and why-comment.
- **Active by default.** Self-explanation / Socratic / Feynman is the default; passive is an escape hatch only.
- **One feature per run.** Big features are split first.
- **Never commit / push / add remote / open PR.** Edit the working tree only; on `main`/`master`, remind the user to branch first.
