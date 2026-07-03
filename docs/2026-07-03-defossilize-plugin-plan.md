# defossilize Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the `defossilize` Claude Code plugin — five commands (`preserve`, `thaw`, `excavate`, `revive`, `curate`) that reduce intent debt and cognitive debt across the fossilization spectrum, per the approved design spec (`docs/2026-07-03-defossilize-plugin-design.md`).

**Architecture:** A command-focused plugin: `.claude-plugin/plugin.json` + `commands/*.md`. The five prompt-driven commands form a Peircean loop over drift-resistant signs stored in the **target project's** `docs/defossil/<unit>/`. `curate` migrates and generalizes the existing `~/.claude/skills/doc-sweep` skill (plus a new E classification for revive-origin signs); `preserve` and `thaw` are the renamed capture/tour; `excavate` and `revive` are new (legacy/fossil support). Deliverables are instruction (prompt) files, so each task validates via **plugin-validator (structure)** + a **behavioral dry-run on a fixture** — there is no runtime code to unit-test.

**Tech Stack:** Claude Code plugin only (markdown commands + JSON manifest). No runtime code, no external dependencies, no MCP, no hooks.

## Global Constraints

Copied from the spec + project rules; every task implicitly includes these.

- **No git commits in this plan.** The user manages git themselves. Leave every change in the working tree; do **not** run `git add` / `git commit` / `git push` / `git mv`. (Repo exists on branch `docs/initial-design`.) Each task ends with "leave in working tree; do NOT commit."
- **Directory rename is user-managed.** The plugin dir is currently `meaning/`; the user renames it to `defossilize/` themselves (they manage git). All absolute paths in this plan assume the renamed dir `/mnt/g/Workspace/F2077/defossilize`. If the dir is still named `meaning/` when a task runs, substitute the current path — but the `plugin.json` `name` is `defossilize` regardless.
- **Language.** Command files, `plugin.json`, README, and code-adjacent artifacts (why-comments, `tour.md` / `intent.md` / `understanding.md` / `map.md` content) are **English** (project rule: rule/README files and code comments = English). The design spec stays Chinese.
- **Plugin root.** `G:\Workspace\F2077\defossilize` (WSL: `/mnt/g/Workspace/F2077/defossilize`). Any intra-plugin path a command must reference uses `${CLAUDE_PLUGIN_ROOT}`.
- **Drift-resistance.** Standalone records live in the **target project** at `docs/defossil/<unit>/` (`intent.md`, `decisions.md`, `tour.md`, `understanding.md`, and for legacy `map.md`). Two sign types stay in place because their location *is* the drift-resistance: **why-comments inline in code**, **characterization tests in the project test dir**. No vector DB, no parallel store.
- **Provenance on signs (new this version).** Every revive-origin record artifact (`intent`/`decisions`/`tour`/`understanding`) and why-comment carries `provenance=revive` + `confidence` (high/med/low); preserve-origin equivalents carry `provenance=preserve`. `map.md` is a meta-index and is provenance-exempt.
- **Guardrails every command must enforce** (spec §8): (1) anti-paraphrase — never restate what the code already shows, only answer what it can't (why, rejected alternatives, invariants, hidden coupling, failure modes); (2) every decision records ≥1 rejected alternative + ≥1 negative consequence, **or is explicitly marked unknown** (revive: never fabricate); (3) no silent code edits — report → user confirms → apply; (4) active is the default (preserve/thaw: self-explanation/Socratic/Feynman; revive: **prediction-first**), passive is an escape hatch only; (5) one unit (feature / system / hotspot) per run; (6) never commit/push/add remote/open PR.
- **Out of scope — do NOT build:** vector DB / knowledge graph, auto-firing hooks, `/decompose`, speculative artifacts (analogy libraries, index-card libraries, auto-generated diagrams).

## Scope Check

One cohesive plugin (5 commands sharing the `docs/defossil/` convention, provenance, and guardrails). `curate` is mostly a migration (lowest risk, done first); `preserve`/`thaw` are renames of the designed capture/tour; `excavate`/`revive` are new. Single plan, seven tasks, each independently testable (validator + dry-run).

## File Structure

```
defossilize/                                   # plugin root (renamed from meaning/)
├── .claude-plugin/
│   └── plugin.json                            # Task 1 — manifest
├── commands/
│   ├── curate.md                             # Task 2 — generalized doc-sweep + E classification
│   ├── preserve.md                           # Task 3 — fresh-context pin (was capture)
│   ├── thaw.md                               # Task 4 — on-demand rebuild (was tour)
│   ├── excavate.md                           # Task 5 — fossil triage + unknown map (new)
│   └── revive.md                             # Task 6 — predict→verify rebuild (new)
├── docs/
│   ├── 2026-07-03-defossilize-plugin-design.md   # spec (exists)
│   └── 2026-07-03-defossilize-plugin-plan.md     # this plan (exists)
├── README.md                              # exists; Task 7 updates status
└── .gitignore                             # exists
```

Each `commands/*.md` is a **self-contained prompt** (YAML frontmatter + markdown body). Shared guardrails are inlined into each command deliberately — these are independent LLM prompts that must carry their own context, so DRY is intentionally relaxed; the **spec is the single source of truth** and Task 7 cross-checks consistency.

## Dry-Run Fixture (shared by Tasks 2–7)

Each behavioral dry-run creates a throwaway fixture under `/tmp/defossil-fixture/` (NOT in the plugin repo). Minimal reproducible layout per task. Clean up (`rm -rf /tmp/defossil-fixture`) at the end of each task.

> **Git inside fixtures is allowed.** The "no git commits" constraint protects the **plugin** working tree and the user's repo state. Running `git init` / `git commit` / `git mv` **inside `/tmp/defossil-fixture`** is test scaffolding (needed to give `excavate`/`revive` fossil history to mine) and is explicitly exempt — it never touches the plugin repo and is deleted at the end of the task.

---

## Task 1: Plugin Scaffold and Manifest

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `commands/` (directory; contents come in Tasks 2–6)

**Interfaces:**
- Produces: a structurally valid plugin that Claude Code can discover (manifest present, `commands/` exists).

- [ ] **Step 1: Create the manifest**

Write `.claude-plugin/plugin.json`:

```json
{
  "name": "defossilize",
  "version": "0.1.0",
  "description": "Turn fossil code back into living understanding. preserve pins theory while it's fresh; thaw rebuilds fading understanding from signs; excavate maps a legacy/outsourced fossil and picks hotspots; revive brings a hotspot back to life via predict->verify; curate keeps intent artifacts aligned with code (incl. reconstruction-aware re-verification).",
  "keywords": ["comprehension", "cognitive-debt", "intent-debt", "legacy", "program-comprehension", "documentation"],
  "license": "MIT"
}
```

- [ ] **Step 2: Create the commands directory**

Run: `mkdir -p /mnt/g/Workspace/F2077/defossilize/commands`
(If the plugin dir is still named `meaning/`, substitute `/mnt/g/Workspace/F2077/meaning/commands`.)

- [ ] **Step 3: Validate structure**

Dispatch the `plugin-dev:plugin-validator` agent on `/mnt/g/Workspace/F2077/defossilize`.
Expected: manifest valid; `name` is kebab-case and unique; no structural errors. (It may note "no commands yet" — acceptable here; Tasks 2–6 add them.)

- [ ] **Step 4: Fix any validator findings, then re-validate**

If the validator reports issues (e.g., a field it expects, a path problem), correct `.claude-plugin/plugin.json` and re-run Step 3 until clean.

- [ ] **Step 5: Do NOT commit**

Leave changes in the working tree. The user manages git.

---

## Task 2: `curate` Command (Migrate + Generalize doc-sweep + add E classification)

Lowest risk — mostly a migration of an existing, working skill. Done first so the plugin's intent-debt capability, the `docs/defossil/` self-audit, and the reconstruction-aware E classification exist before other commands produce records.

**Files:**
- Create: `commands/curate.md`
- Source to migrate from: `~/.claude/skills/doc-sweep/SKILL.md`

**Interfaces:**
- Consumes: the existing doc-sweep skill body (its A/B/C/D classification and report→confirm→apply workflow).
- Produces: `commands/curate.md` — a generalized version covering the broader sign set (spec §5.1) AND the plugin's own `docs/defossil/` records, with a new E classification for revive-origin signs (spec §4.3, §5.5).

- [ ] **Step 1: Read the source skill**

Read `/home/work26/.claude/skills/doc-sweep/SKILL.md`. This is the body to migrate; keep its classification logic and guardrails intact.

- [ ] **Step 2: Author `commands/curate.md`**

The file MUST contain (frontmatter + sections below). Body in English.

Frontmatter:
```yaml
---
description: Audit whether a project's intent artifacts (signs) still match the code, then fix the drift. A generalized doc-sweep covering code comments/docstrings, prose docs, contract specs, ADRs/decision records, design specs and plans, commit messages and PR descriptions, tests-as-specs, AND this plugin's own docs/defossil/ records. Classifies each divergence A/B/C/D plus E (reconstruction-was-wrong, for revive-origin signs); fixes behavioral drift and stale references only after confirmation; flags invariant violations as suspected bugs; routes revive-sign contradictions back to revive. Use when signs may have drifted from code, after a refactor/rename/migration, before a release, or as routine hygiene.
---
```

Body — required sections and mandatory content:

1. **# Curate — align intent artifacts (signs) with code.** One-paragraph purpose: the code is the reference; signs (everything that communicates rationale) are checked against it; classify before touching anything.
2. **What counts as a sign (generalized set).** List verbatim from spec §5.1: code comments & docstrings; README/CHANGELOG/CONTRIBUTING/docs/**; contract specs (OpenAPI/proto/GraphQL/schema); ADRs / decision records; brainstorming specs + writing-plans plans; commit messages + PR/MR descriptions; tests-as-specs; **`excavate`'s `map.md`**; agent-instruction files (CLAUDE.md/AGENTS.md/.cursorrules) → report-only; memory (`.claude/.../memory`, `.remember`) → report-only.
3. **Self-audit — include this plugin's own records.** Mandatory paragraph: `docs/defossil/<unit>/{intent,decisions,tour,understanding}.md` and `docs/defossil/<system>/map.md` are signs and are ALWAYS in scope; why-comments inline in code and characterization tests are audited via their code locations.
4. **The five buckets (carry doc-sweep A/B/C/D verbatim logic + add E).**
   - **Type A — Behavioral drift:** sign describes behavior the code no longer matches, code is the deliberate working behavior → edit the sign.
   - **Type B — Invariant / constraint violation:** sign states a must/always/never/invariant the code breaks → do NOT touch code, do NOT rewrite the sign to bless it; flag as a suspected bug.
   - **Type C — Stale reference:** renamed symbols, dead links, wrong file paths, wrong arg counts/signatures, broken `file:line` links in tour/map files → edit the sign.
   - **Type D — Out of edit scope:** divergence in agent-instruction files or memory → propose the corrected text, do not write it.
   - **Type E — Reconstruction-was-wrong (NEW; only for `provenance=revive` signs):** a revive-origin sign contradicts the code, the code is the deliberate working behavior, and the contradiction is NOT ordinary drift (C) — the reconstruction itself misread the code → do NOT edit the sign to match the code (that would fossilize the misreading), do NOT flag the code as a bug; mark "reconstruction-was-wrong" and route the point back to `revive` for re-verification. Note: for `provenance=preserve` signs, a contradiction is never E — it's A/B/C.
5. **Provenance-aware auditing.** Mandatory paragraph: read each sign's `provenance` (`preserve` | `revive`) and `confidence` before classifying. For `revive` signs, consider E as a live possibility. Additionally: **low-confidence revive signs are prioritized into a re-verification queue** — code changes decay their trust fastest, so they head the "revisit" list.
6. **What you may and may not edit.** May auto-edit (after confirmation): comments, docstrings, prose docs, contract specs, ADRs/decision records, `docs/defossil/**` records (preserve-origin), tests-as-specs text, broken references in map.md. Report-only: agent-instruction files, memory. Never: the code itself (B is flagged, never auto-fixed; E is routed to revive, never auto-fixed). Never: commit/push/add remote/open PR.
7. **Workflow** (seven steps, carried from doc-sweep + provenance): Discover (map both sides; `git ls-files --cached --others --exclude-standard`; memory always in scope) → Analyze & classify (read provenance first; one finding per divergence, record `file:line`, provenance, sign-says/code-does/type/proposed-fix) → Report (template below, grouped A/B/C/D/E) → Confirm (default apply all in-scope A and C; B/D/E not applied) → Apply (batch minimal faithful edits, preserve tone/language) → Verify & handoff (re-check; summarize N fixed / M flagged / K proposed / L to-reverify; on main/master remind user to branch) → Self-audit (the plugin's own docs/defossil/** records are re-checked; low-confidence revive signs queued for re-verify).
8. **Report template** (carry from doc-sweep + add E): Summary + "Will fix (A/C)" table + "Suspected bug — code NOT changed, your call (B)" table + "Propose only (D)" list + **"Reconstruction-was-wrong — route to revive (E)" table** (each row: sign location, provenance, what the code actually does, why it's not drift).
9. **Editing guardrails (non-negotiable).** Never commit/push/add remote/open PR. No silent code edits. Faithful edits only. No fabrication — unverifiable claims marked "unverified", never edited.

- [ ] **Step 3: Validate structure**

Dispatch `plugin-dev:plugin-validator` on the plugin root.
Expected: `commands/curate.md` discovered; frontmatter parses; no structural errors.

- [ ] **Step 4: Dry-run — drift classification incl. new E + no-regression**

Create the fixture:
```bash
mkdir -p /tmp/defossil-fixture/docs/defossil/login
cat > /tmp/defossil-fixture/auth.go <<'EOF'
package auth

// Login returns the user's email.   // <- Type A: actually returns *User
func Login(name, pwd string) (*User, error) {
        // NOTE: callers must not pass an empty name   // <- invariant stated in code
        if name == "" { return nil, errEmpty }
        return lookup(name, pwd)
}
EOF
cat > /tmp/defossil-fixture/docs/defossil/login/tour.md <<'EOF'
<!-- provenance: preserve -->
# login tour
1. auth.go:42 — entry point Login      // <- Type C: line 42 doesn't exist (real line is 5)
EOF
cat > /tmp/defossil-fixture/docs/defossil/login/decisions.md <<'EOF'
<!-- provenance: revive | confidence: low -->
# decisions (reconstructed)
- D1: Login hashes passwords with SHA-1 because the legacy DB column is 40 hex chars.
  rejected: bcrypt (would need schema migration). downside: SHA-1 is weak.
  // <- The code actually calls lookup() which uses bcrypt verify (see auth.go:6).
  //    This is a revive misreading, NOT drift and NOT a code bug -> Type E.
EOF
```
Manually execute the `curate` workflow against `/tmp/defossil-fixture` (read code + signs, classify each divergence). Verify:
- `auth.go:2` comment "returns the user's email" vs code returning `*User` → classified **A** (propose edit sign).
- `auth.go:4` "callers must not pass an empty name" vs code that does check → handled per Type B rules (contract the code honors → not a violation; if contradicted, flag B). Confirm reasoning matches original doc-sweep.
- `tour.md` link `auth.go:42` → classified **C** (stale reference; propose fix to real line).
- `decisions.md` D1 (provenance=revive) claims SHA-1 but code uses bcrypt → classified **E** (reconstruction-was-wrong; route to revive, do NOT edit the sign to say bcrypt, do NOT flag the code). Confirm it does NOT get mis-classified as A (which would fossilize the misreading) or B (which would blame the code).
Expected: A/B/C classification identical to original doc-sweep on equivalent inputs (no regression); E correctly applied only to the revive-origin sign.

- [ ] **Step 5: Do NOT commit; clean up fixture**

`rm -rf /tmp/defossil-fixture`. Leave `commands/curate.md` in the working tree.

---

## Task 3: `preserve` Command (was capture)

**Files:**
- Create: `commands/preserve.md`

**Interfaces:**
- Consumes: target-project code, `git log`/`git diff`, the feature's brainstorming spec and writing-plans plan (if present), prior `simplify`/`code-review` findings.
- Produces: `docs/defossil/<feature>/intent.md` (provenance=preserve), `…/decisions.md`, `…/tour.md`, `…/understanding.md`; inline why-comments in code; characterization tests in the test dir.

- [ ] **Step 1: Author `commands/preserve.md`**

Frontmatter:
```yaml
---
description: Pin a just-shipped feature's theory while context is fresh — declare intent (gu/li/lei), record the intent-to-code decision path, lay drift-resistant signs (why-comments + tour + characterization tests, provenance=preserve), and run a self-explanation checkpoint that scores understanding. Prevents fossilization. Run after simplify, on one feature at a time.
---
```

Body — required sections and mandatory content:

1. **# Preserve — lock in the "why" while it's fresh (prevent fossilization).** Purpose: reduce intent debt (create signs) AND cognitive debt (cement the theory now, while cheap). One feature per run.
2. **When to run.** After `simplify` (feature done, code clean, context fresh), or any "I understand this right now" moment. Not for code you've already forgotten (use `thaw`).
3. **Inputs.** The feature's code; `git log`/`git diff` for the feature; the brainstorming spec and writing-plans plan if they exist; recent `simplify`/`code-review` findings.
4. **Workflow.**
   - **Step 1 — Scope.** User points at the feature (name / files / recent diff / spec). Restate and confirm. Too large → split into sub-features.
   - **Step 2 — Declare intent.** Produce `intent-spec` using the Mozi gu/li/lei schema (below). Socratically challenge vague intent (concept clarification, boundary probing, dependency check, constraint tradeoff). Run reductio (归谬): "if we do this, what's the worst case at 10× scale?" → record in `risk_analysis`. Write `docs/defossil/<feature>/intent.md`.
   - **Step 3 — Record the decision path.** For each non-obvious decision, produce an **ADR-lite** entry: the decision + **≥1 rejected alternative** + **≥1 negative consequence** (hard rule — reject the entry otherwise). Write `docs/defossil/<feature>/decisions.md`.
   - **Step 4 — Propose drift-resistant signs (report, do NOT write yet).** Propose: (a) why-comments — inline at each decision point in code, English, one-line distillation of the ADR-lite (decision + the key rejected alt); (b) `docs/defossil/<feature>/tour.md` — ordered list of `(file:line, what to look at, beacon)`; (c) characterization tests for the happy path / key invariants in the project test dir (`*_orient_test.*`). Present as a report; user confirms/edits. **No silent code edits.**
   - **Step 5 — Apply** confirmed signs (minimal, faithful).
   - **Step 6 — Self-explanation checkpoint → understanding-score.** Without the user looking at the code, ask them to explain 2–4 key decisions / data flows in plain language (Feynman). Compare against the code; where their explanation diverges, that is a gap — surface it and fill it. Compute an **understanding-score** (below). Write `docs/defossil/<feature>/understanding.md`.
   - **Step 7 — Verify & summarize.** Signs reference real code; characterization tests pass. Report: N why-comments / 1 tour / M tests / score / K gaps. Optional tech-debt handoff: suggest running `simplify` / `code-review`.
5. **intent-spec schema (Mozi gu/li/lei).**
   ```
   gu (why):     why this change (business driver / tech debt / user request)
   li (how):     principle or approach (pattern / design principle / tech choice)
   lei (scope):  change category (feature / fix / refactor / perf)
   constraints:          [...]
   acceptance_criteria:  [...]
   risk_analysis: { extreme_scenario: ..., fallback: ... }
   provenance: preserve
   ```
   Stored as `docs/defossil/<feature>/intent.md` (markdown; exact field format finalized at execution).
6. **understanding-score.** Quantify "feels understood": score the user's plain-language explanations of (a) key decisions, (b) the happy-path data flow, (c) the main invariants, by consistency with the code. Record the score and the per-item gaps in `understanding.md`. This makes cognitive debt visible.
7. **Guardrails (inline).** Anti-paraphrase. Every decision needs rejected-alt + downside. Report→confirm→apply. Drift-resistance (signs in their prescribed locations; nothing else). Provenance=preserve on all produced records. Active by default. One feature. Never commit/push.

- [ ] **Step 2: Validate structure**

Dispatch `plugin-dev:plugin-validator`.
Expected: `commands/preserve.md` discovered; frontmatter parses; no errors.

- [ ] **Step 3: Dry-run — preserve a fixture feature**

Create a fixture with a real (tiny) feature:
```bash
mkdir -p /tmp/defossil-fixture
cat > /tmp/defossil-fixture/auth.go <<'EOF'
package auth

func Login(name, pwd string) (*User, error) {
        if name == "" { return nil, errEmpty }
        return lookup(name, pwd)   // uses bcrypt verify inside lookup
}
EOF
```
Execute the `preserve` workflow on the `Login` feature (you play the user for the self-explanation step). Verify the outputs:
- `docs/defossil/login/intent.md` exists with gu/li/lei + constraints + acceptance + risk + `provenance: preserve`.
- `docs/defossil/login/decisions.md` has ≥1 ADR-lite entry, each with a rejected alternative AND a downside.
- A why-comment is proposed at the `lookup` decision point (e.g., why bcrypt / why not plaintext).
- `docs/defossil/login/tour.md` is an ordered `(file:line, …)` list whose links resolve.
- `docs/defossil/login/understanding.md` has a numeric understanding-score + gap list.
Expected: all five artifacts present and well-formed; no artifact restates the code line-by-line; all carry provenance=preserve.

- [ ] **Step 4: Do NOT commit; clean up fixture**

`rm -rf /tmp/defossil-fixture`.

---

## Task 4: `thaw` Command (was tour)

**Files:**
- Create: `commands/thaw.md`

**Interfaces:**
- Consumes: the signs produced by `preserve`/`revive` (`docs/defossil/<unit>/*`, why-comments, characterization tests) + the code.
- Produces: an ephemeral, in-conversation rebuild of understanding; surfaces intent debt (broken signs → hand off to `curate`); optionally proposes a capture-lite why-comment for a gap (with confirmation).

- [ ] **Step 1: Author `commands/thaw.md`**

Frontmatter:
```yaml
---
description: Rebuild your understanding of a feature whose code you've forgotten (half-fossilized). Loads and audits the signs (flagging revive-origin signs as possibly reconstruction-wrong), gives a one-screen orientation, then drives a Socratic rebuild (you explain, it fills the gaps) and scores understanding. Run on demand when you're rusty on your own code. Ephemeral — nothing is persisted unless you confirm a gap-fill.
---
```

Body — required sections and mandatory content:

1. **# Thaw — rebuild the theory from the signs.** Purpose: reduce cognitive debt by reconstructing the interpretant; surface intent debt by auditing the signs. Ephemeral by default.
2. **When to run.** On demand, when you can no longer read your own code (you know the feature but not the code). If no `docs/defossil/<unit>/` signs exist, degrade to a cold rebuild and offer to run `preserve` (or `revive` if it's fossil, not just forgotten).
3. **Workflow.**
   - **Step 1 — Scope + load & audit signs (provenance-aware).** Read `tour.md`, `decisions.md`, `intent.md`, `understanding.md`, the why-comments, and the characterization tests. Audit each for drift: broken `file:line` links, stale references, failing tests, records that contradict the code. **Flag drift, never trust silently.** Broken signs → hand off to `curate`. **Read provenance on each sign: for `provenance=revive` signs, explicitly note "this is a reconstruction — a contradiction may mean the reconstruction was wrong (curate Type E), not ordinary drift."**
   - **Step 2 — Coarse orient (one screen, passive).** Entry points, shape, where things live, the happy-path data flow. Just the map.
   - **Step 3 — Socratic rebuild (active, adaptive depth).** Have the user explain / predict / confirm-or-reject hypotheses; skip what they're solid on, go deep where they're shaky. Techniques: **Feynman** (explain a block in plain language), **deconstruction** (surface unstated assumptions — about external API shapes, input formats, system state, data volume — and rate each assumption's risk if it fails), **reductio** (for each key branch, walk normal / extreme / failure scenarios). **Never paraphrase code** — only answer what the code can't.
   - **Step 4 — understanding-score.** Same mechanism as `preserve`; record what's solid vs. still-gap.
   - **Step 5 — Ephemeral; optional capture-lite.** Persist nothing by default. If a gap the signs didn't cover was found, **propose** adding one why-comment (confirm first).
   - **Step 6 — Escape hatch.** If the user says "just show me", switch to a passive explanation for the rest (respect autonomy); note that retention is weaker.
4. **Guardrails (inline).** Anti-paraphrase. Audit signs before trusting (provenance-aware). Active by default. Ephemeral by default. Report→confirm for any proposed edit. Never commit/push.

- [ ] **Step 2: Validate structure**

Dispatch `plugin-dev:plugin-validator`.
Expected: `commands/thaw.md` discovered; frontmatter parses; no errors.

- [ ] **Step 3: Dry-run — thaw the feature preserved in Task 3**

Recreate the Task 3 fixture WITH its preserved records (re-run Task 3 Step 3 first, or copy its outputs into `/tmp/defossil-fixture/docs/defossil/login/`). Then deliberately introduce drift: change `auth.go` so one `file:line` in `tour.md` no longer resolves. Add one revive-origin sign that contradicts the code to exercise the provenance-aware audit (e.g., a `decisions.md` entry with `<!-- provenance: revive -->` claiming SHA-1 while code uses bcrypt).
Execute the `thaw` workflow (you play a user who has "forgotten" the code). Verify:
- It loads + audits the signs; flags the broken `file:line` and hands it to `curate`.
- **For the revive-origin sign, it explicitly warns "reconstruction — contradiction may be curate Type E, not drift."**
- Coarse orient is one screen.
- Socratic rebuild asks you to explain/predict; it fills gaps without paraphrasing the code.
- It produces an understanding-score.
- Nothing is persisted (no files written) unless you confirm a gap-fill.
Expected: drift caught; provenance-aware warning present; rebuild is active (asks, doesn't lecture); no spurious writes.

- [ ] **Step 4: Do NOT commit; clean up fixture**

`rm -rf /tmp/defossil-fixture`.

---

## Task 5: `excavate` Command (NEW — fossil triage + unknown map)

**Files:**
- Create: `commands/excavate.md`

**Interfaces:**
- Consumes: target-project code (a legacy/outsourced system), git history (commits / PR-MR descriptions / blame / rename history) as degraded intent-fossils, any existing signs (usually none).
- Produces: `docs/defossil/<system>/map.md` — the unknown/confidence map (per-area understanding, recoverability, risk-if-wrong) + a ranked hotspot list for `revive`.

- [ ] **Step 1: Author `commands/excavate.md`**

Frontmatter:
```yaml
---
description: Map a fully-fossilized system — legacy you inherited, or an AI-outsourced black box you never understood. Triages the code, mines git history (commits/PR/blame) as degraded intent-fossils, and produces an unknown/confidence map (where understanding is thinnest, what's recoverable vs irrecoverable, risk-if-wrong) plus a ranked hotspot list to revive. Does NOT try to revive in one pass. Run when taking over a system. Adaptive: degrades gracefully when git is absent/squashed.
---
```

Body — required sections and mandatory content:

1. **# Excavate — map the fossil, pick where to revive.** Purpose: cognitive debt on a fossil is an area problem — solve it by mapping the unknown first, then reviving hotspots one at a time. Never try to revive the whole system in one pass (Naur: a dead theory cannot be wholly resurrected from artifacts). One system per run.
2. **When to run.** On taking over a legacy system, or when you realize a region is an AI-outsourced black box. Before `revive` (or `revive` runs in degraded direct mode without it).
3. **Inputs.** The system's code; **git archaeology** (commits / PR-MR descriptions / blame / rename & move history) — these are degraded intent-fossils (residue of departed authors' intent), NOT authoritative; any existing signs (usually absent).
4. **Workflow.**
   - **Step 1 — Scope.** User points at the system (name / top-level dir / module boundary). Restate and confirm. Too large → split by module/package; excavate one at a time.
   - **Step 2 — Mine git fossils (adaptive).** Read commits, PR/MR descriptions, blame, rename/move history as degraded signs — sources of what departed authors intended. **Adaptive (hard requirement):** if the project is non-git, history was squashed, or it was migrated with broken history → degrade to code-structure + user pointers only, and explicitly mark affected areas "no fossils available" in the map. **Never bless git fossils blindly** — cite them, verify against code before trusting.
   - **Step 3 — Map the unknown.** For each area (module/package/cohesive region), estimate and record (schema below): `area`, `understanding` (low/med/high; no-signs defaults to low), `basis` (the signal set), `recoverability` (recoverable from fossils/comments/structure → candidate for `revive`; or irrecoverable → candidate for rewrite, not understanding), `risk_if_wrong` (blast radius / data safety / external contracts — what breaks if our understanding is wrong).
   - **Step 4 — Select hotspots.** Rank by (understanding=low × risk_if_wrong=high × recoverability=yes); propose top-N to `revive`; user confirms/adjusts.
   - **Step 5 — Produce map.** Write `docs/defossil/<system>/map.md` (persistent — it is the index for subsequent `revive` runs and is itself audited by `curate`).
5. **Hotspot signals (default set).** Change frequency (churn), blast radius (number of dependents), complexity, **has-signs?** (absence = thinner), git-blame age (older = intent more likely evaporated), user-reported scariness ("this block scares me").
6. **map.md schema.**
   ```
   system: <name>
   generated: <yyyymmdd>
   areas:
     - area: <module/path>
       understanding: low | med | high
       basis: [signals that produced the estimate]
       recoverability: recoverable | irrecoverable | no-fossils
       risk_if_wrong: <what breaks if we misread this>
   hotspots_to_revive: [ranked area list]
   ```
7. **Guardrails (inline).** Anti-paraphrase (the map answers "where is it thin/risky/irrecoverable", NOT "what does the code do"). Mark unknowns/irrecoverable honestly — never fabricate. Git fossils are degraded signs: cite, don't bless. No silent code edits. One system per run. Never commit/push.

- [ ] **Step 2: Validate structure**

Dispatch `plugin-dev:plugin-validator`.
Expected: `commands/excavate.md` discovered; frontmatter parses; no errors.

- [ ] **Step 3: Dry-run — excavate a fossil fixture (with git history)**

Create a fixture that is intentionally obscure AND has git history carrying fossilized intent:
```bash
mkdir -p /tmp/defossil-fixture && cd /tmp/defossil-fixture
git init -q && git config user.email t@t && git config user.name t
cat > retry.go <<'EOF'
package retry
// no comments — this is a fossil
func Do(fn func() error, n int) error {
        for i := 0; i < n; i++ {
                if err := fn(); err == nil { return nil }
        }
        return errFailed
}
EOF
git add . && git commit -q -m "fix: cap retries at n to avoid hammering the downstream DB during outages"
# (a second commit that renames something, to exercise rename-history mining)
git mv retry.go retry_do.go && git commit -q -m "refactor: rename retry.Do file for clarity"
```
Execute the `excavate` workflow on `/tmp/defossil-fixture`. Verify:
- It mines the commit messages as degraded intent-fossils (the "cap retries to avoid hammering DB" rationale surfaces) and the rename history.
- `docs/defossil/retry/map.md` exists with ≥1 area entry containing `understanding`, `basis`, `recoverability`, `risk_if_wrong`; `retry_do.go` (no comments) → understanding=low, basis includes has-signs?=no + blame-age.
- A ranked `hotspots_to_revive` list is produced and user-confirmed.
- The map does NOT paraphrase what `Do` does line-by-line (anti-paraphrase).
Expected: map present and well-formed; git fossils cited (not blessed); no fabrication.

- [ ] **Step 4: Dry-run — no-git degradation**

Remove git from a copy and confirm graceful degradation:
```bash
rm -rf /tmp/defossil-fixture-nogit && cp -r /tmp/defossil-fixture /tmp/defossil-fixture-nogit
rm -rf /tmp/defossil-fixture-nogit/.git
```
Re-run `excavate` on `/tmp/defossil-fixture-nogit`. Verify: it detects no git, degrades to code-structure + user pointers, and the map marks areas `recoverability: no-fossils` (or notes "no fossils available"). It does NOT crash and does NOT invent git-derived intent.
Expected: graceful degradation; explicit "no fossils" marking; no fabricated intent.

- [ ] **Step 5: Do NOT commit; clean up fixtures**

`rm -rf /tmp/defossil-fixture /tmp/defossil-fixture-nogit`.

---

## Task 6: `revive` Command (NEW — predict→verify rebuild)

**Files:**
- Create: `commands/revive.md`

**Interfaces:**
- Consumes: a hotspot from `excavate`'s `map.md` (or a user-pointed hotspot in degraded direct mode), the hotspot's code, git fossils, any existing signs.
- Produces: `docs/defossil/<system>/<hotspot>/{intent,decisions,tour,understanding}.md` — ALL tagged `provenance=revive` + `confidence`; optionally why-comments (also revive + confidence) and characterization tests, after confirmation.

- [ ] **Step 1: Author `commands/revive.md`**

Frontmatter:
```yaml
---
description: Bring a fossil hotspot back to life. Per non-obvious decision, runs a predict->reveal->reconcile protocol: YOU read the code and predict intent first, then the AI reveals its hypothesis (intent + rejected alternative + downside + confidence + code evidence, WHY not WHAT), then you reconcile against the code. Lays drift-resistant signs tagged provenance=revive + confidence, and scores how-much-theory-rebuilt (starts near 0; low is honest). Never fabricates — marks irrecoverable intent as unknown. Run on one hotspot at a time, after excavate or directly.
---
```

Body — required sections and mandatory content:

1. **# Revive — bring a fossil hotspot back to life, predict→verify.** Purpose: reverse-rebuild theory where there is none to start from. The code (+ git fossils) is the only ground truth; the user holds ~0 theory. The protocol MUST keep the cognitive labor (read code + judge) on the human side — otherwise this degrades into the passive outsourcing the research warns against. One hotspot per run.
2. **When to run.** After `excavate` selected a hotspot, or directly (degraded) when the user points at one. Not for code you wrote and just forgot — that's `thaw`.
3. **Inputs.** The hotspot's code; git fossils; `excavate`'s `map.md` entry if present; any existing signs.
4. **Core protocol — predict→reveal→reconcile (run per non-obvious decision point).** This is the spine; present as a table and enforce ordering:
   - **① Predict (USER, first).** AI points at a code location and asks ("why do you think this exists? / what happens on input X?"). The user reads the code and commits a prediction. "I have no idea" is a valid low-confidence prediction. **Predicting first is the load-bearing rule** — the prediction is the moment theory gets built.
   - **② Reveal (AI, second).** AI offers its hypothesis: intent + **≥1 rejected alternative + ≥1 negative consequence** (ADR-lite discipline) + `confidence` (high/med/low) + the code evidence it rests on. **Answers WHY only, never restates WHAT** (anti-paraphrase). If intent cannot be supported by code+fossils → explicitly mark `unknown`, do not invent.
   - **③ Reconcile (USER).** User cites code evidence to confirm / refute / refine the AI hypothesis. User's prediction was right → high learning, record the user's insight. AI hypothesis fits code better → user updates theory (active learning). Neither fits → mark `unknown`, leave for later or recommend rewrite.
5. **Why this protocol (cite in-body).** Self-explanation research works by forcing the learner to commit before feedback — the commit is when understanding is built. If AI gives the hypothesis first and the user merely nods, this becomes the passive outsourcing the Anthropic RCT measured at -17%. Ordering is hard: **user reads and judges first; the AI hypothesis is reconciliation feedback only.**
6. **Workflow.**
   - **Step 1 — Scope + load hotspot.** Take hotspot from `map.md` or user pointer; restate and confirm. Too large → split into sub-hotspots.
   - **Step 2 — Per-decision predict→reveal→reconcile** (§4 above). **Bounded:** run only on non-obvious decision points (same threshold as `preserve`), do not force full coverage.
   - **Step 3 — Deconstruct assumptions** (carried from `thaw`). Surface unstated assumptions (external API shapes / input formats / system state / data volume) and rate each assumption's failure risk.
   - **Step 4 — Propose drift-resistant signs (report, do NOT write yet).** why-comments (English, inline, decision + rejected-alt), tour entries, characterization tests — same locations as `preserve`. **All tagged `provenance=revive` + `confidence`.** Present as report; user confirms/edits. **No silent code edits.**
   - **Step 5 — Apply** confirmed signs (minimal, faithful).
   - **Step 6 — understanding-score.** Same mechanism as `preserve` but semantics = **"how much theory has been rebuilt"**, starting near 0. A low score after revive is honest (it maps the remaining fossil), not a failure. Record in `understanding.md`.
   - **Step 7 — Produce artifacts + handoff.** Write `docs/defossil/<system>/<hotspot>/{intent,decisions,tour,understanding}.md`, all `provenance=revive`. `intent.md` uses gu/li/lei but `gu` may be "reconstructed guess" or `unknown`. Verify signs reference real code, characterization tests pass. Report: N decision points / K unknowns / score / how-much-fossil-remains. For sub-areas marked `recoverability=irrecoverable` in the map, **recommend rewrite rather than continued reverse-engineering** (tech-debt handoff).
7. **Guardrails (inline, non-negotiable).** Prediction-first (no rubber-stamping — if the user cannot engage the code, pause rather than reveal). Anti-paraphrase (WHY not WHAT). Every hypothesis needs rejected-alt + downside, OR explicit `unknown`. Report→confirm→apply. **Never fabricate intent** — code+fossils can't support it → mark unknown. Provenance=revive + confidence on all produced records. One hotspot. Never commit/push.

- [ ] **Step 2: Validate structure**

Dispatch `plugin-dev:plugin-validator`.
Expected: `commands/revive.md` discovered; frontmatter parses; no errors.

- [ ] **Step 3: Dry-run — revive a hotspot (prediction-first + provenance + unknowns)**

Create a fossil fixture with no comments and one recoverable + one irrecoverable decision:
```bash
mkdir -p /tmp/defossil-fixture && cd /tmp/defossil-fixture
git init -q && git config user.email t@t && git config user.name t
cat > cache.go <<'EOF'
package cache
func Get(k string) ([]byte, bool) {
        if v, ok := mem[k]; ok { return v, true }
        v, err := db.Load(k)
        if err != nil { return nil, false }
        mem[k] = v
        return v, true
}
EOF
git add . && git commit -q -m "perf: add in-memory memo in front of db.Load to cut repeated lookups (rejected: cache at caller — would duplicate)"
# note: WHY mem is a plain map and not a sized LRU is left UNSTATED -> the irrecoverable decision
```
Execute the `revive` workflow on the `Get` hotspot (you play the user; commit to a prediction before revealing). Verify:
- For the memoization decision: protocol runs **predict → reveal → reconcile** IN THAT ORDER — you (as user) state a prediction BEFORE the AI reveals. The reveal cites the commit-message fossil + code evidence + a rejected alternative + a downside, and states confidence.
- For the "why a plain map not an LRU" decision: intent is irrecoverable from code+fossils → marked **unknown** (NOT fabricated).
- `docs/defossil/cache/Get/intent.md` exists with gu/li/lei (gu = "reconstructed guess" citing the commit, or unknown for the LRU question) + `provenance: revive`.
- `decisions.md` has the memoization ADR-lite (revive) AND an explicit `unknown` entry for the LRU question.
- `understanding.md` has a numeric understanding-score whose semantics is "theory rebuilt" (acknowledged low/near-0 is acceptable) + gap list.
- All four artifacts carry `provenance=revive`; proposed why-comments carry `provenance=revive | confidence: <level>`.
Expected: ordering enforced (predict before reveal); unknowns marked not fabricated; full provenance on all outputs.

- [ ] **Step 4: Do NOT commit; clean up fixture**

`rm -rf /tmp/defossil-fixture`.

---

## Task 7: Integration, Retire Old doc-sweep, End-to-End Dry-Runs

**Files:**
- Modify: `README.md` (status: design → v1 implemented; point at new defossilize docs)
- Delete (after validation): `~/.claude/skills/doc-sweep/` (the now-superseded standalone skill)

**Interfaces:**
- Consumes: all five commands from Tasks 2–6.
- Produces: a consistent, documented v1 plugin; the old standalone `doc-sweep` retired.

- [ ] **Step 1: Cross-check guardrail + naming consistency**

Read all five `commands/*.md`. Verify:
- Shared guardrails (anti-paraphrase; decision-needs-rejected-alt-or-unknown; report→confirm→apply; drift-resistance locations; active-default / prediction-first; provenance on produced records; no-commit) are present and consistent across `preserve`, `thaw`, `excavate`, `revive`, `curate`.
- Naming is consistent: plugin `defossilize`; commands `preserve`/`thaw`/`excavate`/`revive`/`curate`; artifact dir `docs/defossil/<unit>/`; files `intent.md`/`decisions.md`/`tour.md`/`understanding.md`/`map.md`. No leftover `meaning`/`capture`/`tour`/`sweep` references (except inside `README`/docs explaining the rename).
- Provenance vocabulary consistent: values `preserve` | `revive`; `confidence` high/med/low; `curate` E classification references `provenance=revive` only.
Fix any drift between copies.

- [ ] **Step 2: Re-validate the whole plugin**

Dispatch `plugin-dev:plugin-validator` on the plugin root.
Expected: manifest valid; all five commands discovered; no errors.

- [ ] **Step 3: End-to-end dry-run A — fresh pipeline (preserve → curate → thaw)**

Create a small fixture feature (2–3 source files) in `/tmp/defossil-fixture`. Run the fresh pipeline by hand:
1. `preserve` the feature → confirm `docs/defossil/<feature>/` is populated with provenance=preserve, why-comments added, characterization test passes.
2. Mutate the code (rename a function, change a return type) to simulate time passing.
3. `curate` → confirm it classifies the now-drifted signs (A/C) and flags any invariant violation (B).
4. `thaw` → confirm it orients, catches the drift, and Socratically rebuilds understanding; confirm nothing unwanted is persisted.
Expected: the fresh-pipeline loop holds.

- [ ] **Step 4: End-to-end dry-run B — legacy pipeline (excavate → revive → curate, incl. E)**

In `/tmp/defossil-fixture` create a fossil module with git history (reuse the Task 5 retry/cache shape). Run the legacy pipeline by hand:
1. `excavate` → confirm `docs/defossil/<system>/map.md` is produced with hotspots.
2. `revive` one hotspot → confirm predict→reveal→reconcile ordering, provenance=revive artifacts, unknowns marked.
3. `curate` with an injected E scenario: edit a `revive`-origin sign to contradict deliberate code → confirm `curate` classifies it **E (reconstruction-was-wrong)**, routes to revive, does NOT edit the sign to match the code and does NOT flag the code as a bug.
Expected: the legacy-pipeline loop holds; E classification fires correctly on revive-origin signs.

- [ ] **Step 5: Retire the standalone doc-sweep**

Only after Steps 3–4 pass: delete the old skill directory.
Run: `rm -rf /home/work26/.claude/skills/doc-sweep`
(Presence of the migration in `commands/curate.md` is the replacement. Do this only once `curate` is validated.)

- [ ] **Step 6: Update README**

In `README.md`: change the Status line to "v1 implemented (`preserve`, `thaw`, `excavate`, `revive`, `curate`); see the design doc and implementation plan in `docs/`."; ensure any `meaning`/old-command references are updated to `defossilize`/new names; note the plugin dir is `defossilize/` (the top-level rename is user-managed).

- [ ] **Step 7: Do NOT commit; clean up fixture**

`rm -rf /tmp/defossil-fixture`. Leave all plugin changes in the working tree for the user to stage and commit.

---

## Self-Review (run after writing)

- **Spec coverage:** every spec section maps to a task — §4.1 preserve → Task 3; §4.2 thaw → Task 4; §4.3 curate + E classification → Task 2; §4.4 excavate → Task 5; §4.5 revive (predict→verify) → Task 6; §5.1 sign set → Task 2; §5.2 locations + map.md → Global Constraints + each task's body; §5.3 intent-spec → Tasks 3 & 6; §5.4 understanding-score (incl. revive "rebuilt" semantics) → Tasks 3, 4 & 6; §5.5 provenance → Global Constraints + Tasks 2, 3, 6; §6 pipeline integration → Task 7; §7 plugin structure → Task 1; §8 guardrails → Global Constraints + inlined per command; §9 edge cases → handled in command bodies (no-git excavate degrade in Task 5; cold-thaw in Task 4; revive irrecoverable→unknown in Task 6); §11 validation → dry-runs in Tasks 2–7.
- **Placeholder scan:** none — every step shows concrete content (manifest JSON, frontmatter, required sections with mandatory content, fixture commands with heredocs, expected outputs).
- **Type/name consistency:** plugin `defossilize`; commands `preserve`/`thaw`/`excavate`/`revive`/`curate`; artifacts `intent.md`/`decisions.md`/`tour.md`/`understanding.md`/`map.md`; path `docs/defossil/<unit>/`; provenance values `preserve`/`revive`; confidence `high`/`med`/`low`; `curate` buckets A/B/C/D/E — used identically across all tasks.
- **Adaptations noted:** instruction plugin → validate + dry-run instead of unit TDD; no git commits (user-managed); dir rename user-managed. All stated in Global Constraints.
