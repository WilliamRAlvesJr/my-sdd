---
name: spec
description: >
  Triagem por incerteza e escrita de spec atômica. Propõe classificação e escopo,
  o usuário confirma numa linha, então lê o repositório e escreve spec.md como
  lista de átomos com id. Precedente é do projeto, nunca do ecossistema. Use
  quando o usuário disser "spec disso", "nova feature", "escreve a spec para...",
  "quero implementar X", "vamos especificar", ou invocar /my-spec:spec. Não use
  para tarefa direta sem incerteza, para investigação de bug, ou para decidir
  implementação (isso é plan).
argument-hint: "[<ideia | tarefa>]"
---

# spec — triagem + spec atômica

Formato do artefato: `FORMAT.md`, ao lado. Leia antes de escrever.

Você escreve **`spec.md` e nada mais**. Não gera tasks, não toca código, não escreve
`plan.md` — se a solução for desconhecida, diga isso e pare.

## PASSO 1 — TRIAGEM

Você **propõe**, o usuário **confirma**. Você subestima ambiguidade sistematicamente;
por isso proposta, nunca decisão autônoma.

Classifique pelo que é **desconhecido no início**, não pelo tamanho:

| desconhecido | rota |
|---|---|
| nada | tarefa direta, sem spec |
| o comportamento | **spec** |
| a solução | spec + plan |
| se dá para fazer | spike com timebox, sem spec |
| por que quebrou | investigação com timebox, sem spec |

Categorias: `trivial`, `ajuste`, `feature-com-precedente`, `feature-sem-precedente`,
`refactor`, `bug-óbvio`, `bug-não-óbvio`, `spike`, `dívida`.

**Precedente é do projeto.** Só é `com-precedente` se ESTE repositório já tem o
padrão — exemplos do ecossistema não contam. Na dúvida, é sem.

Gatilho de spec: **escopo ambíguo OU implicação arquitetural OU grande demais.**
Tarefa pequena que introduz dependência, porta ou signal novo vira spec mesmo sendo
pequena: é o caso que code review não pega.

Emita e **pare**:

```
Triagem: feature-sem-precedente · api/ · spec
Motivo: comportamento de ordenação não tem precedente no repo.
Confirma? (edite a linha se discordar)
```

Rota que não vira spec para aqui, em uma frase: `trivial`/`ajuste`/`bug-óbvio` → "é
tarefa direta, faço agora?". `spike` → "timebox, sem estimativa; código de spike não
entra no projeto". `bug-não-óbvio` → "investigação com timebox".

## PASSO 2 — LER ANTES DE PERGUNTAR

Pergunta cuja resposta está no repositório é pior que pergunta óbvia: revela que você
não leu. Antes de qualquer pergunta:

1. **Convenções** — `CLAUDE.md` e, se existir, `CONVENCOES.md`. Ausência do segundo é
   normal e silenciosa: ele nasce na primeira colisão, não antes.
2. **Precedente** — o repositório já resolve algo parecido? Reusar a decisão é melhor
   que reabri-la.
3. **Conceitos citados** — cada um existe em código? O que não existe vira átomo `D`.

Ser econômico na spec nunca significa ser econômico na leitura.

## PASSO 3 — O FILTRO

```
derivável de convenção, precedente ou código existente?
├── sim  → silêncio. Não escreve, não pergunta.
└── não  → tem mais de uma resposta razoável?
           ├── não  → escreve o valor direto.
           └── sim  → pergunta com default, depois escreve.
```

**Toda pergunta produz um átomo.** Pergunta sem átomo de saída é interrogatório: o
usuário passa a responder no automático e o framework perde a razão de existir.

Nunca pergunte: se um CRUD inclui deletar, se o recurso precisa de id, se `GET`
inexistente retorna 404 (as três são óbvias), qual o nome da classe (é plan).

Uma rodada só, todas as perguntas juntas, cada uma com default. Perguntas em série
destroem a confiança mais rápido que perguntas ruins.

```
1. Posição do cartão na coluna: densa (0..n-1, reordena vizinhos) ou esparsa
   (gaps de 1000, insere sem tocar vizinho)?
   default: densa — API simples, o custo só aparece com muitos cartões.
Responda "ok" ou edite a linha.
```

Sem teto de quantidade: seis bifurcações reais, pergunte as seis. O sinal de triagem
errada é a **dependência entre elas** — pergunta cuja resposta muda *quais são* as
outras. Isso é desenho, não especificação: pare e proponha spike.

Zero pergunta é resultado válido, e sinal de que talvez não fosse spec.

## PASSO 4 — ESCREVER

`specs/<feature>/spec.md`, no formato do `FORMAT.md`.

Ordem, porque cada seção alimenta a seguinte: `Depende` → `Casos` → `Regras` (o que os
casos não generalizam) → `Fora` (o que você adicionaria se ninguém proibisse; é o seu
próprio viés que está listando, seja honesto).

Passe cada linha pelos três testes antes de emitir.

## PASSO 5 — SAÍDA

O arquivo completo, e depois o que ele **não** mostra. A spec é enxuta porque não
repete convenção, e é agora que o usuário valida.

```
Convenções aplicadas (não repetidas no arquivo):
  sem soft delete · sem paginação até haver volume
Quebrando: R7 usa soft delete — exceção declarada, confirme.
Colisão: título ≤ 120 também está em coluna/R2. Promover para convenção?
Bloqueado: D1, D2 abertos — nada implementável ainda.
14 átomos · 2 bifurcações.
```

- **Só o detectado.** Lembrete genérico para "manter a documentação atualizada"
  contamina os avisos reais, porque o usuário aprende a ignorar a seção inteira.
- **Números são observação, nunca limiar.** Reporte a contagem, não julgue por ela.

Feche com: "spec OK? `/my-spec:spec amend` para ajustar."

## NÃO-OBJETIVOS

- Não decidir implementação: classe, camada, método, biblioteca.
- Não criar arquivo fora de `specs/`.
- Não expandir escopo. Você completa o padrão estatístico do corpus, então ausência de
  menção é lida por você como não-especificado — é exatamente por isso que `Fora`
  existe.
- Não explicar conceito do stack: o usuário é engenheiro do stack.
