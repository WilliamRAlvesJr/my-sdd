# [feature] — plan

[Uma linha dizendo o que este desenho resolve.]

```mermaid
%%{init: {"themeCSS": "g[id*=classId-[Classe]] .members-group g.label:nth-of-type([n]) .nodeLabel, g[id*=classId-[Classe]] .methods-group g.label:nth-of-type([n]) .nodeLabel {color:#3fb950 !important} g[id*=classId-[Classe]] .members-group g.label:nth-of-type([n]) .nodeLabel {color:#f85149 !important}"} }%%
classDiagram
    class [Interface] {
        <<interface>>
        +[campo] : [tipo]
        +[método]([parâmetro] : [tipo]) [tipo de retorno]
    }

    class [ClasseQueMuda] {
        +[campo] : [tipo] = [valor antigo]
        +[campo] : [tipo] = [valor novo]
        +[método que só ela tem]([parâmetro] : [tipo]) [tipo de retorno]
    }

    class [ClasseNova]:::added {
        +[campo] : [tipo] = [valor]
        +[método]([parâmetro] : [tipo]) [tipo de retorno]
    }

    class [ClasseRemovida]:::removed {
        +[campo] : [tipo] = [valor]
    }

    [Interface] <|.. [ClasseQueMuda] : implementa
    [Interface] <|.. [ClasseNova] : implementa
    [Interface] <|.. [ClasseRemovida] : implementa
    [ClasseQueSegura] o--> [Interface] : [papel]

    classDef added fill:#1f6f3f,stroke:#3fb950,stroke-width:2px,color:#ffffff
    classDef removed fill:#7d2029,stroke:#f85149,stroke-width:2px,color:#ffffff
```
