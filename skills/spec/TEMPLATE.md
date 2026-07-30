# [feature] — spec

[Resumo dizendo para que a feature existe.]

## B1 · [behavior, no imperativo]

```gherkin
Scenario: [o caso]
  Given [o estado inicial]
  When [a ação]
  Then [o resultado, com o valor literal]

Scenario: [outro caso do mesmo behavior]
  When [a ação]
  Then [o resultado, com o valor literal]
```

- **Assumido** *(só quando houve suposição)*
  - [a decisão que ninguém tomou, numa linha]

## B2 · [behavior, no imperativo]

```gherkin
Scenario Outline: [o caso]
  When [a ação com <entrada>]
  Then [o resultado com <resultado>]

  Examples:
    | entrada | resultado |
    | [valor] | [valor]   |
    | [valor] | [valor]   |
```
