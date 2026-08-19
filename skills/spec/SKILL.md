---
name: spec
description: >
  Writes the spec of every feature in the request, as Gherkin scenarios anyone can check by
  watching the system run.
  Use when the user says "spec out X", "write the spec for X", or invokes /my-spec:spec.
argument-hint: "[--verbose] <request>"
---

# spec: what the system does, in examples

## Explanation

A phase is a Heading 2 section in this file and is written like this:
```markdown
## PHASE [PHASE NUMBER]: [PHASE NAME]
**[RULE ID]**: [RULE INSTRUCTIONS]
**[RULE ID]**: [RULE INSTRUCTIONS]
**[RULE ID]**: [RULE INSTRUCTIONS]
...
```

A Heading 3 section groups the rules of one phase and is not a phase.

Every bold text in this `SKILL`, like **RB01** and **RC02**, is a rule id.

## Tracing

**RA01**: Ignore the rules **RA02** to **RA05** if the `--verbose` argument is not present.

**RA02**: Before the first tool call of each phase, you will output (no code block) this:
```markdown
▸ PHASE [PHASE NUMBER]: [PHASE NAME]
```

**RA03**: After the last tool call of each phase, you will output (no code block) this:
```markdown
◂ PHASE [PHASE NUMBER]
```

**RA04**: A round is one run of the check of a phase that is a cycle.

**RA05**: A cycle phase emits one of these per round, numbered, between its `▸` and its `◂`:
```markdown
▪ PHASE [PHASE NUMBER] · round [ROUND NUMBER] · [what is still open]
```

## Output

**RD01**: Every line you write to the user is a line some rule asked for.

**RD02**: No preamble before it, no closing note after it, no telling the user what you are about to do.

**RD03**: A label or a heading nobody asked for is prose too: you never add one.

**RD04**: You write in English, whatever language the request came in.

## PHASE 1: WORK OUT THE GHERKIN

**RC01**: The output of this phase is one markdown code block: `TEMPLATE.md` without the steps, plus `Open`.
```markdown
# Feature: [FEATURE]

[Summary saying what the feature exists for.]

## Rule: R1 · [RULE, IMPERATIVE]

- **Assumed**
  - [THE DECISION NOBODY MADE]

### Scenario: S1 · [WHAT SOMEONE DOES] → [WHAT THE SYSTEM DOES]

### Scenario: S2 · ...

## Rule: R2 · [RULE, IMPERATIVE]

### Scenario: S3 · ...

## Open

1. [QUESTION]
2. [QUESTION]
```

### Structure

**RC02**: From the user argument, you will break it into `Scenarios`.

**RC19**: Only what the request names gets in: no other entity, no actor, no permission, no operation.

**RC17**: A `Rule` is one business rule of the feature, and it groups the `Scenarios` that check it.

**RC18**: A `Scenario` name reads `[what someone does] → [what the system does]`, seen from outside.

**RC20**: A result you cannot name is a decision: take the likely one, and it goes under `Assumed`.

**RC21**: Every line traces back to a word of the request: an operation nobody named is out.

**RC22**: What you decided goes to `Assumed`, what you doubt goes to `Open`, and neither shows in a name.

**RC23**: A `Scenario` checks the operation of its `Rule` and nothing else: another capability is out.

**RC25**: Every `Rule` has at least one `Scenario` where its operation fails.

**RC03**: Each `Scenario` must be inside one `Rule`.

**RC04**: Each `Rule` must be inside one `Feature`.

### Assumed

**RC05**: Never invent a missing decision in silence: take the most likely value and write it down.

**RC06**: Every value nobody chose goes under the `Assumed` of the `Rule` that uses it.

**RC07**: A convention you picked for lack of one to inherit goes under `Assumed`, on its first use.

**RC08**: A convention the project already has stays out: its owner is outside this spec.

**RC09**: Write the `Assumed` line even when a `Scenario` already shows the value.

**RC11**: Never write under `Assumed` what the request left out.

**RC26**: An `Assumed` only fills a value in: it never adds an actor, a permission or an operation.

**RC12**: A `Rule` with nothing assumed carries no `Assumed` block at all.

### Open

**RC13**: You will write a numbered list of `Open`, as the last section of the block.

**RC14**: An `Open` item is a question only the user can answer.

**RC15**: The last `Open` item is always `is this list right?`, so the list is never empty.
