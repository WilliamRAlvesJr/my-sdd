# [feature]

[Summary saying what the feature exists for.]

## B1 · [behavior, imperative]

```gherkin
Scenario: S1 · [the case]
  Given [the initial state]
  When [the action]
  Then [the result, with the literal value]
```

```gherkin
Scenario: S2 · [another case of the same behavior]
  When [the action]
  Then [the result, with the literal value]
```

- **Assumed** *(only when you assumed something)*
  - [the decision nobody made, in one line]

## B2 · [behavior, imperative]

```gherkin
Scenario Outline: S3 · [the case]
  When [the action with <input>]
  Then [the result with <result>]

  Examples:
    | input   | result  |
    | [value] | [value] |
    | [value] | [value] |
```
