# Criar board

Um board é onde o trabalho de um time fica organizado. Esta feature entrega a criação: o
sistema recebe um nome, guarda o board e devolve o endereço dele.

## B1 · criar um board a partir do nome

```gherkin
Scenario: S1 · cria o board com o nome informado
  When crio um board com o nome "Sprint 12"
  Then recebo 201 com Location: /boards/{id}
  And o corpo traz esse mesmo id e o nome "Sprint 12"
```

- **Assumed**
  - a criação responde 201 com `Location` e o corpo repetindo o que foi criado

## B2 · recusar um nome inválido

```gherkin
Scenario Outline: S2 · recusa o board quando o nome não serve
  When crio um board com o nome <nome>
  Then recebo 400 em application/problem+json apontando o campo "name"
  And nenhum board foi gravado

  Examples:
    | nome                    | motivo                    |
    | não vem no corpo        | campo ausente             |
    | ""                      | vazio                     |
    | "   "                   | só espaços                |
    | "A" repetido 101 vezes  | passa de 100 caracteres   |
```

- **Assumed**
  - o nome do board vai até 100 caracteres
  - o corpo de erro é `application/problem+json` com o campo inválido apontado

## B3 · aceitar dois boards com o mesmo nome

```gherkin
Scenario: S3 · cria um segundo board com um nome que já existe
  Given existe um board chamado "Sprint 12"
  When crio um board com o nome "Sprint 12"
  Then recebo 201 com um id diferente do board que já existia
```

- **Assumed**
  - o nome do board não é único
