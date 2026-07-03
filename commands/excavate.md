---
description: Map a fully-fossilized system — legacy you inherited, or an AI-outsourced black box you never understood. Triages the code, mines git history (commits/PR/blame) as degraded intent-fossils, and produces an unknown/confidence map (where understanding is thinnest, what's recoverable vs irrecoverable, risk-if-wrong) plus a ranked hotspot list to revive. Does NOT try to revive in one pass. Run when taking over a system. Adaptive — degrades gracefully when git is absent/squashed.
---

# Excavate — map the fossil, pick where to revive

You've taken over a system you don't understand — inherited legacy, or an AI-outsourced black box that was never yours to begin with. Cognitive debt here is an **area problem**: it blankets the codebase, so trying to "understand it all" in one pass is hopeless (Naur: a dead theory cannot be wholly resurrected from artifacts). Excavate solves the area problem first: **map the unknown**, then pick ranked hotspots to feed to `revive` one at a time. Excavate does NOT revive anything itself — it finds where to dig. **One system per run.**

## When to run

On taking over a legacy system, or when you realize a region is an AI black box you can't read. Run **before** `revive` (or `revive` runs in a degraded direct mode without a map). Not for code you wrote and just forgot — that's `thaw`.

## Inputs

The system's code; **git archaeology** — commits, PR/MR descriptions, blame, rename/move history — read as **degraded intent-fossils** (residue of departed authors' intent, NOT authoritative); any existing signs (usually absent — that's the point).

## Workflow

### 1. Scope — one system
The user points at the system (name / top-level dir / module boundary). Restate the scope and confirm. Too large → split by module/package; excavate one at a time.

### 2. Mine git fossils (adaptive — hard requirement)
Read commits, PR/MR descriptions, blame, and rename/move history as **degraded signs** — the best available source of what departed authors intended. These are fossils, not ground truth.

**Adaptive degradation (mandatory):** if the project is non-git, the history was squashed into one commit, or it was migrated with broken/disconnected history → **degrade** to code-structure heuristics + user pointers only, and explicitly mark the affected areas `recoverability: no-fossils` in the map. Do NOT invent git-derived intent when there's nothing to mine.

**Never bless git fossils blindly.** A commit message is a claim, not a fact. Cite the fossil as the *source* of a hypothesis; verify the hypothesis against the code before trusting it. If a fossil and the code disagree, the code wins and the fossil is flagged (it's a degraded sign — `curate`'s job later, but note it here).

### 3. Map the unknown
For each area (module / package / cohesive region), estimate and record (schema below): `area`, `understanding` (low/med/high; **no existing signs defaults to low**), `basis` (the signal set that produced the estimate), `recoverability` (recoverable from fossils/comments/structure → candidate for `revive`; or irrecoverable → candidate for **rewrite**, not understanding), and `risk_if_wrong` (blast radius / data safety / external contracts — what breaks if our understanding is wrong).

### 4. Select hotspots
Rank areas by the revival payoff: **`understanding=low` × `risk_if_wrong=high` × `recoverability=yes`**. Propose the top-N as hotspots to `revive`; the user confirms or adjusts the ranking. High-risk-but-irrecoverable areas are flagged for rewrite consideration, not revival.

### 5. Produce map
Write `docs/defossil/<system>/map.md` (persistent — it's the index for subsequent `revive` runs and is itself audited by `curate`).

## Hotspot signals (default set)

The signals that feed each area's `understanding` estimate and ranking:
- **Change frequency (churn)** — frequently-touched code is higher-value to understand.
- **Blast radius (dependents)** — how many callers/modules depend on this area; bigger = higher `risk_if_wrong`.
- **Complexity** — cyclomatic/structural complexity; higher = thinner understanding per unit effort.
- **Has-signs?** — absence of comments/ADR/tests = thinner (default low).
- **git-blame age** — older untouched code = intent more likely evaporated (the authors are gone).
- **User-reported scariness** — "this block scares me" is a high-quality signal; weight it.

## map.md schema

```
system: <name>
generated: <yyyymmdd>
git_available: yes | no | squashed | migrated-broken
areas:
  - area: <module/path>
    understanding: low | med | high
    basis: [signals that produced the estimate, e.g. "no comments", "10 dependents", "blame 4y old"]
    recoverability: recoverable | irrecoverable | no-fossils
    risk_if_wrong: <what breaks if we misread this — blast radius / data / external contracts>
hotspots_to_revive: [ranked area list, highest payoff first]
rewrite_candidates: [irrecoverable high-risk areas — understand-by-rewriting, not by reviving]
```

## Guardrails (inline, non-negotiable)

- **Anti-paraphrase.** The map answers "where is understanding thin / risky / irrecoverable" — NOT "what does the code do." No line-by-line code restatement.
- **Mark unknowns / irrecoverable honestly.** Never fabricate intent. If an area's intent can't be recovered from code + fossils, say `irrecoverable` and route it to rewrite consideration, not to a confident `revive`.
- **Git fossils are degraded signs.** Cite, don't bless. Verify against code before trusting; flag disagreements.
- **No silent code edits.** Excavate writes only `map.md`; it does not touch code.
- **One system per run.** Big systems are split by module first.
- **Never commit / push / add remote / open PR.** Edit the working tree only; on `main`/`master`, remind the user to branch first.
