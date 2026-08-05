I'll invoke the spec skill.

Vou executar a skill.

```
▸ STEP 1: READ · o pedido, as convenções do projeto e o que já existe em volta
```

Li `specs/` (não existe), `CLAUDE.md` e `specs/conventions.md` (nenhum dos dois existe), o `pom.xml`, o `application.properties` e o `src/` inteiro.

```
◂ STEP 1 · projeto no esqueleto: nada em volta de board, nenhuma convenção para herdar, e dois obstáculos para verificar
▸ STEP 2: WORK OUT THE BEHAVIORS · a lista, a partir do que o STEP 1 leu
↳ R22 · criar com nome novo e criar com nome já usado: uma decisão, dois scenarios
↳ R22 · nome vazio, em branco, ausente e longo demais: uma decisão, uma Scenario Outline
◂ STEP 2 · 2 behaviors
▸ STEP 3: PROPOSE AND STOP · --assume: a lista e a pasta ficam decididas sem perguntar
◂ STEP 3 · specs/create-board/, 2 behaviors, sem divisão em mais de um spec
▸ STEP 4: FILL IN THE TEMPLATE · um spec.md em specs/create-board/
```

```
◂ STEP 4 · specs/create-board/spec.md escrito, 2 behaviors, 3 scenarios, 5 Assumed
▸ STEP 5: REPORT · o arquivo, os avisos e o que ficou de fora
◂ STEP 5 · relatório entregue
```

---

`specs/create-board/spec.md`: 2 behaviors, 3 scenarios. Rodou com `--assume`: o nome da pasta, a lista de behaviors e a decisão de não dividir em mais de um spec foram resolvidos sem perguntar.

**Warning**: `spring-boot-starter-security` está no `pom.xml` sem nenhuma configuração, e o padrão do Spring Boot protege todo endpoint. Enquanto isso continuar assim, nenhum scenario acima pode ser verificado.

**Warning**: `application.properties` só tem `spring.application.name`. Sem datasource, a aplicação não sobe fora do arranjo de teste que levanta o Testcontainers.

**Product decisions still missing** (o valor assumido já está no arquivo, e mudá-lo é editar uma linha do `Then`):

- nome de board repetido (assumido: permitido, dois boards com o mesmo nome)
- o limite de tamanho do nome (assumido: 100 caracteres)
- a resposta da criação (assumido: 201 com `Location` e o corpo repetindo o que foi criado)
- o corpo do erro (assumido: `field` e `message`)
- o idioma dos scenarios (assumido: português)

**Chose the convention here**: o projeto não tem `CLAUDE.md`, não tem `specs/conventions.md` e não tem nada além do esqueleto do Spring Initializr, então não havia o que herdar. Este spec é o primeiro a fixar a resposta de criação, o corpo de erro e o idioma, e toda feature depois dele herda o que for confirmado.

**Left out**: listar, renomear e excluir board, e colunas e cards, que não estavam no pedido.

Rode `/my-spec:clarify` para resolver as 5 suposições.