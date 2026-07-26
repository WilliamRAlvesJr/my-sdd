# FORMAT — spec.md

Define o artefato. Quem escreve é o `SKILL.md` ao lado.

Spec-anchored: a spec carrega a decisão, o código é a verdade executável, os testes
são o enforcer. A spec não descreve o código.

## ÁTOMO

A spec é uma lista de átomos. Nada mais.

> Um **átomo** é uma afirmação falsificável sobre comportamento observável, que o
> humano pode rejeitar sozinho, sem ler o resto da spec.

Três testes. Falhou em um, a linha sai — não é reescrita:

- **rejeição isolada** — riscar essa linha deixa o resto de pé? Não: são dois átomos mal cortados.
- **falsificabilidade** — existe observação que prova essa linha falsa? Não: é prosa.
- **não-derivável** — convenção, precedente ou protocolo já respondem? Sim: é ruído.

Sem teto de tamanho. 40 linhas que passam nos testes é uma spec correta de uma feature
grande; 8 linhas com 3 deriváveis está errada.

## SEÇÕES

Cinco, só `Casos` obrigatória. Toda linha tem id: `C` caso, `R` regra, `F` fora,
`D` depende. Dentro da feature o id nu basta (`R3`); em código, teste e backprop,
qualificado (`cartao/R3`). **Id não é reciclado** — átomo removido aposenta o id.

### Depende

Conceito citado que não existe no repositório. **Spec com `Depende` aberto não vai
para build.** Fecha quando o conceito existe em código, não quando a outra spec foi
escrita.

Spec que nasce com mais `Depende` que `Regras` está fora de ordem: a primeira spec de
um sistema é a que não depende de nada.

### Casos

Entrada e saída observáveis, falsificável por um curl ou um clique. É a instância.

Sublinha `entra`/`sai` decompõe o átomo: sem id, não rejeitável sozinha. **Nomeia, não
enumera** — enumerar campos só na spec que inventa o conceito; depois o DTO é a
verdade e `entra cartão` basta. Nomeie o que carrega decisão (`posição` na saída,
porque o cliente renderiza sem refetch), não o que é convenção (`createdAt`). Sem
entra/sai não-óbvio, o caso é uma linha só.

### Regras

Invariante: falsificável por qualquer caso que a viole, inclusive os que ninguém
escreveu. A regra cobre o conjunto, o caso cobre a instância.

`GET inexistente → 404` é protocolo, não regra. Regra invisível ganha o caso que a
torna observável. Razão na mesma linha após `—` só quando a regra pareceria arbitrária
sem ela.

### Fora

Não tem observação que a prove; tem código que a viola. Restringe o agente, não o
código.

Só o que **você plausivelmente adicionaria** — soft delete, paginação, auditoria,
mapper, campo extra —, não tudo que a feature não faz. `Fora` inchado dilui.

### Revogados

Rodapé, só existe depois do primeiro amend com código no chão.

## ONDE O ÁTOMO MORA

O átomo mora no nível mais específico onde ainda é verdade e sobe só quando colide.
Subiu, **some da spec** — passa a falhar no teste de não-derivável.

Teste de subida: **dá pra enunciar sem nomear a feature?** `sem soft delete` sobe;
`sem reordenação em lote`, que exige uma entidade com ordem, fica.

Promoção acontece na colisão, **nunca na previsão**: promover cedo aplica convenção
errada a tudo.

Contrariar convenção é átomo declarado, com razão:
`R7 cartão tem soft delete (exceção à convenção) — auditoria exige rastro`.
**Convenção que precisa de exceção é convenção errada**: `≤ 120 exceto coluna, que é
60` são dois conceitos, não um com exceção.

## SPEC OU PLAN

Quem só consome o sistema nota a diferença entre as duas opções? Nota → spec. Só quem
lê o código nota → plan.

Granularidade não é o eixo: `≤ 120 caracteres` é fino e é spec, "três camadas" é
grosso e é plan. Termo técnico entra quando é observável (`Idempotency-Key`); nome de
classe, método ou anotação, nunca.

## AMEND

**O código já implementou esse átomo?**

- Não → **correção**. Edita no lugar, mesmo id. O git guarda.
- Sim → **revogação**. O átomo sai da seção e vira linha no rodapé. Não se risca no
  lugar: o morto continuaria onde o olho pousa.

```markdown
## Revogados
R4 → R7 (2026-07-25) — cliente exigiu cascata; excluir coluna leva os cartões
```

Torna verificável a referência órfã: código ou teste citando id revogado é erro.

## EXEMPLO

```markdown
# cartão

Criar, mover e excluir cartão dentro das colunas de um quadro.

## Depende
D1  quadro — não existe no repo; precisa da spec de quadro
D2  coluna — não existe no repo; precisa da spec de coluna

## Casos
C1  POST /coluna/{id}/cartao
    entra  cartão (título)
    sai    201 · id, posição
C2  PATCH /cartao/{id} para coluna de outro quadro   → 422
C3  PATCH /cartao/{id} para a coluna atual           → 200, nada muda
C4  DELETE /coluna/{id} com cartão                   → 409

## Regras
R1  título ≤ 120 caracteres
R2  cartão pertence a exatamente uma coluna
R3  posição é densa dentro da coluna (0..n-1) — inserir e remover reordena os vizinhos
R4  quadro nunca perde cartão por efeito colateral: exclusão é explícita e do próprio cartão

## Fora
F1  sem reordenação em lote — um move por vez
F2  sem arquivamento; DELETE é definitivo
F3  sem descrição, responsável, etiqueta ou prazo
```
