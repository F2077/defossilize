---
description: Audit whether a project's intent artifacts (signs) still match the code, then fix the drift. A generalized doc-sweep covering code comments/docstrings, prose docs, contract specs, ADRs/decision records, design specs and plans, commit messages and PR descriptions, tests-as-specs, AND this plugin's own docs/defossil/ records. Classifies each divergence A/B/C/D plus E (reconstruction-was-wrong, for revive-origin signs); fixes behavioral drift and stale references only after confirmation; flags invariant violations as suspected bugs; routes revive-sign contradictions back to revive. Use when signs may have drifted from code, after a refactor/rename/migration, before a release, or as routine hygiene.
---

# Curate — align intent artifacts (signs) with code

Check whether the project's **signs** — everything that carries the system's rationale — still describe what the code does, and fix the drift. **The code is the reference; the signs are checked against it. Classify every divergence before touching anything.**

Comments rot faster than code: someone renames a function, swaps an algorithm, and the comment now actively lies — worse than no comment, because the next reader *trusts* it. The goal is "remove false statements that mislead," not "make docs pretty."

The trap: when a sign contradicts the code, the lazy fix is to rewrite the sign to match. But sometimes **the sign was right and the code is the bug** — rewriting it then buries the bug under an updated lie. And for *reconstructed* signs (from `revive`), the opposite trap exists: the sign itself may be the misreading. So this command never blindly aligns signs to code; per finding it decides *which side is wrong*, and reads the sign's **provenance** to know which traps can fire.

## What counts as a sign (generalized set)

Intent artifacts are far broader than "docs." Anything that carries system rationale is a sign:

- Code comments & docstrings
- Project prose docs regardless of format — README, CHANGELOG, CONTRIBUTING, SECURITY, CODE_OF_CONDUCT, `docs/**`, any `*.md` / `*.rst` / `*.adoc` / `*.org` / `*.tex`
- Docs-as-code contract specs: OpenAPI/Swagger (`openapi.*`/`swagger.*`), `*.proto`, GraphQL (`*.graphql`/`*.gql`), JSON Schema / AsyncAPI
- **ADRs / decision records** (including this plugin's `decisions.md`)
- **Brainstorming specs + writing-plans plans** (design intent)
- **Commit messages + PR/MR descriptions** (delivery-time intent — also what `excavate` mines as fossils)
- **Tests-as-specs** (assertions encode expected behavior)
- **`excavate`'s `map.md`** (system-level intent map)
- Agent-instruction files (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, `.cursorrules`, `.windsurfrules`) → report-only
- Memory (`.claude/.../memory`, `.remember`) → report-only

## Self-audit — include this plugin's own records

This plugin's own outputs are signs and are **always in scope**:

- `docs/defossil/<unit>/{intent,decisions,tour,understanding}.md` and `docs/defossil/<system>/map.md` — audited as standalone records.
- **why-comments** inline in code and **characterization tests** in the project test dir are audited via their *code locations* (they live in place by design; their location is the drift-resistance).

When the target project has a `docs/defossil/` tree, you MUST include it — the plugin's whole premise is that its own signs stay self-consistent with the code.

## Classify every divergence — five buckets

Every discrepancy is one of five buckets; the bucket decides the action. Read the sign's **provenance** (`preserve` | `revive`) and **confidence** first — it determines whether bucket E can apply.

**Type A — Behavioral drift.** The sign *describes behavior* the code no longer matches, and the code is the deliberate, working behavior. → Edit the sign.
- *Tell:* surrounding code clearly works and was written this way; the sign just wasn't updated.
- *Example:* comment says "returns the user's email" but code returns the whole `User` after a refactor.

**Type B — Invariant / constraint violation.** The sign states a *rule or contract* the code breaks — words like must / always / never / required / invariant / callers must / throws if. → Do NOT touch the code. Do NOT rewrite the sign to bless the violation. Flag it as a suspected bug for a human. Invariant violations are high-value signals — silently "aligning" them hides real defects.
- *Example:* comment says "callers must hold the lock before calling" but the function reads shared state without acquiring it. Almost certainly a bug, not a doc problem.

**Type C — Stale references.** The sign points at things that moved or died: renamed symbols, removed functions, dead links, wrong file paths, wrong arg counts/signatures in examples, deprecated env vars, broken `file:line` links in `tour.md` / `map.md`. → Edit the sign (within scope) to point at the real thing.

**Type D — Out of edit scope.** The divergence is real but lives in an agent-instruction file or memory. → Report only; propose the corrected text but **do not write it** — these are the agent's own instructions and the user's personal memory; silently rewriting them is surprising.

**Type E — Reconstruction-was-wrong (only for `provenance=revive` signs).** A revive-origin sign contradicts the code, the code is the deliberate working behavior, and the contradiction is NOT ordinary drift (C) — the *reconstruction itself misread the code*. → Do NOT edit the sign to match the code (that would fossilize the misreading as if it were author intent). Do NOT flag the code as a bug (B). Mark the finding **"reconstruction-was-wrong"** and route the point back to `revive` for re-verification.
- *Tell:* sign carries `provenance: revive`; the code clearly and deliberately does something different from what the reconstructed intent claims; the sign isn't merely stale (the symbol it references still exists and behaves as claimed elsewhere — the reconstruction's *inference* was wrong).
- *Example:* a reconstructed `decisions.md` says "Login hashes with SHA-1 because the legacy DB column is 40 hex chars" but the code calls `lookup()` which uses bcrypt verify. The code is deliberate; the reconstruction misread it. → E: re-run `revive` on this decision; do not edit the sign to say bcrypt.
- *Hard rule:* for `provenance=preserve` signs, a contradiction is **never** E — the author knew the intent, so it's A/B/C. E fires **only** on `revive`-origin signs.

## Provenance-aware auditing

Before classifying any plugin-produced sign, read its `provenance` and `confidence` (carried in a frontmatter marker or inline HTML comment, e.g. `<!-- provenance: revive | confidence: low -->`):

- For **`provenance=preserve`** signs (authoritative): contradictions are A/B/C as usual.
- For **`provenance=revive`** signs (reconstructed hypotheses): treat E as a live possibility — the sign may simply be wrong.
- **Low-confidence revive signs head the re-verification queue.** Code changes decay a reconstruction's trust fastest, so after any code change, low-confidence revive signs are the first candidates to re-run through `revive`. Surface them explicitly in the report's "re-verify" list.
- `map.md` is a meta-index (it estimates where understanding is thin), not an intent claim about code — it is **provenance-exempt**, but its *references* (area paths, hotspot `file:line`) are still audited as Type C.

## What you may and may not edit

- **May auto-edit (after confirmation):** inline code comments, docstrings, project prose docs, contract specs, ADRs/decision records, `docs/defossil/**` records of `provenance=preserve`, tests-as-specs text, and broken references in `map.md`. (Contract specs that are *generated* by codegen/build are not hand-edited — flag the generator/annotations instead.)
- **Report-only (propose, don't write):** agent-instruction files and memory files.
- **Never auto-edit:** the code itself (B is flagged, never auto-fixed; E is routed to `revive`, never auto-fixed). `docs/defossil/**` records of `provenance=revive` are **not** auto-edited to match code on an E finding — that's the whole point of E.
- **Never:** commit, push, create PRs, add remotes. This command only edits the working tree.

## Docs-as-code contract specs

Machine-readable specs drift as often as prose — treat them as signs: OpenAPI/Swagger, gRPC/protobuf, GraphQL schema, JSON Schema / AsyncAPI. Verify each declared path/endpoint/message/type/field against the real code (route handlers, struct/message definitions, enum values), then classify:
- **Type C** — the spec names an endpoint/param/field/type that was renamed/removed/retyped → edit the spec.
- **Type B** — the spec states a contract the code no longer honors (`required: true` but the field isn't validated; an enum the code never produces) → flag as suspected bug; don't bless it by editing.
- **Codegen caveat:** if the spec is generated from code/annotations or a build step, do not hand-edit it — flag the generator or its source annotations instead.

## The workflow

### 1. Discover — map both sides
Inventory the project with your tools (Glob, Grep, Bash, Read), adapting to the layout you find. Gather both sides: the **signs** to check and the **source code** they must match.

- **Honor `.gitignore`** so build output, venvs, and caches don't drown the signal. In a git repo: `git ls-files --cached --others --exclude-standard`. In a non-git dir, skip obvious vendored/build trees as you Glob.
- **Memory is the exception:** `.claude/.../memory` and `.remember` are frequently gitignored yet always in-scope (report-only) — find them explicitly.
- **`docs/defossil/` is always in-scope** when present (self-audit).
- **Contract specs too:** pick up `*.proto`, `openapi.*`/`swagger.*`, `*.graphql`/`*.gql`, schema files.
- For a large repo (>~30 files of interest), dispatch parallel Explore subagents — one per top-level directory/subsystem — each returning structured `(sign claim, code reality, location, provenance)` tuples.

### 2. Analyze & classify — read provenance first
For each claim touching behavior, signatures, types, side effects, error cases, or external contracts, verify it against the code. **Read the sign's provenance/confidence before classifying.** Classify A/B/C/D/E. Record `file:line`, provenance, what the sign says, what the code does, classification, and proposed fix (or, for E, the routing note).

### 3. Report — present before changing anything
Output one report using the template below, grouped by type. Every finding is concrete and citeable (`file:line`). Separate "will fix" (in-scope A/C) from "needs your call" (B, suspected bug), "propose only" (D), and "route to revive" (E). Include the re-verify queue (low-confidence revive signs).

### 4. Confirm
Ask which findings to apply. Default: apply all in-scope Type A and C; do not apply B, D, or E. Let the user veto individual rows or add scope.

### 5. Apply — batch, then verify
Apply confirmed edits with Edit — minimal, faithful changes, preserving the original tone and language. Do not commit. Re-read the changed regions to confirm they read correctly. (E findings are NOT applied — they are routed.)

### 6. Verify & hand off
Re-check the touched claims against the code. Summarize: N fixed, M flagged as suspected bugs, K proposed for manual agent-instruction/memory edit, L routed to `revive` (E). List the re-verify queue (low-confidence revive signs). On `main`/`master`, remind the user to create a feature branch before committing — but do not branch or commit yourself.

### 7. Self-audit — re-check this plugin's own signs
The plugin's own `docs/defossil/**` records (preserve-origin and revive-origin) and `map.md` are re-checked here for self-consistency. Low-confidence revive signs discovered stale or contradicted are queued for re-verification (route to `revive`).

## Report template

```
# Sign-Code Alignment Report

## Summary
- Scope: <dirs/files>
- Sign files: <count>  |  Code files: <count>
- Will fix (A/C): X  |  Suspected bug (B): Y  |  Propose only (D): Z  |  Reconstruction-was-wrong (E): L

## Will fix — batch-apply (A/C)
| Location | Sign says | Code actually | Prov | Type | Proposed fix |
|----------|-----------|---------------|------|------|--------------|
| src/auth.ts:42 | "returns email" | returns User object | preserve | A | change to "returns User object" |

## Suspected bug — code NOT changed, your call (B)
| Location | Stated invariant | Actual code violation |
|----------|------------------|-----------------------|
| src/cache.rs:88 | "callers must hold the lock" | reads shared state without acquiring it |

## Reconstruction-was-wrong — route to revive (E)
| Location | Prov | Sign (reconstruction) claims | Code actually does | Why it's not drift (C) |
|----------|------|------------------------------|--------------------|------------------------|
| docs/defossil/login/decisions.md:4 | revive:low | "hashes with SHA-1" | bcrypt verify in lookup() | symbol exists & behaves as claimed; the inference was wrong |

## Propose only — edit CLAUDE.md / AGENTS.md / memory by hand (D)
- CLAUDE.md:7 — says "use pnpm" but repo is an npm project; propose "npm"

## Re-verify queue (low-confidence revive signs, prioritize after code changes)
- docs/defossil/<system>/<hotspot>/decisions.md:<line> — revive:low, re-run revive
```

## Editing guardrails (non-negotiable)

- **Never commit, push, add remotes, or open PRs.** Output = working-tree edits + a report.
- **Branch awareness only:** on `main`/`master`, *remind* the user to branch before committing; do not branch or commit yourself. Non-git dir: skip.
- **No silent code edits.** Report → user confirms → apply.
- **Scope:** signs only (comments, docstrings, prose docs, contract specs, ADRs, `docs/defossil/**` preserve-origin records, tests-as-specs text). Not agent-instruction files, not memory, not the code itself.
- **Faithful edits:** rewrite the false sentence to be true; don't delete useful context or invent details you didn't verify against the code.
- **No fabrication:** if a claim can't be verified against the code within a reasonable search, mark it "unverified" — never edit an unverified claim.
- **E is routed, never auto-fixed:** a revive-origin sign that's wrong gets sent back to `revive`; editing it to match the code would launder a misreading into "author intent."

## When to parallelize

For small repos (~≤30 files of interest), do it inline. Above that, dispatch parallel Explore subagents (one per subsystem) to gather findings, then classify and dedupe in the main thread. **Classification and the final report always happen in one place** so the A/B/C/D/E buckets are applied consistently — never let a subagent decide, on its own, to rewrite a comment that actually hides a bug (B) or to bless a misreading (E).
