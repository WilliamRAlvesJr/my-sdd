I'll invoke the spec skill.

▸ STEP 1: READ · convenções, os outros specs e o repositório

Li o repositório: não existe `specs/`, não existe `CLAUDE.md`, e o projeto é um Spring Boot 4.1 / Java 21 recém-gerado (Actuator, Data JPA, Flyway, Security, Validation, Web MVC, Postgres, Testcontainers). Nenhum controller, nenhuma entidade, nenhuma migration em `src/main/resources/db/migration`, `application.properties` só com o nome da aplicação.

↳ R19 · `spring-boot-starter-security` no classpath sem nenhum `SecurityFilterChain`: vira aviso, não vira um `behavior` de autenticar

◂ STEP 1 · nenhum `spec.md` para esta `feature`, projeto vazio sem convenção para herdar, e o Security responde 401 em qualquer chamada

▸ STEP 2: WORK OUT THE BEHAVIORS · a lista, a partir do que STEP 1 leu

↳ R22 · nome vazio, só espaços, longo demais e ausente: uma decisão, um id, quatro linhas de `Examples`

◂ STEP 2 · 3 behaviors

▸ STEP 3: PROPOSE · lista e pasta resolvidas sem perguntar, por `--assume`

◂ STEP 3 · 3 behaviors, `specs/create-board/`

▸ STEP 4: TEMPLATE · escrevendo `specs/create-board/spec.md`

◂ STEP 4 · `specs/create-board/spec.md`, 3 behaviors, 3 scenarios, 4 assumidos

▸ STEP 5: REPORT · o que ficou no arquivo e o que ele não mostra

---

`specs/create-board/spec.md`: 3 behaviors, 3 scenarios. Rodou com `--assume`: a lista, a pasta e a decisão de não dividir em mais de um spec foram fechadas sem perguntar.

**Aviso**: o `spring-boot-starter-security` está no projeto e nenhuma classe configura um `SecurityFilterChain`, então o padrão do Spring Boot vale e toda requisição responde 401. Enquanto isso não mudar, nenhum scenario acima pode ser verificado sem fingir a autenticação, e fingir é justamente o que a verificação não aceita.

**Aviso**: o `application.properties` não configura datasource nenhum. A aplicação só sobe pelo Testcontainers que está em `src/test`; fora dos testes ela não inicia.

**Decisões de produto ainda em aberto** (o valor assumido já está no arquivo, e mudar cada um custa uma linha do `Then`):

- o limite do nome (assumido 120 caracteres)
- o formato da resposta de erro (assumido 400 apontando o campo)
- nome repetido (assumido que não é único: cria outro board)
- a resposta da criação (assumido 201 com `Location` e o corpo do que foi criado)

**Convenção escolhida, não herdada**: o projeto está vazio, sem `specs/conventions.md` e sem `CLAUDE.md`, então as quatro linhas acima são a primeira convenção do repositório e valem para toda feature que vier depois. O texto dos steps ficou em português, também por escolha.

**Ficou de fora**: colunas, cards, arquivar, renomear e dono do board, que não estavam no pedido.

Rode `/my-spec:clarify` para fechar os 4 assumidos.

---

◂ STEP 5 · relatório entregue
