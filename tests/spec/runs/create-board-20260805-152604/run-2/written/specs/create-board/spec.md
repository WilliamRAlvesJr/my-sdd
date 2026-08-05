# Criar um board

O board é o quadro onde o trabalho é organizado. Esta feature cobre a criação de um board a
partir de um nome, e o que o sistema faz quando o nome não serve.

## B1 · criar um board a partir de um nome

```gherkin
Scenario: S1 · cria um board com nome válido
  When envio POST /boards com {"name": "Sprint 42"}
  Then recebo 201 com Location: /boards/{id}
  And o corpo é {"id": "{id}", "name": "Sprint 42"}
```

- **Assumed**
  - criação responde 201 com `Location` e o corpo repete o que foi criado

## B2 · rejeitar um nome que não serve

```gherkin
Scenario Outline: S2 · rejeita o nome inválido
  When envio POST /boards com {"name": <nome>}
  Then recebo 400 com "detail": <detalhe>
  And a resposta não traz Location

  Examples:
    | nome                      | detalhe                                     |
    | ""                        | "name: não pode estar em branco"            |
    | "   "                     | "name: não pode estar em branco"            |
    | um nome de 101 caracteres | "name: tem no máximo 100 caracteres"        |
```

```gherkin
Scenario: S3 · rejeita o corpo sem o campo name
  When envio POST /boards com {}
  Then recebo 400 com "detail": "name: não pode estar em branco"
  And a resposta não traz Location
```

- **Assumed**
  - o nome tem no máximo 100 caracteres
  - espaço em volta não conta: um nome só de espaços é o mesmo que vazio
  - o erro segue ProblemDetail (RFC 7807), com a mensagem em português

## B3 · aceitar dois boards com o mesmo nome

```gherkin
Scenario: S4 · cria um segundo board com um nome que já existe
  Given um board "Sprint 42" já criado
  When envio POST /boards com {"name": "Sprint 42"}
  Then recebo 201 com um Location diferente do primeiro
```

- **Assumed**
  - o nome do board não é único: nada impede a repetição
