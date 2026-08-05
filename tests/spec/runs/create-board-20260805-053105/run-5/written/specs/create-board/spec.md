# Criar board

O board é o quadro onde o trabalho vai ser organizado. Esta feature cobre criar um board a
partir de um nome e devolver o que foi criado.

## B1 · criar um board a partir de um nome

```gherkin
Scenario: S1 · cria um board com nome válido
  When envio POST /boards com o nome "Sprint 12"
  Then recebo 201 com Location: /boards/{id}
  And o corpo traz o id do board e o nome "Sprint 12"
```

- **Assumed**
  - a criação recebe só o nome do board
  - a criação responde 201 com `Location` e o corpo repete o que foi criado
  - o texto dos passos está em português

## B2 · recusar um nome inválido

```gherkin
Scenario Outline: S2 · recusa um nome inválido
  When envio POST /boards com <nome>
  Then recebo 400 com a mensagem "<mensagem>"
  And nenhum board é criado

  Examples:
    | nome                          | mensagem                              |
    | o nome ""                     | nome é obrigatório                    |
    | o nome "   "                  | nome é obrigatório                    |
    | nenhum campo nome             | nome é obrigatório                    |
    | um nome de 61 caracteres      | nome deve ter no máximo 60 caracteres |
```

- **Assumed**
  - o nome tem no máximo 60 caracteres
  - erro de validação responde 400 com uma mensagem por campo recusado

## B3 · aceitar um nome que já existe

```gherkin
Scenario: S3 · cria um segundo board com o mesmo nome
  Given um board chamado "Sprint 12" já criado
  When envio POST /boards com o nome "Sprint 12"
  Then recebo 201 com Location: /boards/{id}
  And o id é diferente do board que já existia
```

- **Assumed**
  - o nome do board não é único
