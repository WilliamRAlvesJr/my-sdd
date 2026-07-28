---
name: spec
description: >
  Escreve a spec de uma feature como cenários Gherkin que alguém confere olhando o sistema
  rodar. Propõe a lista de comportamentos, o usuário confirma, então preenche o template.
  Use quando o usuário disser "especifica X", "o que essa feature precisa fazer", "escreve
  a spec de X", ou invocar /my-spec:spec. Não use para decidir arquitetura, para cortar o
  trabalho em passos, nem para escrever código.
argument-hint: "[<ideia | feature>]"
---

# spec — o que o sistema faz, em exemplos

Esqueleto do artefato: `TEMPLATE.md`, ao lado. Copie e preencha.

Você escreve **`spec.md` e nada mais**.

`spec.md` é permanente: teste e código citam id daqui, e a citação continua valendo depois
que a feature fecha. Por isso ele não fala de desenho — camada, biblioteca, quem gera o
identificador, onde mora a validação — nem de ordem de trabalho. Essas duas coisas mudam, e
a spec não pode mudar junto.

## PASSO 1 — LER

1. **O pedido** — o que veio no argumento da chamada. Vindo vazio, o pedido é o que o
   usuário já disse na conversa; não peça para ele repetir.
2. **Convenções do projeto** — `CLAUDE.md` ou arquivo de convenções. Não havendo, tire do
   repositório: idioma, formato das respostas de erro, o que o sistema já faz em situação
   parecida. Num projeto vazio não há o que herdar — escolha, e diga na saída que escolheu.
   É a primeira feature que fixa a convenção para todas as próximas, e isso o usuário
   confirma agora, não descobre seis features depois.
3. **Specs vizinhas e o repositório** — para saber o que já existe. Comportamento já
   especificado em outro lugar, ou que já funciona e ninguém vai mexer, não é reescrito
   aqui: a spec é da feature, não do sistema inteiro.
4. **O que impede a verificação** — dependência que bloqueia toda chamada, configuração sem
   a qual a aplicação não sobe, arquivo que não compila. Com um desses no caminho, nenhum
   cenário pode ser verificado e a lista inteira vira promessa.

   **Você só lê, nunca roda.** Relate apenas o que dá para descobrir lendo: teste falhando e
   build quebrado só aparecem para quem executa, e você não vai executar.

   **O que achar vira aviso na proposta e na saída, nunca um comportamento da spec.** Se
   ninguém pediu autenticação, "autenticar antes de criar" não é comportamento do produto —
   é você contornando o obstáculo, e esse contorno fica para sempre num arquivo que os
   testes citam.

## PASSO 2 — LEVANTAR OS COMPORTAMENTOS

Cada comportamento é uma coisa que alguém provoca e observa. O que separa dois: **duas
pessoas conferindo fariam ações diferentes?**

Junte pela regra, não pelo caminho. Recusar nome inválido ao criar e ao renomear é a mesma
decisão em dois lugares: um id, dois cenários.

**Escreva o caminho torto junto com o certo** — entrada inválida, coisa que não existe,
estado impossível, a mesma chamada duas vezes. Ninguém pede isso, e é o que decide o
produto: o pedido diz "criar quadro", e sem isso sobra um sistema que aceita qualquer coisa.

**Pare onde o pedido para.** Vendo "criar convite", você completa o padrão: expiração,
limite de usos, revogação, notificação. Cada uma parece óbvia e nenhuma foi pedida.
Comportamento que o usuário não citou é pergunta na saída, nunca linha no arquivo — escrito,
ele vira código sem ninguém ter decidido que o produto tem isso. A fronteira: recusar
entrada inválida é a mesma feature; expirar convite é outra.

## PASSO 3 — PROPOR E PARAR

Uma linha por comportamento, sem cenário nenhum:

````markdown
## criar convite — 5 comportamentos

| id | comportamento |
|----|---------------|
| `S1` | criar um convite para um endereço de e-mail |
| `S2` | recusar e-mail malformado |
| `S3` | aceitar um convite pelo código |
| `S4` | recusar código que não existe |
| `S5` | listar os convites de quem enviou |

**Aviso** — uma dependência de autenticação já está no projeto e responde 401 a toda
requisição. Enquanto continuar assim, nenhum cenário acima pode ser verificado.

**Fora da lista** — expiração e revogação parecem vir junto, mas não estavam no pedido.
````

**A pergunta vai no seletor de opções, não no texto** — uma chamada de `AskUserQuestion`
logo depois da mensagem. A tabela e os avisos ficam onde estão, porque não cabem em rótulo
de opção; no seletor vai só o que o usuário decide. Para a lista acima: *a lista está
certa?* — confirmar, ajustar, dividir em specs — e *expiração e revogação?* — ficam de
fora, entram nesta spec. Uma pergunta por decisão, no mesmo seletor, até quatro.

Pergunta escrita em prosa é respondida em prosa, quando é respondida; e você tende a
seguir escrevendo o arquivo como se tivesse sido. Com o seletor não há como continuar
sem a resposta.

**Lista longa se divide em specs, nunca pela metade.** Vinte comportamentos quase sempre
querem dizer que ali tem mais de uma feature: um CRUD de pessoa é cadastro, consulta e
remoção, e cada um vira sua pasta com sua spec inteira. Diga onde a divisão cai e pergunte;
se o usuário responder que é uma feature só, escreva os vinte. O que não existe é meia
spec — o que ficasse de fora não estaria especificado em lugar nenhum, e escolher o que
entra no primeiro incremento é trabalho do `tasks`, não daqui.

**Pare aqui, e só aqui.** Acertar a lista custa uma linha por item; errá-la custa quinze
cenários jogados fora.

## PASSO 4 — PREENCHER O TEMPLATE

`specs/<feature>/spec.md`, a partir do `TEMPLATE.md`. O que sobrar do esqueleto sai:
colchete não preenchido, seção vazia, e o rótulo em itálico que diz quando o campo entra —
ele é instrução para você, não texto do artefato. O esqueleto mostra dois comportamentos e
duas formas de cenário; a feature tem quantos tiver.

### O cenário

**Gherkin no idioma do projeto, palavras-chave incluídas.** A tradução é oficial: em
português, `Cenário`, `Dado`, `Quando`, `Então`, `E`, `Esquema do Cenário`, `Exemplos`.
Trocar o idioma de quem lê por realce de sintaxe é mau negócio.

**O cenário é texto, não código.** Ele não é step definition, e o framework não pressupõe
nada que execute Gherkin — quem instala isso pode nunca ter usado Cucumber. Do outro lado
existe um teste escrito na tecnologia do projeto, que verifica este cenário. O cenário é o
que uma pessoa lê; o teste é o que a máquina roda.

**Todo cenário é verificado de ponta a ponta, contra o sistema de verdade.** Banco real,
requisição real, cena carregada, sem peça trocada por uma de mentira. Escreva sabendo
disso: se o cenário só passa com metade do sistema substituída, ele não verifica o que
promete. `Então recebo o e-mail de convite` obriga um servidor de e-mail no teste — o que
não proíbe o cenário, mas às vezes mostra que o resultado observável certo é outro: a
mensagem na fila, a linha na tabela.

**O `Então` carrega o valor literal.** `recebo 201 com Location: /convites/{codigo}`, não
"recebo a resposta certa" — descrever o resultado em vez de escrevê-lo faz a verificação
aceitar qualquer coisa.

**Onde entram tempo, frame ou física, o resultado é faixa:** `a porta termina de abrir em
menos de um segundo`, nunca `abre em exatamente 0,5s`. Número exato ali falha em outra
máquina, e quem confere aprende a ignorar o resultado.

**O `Dado` é o estado inicial, e só aparece quando não é o padrão do projeto.** Num backend
ele quase sempre some, porque o padrão é banco vazio; num jogo, `o inimigo a 10 metros do
jogador` é o que decide se o que a pessoa viu era o esperado.

Mesma regra com várias entradas vira `Esquema do Cenário` com tabela de `Exemplos`.

### Assumido

**Decisão que falta não é inventada em silêncio.** Se o cenário precisa de um valor que
ninguém definiu — o limite de um campo, a ordem de uma listagem, a resposta ao apagar o que
não existe —, use o valor mais provável, registre em `Assumido` embaixo do comportamento
que o usou, e leve a mesma linha para a saída. Sem isso, uma decisão de produto entra no
sistema sem ninguém ter decidido nada.

O registro entra mesmo quando o cenário já mostra o valor: o cenário diz o que acontece, o
campo diz que ninguém escolheu. Lista comprida é sinal, não sujeira — não junte nem resuma
para o campo ficar curto. E não registre o que a feature deixou de fora: "o convite não tem
limite de usos" é comportamento de uma feature que não existe, e escrever isso aqui é a
primeira aparição dela no sistema.

### Ids

`S1`, `S2`… na ordem em que aparecem no arquivo. **O número não é reaproveitado:**
comportamento removido deixa o id vago, porque algum teste pode citar aquele número — e o
novo entra com o próximo id livre, mesmo que o lugar dele seja no meio do arquivo.

## PASSO 5 — SAÍDA

O arquivo, e depois o que ele não mostra:

````markdown
`specs/criar-convite/spec.md` — 5 comportamentos, 9 cenários.

**Aviso** — a dependência de autenticação responde 401 a toda requisição, e até isso mudar
nenhum cenário daqui pode ser verificado.

**Faltam decisões de produto** — o valor assumido já está gravado, e trocá-lo é editar uma
linha do `Então`:

- ordem da listagem (assumi mais novo primeiro)
- aceitar o mesmo convite duas vezes (assumi 409)

**Segui a convenção do repositório** — a criação responde 201 com `Location`, e o corpo
repete o que foi criado.

**Ficou de fora** — expiração e revogação, que não estavam no pedido.

**Custa caro verificar** — o `S1` termina em e-mail entregue, e isso pede um servidor de
e-mail no teste. O resultado observável poderia ser a mensagem na fila.
````

**As decisões vão no seletor**, como no PASSO 3: a mensagem relata, o seletor coleta. Uma
pergunta por decisão assumida, com o valor gravado na primeira opção; uma pela convenção
herdada, cuja resposta vale para as próximas specs; uma pelo resultado observável caro,
quando houver. Aviso e "ficou de fora" não entram — o primeiro não se decide aqui, o
segundo já foi decidido no PASSO 3.

Passando de quatro perguntas, vão as decisões assumidas e o resto fica só na mensagem. Não
havendo nenhuma, o seletor pergunta só se a spec está certa.

**Só o detectado.** Rótulo em negrito parece seção obrigatória, e seção que aparece sempre
— às vezes só para dizer que não há nada — ensina o usuário a pular a parte de baixo
inteira. Reporte a contagem sem julgar por ela.

## NÃO-OBJETIVOS

- Não criar `.feature`, step definition, teste ou qualquer arquivo executável.
- Não escrever regra que nenhum exemplo mostra. "O sistema deve ser rápido", "os dados
  precisam ser consistentes": ninguém confere isso olhando. Ou vira cenário com valor
  literal, ou não é spec.
- Não explicar conceito do stack.
