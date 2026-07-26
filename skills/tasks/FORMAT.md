# FORMAT — tasks.md

Define o artefato. Quem escreve é o `SKILL.md` ao lado.

`tasks.md` é descartável: quando a feature fecha, ele pode ser jogado fora e escrito de
novo. Nada permanente aponta para ele — teste e código citam id de spec, nunca de task.

## O QUE É UMA TASK

> A menor coisa que uma pessoa consegue ver funcionando.

Ver funcionando é qualquer coisa observável: uma resposta HTTP, uma linha no banco, algo
na tela, um arquivo gerado, uma mensagem no log. Vale versão descartável — guardar na memória em vez de no
banco, cubo branco em vez de modelo 3D — desde que dê para ver.

**Task não é passo de implementação.** "Criar a entidade" e "adicionar o repositório" não
são tasks: ninguém consegue olhar e dizer se funcionou. Cortar por camada é o corte que
você faria sozinho, e é o errado — ele empurra tudo que é visível para o fim, que é
justamente quando não sobra tempo de mudar de ideia.

**A task é fechada.** Ela entrega o que o cenário mostra e nada além. Comportamento que
pertence a outra task não é adiantado, mesmo quando cabe em duas linhas e melhora o
resultado.

Isso contraria seu reflexo mais forte: você completa padrão. Vendo "criar convite", a
recusa de código inválido vem junto sem ninguém pedir, parece melhor e passa em review. O
custo só aparece depois — a task que cuidaria da recusa chega sem nada para fazer, e a
verificação da task anterior deixa de significar o que dizia. A lista inteira vira
decoração de um trabalho que aconteceu todo de uma vez.

## ESTRUTURA

O arquivo abre com `# <feature> — tasks`, e cada task é um `##`.

Numa API web:

````markdown
## |.| T2 · Aceitar um convite pelo código

```gherkin
Cenário: aceitar convite válido
  Dado um convite criado por POST /convites
  Quando eu envio POST /convites/{codigo}/aceite
  Então recebo 200 com o convite marcado como aceito

Cenário: aceitar convite que já foi usado
  Quando eu envio POST /convites/{codigo}/aceite duas vezes
  Então a segunda chamada recebe 409
```

- **Mexe em** — `ConviteController`, `ConviteRepository`
- **Decisões que usa** — `S4` `P2`
````

Num jogo em Unity, os mesmos campos:

````markdown
## |.| T4 · Cair de muito alto tira vida

```gherkin
Cenário: cair da plataforma mais alta
  Dado o jogador com a vida cheia, na plataforma mais alta do salão
  Quando ele pula para o chão
  Então a vida cai perto da metade, sem chegar a zero
  E o jogador continua de pé
```

- **Mexe em** — `Jogador.cs`, `ZonaDeQueda.cs`, cena `Salao`
- **Decisões que usa** — `S2`
````

Título no imperativo, dizendo o que passa a funcionar. Nome de arquivo, classe ou chamada
pode aparecer dentro dele, nunca no lugar do comportamento. Prosa abaixo do cenário só
quando carrega uma razão que o cenário não carrega; sem isso, os dois campos vêm direto.

## ESTADO

A marca abre o título e é o único lugar onde o arquivo muda depois de escrito:

- `|.|` — não começou
- `|~|` — em andamento
- `|?|` — escrita, esperando o dev conferir
- `|x|` — conferida e funcionando

Todas nascem `|.|`.

**Você nunca marca `|x|`.** Vai até `|?|` e para. Conferir é do dev, e não é falta de
acesso: mesmo podendo rodar o comando, o que você observa é que a chamada devolveu 201 —
não que a coisa funcionou. Marcar sozinho transforma a lista num registro do que você acha
que fez, que é o oposto do que ela serve.

Verificação que você não tem como executar — entrar em Play, olhar a tela, conferir no
Inspector — **não é motivo para inventar substituto**. Deixe em `|?|` e diga o que ficou
faltando conferir.

Não existe marca de falha. Não funcionou, volta para `|~|` e o que aconteceu vai escrito
embaixo da task. Task que falhou é task em andamento.

## O CENÁRIO

Gherkin **no idioma do projeto, palavras-chave incluídas**. O Gherkin tem tradução oficial
para dezenas de idiomas: em português, `Cenário`, `Dado`, `Quando`, `Então`, `E`, `Esquema
do Cenário`, `Exemplos`. O artefato é lido por quem trabalha no projeto — trocar o idioma
dele por realce de sintaxe é mau negócio, e nem todo renderizador colore as traduções.

**O cenário não roda.** Ele não é step definition e ninguém o executa: é texto para uma
pessoa ler e conferir com o produto na frente. Num projeto que tem Gherkin executável, esses
arquivos são código do produto — entram no `Mexe em` como qualquer outro, e o cenário da
task continua sendo texto. Gherkin entrou porque separar estado inicial, ação e resultado
funciona em qualquer tipo de projeto — API, jogo, linha de comando —, e nenhum outro
formato serviu aos três.

**O `Dado` é o estado inicial.** Omita quando for o padrão do projeto e escreva quando não
for: cena, posição, saldo, arquivo já existente. Num backend ele quase sempre some, porque
o padrão é banco vazio; num jogo, `o inimigo a 10 metros do jogador` é o que decide se o
que a pessoa viu era o esperado.

**O `Então` carrega o valor literal.** `recebo 201 com Location: /convites/{codigo}`, não
"recebo a resposta certa". Descrição do resultado no lugar do resultado é o jeito
silencioso de a verificação passar a aceitar qualquer coisa.

**Onde entram tempo, frame ou física, o resultado é faixa.** `a porta termina de abrir em
menos de um segundo` — nunca `abre em exatamente 0,5s`. Número exato ali falha em outra
máquina e ensina quem confere a ignorar o resultado.

Mesma regra com várias entradas vira `Esquema do Cenário` com tabela de `Exemplos`, em vez
de cenários quase iguais em sequência.

Dois ou três cenários por task. Mais que isso, quase sempre são duas tasks.

## OS CAMPOS

**Mexe em** — arquivos e artefatos, incluindo o que não é código: migration de banco, cena
ou prefab de um jogo em Unity, arquivo de configuração. Diz onde o trabalho cai, não o que
fazer lá dentro. Num CRUD várias tasks repetem os mesmos dois arquivos, e está certo — o
campo não mede tamanho.

Arquivo que ainda não existe entra pelo nome mesmo assim, e o nome é provisório: quem
decide o desenho é o plan, e ele troca sem que a task mude.

**Decisões que usa** — ids de spec e plan que a task consome e não decide. **Sem spec e
sem plan o campo não aparece**; escrever "nenhuma" em toda task é a mesma linha repetida
seis vezes.

**Assumido** — só quando a task precisou de uma decisão que ninguém tomou, ao lado de onde
a suposição foi usada. Mais de uma vira lista, nunca o rótulo repetido:

````markdown
- **Assumido**
  - o limite do nome é 120 caracteres
  - nome repetido é permitido
````

As mesmas vão para a saída do skill, onde o usuário decide se sobem para a spec.

A suposição entra mesmo quando o cenário já a mostra: o cenário diz o que acontece, o campo
diz que ninguém decidiu.

Lista comprida é sinal, não sujeira — é a falta de spec ficando visível no artefato, onde o
usuário tropeça nela. Não junte suposições nem resuma para o campo ficar curto.

Não registre o que a task deixou de fora. "O convite não tem limite de usos" é decisão de
uma feature que ainda não existe — escrever isso aqui é a primeira aparição dela no
sistema, e a próxima é uma task para resolvê-la.

## RESULTADO QUE É "NADA MUDOU"

Trocar a versão descartável pela definitiva é uma task, e a verificação dela é que **nada
mudou** por fora: as mesmas respostas, o mesmo comportamento, agora salvando de verdade ou
desviando de obstáculo. Escreva isso na cara limpa, com o cenário mostrando a coisa nova
que só agora funciona — sobreviver ao reinício, contornar a parede, aguentar duas
instâncias.

Sem essa permissão explícita, aparece uma mudança inventada na interface só para haver o
que mostrar.

A posição dessa task na lista não é fixa: ela vem de quem depende dela. Numa API onde tudo
adiante precisa de dado salvo, a troca acontece cedo. Num jogo onde só um cenário com
obstáculo precisa de navegação de verdade, ela pode ser a última.

## O QUE NÃO VIRA TASK

Coisa que atrapalha o trabalho mas não foi pedida vira aviso no topo, nunca item da lista.
São dois casos, com marcação diferente, porque o leitor faz coisas diferentes com cada um.

**Estorvo já instalado** — build quebrado, dependência que bloqueia toda chamada,
ferramenta que reprova o projeto inteiro. Ele resolve e segue:

````markdown
> [!WARNING]
> **Resolva isto antes de começar a T1**
>
> A suíte de testes já estava vermelha antes desta feature. Enquanto continuar assim, não
> dá para saber se uma verificação abaixo falhou por causa do trabalho novo.
````

**Coisa que ainda não existe** — a feature depende de outra que ninguém escreveu, ou de um
serviço que roda fora deste repositório. Ele descobre que veio cedo demais:

````markdown
> [!IMPORTANT]
> **Esta lista pressupõe que já existem**
>
> Um cadastro de cliente e um serviço de cobrança. Nada disso é task daqui: são outra
> feature ou outro repositório, e sem elas nenhuma verificação abaixo pode ser feita.
````

Use o alerta nativo, nunca `<div>` com `style` inline: o GitHub remove estilo inline por
segurança, e lá a caixa apareceria como texto sem cor. No VS Code os alertas dependem de
extensão — o custo de não renderizar é perder a cor, não perder o texto.

## IDS

`T1`, `T2`… na ordem de execução. Id de task não é citado por código nem por teste — o
arquivo é descartável, a referência ficaria órfã na primeira regeneração. Dentro do
arquivo, uma task pode citar outra (`repito a T1 e a T3`).

## TESTE

A task não manda escrever teste: isso é convenção do projeto, e repetir em toda task é
ruído. O nível de teste da feature é decisão de plan, e muda muito com a tecnologia — num
backend cada cenário vira teste de integração quase de graça, num jogo o mesmo cenário
custa caro e às vezes fica manual mesmo.

Um cenário não vira um teste. `nome inválido é recusado` vira três ou quatro testes de
validação e mais um de integração. Não escreva esse mapa à mão.
