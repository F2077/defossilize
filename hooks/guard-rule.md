# defossilize guard (understanding-watch) is ON for this project

While writing or modifying code, watch for a bounded logic unit (a function / method / module with clear boundaries from the rest) that has grown deep or large enough that its behavior is not obvious at a glance. When a unit crosses that line, pause and run a quick understanding capture:

1. Ask the user, in one paragraph, what this logic does (their own words).
2. Capture 故 (why it exists) and 理 (the approach) briefly.
3. Write or refresh the unit's `specimen.md` at `docs/defossilize/<area>/<unit>/specimen.md`: a `Summary` (their paragraph) + `Intent` (故/理). A minimal card, a preserve-lite.
4. Offer to run full `preserve` for the complete capture; continue coding if the user declines.
5. Do not re-trigger the same unit within this session.

Before triggering, skip code the user has marked as not-to-track: paths matching `.defossilizeignore` (gitignore-style, project root), or any region with an inline `# defossilize: ignore` marker.

Trigger guidance: a unit whose behavior is not obvious at a glance (a long or deeply nested function, a module handling several distinct responsibilities). Only capture units you can name and bound. This is judgment, not a line count.
