# Dicionário de dados

> Em construção (Fase 2). Fonte:
> `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`, de 01/11/2020 a
> 31/01/2021: 92 tabelas, uma por dia, com cerca de 4,3 milhões de eventos.

## Grão

Uma linha = um evento. Uma visita (sessão) gera várias linhas.

## Colunas usadas

Fora `event_params`, estas são as colunas da bronze que vão para a staging. Caixas com divisórias
(`RECORD`) aparecem como `caixa.divisória`.

| Coluna | Tipo | Em português | Exemplo |
|---|---|---|---|
| `event_date` | STRING | Data do evento (fuso da propriedade) | `20210131` |
| `event_timestamp` | INTEGER | Momento do evento, em microssegundos desde 1970 (UTC) | `1612069510766593` |
| `event_name` | STRING | Tipo do evento | `page_view` |
| `user_pseudo_id` | STRING | ID anônimo do navegador do usuário | `1026454.4271112504` |
| `user_first_touch_timestamp` | INTEGER | Primeira visita do usuário (microssegundos) | `1612069510766593` |
| `device.category` | STRING | Tipo de dispositivo | `mobile`, `desktop`, `tablet` |
| `device.operating_system` | STRING | Sistema operacional | `Web` em 58% dos eventos (ver limitações) |
| `device.language` | STRING | Idioma do navegador | `en-us` |
| `device.web_info.browser` | STRING | Navegador | `Safari` |
| `geo.country` | STRING | País | `United States` |
| `geo.region` | STRING | Estado / região | `California` |
| `geo.city` | STRING | Cidade | `San Carlos` |
| `traffic_source.source` | STRING | Origem da **primeira** visita do usuário | `google` |
| `traffic_source.medium` | STRING | Mídia da primeira visita | `organic` |
| `traffic_source.name` | STRING | Campanha da primeira visita | `(organic)` |
| `ecommerce.transaction_id` | STRING | ID do pedido | — |
| `ecommerce.purchase_revenue` | FLOAT | Receita do pedido | — |
| `ecommerce.tax_value` | FLOAT | Imposto | — |
| `ecommerce.shipping_value` | FLOAT | Frete | — |
| `ecommerce.total_item_quantity` | INTEGER | Quantidade de itens no pedido | — |

### `items` (lista: um evento pode ter vários produtos)

Vai para a `stg_items`, com `UNNEST` (uma linha por produto por evento).

| Divisória | Tipo | Em português |
|---|---|---|
| `item_id` | STRING | ID do produto |
| `item_name` | STRING | Nome do produto |
| `item_category` | STRING | Categoria |
| `price` | FLOAT | Preço unitário |
| `quantity` | INTEGER | Quantidade |
| `item_revenue` | FLOAT | Receita do item |
| `promotion_name`, `creative_name`, `creative_slot` | STRING | Banner (em `view_promotion` e `select_promotion`) |

**Moeda:** as colunas sem `_in_usd` estão na moeda da propriedade; as `_in_usd` são convertidas
para dólar. Usamos as **sem** `_in_usd`: num cliente brasileiro, elas vêm em reais.

## Eventos (`event_name`)

| Grupo | Eventos | Uso |
|---|---|---|
| Automáticos | `session_start`, `first_visit`, `user_engagement`, `scroll`, `page_view` | Visita e navegação |
| Impressão (visualização) | `view_item`, `view_promotion`, `view_item_list`, `view_search_results` | Exposição a produto, banner, lista e busca |
| Clique | `select_item`, `select_promotion`, `click` | Interesse |
| Funil de compra | `add_to_cart` → `begin_checkout` → `add_shipping_info` → `add_payment_info` → `purchase` | Conversão |

## Etiquetas de `event_params` usadas na staging

| Etiqueta | Tipo do valor | Em português | Para quê |
|---|---|---|---|
| `ga_session_id` | `int_value` | ID da sessão | Junto com `user_pseudo_id`, identifica a sessão |
| `ga_session_number` | `int_value` | Número da sessão do usuário | 1 = primeira visita; novo × recorrente |
| `page_location` | `string_value` | URL da página | Páginas |
| `page_title` | `string_value` | Título da página | Páginas |
| `page_referrer` | `string_value` | Página anterior | Navegação (parcialmente vazio) |
| `source` | `string_value` | Origem | Canal da sessão |
| `medium` | `string_value` | Mídia | Canal da sessão |
| `campaign` | `string_value` | Campanha | Canal da sessão |
| `term` | `string_value` | Termo pago | Canal da sessão |
| `session_engaged` | `string_value` **e** `int_value` | Sessão engajada | Engajamento (tipo misto, ver limitações) |
| `engagement_time_msec` | `int_value` | Tempo de engajamento (ms) | Engajamento |
| `entrances` | `int_value` | Página de entrada (1 = sim) | Landing page |
| `percent_scrolled` | `int_value` | % de rolagem | Comportamento |
| `search_term` | `string_value` | Termo buscado no site | Busca interna |
| `currency` | `string_value` | Moeda | Compra |
| `payment_type` | `string_value` | Forma de pagamento | Compra |
| `shipping_tier` | `string_value` | Tipo de frete | Compra |
| `coupon` | `string_value` | Cupom | Compra |

Descartadas:

- `gclid`, `gclsrc`, `dclid` e `all_data`: vazias pela ofuscação
- `debug_mode`, `clean_event` e `engaged_session_event`: técnicas
- `link_*` e `outbound`: só eventos `click`, fora das perguntas
- `value`, `tax` e `transaction_id`: tipo misto (veja as limitações). Usar as colunas
  `ecommerce.purchase_revenue`, `ecommerce.tax_value` e `ecommerce.transaction_id`, que têm tipo
  fixo
- `promotion_name`: o dado do banner já vem em `items`

## Impressão de promoção (banners internos)

GA4 de site **não traz impressão de anúncio** (isso vem do Google Ads ou do DV360). O que existe
é impressão **dentro do site**:

- `view_promotion`: o banner apareceu. `select_promotion`: o banner foi clicado.
- Os dados do banner ficam em `items`, não em `event_params`: `promotion_id`,
  `promotion_name`, `creative_name`, `creative_slot`.
- Métrica possível: CTR de banner = `select_promotion` ÷ `view_promotion`.

## Limitações conhecidas

- **Ofuscação:** IDs e parte dos valores foram alterados ou apagados pelo Google.
  `gclid`, `gclsrc`, `dclid` e `all_data` estão sempre vazios.
- **Valores mascarados** (medido em 28/10/2026, 92 dias, 4,3 milhões de eventos; query de
  315 MiB sobre `traffic_source`, `device` e `geo`):

  | Coluna | `<Other>` | `(data deleted)` | `(not set)` | Impacto |
  |---|---|---|---|---|
  | `traffic_source.source` | 1,13 mi (26%) | 309 mil (7%) | — | Um terço da origem é desconhecido |
  | `traffic_source.medium` | 597 mil (14%) | 314 mil (7%) | — | Idem para a mídia |
  | `traffic_source.name` (campanha) | 782 mil (18%) | 306 mil (7%) | — | Análise de campanha fica limitada |
  | `geo.city` | — | — | 1,80 mi (42%) | Cidade não serve; usar país |
  | `device.operating_system` | 110 mil (3%) | — | — | `Web` em 2,5 mi (58%): SO não é confiável |
  | `device.web_info.browser` | 114 mil (3%) | — | — | Pouco impacto |
  | `device.category`, `geo.country` | — | — | — | Limpos |

  `<Other>` = valores raros agrupados; `(data deleted)` = apagados; `(not set)` = o GA4 não
  conseguiu identificar.
- **Autorreferência:** `shop.googlemerchandisestore.com` aparece como origem em 366 mil
  eventos. É a própria loja se contando como origem, um problema de configuração de tracking.
- **Não medido:** os mesmos marcadores em `source`/`medium`/`campaign` de `event_params` (a
  query custaria ~1,3 GiB). Medir quando a `stg_events` existir, lendo a staging.
- **`page_referrer`:** aparece em 3,2 milhões de eventos, mas só 1,1 milhão tem valor.
- **`session_engaged`:** vem como texto em 3,68 milhões de eventos e como inteiro em 313 mil.
  É preciso ler os dois tipos.
- **`value`, `tax` e `transaction_id` em `event_params`:** tipo misto. `value` vem como inteiro
  em 1.832 eventos e como decimal em 3.410; `transaction_id` vem como texto em 4.786 e como
  inteiro em 456.
- **`source`/`medium`/`campaign`:** estão em só um terço dos eventos. A origem precisa ser
  atribuída por sessão.
- **`view_item_list`:** 71 eventos contra 31.007 `select_item`. Não dá para calcular o clique
  em listas.
- **`traffic_source`:** guarda a origem da primeira visita do usuário, não a da sessão.
