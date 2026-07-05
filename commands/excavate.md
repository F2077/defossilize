---
description: Map a system you don't understand (inherited legacy or an AI black box) and rank hotspots to feed to `revive`. Run when taking over a system.
argument-hint: <system>
---

# Excavate: map the fossil, pick where to revive

You've taken over a system you don't understand: inherited legacy, or an AI black box that was never yours. Cognitive debt here is an area problem. It blankets the codebase, so trying to "understand it all" in one pass is hopeless (Naur: a dead theory can't be wholly resurrected from artifacts). Excavate solves the area problem first: map the unknown, then pick ranked hotspots to feed to `revive` one at a time. Excavate does not revive anything itself; it finds where to dig. Run it on one system at a time.

## Resume protocol (across sessions)

Before step 1, read `docs/defossilize/<system>/_progress.md`. If THIS command is in-progress here, report the paused step + next action and ask resume-or-restart (default resume); if a different command is in-progress, flag it. After each step, rewrite it with `command`, `unit`, `status: in-progress`, `step`/`step_name`, `done`, a one-line `next`, and `updated`; delete it on completion. It's workflow state, not a sign (`curate` skips it); `/defossilize:continue` lists in-flight work.

## When to run

On taking over a legacy system, or when you realize a region is an AI black box you can't read. Run before `revive` (otherwise `revive` runs in a degraded direct mode with no map). Not for code you wrote and just forgot: that's `thaw`.

## Inputs

The system's code; git archaeology (commits, PR/MR descriptions, blame, rename and move history) read as degraded intent-fossils, which is residue of departed authors' intent, not authoritative; any existing signs (usually absent, which is the point).

## Workflow

### 1. Scope to one system

The user points at the system (name, top-level dir, or module boundary). Restate the scope and confirm. If it's too large, split by module or package and excavate one at a time.

### 2. Mine git fossils (adaptive; required)

Read commits, PR/MR descriptions, blame, and rename/move history as degraded signs: the best available source of what departed authors intended. These are fossils, not ground truth.

Adaptive degradation is mandatory. If the project is non-git, the history was squashed into one commit, or it was migrated with broken or disconnected history, degrade to code-structure heuristics and user pointers only, and mark the affected areas `recoverability: no-fossils` in the map. Do not invent git-derived intent when there's nothing to mine.

Never bless git fossils blindly. A commit message is a claim, not a fact. Cite the fossil as the source of a hypothesis, then verify the hypothesis against the code before trusting it. If a fossil and the code disagree, the code wins and the fossil is flagged. It's a degraded sign; `curate` handles it later, but note it here.

### 3. Map the unknown

For each area (module, package, or cohesive region), estimate and record (schema below): `area`; `understanding` (low/med/high; no existing signs defaults to low); `basis` (the signal set that produced the estimate); `recoverability` (recoverable from fossils, comments, or structure, which makes it a candidate for `revive`; or irrecoverable, which makes it a candidate to rewrite rather than understand); and `risk_if_wrong` (blast radius, data safety, external contracts; what breaks if your understanding is wrong).

### 4. Select hotspots

Rank areas by revival payoff: `understanding=low` times `risk_if_wrong=high` times `recoverability=yes`. Propose the top N as hotspots to `revive`; the user confirms or adjusts the ranking. High-risk-but-irrecoverable areas are flagged for rewrite consideration, not revival.

### 5. Produce the map

Write `docs/defossilize/<system>/map.md`. It's persistent: the index for subsequent `revive` runs, and itself audited by `curate`.

## Hotspot signals (default set)

The signals that feed each area's `understanding` estimate and ranking:

- Change frequency (churn): frequently touched code is higher-value to understand.
- Blast radius (dependents): how many callers or modules depend on this area; bigger means higher `risk_if_wrong`.
- Complexity: cyclomatic or structural complexity; higher means thinner understanding per unit of effort.
- Has-signs?: absence of comments, ADRs, or tests means thinner (default low).
- git-blame age: older untouched code means intent more likely evaporated (the authors are gone).
- User-reported scariness: "this block scares me" is a high-quality signal; weight it.

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
    risk_if_wrong: <what breaks if we misread this: blast radius / data / external contracts>
hotspots_to_revive: [ranked area list, highest payoff first]
rewrite_candidates: [irrecoverable high-risk areas: understand-by-rewriting, not by reviving]
```

## Guardrails (non-negotiable)

- Anti-paraphrase. The map answers "where is understanding thin, risky, or irrecoverable," not "what does the code do." No line-by-line code restatement.
- Mark unknowns and irrecoverable honestly. Never fabricate intent. If an area's intent can't be recovered from code plus fossils, say `irrecoverable` and route it to rewrite consideration, not to a confident `revive`.
- Git fossils are degraded signs. Cite, don't bless. Verify against code before trusting; flag disagreements.
- No silent code edits. Excavate writes only `map.md` (and `_progress.md` for cross-session resume, per the Resume protocol); it does not touch code.
- One system per run. Split big systems by module first.
- Never commit, push, add a remote, or open a PR. Edit the working tree only. On `main` or `master`, remind the user to branch first.
