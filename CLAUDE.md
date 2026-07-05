# CLAUDE.md

Notes for Claude working in this repo. Public docs are README.md and docs/.

## The product is markdown prompts, not code

defossilize is a Claude Code plugin. Its commands are prompt files —
`commands/*.md`, one per slash command. No runtime, no build, no tests.
"Change a command" = edit prompt markdown. Design rationale lives in `docs/`.

## site/

- Self-contained static page → GitHub Pages via `.github/workflows/pages.yml`.
  **Pages publishes only the `site/` directory**, so any asset the page
  references must live inside `site/` (repo-root `logo.png` is unreachable
  from the published page; copy it in).
- Palette is deliberate ("strata / fossil" theme): `--bone --ash --ochre
  --oxblood --verdigris --ink` in `site/index.html :root`. Respect it on
  visual changes.
- Local verify: Playwright MCP blocks `file://`. Run
  `python3 -m http.server <port> --bind 127.0.0.1` inside `site/`, then open
  `http://127.0.0.1:<port>`. Screenshots land in `.playwright-mcp/` (gitignored).

## Releases

Pushing a semver tag triggers `release.yml`. Keep the tag in sync with
`version` in `.claude-plugin/plugin.json`. README §Releases has details.
