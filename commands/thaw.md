---
description: Rebuild your understanding of a feature whose code you've forgotten (half-fossilized). Loads and audits the signs (flagging revive-origin signs as possibly reconstruction-wrong), gives a one-screen orientation, then drives a Socratic rebuild (you explain, it fills the gaps) and scores understanding. Run on demand when you're rusty on your own code. Ephemeral — nothing is persisted unless you confirm a gap-fill.
---

# Thaw — rebuild the theory from the signs

You wrote this feature once but can no longer read your own code — you know *what* it is but not *why* it's written this way. Half-fossilized: the theory has evaporated from your head, but the **signs** (`preserve` laid them down) are still there. Thaw reconstructs the interpretant (your theory) from the signs, and audits the signs for drift while doing it. **Ephemeral by default** — nothing is written unless you confirm a gap-fill.

## When to run

On demand, when you're rusty on your own code. If no `docs/defossil/<unit>/` signs exist, degrade to a **cold rebuild** (pure active, nothing persisted) and offer to run `preserve` (if you wrote it and just never captured it) or — if it's code you never actually understood — `excavate` + `revive` (it's a fossil, not a forgotten feature).

## Workflow

### 1. Scope + load & audit the signs (provenance-aware)
Read `tour.md`, `decisions.md`, `intent.md`, `understanding.md`, the inline why-comments, and the characterization tests. Audit each for drift **before trusting it**: broken `file:line` links, stale references, failing tests, records that contradict the code. **Flag drift, never trust silently.** Broken signs → hand off to `curate` (that's intent debt surfacing).

**Read provenance on every sign.** For `provenance=revive` signs, say so explicitly: *"this is a reconstruction — if it contradicts the code, that may mean the reconstruction was wrong (curate Type E), not ordinary drift."* For `provenance=preserve` signs, a contradiction is ordinary drift (A/C) or a suspected bug (B). This framing changes how you weight contradictions during the rebuild.

### 2. Coarse orient (one screen, passive)
Entry points, shape, where things live, the happy-path data flow. Just the map — one screen. This is the only deliberately passive step; it gets you re-situated fast.

### 3. Socratic rebuild (active, adaptive depth — the core)
Have the user explain / predict / confirm-or-reject hypotheses. Skip what they're solid on; go deep where they're shaky. Techniques:
- **Feynman** — the user explains a block in plain language; you compare to the code and surface divergences as gaps.
- **Deconstruction** — surface the code's unstated assumptions (about external API shapes, input formats, system state, data volume) and rate each assumption's risk if it fails.
- **Reductio** (归谬) — for each key branch, walk normal / extreme / failure scenarios and predict behavior.

**Never paraphrase the code.** Only answer what the code can't: why, what was rejected, invariants, hidden coupling, failure modes. If you find yourself restating what a loop does, stop — that's the code's job.

### 4. understanding-score
Same mechanism as `preserve`: score the user's plain-language explanations of key decisions / happy-path / invariants by consistency with the code. Record what's solid vs. still-gap. This is the metric that makes the rebuild (and any remaining cognitive debt) visible.

### 5. Ephemeral; optional preserve-lite
Persist **nothing** by default — thaw is a rebuild in conversation. If you discover a gap the existing signs didn't cover, **propose** adding one why-comment (preserve-lite) at that point; the user confirms before anything is written.

### 6. Escape hatch
If the user says "just show me" / is getting frustrated, switch to a passive explanation for the rest of the session (respect autonomy). Note that retention is weaker this way — passive reading rebuilds less theory than active self-explanation.

## Guardrails (inline, non-negotiable)

- **Anti-paraphrase.** Never restate what the code already shows; answer only what it can't.
- **Audit signs before trusting — provenance-aware.** revive-origin signs might be wrong (E), not just drifted; preserve-origin signs are A/B/C.
- **Active by default.** Socratic / Feynman / prediction is the default; passive is an escape hatch, not the starting mode.
- **Ephemeral by default.** Nothing persisted unless the user confirms a gap-fill.
- **Report → confirm** for any proposed edit.
- **Never commit / push / add remote / open PR.** Edit the working tree only on confirmed gap-fills; on `main`/`master`, remind the user to branch first.
