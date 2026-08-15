## Skill Activation Router — Read This Before Starting Any Task

You have five installed skills for this project: `spotlight-connect-architect`, `continuous-market-intelligence`, `data-moat-strategist`, `senior-engineering-discipline`, `creative-differentiation-designer`. Do not load all five into active reasoning for every task — that wastes context and dilutes focus. Instead, use the trigger table below to determine which skill(s) apply to the specific task in front of you right now, activate only those, and hand off explicitly when the task moves into a different phase.

### Step 1 — Classify the task before doing anything else

Every task you receive on this project falls into one of these categories. State which category applies, out loud, before proceeding:

1. **Schema / data model change** (new table, new column, new relationship, anything touching `fans`, `fan_identities`, `fan_events`, `deals`, or any canonical table)
2. **New feature / module proposal** (a new capability being considered, regardless of whether it's UI, backend, or algorithmic)
3. **Algorithm / scoring / ranking / matching logic** (anything computing a score, rank, fit, or recommendation)
4. **UI / UX / screen / user-facing flow work**
5. **Research / competitive / regulatory question** (anything about what a competitor does, what a law requires, or whether a market assumption still holds)
6. **Routine implementation** (bug fix, refactor, test-writing, straightforward CRUD work with no schema or algorithm novelty)
7. **Legal-gate-adjacent work** (anything touching Bridge Agency deal procurement, minor-creator compliance, or consent/privacy workflows)

### Step 2 — Activate skills based on category (this is the actual routing table)

| Task category | Activate these skills, in this order | Do NOT proceed until |
|---|---|---|
| 1. Schema / data model change | `spotlight-connect-architect` FIRST (mandatory, always) → `senior-engineering-discipline` for implementation | The architect skill's full output format (schema impact / duplication check / RLS impact / DO NOT BUILD check / recommendation) has been produced and shows "proceed" or "proceed with modification" |
| 2. New feature / module proposal | `spotlight-connect-architect` → `data-moat-strategist` → `continuous-market-intelligence` (if the moat-strategist flags it Category 3, verify the competitive landscape is current before finalizing "integrate" as the answer) | Both the architect and moat-strategist have produced their structured outputs, and if Category 3, the market-check confirms the recommended integration partner is still viable |
| 3. Algorithm / scoring / ranking / matching logic | `data-moat-strategist` FIRST (mandatory, always) → `spotlight-connect-architect` (to confirm schema support exists) → `senior-engineering-discipline` for implementation | The moat-strategist has classified the algorithm into Category 1-4 and, if Category 1, confirmed which proprietary data it depends on and that the schema captures it |
| 4. UI / UX / screen / user-facing flow work | `creative-differentiation-designer` → `spotlight-connect-architect` (only if the screen surfaces new data not yet in the schema) | The differentiation skill's output format is complete, including the "data dependency" check confirming nothing is invented that the schema doesn't support |
| 5. Research / competitive / regulatory question | `continuous-market-intelligence` ONLY | A dated, sourced summary has been produced — never answer a research question from memory alone on this project without running this skill first |
| 6. Routine implementation (no schema/algorithm/UI novelty) | `senior-engineering-discipline` ONLY | Plan has been stated, assumptions declared, and the specific test/verification method for this change is identified |
| 7. Legal-gate-adjacent work | `spotlight-connect-architect` → STOP and escalate to human — do not attempt to resolve legal-structure questions autonomously | Human has explicitly confirmed the legal/compliance question is resolved or provided the specific handling instruction |

### Step 3 — Handoff protocol between skills

When a task requires more than one skill (which is most tasks — see table above), treat each skill's output as the structured input to the next, not as a final answer to react to informally[web:352]:

1. Run the first skill in the sequence and produce its full structured output exactly in the format that skill specifies.
2. Before moving to the next skill, restate the prior skill's key finding in one line (e.g., "Architect check: no schema duplication found, RLS plan required for two new tables — proceeding to moat-strategist check").
3. Run the next skill using that finding as context, not by re-deriving it from scratch.
4. Only after every required skill in the sequence has produced a "proceed" (or equivalent) verdict should implementation begin.
5. If any skill in the sequence produces a "stop and ask" or "escalate to human" verdict, halt the entire sequence immediately — do not continue to the next skill in the chain, and do not attempt to route around the blocker.

### Step 4 — When to activate `senior-engineering-discipline` regardless of category

This skill has a broader activation condition than the others: activate it for **any** task that involves writing or modifying code, regardless of which category (1-7) the task falls into, in addition to whichever other skill(s) the table above specifies. It is the one skill in this pack designed to run continuously alongside the others, not just at a single decision point — think of it as the quality layer wrapping every other skill's output, not a peer competing for the same slot in the sequence.

### Step 5 — When to activate `continuous-market-intelligence` on a standing cadence, not just per-task

In addition to the per-task triggers in the routing table, activate this skill automatically:
- At the start of any new module/phase in the build sequence (Fan/Passport, Bridge Agency, Local Catalyst, Stream to Cart, RouteIQ, Trust layer, API product) — before any other skill runs for that phase.
- Before finalizing any document, report, or output that will be shown to an investor, partner, or external party, to verify every named statistic still has a current, citable source.
- If more than 14 days have passed since the last time this skill was run on this project, run it once at the start of the next session before doing anything else, specifically checking the watch-list items defined in that skill's own instructions.

---

## Explicit Trigger Keywords (For Faster Auto-Activation)

Per current best practice, skills should be discoverable by the exact words a user would actually type, not just paraphrased intent[web:348]. If any of these words or phrases appear in a task description, treat it as an automatic signal to run the check listed, even if the task wasn't explicitly categorized using Step 1 above:

| If the task mentions... | Auto-activate |
|---|---|
| "table," "column," "schema," "migration," "RLS," "policy," "fan_events," "fan_identities" | `spotlight-connect-architect` |
| "competitor," "market," "still true," "current," "verify," "check if," "has this changed" | `continuous-market-intelligence` |
| "score," "rank," "match," "algorithm," "formula," "weight," "fit," "recommend" | `data-moat-strategist` |
| "screen," "UI," "UX," "design," "layout," "dashboard," "flow," "onboarding" | `creative-differentiation-designer` |
| "build," "implement," "fix," "refactor," "test," "debug" (with no other trigger word present) | `senior-engineering-discipline` |
| "deal," "contract," "procure," "negotiate," "minor," "consent," "privacy request" | `spotlight-connect-architect` (legal-gate path) + escalate |

---

## What "Deployed Correctly" Looks Like — Self-Check

Before considering any multi-skill task complete, confirm all of the following are true. If any is false, the skills were not actually deployed correctly for this task, regardless of whether the final code/output looks fine:

- [ ] The task was classified into one of the seven categories before any skill ran.
- [ ] Every skill required by the routing table for that category actually ran and produced its full structured output — not a shortcut summary.
- [ ] Each skill's output was explicitly restated as input context before the next skill in the sequence ran.
- [ ] No skill's "stop and ask" or "escalate" verdict was silently overridden or worked around.
- [ ] If the task touched code, `senior-engineering-discipline` was active throughout, not just invoked once at the start.
- [ ] If the task relied on any competitive, market, or regulatory claim, that claim traces to a `continuous-market-intelligence` check run within the last 14 days — not to general knowledge or an older, unverified assumption.

## The one override rule that beats every trigger table above

Regardless of task classification or keyword matching, if you are ever uncertain which skill applies, or uncertain whether a "stop and ask" condition has been met, default to running `spotlight-connect-architect` and stating your uncertainty explicitly rather than guessing and proceeding. An unnecessary architect check costs a small amount of time; a skipped one risks the exact schema fragmentation, security gap, or legal exposure this entire skill system exists to prevent.
