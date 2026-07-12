---
description: Survey before you dig. Survey an unfamiliar system (inherited legacy or AI black box), rank units for revive. Run when taking over a system.
argument-hint: <system or directory>
---

# excavate: survey an unfamiliar system

When you inherit a system you don't yet understand, get the lay of the land first: where it's worth spending time to rebuild understanding, and where it can wait. Produce a system map (map.md) ranking the units to work on, and hand them to revive.

## Prep

1. Pick the object: turn `<system or directory>` into `<area>`; write the map to `docs/defossilize/<area>/map.md`.

## Workflow

1. Read the change history: use git history if you have it (frequently changed files, recent commits and PRs, where blame concentrates are all clues to understanding density); also sweep with structural heuristics (entry points, module layering, coupling, test sparseness). With no git history, fall back to structural heuristics alone; don't invent stories.
2. Pick units to rebuild: choose the units most worth rebuilding understanding for (usually 3 to 8). For each, estimate three things: understanding (0-100%), recoverability (high/medium/low), risk (what you'd trip over without understanding it, and the blast radius).
3. Rank and output: order by "high risk x high recoverability x low understanding" into map.md; call out cross-cutting themes (shared assumptions or contracts) in their own section.
   [milestone: hotspots-ranked]

## Output

System map `docs/defossilize/<area>/map.md`:

```markdown
# System map: <area>
provenance: excavate  ·  generated: <date>

## Overview
<what this system does; overall understanding first read>

## Units ranked (for revive)
| rank | unit | understanding | recoverability | risk | entry |
|---|---|---|---|---|---|
| 1 | <name> | <N>% | <high/med/low> | <…> | <file:line> |

## Cross-cutting themes
- <shared hidden assumptions or contracts: which units they span>
```

Progress `docs/defossilize/<area>/.progress.md` (format per preserve; excavate writes a milestone at hotspots-ranked).

## Constraints

- Only map the terrain and rank priorities; don't go deep on any single unit in this command (that's revive's job).
- Mark uncertain estimates as low-confidence; don't invent precise numbers.
- Don't fix bugs: if you find a real code bug, write a handoff to `docs/defossilize/handoffs/H<NNN>-<slug>.md` (id/title/severity/status:open/found_by/found_in/git_ref/created/location + evidence + suggested fix direction); don't fix it in this task.
