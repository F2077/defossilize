<div align="center">
  <img src="logo.png" alt="defossilize logo" width="240">

  <h1>defossilize</h1>

  <p><em>Turn fossil code back into understanding.</em></p>

  <p>A <a href="https://claude.com/claude-code">Claude Code</a> plugin that reduces <strong>intent debt</strong> and <strong>cognitive debt</strong> — the Sign and Interpretant of Margaret-Anne Storey's <a href="https://margaretstorey.com/blog/2026/06/23/three-threats-to-meaning/">triple-debt model</a>. Technical debt (the Object) is out of scope and left to other tools.</p>

  <p>
    <img alt="version" src="https://img.shields.io/badge/version-v0.1.0-8B4513">
    <img alt="license" src="https://img.shields.io/badge/license-MIT-green">
    <img alt="Claude Code" src="https://img.shields.io/badge/Claude%20Code-plugin-D97757">
  </p>
</div>


## About

Code doesn't sit at two poles ("I fully understand it" versus "legacy black box"). It degrades along a continuous spectrum, and `defossilize` walks it back to life. AI-outsourced code you no longer understand is also a fossil: the theory never truly lived in your head. So the same plugin covers both "I wrote it and forgot" and "I inherited it, or an AI wrote it, and I never understood it."

## Installation

Available via the `f2077` marketplace on GitHub.

**1. Add the marketplace in Claude Code:**

```
/plugin marketplace add F2077/defossilize
```

**2. Install the plugin:**

```
/plugin install defossilize@f2077
```

Then run any command as `/defossilize:<command>` — e.g. `/defossilize:preserve`.

## Commands (the fossilization lifecycle)

| Stage | Command | What it does |
|---|---|---|
| Alive | `preserve` | Pin a feature's "why" in code while you still understand it. Captures intent (Mozi 故/理/类), the decision path with rejected alternatives, drift-resistant signs (why-comments, a reading tour, characterization tests), and a self-explanation score. Run after `simplify`, one feature at a time. |
| Half-fossil | `thaw` | Rebuild your grasp of a feature you wrote but can't read anymore. Loads the signs `preserve` left, audits them for drift, gives a one-screen orientation, then walks you through a Socratic rebuild and scores what holds. Ephemeral by default. |
| Full fossil · dig | `excavate` | Map a system you don't understand, whether legacy or an AI black box. Mines git history as degraded intent-fossils, produces a map of where understanding is thinnest and what's recoverable, and ranks hotspots for `revive`. Does not revive anything itself. Degrades gracefully without git. |
| Full fossil · revive | `revive` | Bring one fossil hotspot back to understanding. For each decision it runs predict → reveal → reconcile: you predict first, the AI offers its hypothesis, you reconcile against the code. Lays `provenance=revive` signs. Never fabricates; marks irrecoverable intent as `unknown`. |
| Maintenance | `curate` | Check whether comments, docs, and decision records still match the code, and fix what's drifted. Classifies each mismatch (drift, stale reference, suspected bug, out-of-scope, reconstruction-was-wrong). Only fixes drift and stale references, after you confirm; bugs are flagged, and revive-origin contradictions go back to `revive`. |

Signs live in the **target project** at `docs/defossilize/<unit>/` (`intent.md`, `decisions.md`, `tour.md`, `understanding.md`, and for legacy `map.md`). Two sign types stay in place: **why-comments inline in code** and **characterization tests in the project test dir**, because their location is the drift-resistance. No vector DB, no parallel store.

## Typical flow

- **About to forget code you just wrote** → `preserve` pins the why while it's fresh.
- **Wrote it, can't read it anymore** → `thaw` rebuilds the theory from the signs `preserve` left.
- **Inherited a black box** → `excavate` maps it, then `revive` rebuilds one hotspot at a time.
- **Signs and code have drifted apart** → `curate` reconciles them.

## Resuming across sessions

`preserve`, `excavate`, and `revive` write a small `docs/defossilize/<unit>/_progress.md` as they work, so a paused run can pick up in a later session. Run `/defossilize:continue` to see everything in flight and where each one stopped. (`thaw` is session-scoped by design; `curate` is safely re-runnable from scratch.)

## Theory roots

Peirce's meaning triangle (Object / Sign / Interpretant) mapped to software health via Storey's triple-debt model; Naur's *Programming as Theory Building* (theory lives in developers' heads, and a dead program usually can't be revived from docs alone, hence `revive`'s honesty about `unknown`s); the self-explanation effect (why every rebuild is active: predict and explain first, never passively outsource). Full references in the design doc.

## Status

v0.1.0 — five lifecycle commands (`preserve`, `thaw`, `excavate`, `revive`, `curate`) plus `/defossilize:continue` for resuming a paused run across sessions. See the design doc and implementation plan in [`docs/`](docs/) (dated 2026-07-03).

## Contributing

Contributions are welcome. The project is early-stage, so please open an issue first to sketch what you'd like to change. See [`docs/`](docs/) for the design rationale behind each command before proposing structural changes.

## License

[MIT](LICENSE) © F2077
