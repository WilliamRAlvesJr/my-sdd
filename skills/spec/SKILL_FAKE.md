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

## PHASE 1: READ

**RB01**: You will follow the rules of this phase in the order they are written, top to bottom, one at a time.

**RB02**: List the project's root folder with a `Glob` tool call. Output it to the user as a tree.

**RB03**: Output a "Hello World" script in Java to the user.

**RB04**: Open `src/main/resources/application.properties` with a `Read` tool call.

**RB05**: Output the content of `application.properties` to the user verbatim.

## PHASE 2: WORK OUT THE GHERKIN

**RC01**: Between the `▸` and the `◂` of this phase you output this markdown code block and nothing else:
```markdown
[FEATURE NAME]
├── [RULE NAME]
│   ├── [SCENARIO NAME]
│   ├── ...
│   └── [SCENARIO NAME]
├── ...
└── [RULE NAME]
    ├── [SCENARIO NAME]
    ├── ...
    └── [SCENARIO NAME]

Assumed:
- [ASSUMPTION]
- [ASSUMPTION]

Open:
1. [QUESTION]
2. [QUESTION]
```

### Tree

**RC02**: From the user argument, you will break it into `Scenarios` that fit only what was explicitly requested.

**RC03**: Each `Scenario` must be inside one `Rule`.

**RC04**: Each `Rule` must be inside one `Feature`.

### Assumed

**RC05**: Never invent a missing decision in silence: take the most likely value and write it down.

**RC06**: Every value nobody chose goes under `Assumed`, right below the tree.

**RC07**: A convention you picked for lack of one to inherit goes under `Assumed`, on its first use.

**RC08**: A convention the project already has stays out: its owner is outside this spec.

**RC09**: Write the `Assumed` line even when a `Scenario` already shows the value.

**RC10**: A long `Assumed` list is a signal, not clutter: never merge or summarize it.

**RC11**: Never write under `Assumed` what the request left out.

**RC12**: The `Assumed:` line is always there, and with nothing to list it is one item, `nothing`.

### Open

**RC13**: You will write a numbered list of `Open`, right below the `Assumed`.

**RC14**: An `Open` item is a question only the user can answer.

**RC15**: The last `Open` item is always `is this list right?`, so the list is never empty.
