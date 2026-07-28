# [feature] — spec

[Resumo dizendo para que a feature existe.]

## S1 · [comportamento, no imperativo]

```gherkin
Cenário: [o caso]
  Dado [o estado inicial]
  Quando [a ação]
  Então [o resultado, com o valor literal]

Cenário: [outro caso do mesmo comportamento]
  Quando [a ação]
  Então [o resultado, com o valor literal]
```

## S2 · [comportamento, no imperativo]

```gherkin
Esquema do Cenário: [a regra]
  Quando [a ação com <entrada>]
  Então [o resultado com <resultado>]

  Exemplos:
    | entrada | resultado |
    | [valor] | [valor]   |
    | [valor] | [valor]   |
```

- **Assumido** *(só quando houve suposição)*
  - [a decisão que ninguém tomou, numa linha]
