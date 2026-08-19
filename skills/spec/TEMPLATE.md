# Feature: [feature]

[Summary saying what the feature exists for.]

## Rule: R1 · [rule, imperative]

- **Assumed** *(only when you assumed something)*
  - [the decision nobody made, in one line with less than 120 characters]

### Scenario: S1 · [the case]

* Given [the initial state]
* When [the action]
* Then [the result, with the literal value]

### Scenario: S2 · [another case of the same rule]

* When [the action]
* Then [the result, with the literal value]

## Rule: R2 · [rule, imperative]

### Scenario Outline: S3 · [the case]

* When [the action with <input>]
* Then [the result with <result>]

#### Examples:

  | input   | result  |
  | ------- | ------- |
  | [value] | [value] |
  | [value] | [value] |
