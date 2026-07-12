---
description: Pin the why before it petrifies. Pin a feature's "why" into code while you still understand it. One feature at a time; run after simplify.
argument-hint: <feature>
---

# preserve: pin the why

While you still remember why a feature is written this way, pin that "why" into the code and an understanding card, before that memory (记忆, not 内存) fossilizes. One feature at a time.

## Prep

1. Pick the object: turn `<feature>` into `<area>/<unit>`; write artifacts under `docs/defossilize/<area>/<unit>/`. If a `.progress.md` already exists, read it and ask whether to resume or redo (default: resume).

## Workflow

1. Scope: confirm with the user that this run covers exactly one feature's boundary; split if too large. Note which files and entry points are in or out.
2. State intent: describe why this feature exists along three axes (from the Mohist Canon), each backed by code (cite file:line):
   - reason (故): why it exists (business driver / technical constraint / user need).
   - principle (理): the approach (design principle / pattern / trade-off).
   - category (类): the change type (feature / fix / refactor / perf).
   Mark any axis you can't back with code as "inferred" and lower its confidence; don't force it.
   [milestone: intent-declared]
3. Record the non-obvious decisions: the ones you can't read out of the code. Each needs the decision, a rejected alternative, and the cost. A decision whose cost you can't name isn't really understood.
4. Write signs: a sign (代码标记) states something the code can't say on its own (a hidden assumption, an invariant, a cross-package contract) in a source comment that breaks loudly when the code drifts. Don't restate what the code already shows. Log it in the card's sign list.
   [milestone: signs-applied]
5. Self-explanation checkpoint: have the user explain the unit in their own words. First a one-paragraph summary of what it does (the macro picture), then the reasoning (how 故 leads to 理 and on to the current implementation). If they stall or muddle the summary, that's a gap; go back to the code and clarify, don't rush to a verdict. Save their one-paragraph summary into the card's Summary field (their words; polish only with their OK). Optionally, if they ask, also write it as a file-level doc comment in the code.
6. Score understanding: give a current understanding score (0-100%) with basis (test coverage, comments, evidence).
7. Wrap up: write the understanding card (specimen.md); list any handoffs (接手文档) found this run; [milestone: completed]; set `.progress.md` status to completed and keep the file (don't delete).

## Output

Understanding card `docs/defossilize/<area>/<unit>/specimen.md`:

```markdown
# Understanding card: <area> / <unit>
provenance: preserve  ·  understanding: <N>%

## Summary
<one paragraph: what this unit does (the author's own words)>

## Intent (故/理/类)
- 故 (reason): <why it exists; code evidence file:line>
- 理 (principle): <design approach / pattern / trade-off>
- 类 (category): <feature / fix / refactor / perf>

## Decisions (non-obvious only)
- decision: <…>; rejected: <…>; cost: <…>

## Reading tour
1. <what it does> (<file:line>)

## Signs (written into source)
- <file funcX>: <stated assumption / invariant, guaranteed by whom>

## Understanding & open threads
- understanding: <N>%; open: <…> (-> handoff HNNN or open thread)
```

Progress `docs/defossilize/<area>/<unit>/.progress.md` (milestone format; other commands follow this):

```markdown
---
unit: <unit>
scope: <area>
command: preserve
status: in-progress        # completed is kept, not deleted
git_ref: <HEAD short sha>
updated: <ISO time>
---

## Milestones
- [<time>] intent-declared: <one line> (source: auto)
- [<time>] signs-applied: <one line> (source: auto)

## Next
<next>

## Context (for resuming)
<context_digest: what this unit is, the main conclusion, the current debt; enough for a fresh session to pick up>
```

## Constraints

- No paraphrase: don't restate what the code already expresses; answer only the "why" the code can't.
- No fabrication: mark uncertainty as unknown or inferred; never invent.
- Don't fix bugs: if you find a real code bug, write a handoff to `docs/defossilize/handoffs/H<NNN>-<slug>.md` (frontmatter: id/title/severity/status:open/found_by/found_in/git_ref/created/location; body: evidence & reproduction, suggested fix direction); don't fix it in this task; summarize at the end.
