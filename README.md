# meaning

A user-level [Claude Code](https://claude.com/claude-code) plugin that reduces
**intent debt** and **cognitive debt** — the Sign and Interpretant of
Margaret-Anne Storey's
[triple-debt model](https://margaretstorey.com/blog/2026/06/23/three-threats-to-meaning/).
Technical debt (the Object) is out of scope and delegated to other tools.

## Status

Design only — see
[`docs/2026-07-01-meaning-plugin-design.md`](docs/2026-07-01-meaning-plugin-design.md).

## Components (planned)

- **`capture`** — run after `simplify`, while context is fresh: declare intent,
  record the intent-to-code decision path, lay drift-resistant signs, and run a
  self-explanation checkpoint that scores understanding.
- **`tour`** — on demand, when you have forgotten the code: rebuild
  understanding from the signs via Socratic dialogue, and audit the signs for
  drift.
- **`sweep`** — a generalized doc-sweep: keep intent artifacts (broader than
  docs: ADRs, specs, plans, commits, tests-as-specs) aligned with code.
