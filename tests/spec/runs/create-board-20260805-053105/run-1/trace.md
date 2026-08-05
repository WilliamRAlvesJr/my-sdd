I'll invoke the spec skill.

▸ STEP 1: READ · conventions, the other specs and the repository

▸ STEP 1: READ · conventions, os outros specs e o repositório
◂ STEP 1 · não existe `specs/`, nada de convenção para herdar, e o Spring Security está no projeto sem configuração

▸ STEP 2: WORK OUT THE BEHAVIORS · a lista, a partir do que o STEP 1 leu
↳ R22 · recusar nome vazio e nome longo demais é a mesma decisão: um id, um `Scenario Outline`
↳ R22 · criar um board com um nome que já existe é a mesma decisão de criar: um id, um segundo `scenario`
◂ STEP 2 · 2 behaviors

▸ STEP 3: PROPOSE · lista e pasta resolvidas sem perguntar, por `--assume`
◂ STEP 3 · 2 behaviors, `specs/create-board/`

▸ STEP 4: TEMPLATE · escrevendo `specs/create-board/spec.md`

◂ STEP 4 · `specs/create-board/spec.md`, 2 behaviors, 3 scenarios

▸ STEP 5: REPORT · o arquivo, os avisos e o que ficou de fora
◂ STEP 5 · o relatório

---

`specs/create-board/spec.md`: 2 behaviors, 3 scenarios. Rodou com `--assume`: o nome da pasta e a lista de behaviors foram decididos sem perguntar.

**Aviso**: `spring-boot-starter-security` está no projeto sem nenhuma configuração, e o padrão do Spring Security protege todos os endpoints. Enquanto isso valer, toda requisição responde 401 e nenhuma scenario daqui pode ser verificada.

**Decisões de produto ainda em aberto** (o valor assumido já está no arquivo, e mudar cada um é editar uma linha do `Then`):

- a língua das scenarios (assumido português)
- a resposta da criação (assumido 201 com `Location` e o corpo do board criado)
- dois boards com o mesmo nome (assumido permitido)
- o limite do nome (assumido 100 caracteres)
- o formato da resposta de erro (assumido 400 com o campo e o motivo)

**Conventions escolhidas por não haver o que herdar**: o projeto está vazio, sem `specs/conventions.md` e sem `CLAUDE.md`, então este é o primeiro spec e as três primeiras linhas acima valem para todas as features seguintes.

**Ficou de fora**: ler, listar, renomear e excluir um board, e as colunas que um board novo poderia já vir com. Nada disso estava no pedido.

Rode `/my-spec:clarify` para resolver as 5 suposições.
