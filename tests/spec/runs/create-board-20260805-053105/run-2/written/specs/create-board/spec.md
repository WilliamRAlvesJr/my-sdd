# Criar um board

Um board é onde o trabalho de um time fica visível. Esta feature cria um board a partir de um
nome e responde com o endereço dele.

## B1 · cria um board com o nome informado

```gherkin
Scenario: S1 · cria o board e responde com o endereço dele
  When crio um board com o nome "Sprint 12"
  Then recebo 201 com Location: /boards/{id}
  And o corpo traz esse mesmo id e o nome "Sprint 12"
```

- **Assumed**
  - a criação responde 201 com `Location` e o corpo do que foi criado

## B2 · recusa um nome que não serve

```gherkin
Scenario Outline: S2 · recusa o nome e não cria nada
  When crio um board com o nome <nome>
  Then recebo 400 apontando o campo "name"
  And nenhum board foi criado

  Examples:
    | nome                              |
    | ""                                |
    | "   "                             |
    | um texto de 121 caracteres        |
    | nenhum: o campo não vem no corpo  |
```

- **Assumed**
  - o nome vai até 120 caracteres
  - a resposta de erro é 400 apontando o campo que foi recusado

## B3 · aceita dois boards com o mesmo nome

```gherkin
Scenario: S3 · cria um segundo board de mesmo nome, com id próprio
  Given um board chamado "Sprint 12"
  When crio um board com o nome "Sprint 12"
  Then recebo 201 com um id diferente do primeiro
  And os dois boards existem
```

- **Assumed**
  - o nome do board não é único
