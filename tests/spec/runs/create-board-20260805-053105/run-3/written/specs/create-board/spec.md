# Criar um board

O board é o quadro onde o trabalho é organizado. Esta feature cobre a criação de um board a
partir do nome que a pessoa dá a ele, e a recusa de um nome que não serve.

## B1 · criar um board com um nome

```gherkin
Scenario: S1 · cria um board com um nome válido
  When crio um board com o nome "Sprint 12"
  Then recebo 201 com Location: /boards/{id}
  And o corpo traz o id gerado e o nome "Sprint 12"
```

- **Assumed**
  - o texto dos passos está em português, porque o projeto está vazio e não havia convenção a herdar
  - criar responde 201 com Location e o corpo repete o que foi criado
  - o id do board é gerado pelo sistema, e não chega no pedido

## B2 · recusar um board cujo nome não serve

```gherkin
Scenario Outline: S2 · recusa um nome inválido
  When crio um board com <nome>
  Then recebo 400 dizendo que o campo nome é inválido

  Examples:
    | nome                             |
    | nenhum campo nome no pedido      |
    | ""                               |
    | "   "                            |
    | um nome de 101 caracteres        |
```

- **Assumed**
  - o nome do board vai até 100 caracteres
  - um nome só de espaços conta como nome em branco
  - o erro de validação responde 400 dizendo qual campo falhou

## B3 · aceitar um nome que outro board já usa

```gherkin
Scenario: S3 · dois boards podem ter o mesmo nome
  Given já existe um board com o nome "Sprint 12"
  When crio um board com o nome "Sprint 12"
  Then recebo 201 com um id diferente do primeiro
```

- **Assumed**
  - o nome do board não é único: ninguém pediu que fosse
