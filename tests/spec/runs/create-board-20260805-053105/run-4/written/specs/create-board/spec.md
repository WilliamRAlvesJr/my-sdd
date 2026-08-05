# Criar um board

O board é a unidade que agrupa o trabalho no kanban. Esta feature cobre a criação de um
board a partir do nome: o board criado, o nome que não serve e o nome que já existe.

## B1 · criar um board a partir do nome

```gherkin
Scenario: S1 · cria o board e devolve o endereço dele
  When eu crio um board com o nome "Sprint 42"
  Then recebo 201 com Location: /boards/{id}
  And o corpo traz esse id e o nome "Sprint 42"
```

- **Assumed**
  - o recurso é `/boards`, e a criação responde 201 com `Location` e o corpo repetindo o que foi criado
  - o contrato da API é em inglês: o campo do nome é `name`

## B2 · recusar o nome que não serve

```gherkin
Scenario Outline: S2 · recusa o board com nome inválido
  When eu crio um board com o nome <nome>
  Then recebo 400 apontando o campo "name"

  Examples:
    | nome                      |
    | ""                        |
    | "   "                     |
    | um nome de 101 caracteres |
```

```gherkin
Scenario: S3 · recusa a criação sem o campo do nome
  When eu crio um board sem enviar o campo "name"
  Then recebo 400 apontando o campo "name"
```

- **Assumed**
  - o nome vai até 100 caracteres
  - erro de validação responde 400 com um corpo que diz qual campo está errado

## B3 · aceitar dois boards com o mesmo nome

```gherkin
Scenario: S4 · o nome repetido cria um segundo board
  Given existe um board com o nome "Sprint 42"
  When eu crio um board com o nome "Sprint 42"
  Then recebo 201 com um id diferente do board que já existia
```

- **Assumed**
  - nome repetido é aceito, e cada board tem o seu próprio id
