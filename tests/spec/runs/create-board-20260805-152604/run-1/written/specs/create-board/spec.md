# Criar board

O board é onde o trabalho fica organizado, e é a primeira coisa que alguém precisa ter para
usar o sistema. Esta feature cria o board a partir de um nome e devolve o endereço dele, e
recusa o nome que não serve.

## B1 · criar um board a partir do nome

```gherkin
Scenario: S1 · cria o board e devolve o endereço
  When eu crio um board com o nome "Sprint 42"
  Then recebo 201 com Location: /boards/{id}
  And o corpo traz {"id": "{id}", "name": "Sprint 42"}
  And existe um board gravado com o nome "Sprint 42"
```

```gherkin
Scenario: S2 · dois boards podem ter o mesmo nome
  Given um board com o nome "Sprint 42" já existe
  When eu crio um board com o nome "Sprint 42"
  Then recebo 201 com um id diferente do board que já existia
  And existem dois boards gravados com o nome "Sprint 42"
```

- **Assumed**
  - nome de board não é único: ninguém decidiu se o nome se repete ou se a segunda criação é
    recusada
  - criação responde 201 com `Location` e o corpo repete o que foi criado: o projeto não tinha
    convenção de resposta
  - o texto dos scenarios está em português: o projeto não tinha nada escrito em prosa para
    herdar o idioma

## B2 · recusar o board sem nome válido

```gherkin
Scenario Outline: S3 · recusa o nome que não serve
  When eu crio um board com o nome <nome>
  Then recebo 400 com {"field": "name", "message": "<mensagem>"}
  And nenhum board é gravado

  Examples:
    | nome                     | mensagem                          |
    | ""                       | nome é obrigatório                |
    | "   "                    | nome é obrigatório                |
    | ausente do corpo         | nome é obrigatório                |
    | um nome de 101 caracteres| nome tem no máximo 100 caracteres |
```

- **Assumed**
  - o limite de 100 caracteres para o nome: ninguém escolheu o tamanho
  - o corpo do erro traz `field` e `message`: o projeto não tinha convenção de erro
