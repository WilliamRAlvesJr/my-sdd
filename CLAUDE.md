# my-sdd

Framework SDD spec-anchored para Claude Code, distribuído como plugin (`my-spec`).

O que se escreve aqui é **prompt, não documentação**. O leitor final é o agente; o
usuário só revisa.

## O que o framework é

Quase um BDD conduzido pelo agente. O centro é o cenário Gherkin: ele é o que o usuário
revisa, o que o teste verifica e a única referência que sobrevive à feature.

Três decisões daí, que valem em todo bloco:

**O Gherkin mora na spec, não nas tasks.** O próprio BDD chama o Gherkin de especificação,
e era isso que o `tasks.md` estava sendo. `spec.md` tem os cenários, numerados `S1`, `S2` e
permanentes; `tasks.md` é ordem, estado e onde o trabalho cai, citando os ids.

**Todo cenário é verificado de ponta a ponta, contra o sistema de verdade.** Sem mock, sem
peça substituída. É daí que sai a proibição da versão intermediária nas tasks: valor
chumbado, resposta montada sem gravar e cubo branco morreram todos junto, porque cenário
que passa com metade do sistema fingido não diz nada sobre o produto.

**O Gherkin não vira código.** Ele existe para ser legível por gente. O framework não
pressupõe Cucumber nem nada que execute `.feature` — quem verifica o cenário é um teste
escrito na tecnologia do projeto. A referência de estilo é o `Temp/acceptance-tests-master`
(`generic-automation`): cenário em português, teste de aceitação real por trás.

## Estado

Construído bloco a bloco. Cada bloco é validado pelo usuário antes do próximo começar.

| bloco | estado |
|---|---|
| `skills/spec/` + `commands/spec.md` | `SKILL.md` + `TEMPLATE.md`; nenhuma execução ainda |
| `skills/plan/` + `commands/plan.md` | **corrente** — hoje carrega uma coisa só, o diagrama de classes, e ele é sempre tentado; nenhuma execução ainda |
| `TESTS/` | exemplos à mão que originaram o formato: `quadro/` e `cartao/` (API), `inimigo/` (Unity). Hoje só têm `plan.md`. `diagrama-armas.md` é o UML de diff de onde o formato do diagrama do `plan` saiu |
| `tasks` | apagado no commit em que a spec absorveu o Gherkin. Duas execuções no lab-rat e doze defeitos corrigidos estão no histórico do git, e é de lá que a versão nova sai quando a vez dele chegar |
| `clarify` | decidido e não começado — o `spec` já manda rodar ele no fim do relato |
| `build`, `check`, `init` | não começados |
| `OLD/` | versão anterior; referência, não editar |
| `Temp/cavekit-main`, `Temp/ponytail-main`, `Temp/spec-kit-main`, `Temp/acceptance-tests-master` | projetos de terceiros para análise. **Nunca editar** |
| `Temp/my-kanban-api` | lab-rat. Tem git próprio e o plugin declarado em `.claude/settings.json` |

Nada fora do bloco corrente é implementado, mesmo que a decisão já esteja tomada.

### Requisitos já levantados para blocos que não começaram

Vieram da leitura do `Temp/spec-kit-main`. Ficam aqui para não se perderem; nenhum é
implementado agora.

**`clarify` — a decisão que ninguém tomou, resolvida fora do `spec`.** O `spec` grava em
`Assumido` e não pergunta; o `clarify` lê o `spec.md`, para em cada item e edita o arquivo.
Três coisas que ele precisa carregar:

- **confirmar um assumido apaga a linha.** O campo diz que ninguém escolheu; respondida a
  pergunta, alguém escolheu — o valor fica no `Then` e a linha some. Daí sai o critério de
  saída do ciclo, verificável de fora: `spec.md` sem nenhum `Assumido` está clarificada.
  Sem isso o comando reabre as mesmas perguntas toda vez que roda;
- **não levantar decisão para ter o que perguntar**, senão a fila nunca esvazia;
- **a última volta é a confirmação da `spec`**, inclusive quando não havia assumido nenhum.
  É o único lugar onde a `spec` é aprovada — o `spec` não confirma mais nada depois do
  PASSO 3.

Convenção herdada do repositório não é pauta dele: essa é do `init`. `Scenario` caro de
verificar também não — é aviso do relato do `spec`, não decisão pendente.

**`check` — cobertura nos dois sentidos.** Cenário da spec que nenhuma task exerce, e teste
no repositório que não cita id nenhum. São defeitos baratos de achar e que releitura não
pega. Quem escreve o `tasks.md` confere a própria conta, e isso não conta. Cabe aqui também
o seletor do diagrama apontando para linha que não existe: o agente não renderiza o que
escreve, então índice errado passa em silêncio.

**`init` — onde mora a convenção que atravessa as features.** Decisão que já vale no
repositório inteiro não é da spec de uma feature, e hoje o skill de spec pergunta e o
usuário responde "confirme uma vez e eu paro de perguntar" — sem que exista o arquivo onde
essa confirmação fica. Falta ele: quem cria, onde fica, quem lê ao escrever a próxima spec.

**`build` — escopo e parada.** Rodar a lista inteira de uma vez faz o agente perder o
plano no meio. O escopo é pedido na chamada (uma task, um trecho), e a retomada sai da
marca de estado, que já distingue escrita de conferida. Ele para em `?` e nunca marca `x`.
É aqui que "sem mock" é cobrado de verdade: o teste que ele escreve sobe o sistema.

**A ordem de construção é o inverso da ordem de uso.** Em uso, spec gera plan que gera
tasks. Na construção, escrevemos as tasks à mão primeiro e inferimos daí o que spec e plan
precisam carregar — decisão que o artefato de baixo não consegue tomar sozinho é requisito
do de cima. Começar pelo topo produz documento que ninguém consome.

E foi assim que a spec apareceu pronta: duas execuções afiando o `tasks.md` produziram o
formato de cenário, e só então ficou visível que aquilo nunca tinha sido task. O conteúdo
mudou de arquivo sem mudar de forma.

## Como escrevemos os prompts

**Razão só onde há prior contrário.** Regra que o modelo seguiria sozinho leva uma
linha, sem justificativa. Regra que luta contra o treino leva a razão junto, senão é
obedecida na primeira vez e abandonada na terceira.

**Diluição é custo.** Regra enterrada em 250 linhas disputa atenção com 249 outras.
Cortar demais e cortar de menos não são simetricamente ruins.

**Um exemplo completo vale mais que seis parciais.** O modelo segue exemplo melhor que
descrição, mas exemplo repetido é duplicação como qualquer outra.

**Desenho onde ele encurta o review.** O usuário confere um diagrama mais rápido que a
lista equivalente, e é por isso que o diagrama de classes entrou no `plan`. Todo artefato
novo é perguntado assim: tem aqui coisa que se vê melhor desenhada? Tendo, ele leva o
desenho; não tendo, texto — diagrama que só ilustra custa o mesmo que qualquer duplicação.

**Nada compartilhado antes do segundo consumidor.** Núcleo com uma implementação é a
abstração que o próprio framework condena.

**O formato segue o dono do artefato.** O esqueleto de `spec.md` vive em `skills/spec/`,
não numa pasta `templates/` na raiz — o skill e o template do bloco viajam juntos, e um
bloco novo é uma pasta só. Comando não carrega definição de artefato que não escreve.

**O formato é template, não descrição.** Cada bloco é uma pasta com dois arquivos de nome
fixo: `SKILL.md` e `TEMPLATE.md`. O template é o artefato em branco, com placeholder entre
colchetes, que o agente copia e preenche; toda prosa sobre o artefato — a regra e a razão
dela — fica no `SKILL.md`. O template não explica nada, porque comentário de instrução
dentro do esqueleto sobrevive ao preenchimento e vaza para o arquivo do usuário. O padrão
veio do `Temp/spec-kit-main/templates/`, sem o prefixo no nome: lá os templates dividem uma
pasta e precisam se distinguir, aqui cada um já está na pasta do dono.

**Comando fino.** `commands/*.md` delega para o skill e não repete regra.

**O que vive em `skills/` não conhece este repositório.** `Temp/`, `TESTS/` e este
`CLAUDE.md` são andaime de construção — quem instala o plugin não tem nenhum dos três, e o
`.gitignore` garante isso: o repositório publicado em
[WilliamRAlvesJr/my-sdd](https://github.com/WilliamRAlvesJr/my-sdd) contém apenas
`.claude-plugin/`, `skills/` e `commands/`.
Exemplo tirado do lab-rat, regra tirada daqui, até o idioma: tudo isso entra parecendo
conhecimento e é só o que estava aberto na tela. A documentação do framework inventa os
próprios exemplos.

## Escrita

Português. Prosa técnica enxuta — sem símbolos, sem telegrama. O revisor é engenheiro:
precisão nas bifurcações vale mais que economia de token. Seta `→` como notação leve.

Não explicar conceito do stack: o leitor é engenheiro Java/Spring.

**Palavra comum, nunca vocabulário de metodologia.** Átomo, stub, prova, corte vertical,
fatia — o modelo inventa esse dialeto e passa a usar como se todo mundo soubesse, e aí o
revisor trava na palavra em vez de discordar da ideia. Termo que precisa de definição vira
a frase que ele definiria: "guardar na memória do programa, sem banco", não "stub". Vale
para rótulo de campo — **Mexe em**, não "toca". O conteúdo continua denso; o que sai é só
o jargão.

**Termo de um domínio só entra com o domínio dito.** "Um endpoint de uma API web", "uma
cena de um jogo em Unity", "uma migration de banco num backend" — nomes concretos são
bem-vindos em exemplo, o que não pode é o termo solto, porque solto ele é lido como se valesse em todo projeto, e é assim
que o formato ganha jeito de backend. Onde a lista já mistura domínios, a variedade diz
isso sozinha e nomear cada item é ruído.

## Verificação

Bloco só fecha depois de rodar contra o `Temp/my-kanban-api` — greenfield Spring Boot
+ Flyway + Testcontainers, cobaia real.

**Quem verifica não pode ter participado da escrita.** Rodar o skill na mesma conversa em
que ele foi escrito não testa nada: o resultado sai da memória do que já foi decidido, não
do prompt. A execução vale quando é feita por um agente sem esse contexto, proibido de ler
`TESTS/` — que contém a resposta — e instruído a relatar onde o prompt atrapalhou e onde
quase desobedeceu. Foi assim que apareceram as contradições que nenhuma releitura pegou.

O primeiro alvo é `quadro`: a única feature sem dependência, e portanto a única que pode
ir a build num sistema vazio.

O segundo exemplo é de outro tipo de projeto — hoje `TESTS/inimigo/`, Unity. Formato
validado num domínio só não é formato, é o jeito daquele domínio: foi o Unity que mostrou
que o estado inicial é campo, que resultado pode ser faixa e não número, e que existe task
cuja verificação nenhum teste faz.

Sinais de que o bloco falhou, não de que o projeto é difícil: pergunta óbvia na saída,
linha derivável no artefato, regra do prompt que nenhuma execução exerceu, **task para
problema que ninguém pediu para resolver** — obstáculo no caminho vira aviso, não item de
lista.
