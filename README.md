# defossilize

A user-level [Claude Code](https://claude.com/claude-code) plugin that turns
**fossil code back into living understanding**. It reduces **intent debt** and
**cognitive debt** — the Sign and Interpretant of Margaret-Anne Storey's
[triple-debt model](https://margaretstorey.com/blog/2026/06/23/three-threats-to-meaning/).
Technical debt (the Object) is out of scope and delegated to other tools.

> Renamed from `meaning` (see `docs/2026-07-03-defossilize-plugin-design.md` §14).
> The top-level directory rename `meaning/` → `defossilize/` is user-managed
> (git); the plugin `name` in `plugin.json` is `defossilize` regardless.

## The idea: understanding is a fossilization spectrum

Code doesn't sit at two poles ("I fully understand it" vs "legacy black box").
It degrades along a continuous spectrum, and `defossilize` walks it back to
life. Crucially, **AI-outsourced code you no longer understand is also a
fossil** — the theory never truly lived in your head. So the same plugin covers
both "I wrote it and forgot" and "I inherited it / an AI wrote it and I never
understood it."

## Status

v1 implemented — five commands: `preserve`, `thaw`, `excavate`, `revive`,
`curate`. See the design doc and implementation plan in
[`docs/`](docs/) (dated 2026-07-03).

## Commands (the fossilization lifecycle)

| Stage | Command | What it does |
|---|---|---|
| Alive | `preserve` | Pin a just-shipped feature's theory while context is fresh — declare intent (Mozi gu/li/lei), record the intent→code decision path, lay drift-resistant signs, and self-explanation-score understanding. Prevents fossilization. Run after `simplify`. |
| Half-fossil | `thaw` | You wrote it but forgot the code. Loads & audits the signs, gives a one-screen orientation, then drives a Socratic rebuild (you explain, it fills the gaps) and scores understanding. Ephemeral. |
| Full fossil · dig | `excavate` | Map a legacy / AI-outsourced system you never understood. Triages the code, mines git history as degraded intent-fossils, produces an unknown/confidence map, and picks ranked hotspots. Does **not** revive in one pass. Adaptive — degrades when git is absent/squashed. |
| Full fossil · revive | `revive` | Bring one hotspot back to life. Per non-obvious decision, runs **predict → reveal → reconcile**: *you* read the code and predict first, then the AI reveals its hypothesis (intent + rejected alternative + downside + confidence + code evidence), then you reconcile against the code. Lays `provenance=revive` signs. Never fabricates — marks irrecoverable intent as `unknown`. |
| Maintenance | `curate` | A generalized doc-sweep: keep intent artifacts aligned with code. Classifies drift A/B/C/D plus **E** (reconstruction-was-wrong, for `revive`-origin signs) and routes those back to `revive` rather than fossilizing the misreading. |

Signs live in the **target project** at `docs/defossil/<unit>/`
(`intent.md`, `decisions.md`, `tour.md`, `understanding.md`, and for legacy
`map.md`). Two sign types stay in place — **why-comments inline in code** and
**characterization tests in the project test dir** — because their location is
the drift-resistance. No vector DB, no parallel store.

## Theory roots

Peirce's meaning triangle (Object / Sign / Interpretant) mapped to software
health via Storey's triple-debt model; Naur's *Programming as Theory Building*
(theory lives in developers' heads; a dead program usually can't be revived
from docs alone — hence `revive`'s honesty about `unknown`s); the
self-explanation effect (why every rebuild is *active* — predict/explain first,
never passive outsourcing). Full references in the design doc.
