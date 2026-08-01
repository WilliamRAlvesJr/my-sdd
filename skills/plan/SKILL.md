---
name: plan
description: >
  Desenha o diagrama de classes da feature: o que entra, o que sai e o que muda, com a
  marca de diff em cima do UML. Use quando o usuário disser "planeja X", "como isso vai ser
  feito", "desenha as classes de X", ou invocar /my-spec:plan. Não use para escrever a
  spec, para cortar o trabalho em passos, nem para escrever código.
argument-hint: "[<feature | caminho da spec>]"
---

# plan — o desenho da feature, em classes

Notação do diagrama: `diagrams/class-diff.md`, ao lado. Leia antes de desenhar.

Você escreve **`specs/<feature>/plan.md` e nada mais**. Hoje ele tem uma coisa só: o
diagrama de classes da feature.

O diagrama é um diff: ele não mostra o sistema, mostra a mudança. Classe que entra, classe
que sai, e dentro das que ficam, o campo e a assinatura que mudam. Quem lê precisa ver, numa
olhada, o tamanho do estrago.

**Você sempre desenha.** Mesmo que a feature pareça caber numa classe só.

## PASSO 1 — LER

1. **O pedido** — o que veio no argumento da chamada. Vindo vazio, o pedido é o que o
   usuário já disse na conversa; não peça para ele repetir.
2. **A `spec` da feature** — `specs/<feature>/spec.md`, quando existir. Os `behaviors`
   dizem o que precisa existir; o desenho é como. Não havendo `spec`, o desenho sai do
   pedido e isso vira aviso na saída.
3. **O repositório** — os nomes reais do que já existe: a classe que vai mudar, a interface
   que ela já implementa, quem segura a referência. Desenho com nome inventado para classe
   que existe é pior que desenho nenhum, porque ninguém acha o arquivo.
4. **Você só lê, nunca roda.** Relate apenas o que dá para descobrir lendo.

## PASSO 2 — ESCOLHER O QUE ENTRA NO DESENHO

Entra a classe que a feature cria, remove ou altera. Entram também as que a relação precisa
para fazer sentido — a interface que a classe nova implementa, quem guarda a referência para
ela —, mesmo intocadas.

Fica de fora classe intocada que não participa de nenhuma relação do desenho, e fica de fora
classe que resolve problema que ninguém pediu. **Obstáculo que você encontrou no caminho
vira aviso na saída, nunca caixa no diagrama** — desenhado, ele parece decisão tomada, e a
próxima pessoa implementa.

## PASSO 3 — SAÍDA

O arquivo é o título `# <feature> — plan`, uma linha dizendo o que o desenho resolve, e o
bloco. Nada mais.

Depois dele, na conversa, o que ele não mostra:

````markdown
`specs/criar-convite/plan.md` — 5 classes, 2 novas, 1 removida.

**Assumi** — o código do convite é `string`; ninguém definiu o tipo.

**Aviso** — a feature não tem `spec.md`, então o desenho saiu do pedido.

**Ficou de fora** — expiração apareceu no caminho e não foi pedida; não virou classe.
````

**A confirmação vai no seletor de opções, não no texto** — uma chamada de `AskUserQuestion`
logo depois da mensagem. Uma pergunta por decisão assumida, com o valor gravado na primeira
opção, e a última é sempre *o desenho está certo?*. Pergunta escrita em prosa é respondida
em prosa, quando é respondida.

**O passo é um ciclo.** Cada volta: grave o arquivo como está decidido até agora, emita o
relato ajustado, chame o seletor com o que sobrou, aplique as respostas — e volte ao começo.
Você sai pela resposta que confirma o desenho, com nada pendente, e por mais nada.

## NÃO-OBJETIVOS

- Não escrever código, migration, teste ou qualquer arquivo executável.
- Não cortar o trabalho em passos: ordem e estado são de outro artefato.
- Não repetir em prosa o `behavior` que a `spec` já descreve.
- Não explicar conceito do stack.
