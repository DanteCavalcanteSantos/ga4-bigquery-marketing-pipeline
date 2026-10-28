# Perguntas de negócio

> Fase 3. Define **o que** o dashboard responde antes de modelar as marts.

**Persona:** gestor de marketing da Google Merchandise Store.
**Escopo:** pós-clique (o que acontece dentro do site). Custo, impressões de anúncio, CPC e CPM
não existem no GA4 e ficam fora deste projeto.

## Perguntas

| # | Pergunta | Decisão que ela apoia | Limitação conhecida |
|---|---|---|---|
| 1 | Quais canais (`source`/`medium` da sessão) trazem mais sessões, conversões e receita? | Onde investir | ~1/3 da origem é `<Other>` ou `(data deleted)`: mostrar como "não identificado" |
| 2 | Quantas conversões (compras) aconteceram, e como evoluem no tempo? | Saúde geral do negócio | — |
| 3 | Onde o funil vaza? (`view_item` → `add_to_cart` → `begin_checkout` → `purchase`) | O que corrigir no site | — |
| 4 | Quais produtos e categorias vendem mais? Quais são vistos e não comprados? | Vitrine e estoque | — |
| 5 | Desktop × mobile × tablet: a conversão muda? | Prioridade de UX | — |
| 6 | Quais países geram mais receita? | Mercados | Cidade não serve (42% `(not set)`) |
| 7 | Novos × recorrentes, e retenção por coorte de primeira visita | Fidelização | — |

## KPIs

| KPI | Fórmula | Observação |
|---|---|---|
| Sessões | contagem distinta de `user_pseudo_id` + `ga_session_id` | A sessão é a unidade de visita |
| Usuários | contagem distinta de `user_pseudo_id` | Navegador, não pessoa |
| Conversões | contagem distinta de `transaction_id` em `purchase` | Distinta para não contar compra duplicada |
| Taxa de conversão | sessões com compra ÷ sessões | Por canal, dispositivo e país |
| Receita | soma de `ecommerce.purchase_revenue` | Moeda da propriedade |
| Ticket médio | receita ÷ conversões | — |
| Receita por sessão | receita ÷ sessões | Compara canais de tamanhos diferentes |
| Taxa de cada etapa do funil | sessões com a etapa ÷ sessões com a etapa anterior | Mostra onde vaza |
| CTR de banner interno | `select_promotion` ÷ `view_promotion` | Impressão e clique **dentro** do site |
