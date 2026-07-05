# Contributing to defossilize

Thanks for considering a contribution. defossilize is early-stage, so before you write code or restructure a command, open an issue first to sketch what you want to change. This keeps work aligned and avoids throwaway PRs.

## Project shape

defossilize is a Claude Code plugin. The product is a set of slash commands (`commands/*.md`) plus design notes (`docs/`). There is no runtime, no build step, and no test suite — each command is a prompt that Claude Code executes. "Changing the code" usually means editing prompt markdown.

Each command's wording reflects deliberate choices grounded in the design notes (Peirce's meaning triangle, Storey's triple-debt model, Naur's theory building). Read the relevant notes in `docs/` before proposing structural changes to a command.

## How to propose a change

1. Open an issue describing the problem and the shape of the fix.
2. After agreement, branch from `main`: `feat/...`, `fix/...`, `docs/...`, `chore/...`.
3. Open a PR against `main`. Do not push directly to `main`.
4. Reference the issue in the PR body (`Closes #N`).

## Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/). Subject in English, imperative mood, ≤72 chars — for example `feat(preserve): ...`, `fix(thaw): ...`, `docs: ...`. One logical change per commit.

## Language conventions

- **Public-facing docs** (README, this file, command prompts): English. Command prompts are part of the plugin's public contract.
- **Inline implementation notes, TODOs, internal doc drafts**: Chinese is fine.
- **User-visible strings**: English.

## Releases

Releases are cut by pushing a semver tag (`v0.x.0`). The version also lives in `.claude-plugin/plugin.json` — keep the tag and that field in sync. See the [Releases](README.md#releases) section of the README.

## License

By contributing, you agree that your contributions are licensed under the [MIT license](LICENSE).
