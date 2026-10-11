# GA4 → BigQuery → Power BI: pipeline de marketing digital

> 🚧 **Em construção.** Acompanhe o progresso no [roadmap](docs/roadmap.md).

Pipeline de dados ponta a ponta sobre dados de e-commerce do Google Analytics 4: extração no
BigQuery, transformação em camadas com Dataform (SQLX) e dashboard em Power BI com
indicadores de aquisição, funil, produtos e retenção.

## Arquitetura

```
GA4 (dataset público)          BigQuery                         Power BI
events_*  ──────────>  staging  ──────>  marts  ──────────>  dashboard
                       (Dataform: limpeza)  (Dataform: agregação)   (modo Import)
```

- **Fonte:** `bigquery-public-data.ga4_obfuscated_sample_ecommerce`, eventos da Google
  Merchandise Store (nov/2020 a jan/2021)
- **Staging:** achata o dado bruto do GA4 (`event_params`, `items`) em colunas tipadas
- **Marts:** tabelas agregadas e prontas para análise (sessões, funil, canais, produtos,
  coortes)
- **Power BI:** lê **apenas as marts**, nunca o dado bruto, o que mantém o custo de consulta
  previsível

## Stack

BigQuery (sandbox) · Dataform CLI (SQLX) · Python · Power BI · Git

## Decisões técnicas

- **Custo sob controle:** toda consulta filtra `_TABLE_SUFFIX` e seleciona só as colunas
  necessárias. Cada query nova passa antes por um *dry run*, que estima os bytes lidos sem
  custo
- **Compatível com o sandbox:** os models usam `table`/`view` (`CREATE OR REPLACE`), sem DML
  nem carga incremental
- **Sem credenciais no código:** a autenticação é feita via Application Default Credentials
  (`gcloud auth application-default login`)

## Estrutura

```
├── docs/
│   └── roadmap.md            # fases e progresso do projeto
└── scripts/
    └── test_connection.py    # teste de conexão com o BigQuery (dry run)
```

## Como rodar

Pré-requisitos: Google Cloud SDK, Python 3.11+ e um projeto GCP com BigQuery.

```powershell
gcloud auth application-default login
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install google-cloud-bigquery pandas db-dtypes
python scripts/test_connection.py
```

Troque o `PROJECT_ID` em `scripts/test_connection.py` pelo ID do seu projeto.

## Licença

[MIT](LICENSE) © 2026 Dante Cavalcante Santos
