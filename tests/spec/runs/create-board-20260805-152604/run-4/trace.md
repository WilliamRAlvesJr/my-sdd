I'll invoke the spec skill.

▸ STEP 1: READ · o argumento da chamada, e o que o projeto já tem em volta

◂ STEP 1 · pedido lido, projeto vazio (nenhum `specs/`, nenhum `CLAUDE.md`, nenhum código de domínio), sem convenção a herdar, e um obstáculo à verificação

▸ STEP 2: WORK OUT THE BEHAVIORS · a lista, a partir do que o STEP 1 leu
↳ R22 · nome ausente, nome vazio, nome só com espaços e nome longo demais são a mesma decisão: um id, uma tabela de Examples
◂ STEP 2 · 2 behaviors

▸ STEP 3: PROPOSE AND STOP · 2 behaviors na mesa, sem mensagem por causa do `--assume`
◂ STEP 3 · lista fechada sem perguntar, em `specs/create-board/`

▸ STEP 4: FILL IN THE TEMPLATE · um `spec.md` na pasta que o STEP 3 fixou

◂ STEP 4 · `specs/create-board/spec.md` escrito, 2 behaviors, 2 scenarios, 7 linhas de `Assumed`

▸ STEP 5: REPORT · o arquivo, os avisos e o que ficou de fora
◂ STEP 5 · relatório entregue

---

`specs/create-board/spec.md`: 2 behaviors, 2 scenarios. Rodou com `--assume`: o nome da pasta e a lista de behaviors foram fechados sem perguntar.

**Aviso**: `spring-boot-starter-security` está no `pom.xml` e não há nenhuma configuração de segurança no projeto, então o padrão do Spring Security vale para tudo e toda requisição responde 401. Enquanto isso valer, nenhum dos dois scenarios pode ser verificado.

**Decisões de produto ainda em aberto** (o valor assumido já está no arquivo, e mudar cada um é editar uma linha do `Then`):

- o caminho do recurso (assumido `/boards`)
- a resposta da criação (assumido 201 com `Location` e o corpo repetindo o que foi criado)
- os campos do board (assumido só o nome)
- nome repetido (assumido que cria outro board, sem unicidade)
- o limite do nome (assumido 100 caracteres)
- nome só com espaços (assumido igual a ausente)
- o formato do corpo de erro (assumido `{"campo": ..., "mensagem": ...}`)

**Escolhi a convenção aqui**: o projeto é um esqueleto do Spring Initializr, sem `specs/conventions.md`, sem `CLAUDE.md` e sem nenhum endpoint escrito, então não havia nada a herdar. Este spec é o primeiro a fixar a forma da criação e a forma do corpo de erro, e toda feature depois dele herda o que for confirmado. O texto dos steps está em português, e as keywords do Gherkin em inglês.

**Fora**: ler, listar, renomear e apagar um board; colunas e cartões; dono do board e autenticação. Nada disso estava no pedido, e a autenticação em particular é o obstáculo acima, não uma decisão de produto que alguém tomou.

Rode `/my-spec:clarify` para resolver as 7 suposições.