# CLAUDE.md

Notes for Claude working in this repo. Public docs are README.md and docs/.

## The product is markdown prompts, not code

defossilize is a Claude Code plugin. Its commands are prompt files in
`commands/*.md`, one per slash command. No runtime, no build, no tests.
"Change a command" = edit prompt markdown. Design rationale lives in `docs/`.

## Commands and artifacts

Nine commands: seven lifecycle (`preserve`, `thaw`, `excavate`, `revive`,
`curate`, `catalog`, `continue`) plus `guard` (understanding-watch) and
`using-defossilize` (router). The metaphor is fossil / strata / archaeology
/ museum; it lives in command names and one-line descriptions only. Command
bodies (workflow, output, constraints) stay plain and functional.

Artifacts are lean and written into the TARGET project at
`docs/defossilize/<area>/<unit>/`, never into this repo. One `specimen.md`
(understanding card) plus `.progress.md` (milestone-based, durable,
context-rich) per unit. On demand: `map.md` per area (from `excavate`),
`handoffs/H<NNN>-<slug>.md` when a real bug is found, `curate-report.md`
when a drift report is wanted on disk. why-comments stay inline in source.
Progress is a milestone, not a step counter; `completed` files are kept.

## Hooks

`hooks/hooks.json` (plugin wrapper format). `guard`'s SessionStart
understanding-watch is opt-in: `guard on` sets `understanding-watch: on`
in the project's `.claude/defossilize.local.md`; the hook
(`hooks/guard-session-start.sh`) outputs `hooks/guard-rule.md` only when on
(env `DEFOSILIZE_UNDERSTANDING_WATCH` overrides; `.defossilizeignore` /
inline `# defossilize: ignore` skip code). Hook scripts use
`$CLAUDE_PLUGIN_ROOT` / `$CLAUDE_PROJECT_DIR`, `set -euo pipefail`, and
always `exit 0` (never block session start).

## Writing and originality

- **Language:** the plugin is written in English. Artifacts are produced in
  the user's working language by default (no explicit language step). For
  terms machine translation tends to get wrong, the correct Chinese follows
  in parentheses, most importantly *memory* (记忆, the understanding in
  someone's head, never 内存/RAM) and the Mohist axes 故 / 理 / 类.
- **Writing:** no em/en dashes, no translationese, no AI-coded words (key,
  ensure, leverage, robust, comprehensive, seamless, ...), no mechanical
  bold. Run `/humanizer` on command prose after substantive edits.
- **Originality:** present all content as original defossilize work, framed
  on the Mohist Canon (故/理/类), Peirce's meaning triangle, Storey's
  triple-debt model, and the "understanding-as-fossil" metaphor. Do not
  reference or hint at any external prior project in any shipped file.

## site/

- Self-contained static page → GitHub Pages via `.github/workflows/pages.yml`.
  **Pages publishes only the `site/` directory**, so any asset the page
  references must live inside `site/`. The logo lives at `site/logo.png`
  and is referenced from both the page and the README.
- Palette is deliberate ("strata / fossil" theme): `--bone --ash --ochre
  --oxblood --verdigris --ink` in `site/index.html :root`. Respect it on
  visual changes.
- Local verify: Playwright MCP blocks `file://`. Run
  `python3 -m http.server <port> --bind 127.0.0.1` inside `site/`, then open
  `http://127.0.0.1:<port>`. Screenshots land in `.playwright-mcp/` (gitignored).

## Releases

Pushing a semver tag triggers `release.yml`. Keep the tag in sync with
`version` in `.claude-plugin/plugin.json`. README §Releases has details.
