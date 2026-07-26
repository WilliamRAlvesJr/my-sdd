---
name: tasks
description: >
  Corta uma feature em tasks — cada uma a menor coisa que dá para ver funcionando.
  Lê spec, plan e repositório, propõe o corte e a ordem numa lista curta, o usuário
  confirma, então escreve tasks.md com um cenário Gherkin por task. Use quando o
  usuário disser "quebra isso em tasks", "por onde começo", "monta o passo a passo
  de X", ou invocar /my-spec:tasks. Não use para decidir arquitetura (isso é plan),
  para escrever código, nem para tarefa que já cabe numa sentada.
argument-hint: "[<feature>]"
---

# tasks — cortar a feature no que dá para ver

Formato do artefato: `FORMAT.md`, ao lado. Leia antes de escrever.

Você escreve **`tasks.md` e nada mais**. Não implementa nenhuma task, não escreve teste,
não cria `.feature`.

## PASSO 1 — LER

1. **Spec e plan da feature**, se existirem. Não pergunte nada aqui: faltando spec, isso
   entra na proposta do PASSO 3, que é a única parada.
2. **Convenções do projeto** — `CLAUDE.md` e arquivo de convenções, se existirem. Não
   havendo nenhum dos dois, tire do próprio repositório: idioma dos comentários, formato
   das mensagens de commit, quem é dono do schema do banco.
3. **O repositório** — o que já existe do que a feature cita, e o que ela vai precisar que
   ainda não existe.
4. **O que atrapalha** — dependência instalada que bloqueia toda chamada, configuração que
   impede a aplicação de subir, build já quebrado. Você vai encontrar isso ao ler, e ele
   **não** vira task: vira o aviso do topo.

## PASSO 2 — CORTAR

Cada task é um comportamento que alguém consegue olhar e dizer se funcionou.

**Nunca corte por camada.** Migration, entidade, repositório, controlador é o corte que
você faria sozinho, e ele deixa a primeira coisa visível para o fim — que é quando já não
sobra tempo de mudar de ideia. O corte certo atravessa as camadas todas de uma vez, para
um comportamento só.

Versão descartável é permitida e costuma ser a primeira task: guardar na memória em vez de
no banco, cubo branco em vez de modelo, valor chumbado em vez de configuração. Ela existe
para adiantar o que dá para ver, e some numa task própria mais adiante.

**Ela não é obrigatória, e tem um caso em que atrapalha:** quando a versão descartável
custa mais trabalho que a definitiva — a tabela já existe, a cena já está montada, o dado
já vem pronto. Custar menos e parecer inacabado não é esse caso. Aí vá direto ao definitivo
e diga na saída que não houve versão descartável.

A ordem sai de quem depende de quem, não de camadas nem de importância. A task que troca a
versão descartável pela definitiva entra no ponto em que alguém passa a depender dela — e
esse ponto muda de projeto para projeto.

## PASSO 3 — PROPOR E PARAR

Uma linha por task, na ordem, sem cenário nenhum. É aqui que o corte é barato de mudar:

````markdown
## criar convite — 5 tasks

| id | passa a funcionar |
|----|-------------------|
| `T1` | criar convite, guardando na memória |
| `T2` | aceitar um convite pelo código |
| `T3` | o convite continua valendo depois do reinício |
| `T4` | listar os convites de quem enviou |
| `T5` | recusar código expirado |

**Fora da lista** — a suíte já está vermelha: vira aviso, não task.

**Sem spec** — as tasks nascem sem id para citar, e decisão de produto vira suposição
minha.

Confirma? Ou diga o que muda — outra ordem, juntar duas, cortar uma, ou algo que faltou.
````

Os dois rótulos de baixo só entram quando há o que relatar — mesma regra do PASSO 5.

**Pare aqui, e só aqui.** Escrever oito cenários antes de acertar o corte é jogar fora oito
cenários — e parar duas vezes numa feature pequena é atrito que o usuário paga sem receber
nada.

## PASSO 4 — ESCREVER

`specs/<feature>/tasks.md`, no formato do `FORMAT.md`.

Cada task: marca de estado, título, cenário e `Mexe em`. `Decisões que usa` só quando há
spec ou plan; `Assumido` só quando houve suposição. Todas nascem `|.|`. O aviso, se
houver, vem antes da T1.

**Decisão que falta não é inventada.** Se a task precisa de um valor ou de um
comportamento que nem a spec nem o plan definem — o limite de um campo, a ordem de uma
listagem, o que acontece ao apagar o que não existe —, escreva a task com o valor mais
provável, registre no campo `Assumido` e leve a mesma linha para a saída. Inventar em
silêncio é como uma decisão de produto entra no sistema sem ninguém ter decidido nada.

## PASSO 5 — SAÍDA

O arquivo, e depois o que ele não mostra:

````markdown
`specs/criar-convite/tasks.md` — 5 tasks, 2 na versão descartável, trocada na T3.

**Aviso** — suíte de testes já vermelha: resolver antes da T1.

**Faltam decisões** — sobem para a spec, ou confirme aqui:

- ordem da listagem (assumi mais novo primeiro)
- aceitar o mesmo convite duas vezes (assumi 409)

**Sem plan** — o nível de teste da feature não está decidido em lugar nenhum.

tasks OK? posso começar pela T1?
````

- **Só o detectado.** Rótulo em negrito parece seção obrigatória, e seção que aparece
  sempre — às vezes só para dizer que não há nada — ensina o usuário a pular a parte de
  baixo inteira.
- **Números são observação, nunca nota.** Reporte a contagem, não julgue por ela.

## NÃO-OBJETIVOS

- Não implementar, não escrever teste, não gerar `.feature` nem step definition.
- Não conferir nada e não marcar `|x|`. Quem confere é o dev, e ele pede quando quiser.
- Não criar task para obstáculo do projeto: dependência que bloqueia toda chamada, build
  quebrado, configuração faltando. Vira aviso — você trata obstáculo como trabalho a
  fazer, e é assim que a lista ganha itens que o usuário nunca aprovou.
  **Comportamento do produto é outra coisa.** Recusar entrada inválida, responder ao que
  não existe, impedir o estado impossível: isso é task mesmo sem spec, com a suposição
  registrada. Deixar de fora porque "ninguém pediu" entrega um sistema que aceita
  qualquer coisa.
- Não repetir em cada task que é preciso testar: é convenção do projeto, e o nível de
  teste é decisão de plan.
- Não decidir camada, biblioteca ou padrão. Nomear o arquivo onde o trabalho cai é
  permitido, e o nome é provisório; escolher a arquitetura, não.
- Não explicar conceito do stack.
