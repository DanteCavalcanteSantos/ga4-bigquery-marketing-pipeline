# Camadas do pipeline: um evento atravessando bronze, prata e ouro

Um evento real (um `page_view` de 31/01/2021) seguido pelas três camadas. Os nomes no código
seguem o padrão Dataform/dbt (`staging`, `marts`); bronze, prata e ouro são a equivalência na
convenção *medallion*.

```
events_* (bronze, Google)  →  staging (prata, BigQuery)  →  marts (ouro, BigQuery)  →  Power BI
                    ↑ o código (.sqlx) fica no GitHub; o dado, só no BigQuery ↑
```

Em uma frase: a bronze é a ficha original, a prata é a ficha passada a limpo numa planilha,
e o ouro é o relatório pronto.

## 🥉 Bronze: `events_*`

92 tabelas (uma por dia), cerca de 4,3 milhões de linhas e 23 colunas. Uma linha = um evento.
Colunas aninhadas: `RECORD` (caixa com divisórias) e `REPEATED` (lista).

| Coluna | Valor real |
|---|---|
| `event_date` | `20210131` (texto) |
| `event_timestamp` | `1612069510766593` (microssegundos desde 1970) |
| `event_name` | `page_view` |
| `user_pseudo_id` | `1026454.4271112504` |
| `device` | `{category: mobile, web_info: {browser: Safari}, ...}` |
| `geo` | `{country: United States, city: San Carlos, ...}` |
| `traffic_source` | `{source: google, medium: organic}` (origem da **primeira** visita) |
| `event_params` | lista com 12 etiquetas: `ga_session_id = 661084800`, `page_title = Home`... |
| `ecommerce`, `items` | vazios (não é compra) |

## 🥈 Prata: `stg_events`

O mesmo número de linhas da bronze. Cada etiqueta e cada divisória viram uma coluna simples,
com o tipo certo. Ainda sem regra de negócio.

| Coluna | Valor |
|---|---|
| `event_date` | `2021-01-31` (DATE) |
| `event_datetime` | `2021-01-31 05:05:10` (UTC) |
| `event_name` | `page_view` |
| `user_pseudo_id` | `1026454.4271112504` |
| `ga_session_id` | `661084800` |
| `ga_session_number` | `1` |
| `page_title` | `Home` |
| `page_location` | `https://shop.googlemerchandisestore.com/` |
| `entrances` | `1` |
| `session_engaged` | `0` |
| `device_category` | `mobile` |
| `browser` | `Safari` |
| `country` | `United States` |
| `city` | `San Carlos` |
| `source` / `medium` | vazio neste evento (a origem é atribuída por sessão, no ouro) |

## 🥇 Ouro: marts

O grão muda: muitos eventos viram uma linha por sessão, por compra, por produto e dia, ou por
coorte. A mesma visita do `page_view` acima, agora como **uma linha real** da `fct_sessions`:

| Coluna | Valor |
|---|---|
| `session_key` | `1026454.4271112504-661084800` (usuário + sessão) |
| `session_start` | `2021-01-31 05:05:10` (UTC) |
| `is_new_user` | `true` (`session_number = 1`) |
| `channel` | `Não identificado` (nenhum evento da visita trouxe `source`/`medium`) |
| `landing_page` | `https://shop.googlemerchandisestore.com/` |
| `device_category` / `country` | `mobile` / `United States` |
| `pageviews` | `2` |
| `is_engaged` / `engagement_time_sec` | `true` / `19,29` |
| `has_view_item` … `has_purchase` | todos `false` |
| `transactions` / `revenue` | `0` / `0` |

## Mapa das tabelas

```
bronze                         prata (staging)                ouro (marts)
events_* ─────────────┬──────→ stg_events ──┬──────────────→ fct_purchases ──┐
(92 tabelas, Google)  │        4,3 mi linhas │                5.372 compras   │
                      │                      └──────────────→ fct_sessions ←──┘
                      │                                       360 mil sessões
                      │                                            └────────→ mart_cohort_weekly
                      └──────→ stg_items ───────────────────→ mart_product_daily
                               4,0 mi linhas                  51 mil linhas
```

| Tabela | Grão (uma linha = ) | Para que serve no Power BI |
|---|---|---|
| `fct_sessions` | uma sessão | Canal, dispositivo, país, funil, conversão, receita, novos × recorrentes |
| `fct_purchases` | uma compra | Pedidos, receita, ticket médio, forma de pagamento. Liga à sessão por `session_key` |
| `mart_product_daily` | um produto num dia | Produtos mais vistos, adicionados e comprados |
| `mart_cohort_weekly` | uma coorte × semana | Matriz de retenção |

`mart_channel_daily` e `mart_funnel_daily`, previstas no roadmap, **não foram criadas**: a
`fct_sessions` já responde às duas perguntas no Power BI, sem o problema das métricas não
aditivas (usuários de dias diferentes não se somam).

Custo de uma execução completa (`dataform run dataform`): **~4,3 GiB** (staging ~2,8 GiB +
marts ~1,5 GiB). Armazenamento: ~2,2 GiB dos 10 GiB do sandbox.
