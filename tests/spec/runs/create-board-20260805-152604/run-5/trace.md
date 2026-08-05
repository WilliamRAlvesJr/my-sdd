I'll invoke the spec skill.

## ▸ STEP 1: READ · o pedido `criar um board` e o que o projeto já tem

Li o projeto: Spring Boot 4.1 + JPA + Flyway + Testcontainers, greenfield. Não há `specs/`, não há `CLAUDE.md`, `src/main/resources/db/migration` está vazia e o único código é a classe de boot.

```
◂ STEP 1 · pedido lido, nenhuma spec existente, nenhuma convenção para herdar, um obstáculo: spring-boot-starter-security no classpath sem configuração
```

## ▸ STEP 2: WORK OUT THE BEHAVIORS · a lista, a partir do que STEP 1 leu

```
↳ R22 · nome ausente, em branco e acima do limite decidem a mesma coisa: um id só, com Scenario Outline
◂ STEP 2 · 3 behaviors
```

## ▸ STEP 3: PROPOSE AND STOP · 3 behaviors, com `--assume` não há mensagem nem confirmação

```
↳ R3 · o Then fecha no corpo da resposta, então ler o board de volta é outra feature: uma spec só
◂ STEP 3 · lista fechada sem perguntar, pasta specs/create-board/
```

## ▸ STEP 4: FILL IN THE TEMPLATE · um arquivo, a partir de `TEMPLATE.md`

```
◂ STEP 4 · specs/create-board/spec.md escrito, B1 a B3, S1 a S3
```

## ▸ STEP 5: REPORT · o arquivo e o que ele não mostra

`specs/create-board/spec.md`: 3 behaviors, 3 scenarios. A pasta, a lista e o fato de ser uma spec só foram decididos sem perguntar, por causa de `--assume`.

**Warning**: `spring-boot-starter-security` está no classpath sem nenhuma configuração, então toda requisição cai no HTTP Basic gerado no boot e responde 401. Enquanto isso valer, nenhum scenario acima pode ser verificado.

**Product decisions still missing** (o valor assumido já está no arquivo, e mudar cada um é editar uma linha do `Then`):

- o limite do nome (assumido 100 caracteres)
- criar dois boards com o mesmo nome (assumido aceita, ids diferentes)
- o corpo do erro de validação (assumido `application/problem+json` apontando o campo)
- a resposta da criação (assumido 201 com `Location` e o corpo do que foi criado)

**Chose the convention here**: o projeto está vazio, sem `specs/conventions.md` e sem `CLAUDE.md`, então esta é a primeira spec a fixar a forma da criação e a forma do erro. Toda feature depois desta herda o que for confirmado aqui.

**Left out**: colunas, cards, dono do board, e ler, listar, renomear ou excluir board, nada disso estava no pedido.

Run `/my-spec:clarify` to settle the 4 assumptions.

```
◂ STEP 5 · relatório entregue
```