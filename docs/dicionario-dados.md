# Dicionário de dados

> Em construção (Fase 2). Fonte:
> `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`, de 01/11/2020 a
> 31/01/2021: 92 tabelas, uma por dia, com cerca de 4,3 milhões de eventos.

## Grão

Uma linha = um evento. Uma visita (sessão) gera várias linhas.

## Eventos (`event_name`)

| Grupo | Eventos | Uso |
|---|---|---|
| Automáticos | `session_start`, `first_visit`, `user_engagement`, `scroll`, `page_view` | Visita e navegação |
| Impressão (visualização) | `view_item`, `view_promotion`, `view_item_list`, `view_search_results` | Exposição a produto, banner, lista e busca |
| Clique | `select_item`, `select_promotion`, `click` | Interesse |
| Funil de compra | `add_to_cart` → `begin_checkout` → `add_shipping_info` → `add_payment_info` → `purchase` | Conversão |

## Etiquetas de `event_params` usadas na staging

| Etiqueta | Gaveta (tipo) | Em português | Para quê |
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

Descartadas: `gclid`, `gclsrc`, `dclid` e `all_data` (vazias pela ofuscação), `debug_mode` e
`clean_event` (técnicas), `link_*` e `outbound` (só eventos `click`, fora das perguntas).

Pendente: conferir as etiquetas das linhas 24 a 29 da contagem.

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
- **`page_referrer`:** aparece em 3,2 milhões de eventos, mas só 1,1 milhão tem valor.
- **`session_engaged`:** vem como texto em 3,68 milhões de eventos e como inteiro em 313 mil.
  É preciso ler as duas gavetas.
- **`source`/`medium`/`campaign`:** estão em só um terço dos eventos. A origem precisa ser
  atribuída por sessão.
- **`view_item_list`:** 71 eventos contra 31.007 `select_item`. Não dá para calcular o clique
  em listas.
- **`traffic_source`:** guarda a origem da primeira visita do usuário, não a da sessão.
