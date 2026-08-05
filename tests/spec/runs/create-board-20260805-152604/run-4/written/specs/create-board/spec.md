# Criar um board

Um board é a raiz do kanban: colunas e cartões existem dentro de um. Esta feature entrega a
criação de um board a partir de um nome, e a recusa do nome que não serve.

## B1 · criar um board a partir de um nome

```gherkin
Scenario: S1 · cria um board com nome válido
  When crio um board com o nome "Sprint 12"
  Then recebo 201 com Location: /boards/{id}
  And o corpo é {"id": "{id}", "name": "Sprint 12"}
```

- **Assumed**
  - o caminho do recurso é `/boards`
  - criar responde `201` com `Location`, e o corpo repete o que foi criado
  - o board é criado só com um nome, e nenhum outro campo entra na requisição
  - nome repetido cria outro board: o nome não é único

## B2 · recusar um nome inválido

```gherkin
Scenario Outline: S2 · recusa um nome inválido
  When crio um board com <nome>
  Then recebo 400 com o corpo {"campo": "name", "mensagem": <mensagem>}

  Examples:
    | nome                      | mensagem                                 |
    | nenhum campo name         | "name é obrigatório"                     |
    | ""                        | "name é obrigatório"                     |
    | "   "                     | "name é obrigatório"                     |
    | um nome de 101 caracteres | "name deve ter no máximo 100 caracteres" |
```

- **Assumed**
  - o nome tem no máximo 100 caracteres
  - um nome só com espaços conta como ausente
  - o corpo do erro é `{"campo": ..., "mensagem": ...}`
