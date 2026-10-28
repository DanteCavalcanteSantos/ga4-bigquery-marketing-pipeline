# Roadmap

Cada item cabe numa sessão de 30 a 40 minutos. Marque `[x]` ao concluir.

**Fonte:** `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`, dados da loja
Google Merchandise Store de 01/11/2020 a 31/01/2021.

## Fase 0 — Ambiente

- [x] gcloud instalado e ADC autenticado
- [x] Projeto `portfolio-marketing-digital` configurado (projeto e quota project)
- [x] venv com Python 3.14 e pacotes instalados
- [x] Repositório criado no GitHub e `origin` configurado
- [x] Teste de conexão com dry run (`scripts/test_connection.py`)
- [x] `.gitignore`

## Fase 1 — Primeiro commit

- [x] `LICENSE` (MIT)
- [x] `README.md` inicial: o que é o projeto, a stack e o status "em construção"
- [x] Primeiro commit e push (`git push -u origin main`)

## Fase 2 — Entender os dados

- [x] Ler o schema (grátis): `event_params`, `user_properties`, `items`, `traffic_source`,
      `device`, `geo`, `ecommerce`. Feito pelo Python em `notebooks/01_explore_ga4.ipynb`
- [x] Dry run do período inteiro com as colunas que vamos usar e anotar o tamanho: rascunho da
      `stg_events` = 1,68 GiB por execução (~1,3 GiB só do `event_params`)
- [x] Listar os `event_name` e a contagem de cada um (base do funil): 17 eventos, 53,4 MiB
      para os 92 dias
- [x] Mapear as chaves de `event_params` que interessam (`ga_session_id`, `page_location`,
      `source`, `medium`, `campaign` etc.): 34 etiquetas, 16 escolhidas, 1,31 GiB
- [x] Dicionário de dados em `docs/dicionario-dados.md`
- [x] Anotar as limitações do dataset (ofuscação, valores `<Other>`, `(data deleted)`)

## Fase 3 — Perguntas de negócio

Definir **o que** o dashboard responde antes de modelar.

- [x] Escrever as perguntas em `docs/perguntas-negocio.md`. Ponto de partida:
  - Quais canais (source/medium) trazem mais sessões, conversões e receita?
  - Onde o funil vaza? (`view_item` → `add_to_cart` → `begin_checkout` → `purchase`)
  - Quais produtos e categorias vendem mais? Quais são vistos mas não comprados?
  - Desktop × mobile: a conversão muda?
  - Quais países geram mais receita?
  - Usuários novos × recorrentes, e retenção por coorte de primeira visita
- [x] Definir os KPIs com a fórmula de cada um: sessões, usuários, taxa de conversão, receita,
      ticket médio, receita por sessão

## Fase 4 — Dataform: setup

- [x] `npm i -g @dataform/cli` e conferir com `dataform --version` (3.1.2)
- [x] Decidir a estrutura: projeto Dataform na pasta `dataform/` deste repositório
- [x] `dataform init` e configurar o `workflow_settings.yaml` (projeto, dataset e localização `US`)
- [x] `.df-credentials.json` via `dataform init-creds` (já está no `.gitignore`)
- [ ] Primeiro `dataform compile` e `dataform run` com uma view simples

## Fase 5 — Camada staging

Limpar e achatar o dado bruto, sem regra de negócio. Uma linha por evento.

- [ ] Variáveis de período (`start_date`, `end_date`) para filtrar `_TABLE_SUFFIX`
- [ ] `stg_events`: colunas tipadas, `event_params` extraídos, `event_timestamp` em datetime
- [ ] `stg_items`: `UNNEST(items)`, uma linha por item por evento
- [ ] Dry run de cada model antes de rodar
- [ ] Perfil da `stg_events` (lendo a staging, não a bronze): nulos por coluna, tipos, valores
      fora do padrão e outliers de receita e quantidade

## Fase 6 — Camada marts

Tabelas prontas para o Power BI, já agregadas.

- [ ] `fct_sessions`: uma linha por sessão (`user_pseudo_id` + `ga_session_id`), com canal,
      dispositivo, país, se converteu e receita
- [ ] `fct_purchases`: uma linha por transação
- [ ] `mart_funnel_daily`: etapas do funil por dia e canal
- [ ] `mart_channel_daily`: sessões, conversões e receita por canal e dia
- [ ] `mart_product_daily`: visualizações, adições ao carrinho e compras por produto
- [ ] `mart_cohort`: retenção por coorte de primeira visita
- [ ] Assertions (testes do Dataform): unicidade, não nulo, receita ≥ 0
- [ ] Rodar o pipeline inteiro e anotar o custo total de uma execução

## Fase 7 — Power BI

- [ ] Conectar às marts em modo Import (nunca na `events_*`)
- [ ] Modelo estrela: fatos + dimensão calendário + dimensões de canal, produto e país
- [ ] Medidas DAX dos KPIs da Fase 3
- [ ] Página 1: visão geral (KPIs e tendência)
- [ ] Página 2: aquisição (canais)
- [ ] Página 3: funil
- [ ] Página 4: produtos
- [ ] Página 5: retenção e coortes
- [ ] Revisão visual: cores, títulos e tooltips

## Fase 8 — Insights

- [ ] Responder às perguntas da Fase 3 com os números e registrar em `docs/insights.md`
- [ ] Três a cinco recomendações acionáveis (o que um gestor de marketing faria com isso)

## Fase 9 — Portfólio

- [ ] README final: diagrama da arquitetura, decisões técnicas, custo do pipeline e prints
- [ ] Exportar o dashboard em PDF e prints para o README
- [ ] Decidir se o `.pbix` entra no repositório (tamanho) ou só os prints e o `.pbit`
- [ ] Decidir se substitui o `Dashboard_Marketing_Dante` no portfólio
- [ ] Post no LinkedIn

## Fase 10 — Templates

Extrair o que funcionou para `templates/`. Ver a seção *Templates* do `CLAUDE.md`.

- [ ] `templates/dataform-ga4/`: staging e marts parametrizados por variáveis
- [ ] `templates/powerbi/`: `.pbit` com parâmetros de projeto e dataset
- [ ] `templates/docs/`: README, checklist de setup do cliente e dicionário de dados
- [ ] `templates/python/`: teste de conexão parametrizado
- [ ] Testar o template do zero num dataset novo
