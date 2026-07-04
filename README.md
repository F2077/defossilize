# defossilize

A [Claude Code](https://claude.com/claude-code) plugin that turns fossil code back into understanding. It targets **intent debt** and **cognitive debt** (the Sign and Interpretant in Margaret-Anne Storey's [triple-debt model](https://margaretstorey.com/blog/2026/06/23/three-threats-to-meaning/)). Technical debt (the Object) is out of scope and left to other tools.

> Renamed from `meaning` (see `docs/2026-07-03-defossilize-plugin-design.md` §14). The top-level directory rename `meaning/` to `defossilize/` is user-managed (git); the plugin `name` in `plugin.json` is `defossilize` regardless.

## The idea: understanding is a fossilization spectrum

Code doesn't sit at two poles ("I fully understand it" versus "legacy black box"). It degrades along a continuous spectrum, and `defossilize` walks it back to life. AI-outsourced code you no longer understand is also a fossil: the theory never truly lived in your head. So the same plugin covers both "I wrote it and forgot" and "I inherited it, or an AI wrote it, and I never understood it."

## Status

v1 implemented, five lifecycle commands (`preserve`, `thaw`, `excavate`, `revive`, `curate`) plus `/defossilize:continue` for resuming a paused run across sessions. See the design doc and implementation plan in [`docs/`](docs/) (dated 2026-07-03).

## Commands (the fossilization lifecycle)

| Stage | Command | What it does |
|---|---|---|
| Alive | `preserve` | Pin a feature's "why" in code while you still understand it. Captures intent (Mozi 故/理/类), the decision path with rejected alternatives, drift-resistant signs (why-comments, a reading tour, characterization tests), and a self-explanation score. Run after `simplify`, one feature at a time. |
| Half-fossil | `thaw` | Rebuild your grasp of a feature you wrote but can't read anymore. Loads the signs `preserve` left, audits them for drift, gives a one-screen orientation, then walks you through a Socratic rebuild and scores what holds. Ephemeral by default. |
| Full fossil · dig | `excavate` | Map a system you don't understand, whether legacy or an AI black box. Mines git history as degraded intent-fossils, produces a map of where understanding is thinnest and what's recoverable, and ranks hotspots for `revive`. Does not revive anything itself. Degrades gracefully without git. |
| Full fossil · revive | `revive` | Bring one fossil hotspot back to understanding. For each decision it runs predict then reveal then reconcile: you predict first, the AI offers its hypothesis, you reconcile against the code. Lays `provenance=revive` signs. Never fabricates; marks irrecoverable intent as `unknown`. |
| Maintenance | `curate` | Check whether comments, docs, and decision records still match the code, and fix what's drifted. Classifies each mismatch (drift, stale reference, suspected bug, out-of-scope, reconstruction-was-wrong). Only fixes drift and stale references, after you confirm; bugs are flagged, and revive-origin contradictions go back to `revive`. |

Signs live in the **target project** at `docs/defossilize/<unit>/` (`intent.md`, `decisions.md`, `tour.md`, `understanding.md`, and for legacy `map.md`). Two sign types stay in place: **why-comments inline in code** and **characterization tests in the project test dir**, because their location is the drift-resistance. No vector DB, no parallel store.

## Resuming across sessions

`preserve`, `excavate`, and `revive` write a small `docs/defossilize/<unit>/_progress.md` as they work, so a paused run can pick up in a later session. Run `/defossilize:continue` to see everything in flight and where each one stopped. (`thaw` is session-scoped by design; `curate` is safely re-runnable from scratch.)

## Theory roots

Peirce's meaning triangle (Object / Sign / Interpretant) mapped to software health via Storey's triple-debt model; Naur's *Programming as Theory Building* (theory lives in developers' heads, and a dead program usually can't be revived from docs alone, hence `revive`'s honesty about `unknown`s); the self-explanation effect (why every rebuild is active: predict and explain first, never passively outsource). Full references in the design doc.
