I'll invoke the spec skill.

▸ STEP 1: READ · o pedido `criar um board`, com `--assume` e `--verbose`, contra o que o projeto já tem

- `specs/` não existe: nenhuma `spec` cobre esta `feature`.
- Sem `specs/conventions.md` e sem `CLAUDE.md`: não há convenção a herdar. Projeto greenfield, Spring Boot 4.1 + JPA + Flyway + Postgres + Validation, sem nenhuma migration, entidade ou controller.
- `spring-boot-starter-security` está no classpath sem nenhuma configuração: enquanto isso valer, toda requisição responde 401 e nenhum `scenario` daqui pode ser verificado.

◂ STEP 1 · pedido lido, nenhuma `spec` existente, convenções a escolher, um obstáculo de verificação

▸ STEP 2: WORK OUT THE BEHAVIORS · a lista, a partir do que STEP 1 leu
↳ R22 · nome ausente, em branco e acima do limite são a mesma decisão: um id, uma tabela de linhas
↳ R22 · criar duas vezes com o mesmo nome ficou como `scenario` de `B1`, não como id próprio
◂ STEP 2 · 2 behaviors

▸ STEP 3: PROPOSE AND STOP · 2 behaviors, sem mensagem por causa de `--assume`
◂ STEP 3 · `specs/create-board/`, lista fixada sem perguntar

▸ STEP 4: FILL IN THE TEMPLATE · um arquivo, a partir da lista fixada

◂ STEP 4 · `specs/create-board/spec.md`, 2 behaviors, 3 scenarios, ids fixados

▸ STEP 5: REPORT · o arquivo, os avisos e o que ficou de fora
◂ STEP 5 · relatório entregue

---

`specs/create-board/spec.md`: 2 behaviors, 3 scenarios. Rodou com `--assume`: o nome da pasta e a lista de behaviors foram decididos sem perguntar.

**Aviso**: `spring-boot-starter-security` está no projeto sem nenhuma configuração, e nessa situação toda requisição responde 401. Enquanto isso valer, nenhum scenario daqui pode ser verificado.

**Decisões de produto ainda em aberto** (o valor assumido já está no arquivo, e mudá-lo custa uma linha do `Then`):

- a forma da resposta de criação (assumido 201 com `Location` e o corpo repetindo o board)
- o idioma do texto dos scenarios (assumido português)
- criar dois boards com o mesmo nome (assumido permitido)
- o limite do nome (assumido 100 caracteres)
- a forma do corpo de erro (assumido campo inválido mais mensagem)

**Convenção escolhida aqui**: o projeto está vazio, sem `specs/conventions.md` e sem `CLAUDE.md`, então esta spec é a primeira a fixar a resposta de criação, a forma do corpo de erro e o idioma do texto. Toda feature depois desta herda o que for confirmado.

**Ficou de fora**: listar, renomear e apagar board, e as colunas do quadro, que não estavam no pedido.

Rode `/my-spec:clarify` para resolver as 5 suposições.