I'll invoke the spec skill.

▸ STEP 1: READ · o pedido, o que o projeto já tem e o que atrapalha verificar

Lido: sem `specs/`, sem `CLAUDE.md`, sem `specs/conventions.md`. Projeto Spring Boot 4.1 / Java 21 vazio (só a classe de aplicação), Postgres + Flyway com `db/migration` vazia, Testcontainers montado nos testes. `spring-boot-starter-security` está no classpath sem nenhuma configuração.

◂ STEP 1 · pedido "criar um board"; nenhuma convenção para herdar; obstáculo: com security no classpath e sem configuração, toda requisição responde 401

▸ STEP 2: WORK OUT THE BEHAVIORS · a lista, a partir do que o STEP 1 leu
↳ R22 · nome vazio, só espaços e acima do limite: uma decisão, um id, três linhas de `Examples`
◂ STEP 2 · 3 behaviors

▸ STEP 3: PROPOSE AND STOP · `--assume`: sem tabela, sem perguntas
↳ R27 · criar um board não pressupõe feature que ninguém especificou: nada a perguntar
◂ STEP 3 · `specs/create-board/`, 3 behaviors, sem divisão em mais de um spec

▸ STEP 4: FILL IN THE TEMPLATE · um `spec.md` em `specs/create-board/`

◂ STEP 4 · `specs/create-board/spec.md`: 3 behaviors, 4 scenarios, 5 assumidos

▸ STEP 5: REPORT · o arquivo, o aviso e o que ficou de fora

---

`specs/create-board/spec.md`: 3 behaviors, 4 scenarios. Rodou com `--assume`: o nome da pasta e a lista de behaviors foram decididos sem perguntar, e não houve divisão em mais de um spec.

**Warning**: `spring-boot-starter-security` está no classpath sem nenhuma configuração, e a autoconfiguração exige autenticação em toda requisição. Enquanto isso valer, `POST /boards` responde 401 e nenhum scenario acima pode ser verificado.

**Decisões de produto ainda em aberto** (o valor assumido já está no arquivo, e mudar é editar uma linha do `Then`):

- o limite do nome (assumido 100 caracteres)
- espaço em volta do nome (assumido que só espaços é o mesmo que vazio)
- o formato do corpo de erro (assumido ProblemDetail, mensagem em português)
- criar dois boards com o mesmo nome (assumido que pode)
- a resposta da criação (assumido 201 com `Location` e o corpo repetindo o que foi criado)

**Escolhi a convenção aqui**: o projeto está vazio, sem `specs/conventions.md` e sem `CLAUDE.md`, então não havia nada a herdar sobre rota, resposta de criação nem formato de erro. Esta é a primeira feature a fixar as três, e toda feature depois dela herda o que for confirmado.

**Ficou de fora**: dono do board, colunas e cards, listar, renomear e remover, nada disso estava no pedido.

Rode `/my-spec:clarify` para resolver os 5 assumidos.

---

◂ STEP 5 · relatório entregue