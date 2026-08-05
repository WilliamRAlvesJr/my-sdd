# Criar um board

Um board é o quadro onde o trabalho é organizado. A feature cobre a criação de um board a
partir do nome que a pessoa dá a ele, e a recusa de um nome que não serve.

## B1 · criar um board a partir do nome

```gherkin
Scenario: S1 · cria o board e devolve o endereço dele
  When envio POST /boards com o nome "Sprint 12"
  Then recebo 201 com Location: /boards/{id}
  And o corpo traz o id do board criado e o nome "Sprint 12"
```

```gherkin
Scenario: S2 · dois boards podem ter o mesmo nome
  Given um board chamado "Sprint 12" já criado
  When envio POST /boards com o nome "Sprint 12"
  Then recebo 201 e o id do novo board é diferente do id do primeiro
```

- **Assumed**
  - a criação responde 201 com `Location: /boards/{id}` e o corpo repetindo o board criado
  - o texto dos scenarios está em português
  - o mesmo nome pode se repetir entre boards

## B2 · recusar um board com nome inválido

```gherkin
Scenario Outline: S3 · recusa o nome que não serve
  When envio POST /boards com <nome enviado>
  Then recebo 400 e o corpo aponta o campo "name" com a mensagem <mensagem>

  Examples:
    | nome enviado              | mensagem                              |
    | sem o campo name          | "o nome é obrigatório"                |
    | ""                        | "o nome é obrigatório"                |
    | "   "                     | "o nome é obrigatório"                |
    | um nome de 101 caracteres | "o nome tem no máximo 100 caracteres" |
```

- **Assumed**
  - o limite do nome é 100 caracteres
  - o corpo de erro traz o campo inválido e a mensagem correspondente
