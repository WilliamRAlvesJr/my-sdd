# criar um board

O board é o quadro onde o trabalho vai ser organizado. Esta feature cria um board a partir do
nome escolhido e devolve o endereço em que ele passa a existir.

## B1 · criar um board com o nome escolhido

```gherkin
Scenario: S1 · cria um board
  When crio um board com o nome "Sprint 12"
  Then recebo 201 com Location: /boards/{id}
  And o corpo traz o id gerado e o nome "Sprint 12"
```

```gherkin
Scenario: S2 · cria um board com um nome que já existe
  Given um board chamado "Sprint 12"
  When crio um board com o nome "Sprint 12"
  Then recebo 201 com um id diferente do board que já existia
```

- **Assumed**
  - as scenarios são escritas em português, que o projeto ainda não tinha definido
  - a criação responde 201 com `Location` e o corpo do board criado
  - dois boards podem ter o mesmo nome

## B2 · recusar um nome inválido

```gherkin
Scenario Outline: S3 · recusa o nome inválido
  When crio um board com o nome <nome>
  Then recebo 400 apontando o campo "name" com o motivo <motivo>

  Examples:
    | nome                     | motivo                     |
    | ""                       | "não pode ser vazio"       |
    | "   "                    | "não pode ser vazio"       |
    | não enviado              | "é obrigatório"            |
    | 101 caracteres           | "no máximo 100 caracteres" |
```

- **Assumed**
  - o nome tem no máximo 100 caracteres
  - a resposta de erro traz o campo recusado e o motivo
