<div align="center">
  <img src="site/logo.png" alt="defossilize logo" width="240">

  <h1>defossilize</h1>

  <p><em>Turn fossil code back into understanding.</em></p>

  <p>A <a href="https://claude.com/claude-code">Claude Code</a> plugin that reduces <strong>intent debt</strong> and <strong>cognitive debt</strong> (the Sign and Interpretant of Margaret-Anne Storey's <a href="https://margaretstorey.com/blog/2026/06/23/three-threats-to-meaning/">triple-debt model</a>). Technical debt (the Object) is out of scope and left to other tools.</p>

  <p>
    <img alt="version" src="https://img.shields.io/badge/version-v0.2.0-8B4513">
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

Then run any command as `/defossilize:<command>`, e.g. `/defossilize:preserve`.

## Commands

| Command | What it does |
|---|---|
| `preserve` | Pin the why before it petrifies. Pin a feature's "why" into code while you still understand it. One feature at a time; run after `simplify`. |
| `thaw` | Re-grasp your own code you can no longer read. Loads the signs `preserve` left, orients you, then rebuilds via retelling or deconstruction. Session-scoped by default. |
| `excavate` | Survey an unfamiliar system (inherited legacy or AI black box), rank units for `revive`. Mines git history and structure; degrades gracefully without git. |
| `revive` | Rebuild understanding of one unit that has gone cold: you predict, the assistant reveals a confidence-rated hypothesis, then you check it against code. Never fabricates; marks irrecoverable intent as `unknown`. |
| `curate` | Before a refactor or release, reconcile comments/docs/specs/signs with the code. Classifies each mismatch (drift, invariant violated, stale reference, out-of-scope, reconstruction-was-wrong); after you confirm, fixes only the artifacts, not the logic. |
| `continue` | See in-flight work and pick up where you left off. Run when you come back and don't remember where a run stopped. |
| `catalog` | Save a manual checkpoint. Use it to pause inside any in-flight command, or call standalone bound to a unit. |
| `guard` | Toggle the understanding-watch. On = while coding, the model pauses to capture your understanding when a logic unit grows deep/large. Opt-in, persists per project. |
| `using-defossilize` | Not sure which command? Describe your situation; it reads git and in-flight state, picks the right command, and runs it. |

Signs live in the **target project** at `docs/defossilize/<area>/<unit>/` (`specimen.md`, `.progress.md`, and for legacy `map.md`). One sign type stays in place: **why-comments inline in code**, because their location is the drift-resistance. No vector DB, no parallel store.

## Typical flow

- **About to forget code you just wrote** → `preserve` pins the why while it's fresh.
- **Wrote it, can't read it anymore** → `thaw` rebuilds the theory from the signs `preserve` left.
- **Inherited a black box** → `excavate` maps it, then `revive` rebuilds one hotspot at a time.
- **Signs and code have drifted apart** → `curate` reconciles them.
- **Need to stop mid-run** → `catalog` saves a checkpoint; `continue` picks it up later.

## Resuming across sessions

`preserve`, `excavate`, and `revive` write a small `docs/defossilize/<area>/<unit>/.progress.md` as they work, so a paused run can pick up in a later session. Run `/defossilize:continue` to see everything in flight and where each one stopped. Need to pause on purpose? `/defossilize:catalog` saves a manual checkpoint bound to the unit. (`thaw` is session-scoped by design; `curate` is safely re-runnable from scratch.)

## Understanding-watch (`guard`)

Opt-in, default off. Turn it on in a project where you want defossilize to watch your understanding while you code:

```
/defossilize:guard on
```

When on, the model watches for a bounded logic unit (a function / method / module with clear boundaries) that has grown deep or large, and pauses for a quick capture: you summarize what it does in one paragraph, it records 故/理 into the unit's `specimen.md`, and offers full `preserve`. It persists per project (a SessionStart hook re-enables it each session). Skip code you don't want tracked with a `.defossilizeignore` (gitignore-style) or an inline `# defossilize: ignore` marker. Turn it off with `/defossilize:guard off`.

## Theory roots

Peirce's meaning triangle (Object / Sign / Interpretant) mapped to software health via Storey's triple-debt model; Naur's *Programming as Theory Building* (theory lives in developers' heads, and a dead program usually can't be revived from docs alone, hence `revive`'s honesty about `unknown`s); the self-explanation effect (why every rebuild is active: predict and explain first, never passively outsource). Full references in the design doc.

## Status

v0.2.0: seven lifecycle commands (`preserve`, `thaw`, `excavate`, `revive`, `curate`, `catalog`, `continue`) plus `guard` (understanding-watch) and `using-defossilize` (router). See the design docs in [`docs/`](docs/).

## Releases

Releases are cut by pushing a semver tag. Pushing `v0.x.0` triggers the [`Release` workflow](.github/workflows/release.yml), which drafts a GitHub Release with auto-generated notes (PR/commit summary since the previous tag) and GitHub's built-in source archive assets.

```bash
git tag v0.2.0
git push origin v0.2.0
```

The release body notes any mismatch between the tag and the version in [`plugin.json`](.claude-plugin/plugin.json). Keep them in sync.

## Site

The project site lives in [`site/`](site/) and is published to GitHub Pages by the [`pages.yml` workflow](.github/workflows/pages.yml) on every push to `main` that touches `site/`. It is a self-contained static page (no build step). After enabling Pages in the repo settings (**Settings → Pages → Source: GitHub Actions**), it will be served at `https://f2077.github.io/defossilize/`.

## Contributing

Contributions are welcome. The project is early-stage, so please open an issue first to sketch what you'd like to change. See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the contribution workflow, and [`docs/`](docs/) for the design rationale behind each command before proposing structural changes.

## License

[MIT](LICENSE) © F2077

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=F2077/defossilize&type=Date)](https://star-history.com/#F2077/defossilize&Date)
