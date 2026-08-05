I'll invoke the spec skill.

▸ STEP 1: READ · convenções, as outras specs e o repositório
↳ R19 · `spring-boot-starter-security` sem configuração responde 401 em tudo: vira aviso, não vira behavior

Lido: não existe `specs/`, não existe `specs/conventions.md` nem `CLAUDE.md`. O repositório é um Spring Boot 4.1 recém-gerado (webmvc, data-jpa, flyway, validation, security, actuator, Testcontainers), sem controller, sem entidade, sem migration e sem nada em `application.properties` além do nome da aplicação.

◂ STEP 1 · nenhum `spec.md` para esta feature, nenhuma convenção escrita para herdar (formato de erro, resposta de criação e idioma ficam em aberto), e o security bloqueia toda chamada

▸ STEP 2: WORK OUT THE BEHAVIORS · a lista, a partir do que a STEP 1 leu
↳ R22 · nome em branco, nome ausente e nome longo demais são a mesma decisão: um id só, com um `Scenario Outline`
◂ STEP 2 · 3 behaviors

▸ STEP 3: PROPOSE · com `--assume`, a lista e a pasta são fechadas sem perguntar
◂ STEP 3 · 3 behaviors, sem divisão em mais de um `spec`, `specs/create-board/`

▸ STEP 4: TEMPLATE · escrevendo `specs/create-board/spec.md`

◂ STEP 4 · `specs/create-board/spec.md` escrito, 3 behaviors, 3 scenarios, `Assumed` no lugar

▸ STEP 5: REPORT · o arquivo e o que ele não mostra
◂ STEP 5 · relatório entregue

---

`specs/create-board/spec.md`: 3 behaviors, 3 scenarios. Rodou com `--assume`: a pasta, a lista de behaviors e a decisão de manter tudo num único `spec` foram fechadas sem perguntar.

**Aviso**: `spring-boot-starter-security` está no `pom.xml` sem nenhuma configuração, então toda requisição cai no basic auth padrão e responde 401. Enquanto isso valer, nenhum scenario daqui pode ser verificado.

**Decisões de produto ainda em aberto** (o valor assumido já está no arquivo, e mudar significa editar uma linha do `Then`):

- a criação recebe só o nome do board
- a criação responde 201 com `Location` e o corpo repete o que foi criado
- o texto dos passos está em português
- o limite de 60 caracteres para o nome
- o formato do erro de validação (assumido 400 com uma mensagem por campo)
- nome de board repetido (assumido permitido)

O projeto está recém-gerado: não havia `specs/conventions.md`, `CLAUDE.md` nem código anterior, então nenhuma das convenções acima foi herdada. Esta é a primeira feature, e o que for decidido aqui vale para as próximas.

**Ficou de fora**: listar, renomear, excluir e arquivar board, além de colunas e cards, que não estavam no pedido.

**Dono do board**: o board é criado sem dono. Nenhuma feature de usuário ou autenticação está especificada, e este `spec` não decide a quem o board pertence.

Rode `/my-spec:clarify` para resolver as 6 suposições.
