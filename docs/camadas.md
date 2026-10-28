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

O grão muda: muitos eventos viram uma linha por sessão, por dia ou por produto. Exemplo
**ilustrativo** da `fct_sessions` (os `?` dependem dos outros eventos da mesma visita):

| Coluna | Valor |
|---|---|
| `session_key` | `1026454.4271112504-661084800` (usuário + sessão) |
| `session_start` | `2021-01-31 05:05:10` |
| `is_new_user` | `true` (`ga_session_number = 1`) |
| `channel` | `?` |
| `device_category` / `country` | `mobile` / `United States` |
| `pageviews` | `?` |
| `converted` / `revenue` | `?` |

Outras marts previstas: `mart_channel_daily`, `mart_funnel_daily`, `mart_product_daily` e
`mart_cohort` (ver o [roadmap](roadmap.md)).
