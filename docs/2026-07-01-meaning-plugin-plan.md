# meaning Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the `meaning` Claude Code plugin — three commands (`capture`, `tour`, `sweep`) that reduce intent debt and cognitive debt, per the approved design spec (`docs/2026-07-01-meaning-plugin-design.md`).

**Architecture:** A command-focused plugin: `.claude-plugin/plugin.json` + `commands/*.md`. The three prompt-driven commands form a Peircean loop over drift-resistant signs stored in the **target project's** `docs/meaning/<feature>/`. `sweep` migrates and generalizes the existing `~/.claude/skills/doc-sweep` skill; `capture` and `tour` are new. Deliverables are instruction (prompt) files, so each task validates via **plugin-validator (structure)** + a **behavioral dry-run on a fixture** — there is no runtime code to unit-test.

**Tech Stack:** Claude Code plugin only (markdown commands + JSON manifest). No runtime code, no external dependencies, no MCP, no hooks.

## Global Constraints

Copied from the spec; every task implicitly includes these.

- **No git commits in this plan.** The user manages git themselves. Leave every change in the working tree; do **not** run `git add` / `git commit` / `git push`. (Repo already exists at the plugin root on branch `docs/initial-design`.)
- **Language.** Command files, `plugin.json`, README, and code-adjacent artifacts (why-comments, `tour.md` / `intent.md` / `understanding.md` content) are **English** (project rule: rule/README files and code comments = English). The design spec stays Chinese.
- **Plugin root.** `G:\Workspace\F2077\meaning` (WSL: `/mnt/g/Workspace/F2077/meaning`). Any intra-plugin path a command must reference uses `${CLAUDE_PLUGIN_ROOT}`.
- **Drift-resistance.** Standalone records live in the **target project** at `docs/meaning/<feature>/` (`intent.md`, `decisions.md`, `tour.md`, `understanding.md`). Two sign types stay in place because their location *is* the drift-resistance: **why-comments inline in code**, **characterization tests in the project test dir**. No vector DB, no parallel store.
- **Guardrails every command must enforce** (spec §8): (1) anti-paraphrase — never restate what the code already shows, only answer what it can't (why, rejected alternatives, invariants, hidden coupling, failure modes); (2) every decision records ≥1 rejected alternative + ≥1 negative consequence; (3) no silent code edits — report → user confirms → apply; (4) active (Socratic / self-explanation) is the default, passive is an escape hatch only; (5) one feature per run; (6) never commit/push/add remote/open PR.
- **Out of scope — do NOT build:** vector DB / knowledge graph, auto-firing hooks, `/decompose`, Occam's razor / 5-whys (technical debt → `simplify` / `code-review`), speculative artifacts (analogy libraries, index-card libraries, auto-generated diagrams).

## Scope Check

One cohesive plugin (3 commands sharing the `docs/meaning/` convention and guardrails). `sweep` is mostly a migration (lowest risk, done first); `capture` and `tour` are new. Single plan, five tasks, each independently testable.

## File Structure

```
meaning/                                   # plugin root
├── .claude-plugin/
│   └── plugin.json                        # Task 1 — manifest
├── commands/
│   ├── sweep.md                           # Task 2 — generalized doc-sweep
│   ├── capture.md                         # Task 3 — fresh-context capture
│   └── tour.md                            # Task 4 — on-demand rebuild
├── docs/
│   ├── 2026-07-01-meaning-plugin-design.md   # spec (exists)
│   └── 2026-07-01-meaning-plugin-plan.md     # this plan (exists)
├── README.md                              # exists; Task 5 updates status
└── .gitignore                             # exists
```

Each `commands/*.md` is a **self-contained prompt** (YAML frontmatter + markdown body). Shared guardrails are inlined into each command deliberately — these are independent LLM prompts that must carry their own context, so DRY is intentionally relaxed; the **spec is the single source of truth** and Task 5 cross-checks consistency.

## Dry-Run Fixture (shared by Tasks 2–4)

Each behavioral dry-run creates a throwaway fixture under `/tmp/meaning-fixture/` (NOT in the plugin repo). Minimal reproducible layout:

```
/tmp/meaning-fixture/                     # a fake target project
├── auth.go                               # has a STALE comment (Type A) + an UNSTATED invariant (Type B)
├── auth_test.go                          # happy-path test (will become a characterization test)
└── docs/meaning/login/                   # a pre-existing meaning record set (for sweep self-audit)
    ├── intent.md
    └── tour.md                           # contains a BROKEN file:line link (Type C)
```

Concrete fixture contents are specified inside each task's dry-run step. Clean up (`rm -rf /tmp/meaning-fixture`) at the end of each task.

---

## Task 1: Plugin Scaffold and Manifest

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `commands/` (directory; contents come in Tasks 2–4)

**Interfaces:**
- Produces: a structurally valid plugin that Claude Code can discover (manifest present, `commands/` exists).

- [ ] **Step 1: Create the manifest**

Write `.claude-plugin/plugin.json`:

```json
{
  "name": "meaning",
  "version": "0.1.0",
  "description": "Reduce intent debt and cognitive debt. capture lays down drift-resistant signs and scores understanding while context is fresh; tour rebuilds understanding on demand; sweep keeps intent artifacts aligned with code.",
  "keywords": ["comprehension", "cognitive-debt", "intent-debt", "documentation", "program-comprehension"],
  "license": "MIT"
}
```

- [ ] **Step 2: Create the commands directory**

Run: `mkdir -p /mnt/g/Workspace/F2077/meaning/commands`

- [ ] **Step 3: Validate structure**

Dispatch the `plugin-dev:plugin-validator` agent on `/mnt/g/Workspace/F2077/meaning`.
Expected: manifest valid; `name` kebab-case and unique; no structural errors. (It may note "no commands yet" — acceptable here; Tasks 2–4 add them.)

- [ ] **Step 4: Fix any validator findings, then re-validate**

If the validator reports issues (e.g., a field it expects, a path problem), correct `.claude-plugin/plugin.json` and re-run Step 3 until clean.

- [ ] **Step 5: Do NOT commit**

Leave changes in the working tree. The user manages git.

---

## Task 2: `sweep` Command (Migrate + Generalize doc-sweep)

Lowest risk — mostly a migration of an existing, working skill. Done first so the plugin's intent-debt capability and the `docs/meaning/` self-audit exist before `capture` produces records.

**Files:**
- Create: `commands/sweep.md`
- Source to migrate from: `~/.claude/skills/doc-sweep/SKILL.md`

**Interfaces:**
- Consumes: the existing doc-sweep skill body (its A/B/C/D classification and report→confirm→apply workflow).
- Produces: `commands/sweep.md` — a generalized version covering the broader sign set (spec §5.1) AND the plugin's own `docs/meaning/<feature>/` records.

- [ ] **Step 1: Read the source skill**

Read `/home/work26/.claude/skills/doc-sweep/SKILL.md`. This is the body to migrate; keep its classification logic and guardrails intact.

- [ ] **Step 2: Author `commands/sweep.md`**

The file MUST contain (frontmatter + sections below). Body in English.

Frontmatter:
```yaml
---
description: Audit whether a project's intent artifacts (signs) still match the code, then fix the drift. A generalized doc-sweep — covers code comments/docstrings, prose docs, contract specs (OpenAPI/proto/GraphQL), ADRs/decision records, design specs and plans, commit messages and PR descriptions, tests-as-specs, AND this plugin's own docs/meaning/ records. Use when signs may have drifted from code, after a refactor/rename/migration, before a release, or as routine hygiene. Classifies each divergence A/B/C/D; fixes behavioral drift and stale references only after confirmation; flags invariant violations as suspected bugs.
---
```

Body — required sections and mandatory content:

1. **# Sweep — align intent artifacts (signs) with code.** One-paragraph purpose: the code is the reference; signs (everything that communicates rationale) are checked against it; classify before touching anything.
2. **What counts as a sign (generalized set).** List verbatim from spec §5.1: code comments & docstrings; README/CHANGELOG/CONTRIBUTING/docs/**; contract specs (OpenAPI/proto/GraphQL/schema); **ADRs / decision records**; **brainstorming specs + writing-plans plans**; **commit messages + PR/MR descriptions**; **tests-as-specs**; agent-instruction files (CLAUDE.md/AGENTS.md/.cursorrules) → report-only; memory (`.claude/.../memory`, `.remember`) → report-only.
3. **Self-audit — include this plugin's own records.** Mandatory paragraph: `docs/meaning/<feature>/{intent,decisions,tour,understanding}.md` are signs and are ALWAYS in scope; why-comments inline in code and characterization tests are audited via their code locations.
4. **The four buckets (carry over from doc-sweep verbatim logic).**
   - **Type A — Behavioral drift:** sign describes behavior the code no longer matches, code is the deliberate working behavior → edit the sign.
   - **Type B — Invariant / constraint violation:** sign states a must/always/never/invariant the code breaks → do NOT touch code, do NOT rewrite the sign to bless it; flag as a suspected bug.
   - **Type C — Stale reference:** renamed symbols, dead links, wrong file paths, wrong arg counts/signatures, broken `file:line` links in tour files → edit the sign.
   - **Type D — Out of edit scope:** divergence in agent-instruction files or memory → propose the corrected text, do not write it.
5. **What you may and may not edit.** May auto-edit (after confirmation): comments, docstrings, prose docs, contract specs, ADRs/decision records, `docs/meaning/**` records, tests-as-specs text. Report-only: agent-instruction files, memory. Never: the code itself (Type B is flagged, never auto-fixed). Never: commit/push/add remote/open PR.
6. **Workflow** (six steps, carried from doc-sweep): Discover (map both sides; `git ls-files --cached --others --exclude-standard`; memory always in scope) → Analyze & classify (one finding per divergence, record `file:line`, sign-says/code-does/type/proposed-fix) → Report (template below, grouped by type) → Confirm (default apply all in-scope A and C; B and D not applied) → Apply (batch minimal faithful edits, preserve tone/language) → Verify & handoff (re-check; summarize N fixed / M flagged / K proposed; on main/master remind user to branch).
7. **Report template** (carry from doc-sweep): Summary + "Will fix (A/C)" table + "Suspected bug — code NOT changed, your call (B)" table + "Propose only (D)" list.
8. **Editing guardrails (non-negotiable).** Never commit/push/add remote/open PR. No silent code edits. Faithful edits only. No fabrication — unverifiable claims marked "unverified", never edited.

- [ ] **Step 3: Validate structure**

Dispatch `plugin-dev:plugin-validator` on the plugin root.
Expected: `commands/sweep.md` discovered; frontmatter parses; no structural errors.

- [ ] **Step 4: Dry-run — drift classification + no-regression**

Create the fixture:
```bash
mkdir -p /tmp/meaning-fixture/docs/meaning/login
cat > /tmp/meaning-fixture/auth.go <<'EOF'
package auth

// Login returns the user's email.   // <- Type A: actually returns *User
func Login(name, pwd string) (*User, error) {
        // NOTE: callers must not pass an empty name   // <- Type B-ish invariant stated in code
        if name == "" { return nil, errEmpty }
        return lookup(name, pwd)
}
EOF
cat > /tmp/meaning-fixture/docs/meaning/login/tour.md <<'EOF'
# login tour
1. auth.go:42 — entry point Login      // <- Type C: line 42 doesn't exist (real line is 5)
EOF
```
Manually execute the `sweep` workflow against `/tmp/meaning-fixture` (read code + signs, classify each divergence). Verify:
- `auth.go:2` comment "returns the user's email" vs code returning `*User` → classified **A** (propose edit sign).
- `auth.go:4` "callers must not pass an empty name" vs code that does check but the invariant wording → handled per Type B rules (if it states a contract the code honors, not a violation; if contradicted, flag) — confirm the classification reasoning matches original doc-sweep.
- `tour.md` link `auth.go:42` → classified **C** (stale reference; propose fix to real line).
Expected: classification identical to what original `doc-sweep` would produce on the same inputs (no regression).

- [ ] **Step 5: Do NOT commit; clean up fixture**

`rm -rf /tmp/meaning-fixture`. Leave `commands/sweep.md` in the working tree.

---

## Task 3: `capture` Command

**Files:**
- Create: `commands/capture.md`

**Interfaces:**
- Consumes: target-project code, `git log`/`git diff`, the feature's brainstorming spec and writing-plans plan (if present), prior `simplify`/`code-review` findings.
- Produces: `docs/meaning/<feature>/intent.md`, `…/decisions.md`, `…/tour.md`, `…/understanding.md`; inline why-comments in code; characterization tests in the test dir.

- [ ] **Step 1: Author `commands/capture.md`**

Frontmatter:
```yaml
---
description: Capture a just-shipped feature while context is fresh — declare intent (故/理/类), record the intent-to-code decision path, lay drift-resistant signs (why-comments + tour + characterization tests), and run a self-explanation checkpoint that scores understanding. Run after simplify, on one feature at a time.
---
```

Body — required sections and mandatory content:

1. **# Capture — lock in the "why" while it's fresh.** Purpose: reduce intent debt (create signs) AND cognitive debt (cement the theory now, while cheap). One feature per run.
2. **When to run.** After `simplify` (feature done, code clean, context fresh), or any "I understand this right now" moment. Not for code you've already forgotten (use `tour`).
3. **Inputs.** The feature's code; `git log`/`git diff` for the feature; the brainstorming spec and writing-plans plan if they exist; recent `simplify`/`code-review` findings.
4. **Workflow.**
   - **Step 1 — Scope.** User points at the feature (name / files / recent diff / spec). Restate and confirm. Too large → split into sub-features.
   - **Step 2 — Declare intent.** Produce `intent-spec` using the 墨子 故/理/类 schema (below). Socratically challenge vague intent (concept clarification, boundary probing, dependency check, constraint tradeoff). Run 归谬法 (reductio): "if we do this, what's the worst case at 10× scale?" → record in `risk_analysis`. Write `docs/meaning/<feature>/intent.md`.
   - **Step 3 — Record the decision path.** For each non-obvious decision, produce an **ADR-lite** entry: the decision + **≥1 rejected alternative** + **≥1 negative consequence** (hard rule — reject the entry otherwise). Write `docs/meaning/<feature>/decisions.md`.
   - **Step 4 — Propose drift-resistant signs (report, do NOT write yet).** Propose: (a) why-comments — inline at each decision point in code, English, one-line distillation of the ADR-lite (decision + the key rejected alt); (b) `docs/meaning/<feature>/tour.md` — ordered list of `(file:line, what to look at, beacon)`; (c) characterization tests for the happy path / key invariants in the project test dir (`*_orient_test.*`). Present as a report; user confirms/edits. **No silent code edits.**
   - **Step 5 — Apply** confirmed signs (minimal, faithful).
   - **Step 6 — Self-explanation checkpoint → understanding-score.** Without the user looking at the code, ask them to explain 2–4 key decisions / data flows in plain language (Feynman). Compare against the code; where their explanation diverges, that is a gap — surface it and fill it. Compute an **understanding-score** (below). Write `docs/meaning/<feature>/understanding.md`.
   - **Step 7 — Verify & summarize.** Signs reference real code; characterization tests pass. Report: N why-comments / 1 tour / M tests / score / K gaps. Optional tech-debt handoff: suggest running `simplify` / `code-review`.
5. **intent-spec schema (墨子 故/理/类).**
   ```
   gu (故 / why):     why this change (business driver / tech debt / user request)
   li (理 / how):     principle or approach (pattern / design principle / tech choice)
   lei (类 / scope):  change category (feature / fix / refactor / perf)
   constraints:          [...]
   acceptance_criteria:  [...]
   risk_analysis: { extreme_scenario: ..., fallback: ... }
   ```
   Stored as `docs/meaning/<feature>/intent.md` (markdown; exact field format finalized at execution).
6. **understanding-score.** Quantify "feels understood": score the user's plain-language explanations of (a) key decisions, (b) the happy-path data flow, (c) the main invariants, by consistency with the code. Record the score and the per-item gaps in `understanding.md`. This makes cognitive debt visible.
7. **Guardrails (inline).** Anti-paraphrase. Every decision needs rejected-alt + downside. Report→confirm→apply. Drift-resistance (signs in their prescribed locations; nothing else). Active by default. One feature. Never commit/push.

- [ ] **Step 2: Validate structure**

Dispatch `plugin-dev:plugin-validator`.
Expected: `commands/capture.md` discovered; frontmatter parses; no errors.

- [ ] **Step 3: Dry-run — capture a fixture feature**

Create a fixture with a real (tiny) feature:
```bash
mkdir -p /tmp/meaning-fixture
cat > /tmp/meaning-fixture/auth.go <<'EOF'
package auth

func Login(name, pwd string) (*User, error) {
        if name == "" { return nil, errEmpty }
        return lookup(name, pwd)   // uses bcrypt verify inside lookup
}
EOF
```
Execute the `capture` workflow on the `Login` feature (you play the user for the self-explanation step). Verify the outputs:
- `docs/meaning/login/intent.md` exists with 故/理/类 + constraints + acceptance + risk.
- `docs/meaning/login/decisions.md` has ≥1 ADR-lite entry, each with a rejected alternative AND a downside.
- A why-comment is proposed at the `lookup` decision point (e.g., why bcrypt / why not plaintext).
- `docs/meaning/login/tour.md` is an ordered `(file:line, …)` list whose links resolve.
- `docs/meaning/login/understanding.md` has a numeric understanding-score + gap list.
Expected: all five artifacts present and well-formed; no artifact restates the code line-by-line.

- [ ] **Step 4: Do NOT commit; clean up fixture**

`rm -rf /tmp/meaning-fixture`.

---

## Task 4: `tour` Command

**Files:**
- Create: `commands/tour.md`

**Interfaces:**
- Consumes: the signs produced by `capture` (`docs/meaning/<feature>/*`, why-comments, characterization tests) + the code.
- Produces: an ephemeral, in-conversation rebuild of understanding; surfaces intent debt (broken signs → hand off to `sweep`); optionally proposes a capture-lite why-comment for a gap (with confirmation).

- [ ] **Step 1: Author `commands/tour.md`**

Frontmatter:
```yaml
---
description: Rebuild your understanding of a feature whose code you've forgotten. Loads and audits the capture signs, gives a one-screen orientation, then drives a Socratic rebuild (you explain, it fills the gaps) and scores understanding. Run on demand when you're rusty on your own code. Ephemeral — nothing is persisted unless you confirm a gap-fill.
---
```

Body — required sections and mandatory content:

1. **# Tour — rebuild the theory from the signs.** Purpose: reduce cognitive debt by reconstructing the interpretant; surface intent debt by auditing the signs. Ephemeral by default.
2. **When to run.** On demand, when you can no longer read your own code (you know the feature but not the code). If no `docs/meaning/<feature>/` signs exist, degrade to a cold rebuild and offer to run `capture`.
3. **Workflow.**
   - **Step 1 — Scope + load & audit signs.** Read `tour.md`, `decisions.md`, `intent.md`, `understanding.md`, the why-comments, and the characterization tests. Audit each for drift: broken `file:line` links, stale references, failing tests, records that contradict the code. **Flag drift, never trust silently.** Broken signs → hand off to `sweep`.
   - **Step 2 — Coarse orient (one screen, passive).** Entry points, shape, where things live, the happy-path data flow. Just the map.
   - **Step 3 — Socratic rebuild (active, adaptive depth).** Have the user explain / predict / confirm-or-reject hypotheses; skip what they're solid on, go deep where they're shaky. Techniques: **Feynman** (explain a block in plain language), **解构 / deconstruction** (surface unstated assumptions — about external API shapes, input formats, system state, data volume — and rate each assumption's risk if it fails), **归谬 / reductio** (for each key branch, walk normal / extreme / failure scenarios). **Never paraphrase code** — only answer what the code can't.
   - **Step 4 — understanding-score.** Same mechanism as `capture`; record what's solid vs. still-gap.
   - **Step 5 — Ephemeral; optional capture-lite.** Persist nothing by default. If a gap the signs didn't cover was found, **propose** adding one why-comment (confirm first).
   - **Step 6 — Escape hatch.** If the user says "just show me", switch to a passive explanation for the rest (respect autonomy); note that retention is weaker.
4. **Guardrails (inline).** Anti-paraphrase. Audit signs before trusting. Active by default. Ephemeral by default. Report→confirm for any proposed edit. Never commit/push.

- [ ] **Step 2: Validate structure**

Dispatch `plugin-dev:plugin-validator`.
Expected: `commands/tour.md` discovered; frontmatter parses; no errors.

- [ ] **Step 3: Dry-run — tour the feature captured in Task 3**

Recreate the Task 3 fixture WITH its captured records (re-run Task 3 Step 3 first, or copy its outputs into `/tmp/meaning-fixture/docs/meaning/login/`). Then deliberately introduce drift: change `auth.go` so one `file:line` in `tour.md` no longer resolves.
Execute the `tour` workflow (you play a user who has "forgotten" the code). Verify:
- It loads + audits the signs; flags the broken `file:line` and hands it to `sweep`.
- Coarse orient is one screen.
- Socratic rebuild asks you to explain/predict; it fills gaps without paraphrasing the code.
- It produces an understanding-score.
- Nothing is persisted (no files written) unless you confirm a gap-fill.
Expected: drift caught; rebuild is active (asks, doesn't lecture); no spurious writes.

- [ ] **Step 4: Do NOT commit; clean up fixture**

`rm -rf /tmp/meaning-fixture`.

---

## Task 5: Integration, Retire Old doc-sweep, End-to-End Dry-Run

**Files:**
- Modify: `README.md` (status: design → v1 implemented)
- Delete (after validation): `~/.claude/skills/doc-sweep/` (the now-superseded standalone skill)

**Interfaces:**
- Consumes: all three commands from Tasks 2–4.
- Produces: a consistent, documented v1 plugin; the old standalone `doc-sweep` retired.

- [ ] **Step 1: Cross-check guardrail consistency**

Read all three `commands/*.md`. Verify the shared guardrails (anti-paraphrase; decision-needs-rejected-alt; report→confirm→apply; drift-resistance locations; active-default; no-commit) are present and consistent across `capture`, `tour`, `sweep`. Fix any drift between copies.

- [ ] **Step 2: Re-validate the whole plugin**

Dispatch `plugin-dev:plugin-validator` on the plugin root.
Expected: manifest valid; all three commands discovered; no errors.

- [ ] **Step 3: End-to-end dry-run on a fresh fixture**

Create a small fixture feature (2–3 source files) in `/tmp/meaning-fixture`. Run the full intended pipeline by hand:
1. `capture` the feature → confirm `docs/meaning/<feature>/` is populated, why-comments added, characterization test passes.
2. Mutate the code (rename a function, change a return type) to simulate time passing.
3. `sweep` → confirm it classifies the now-drifted signs (A/C) and flags any invariant violation (B).
4. `tour` → confirm it orients, catches the drift, and Socratically rebuilds understanding; confirm nothing unwanted is persisted.
Expected: the loop holds — capture creates signs, sweep keeps them honest, tour rebuilds from them and audits them.

- [ ] **Step 4: Retire the standalone doc-sweep**

Only after Step 3 passes: delete the old skill directory.
Run: `rm -rf /home/work26/.claude/skills/doc-sweep`
(Presence of the migration in `commands/sweep.md` is the replacement. Do this only once `sweep` is validated.)

- [ ] **Step 5: Update README status**

In `README.md`, change the Status line from "Design only" to "v1 implemented (`capture`, `tour`, `sweep`); see the design doc and implementation plan in `docs/`."

- [ ] **Step 6: Do NOT commit; clean up fixture**

`rm -rf /tmp/meaning-fixture`. Leave all plugin changes in the working tree for the user to stage and commit.

---

## Self-Review (run after writing)

- **Spec coverage:** every spec section maps to a task — §4.1 capture → Task 3; §4.2 tour → Task 4; §4.3 sweep + §5.1 sign set → Task 2; §5.2 locations → Global Constraints + each task's body; §5.3 intent-spec → Task 3; §5.4 understanding-score → Tasks 3 & 4; §6 pipeline integration → Task 5; §7 plugin structure → Task 1; §8 guardrails → Global Constraints + inlined per command; §9 edge cases → handled in command bodies (cold-tour, no-spec, non-git, no-test-framework); §11 validation → dry-runs in Tasks 2–5.
- **Placeholder scan:** none — every step shows concrete content (manifest JSON, frontmatter, required sections with mandatory content, fixture commands, expected outputs).
- **Type/name consistency:** command names `capture`/`tour`/`sweep` and artifact names `intent.md`/`decisions.md`/`tour.md`/`understanding.md` are used identically across all tasks; `docs/meaning/<feature>/` path is consistent throughout.
- **Adaptations noted:** instruction plugin → validate + dry-run instead of unit TDD; no git commits (user-managed). Both stated in Global Constraints.
