# Marketing Digital — Pipeline GA4 → BigQuery → Dashboard

Projeto de portfólio de dados do Dante Cavalcante Santos. Este chat é **exclusivamente
técnico**: estratégia de cliente, precificação e plataformas de freelance ficam em outra
conversa. Não traga esses assuntos aqui.

## Quem sou

Insight Data Analyst Junior na Galeria (agência, São Paulo) desde fevereiro de 2026. Trabalho
com pipelines em GCP e ETL sobre bases consolidadas de clientes. Antes: BI Analyst na TruckPad
e analista de dados na Mais Diversidade. Formação em Data Science pela Uninove, 2026.

Stack: Python, SQL, BigQuery, Dataform (SQLX), GCP, Firebase, Power BI, Excel/VBA. Front-end
eu conheço, mas é conhecimento antigo. Inglês conversacional.

## O projeto

Dashboard de marketing digital construído com dados públicos. É o mesmo domínio em que atuo
profissionalmente, mas **sem usar nenhum dado, conta ou taxonomia da Galeria**. Regra fixa,
não se discute. Quando eu citar a Galeria, é só como referência de **método** ("lá a gente
puxa o repositório de SQLX e trabalha localmente"). Não é pedido para trazer nada de lá.

**Objetivo:** peça de portfólio que demonstre pipeline de dados ponta a ponta, não só um
dashboard bonito.

### Plano (blocos de uma noite)

1. venv + teste de conexão em Python (com dry run)
2. `.gitignore` + primeiro commit + repositório no GitHub (`gh` já está logado como
   `DanteCavalcanteSantos`; o push só sai com o meu aval)
3. Entender os dados: schema primeiro (grátis), depois dry run para medir o tamanho
4. Dataform: SQLX escritos aqui, num repositório próprio, editados localmente no VS Code
   e rodados pelo Dataform CLI (`npm i -g @dataform/cli`). Camadas `staging` → `marts`
5. Power BI conectado **só às marts**, em modo Import

Decisões técnicas já tomadas:

- **O Power BI nunca lê a `events_*` direto.** Cada atualização ou clique viraria consulta
  no dado bruto.
- **Dataform no sandbox: só `type: "table"` ou `"view"`.** O modo incremental usa `MERGE` e
  `INSERT`, que são DML. As tabelas expiram em 60 dias; rodar o Dataform de novo recria tudo.
- **Credencial do Dataform CLI** (`.df-credentials.json`) entra no `.gitignore`.

### Ambiente

- Pasta local: `C:\Users\dante\Projetos\marketing-digital`. **Fora do OneDrive de
  propósito:** Git dentro do OneDrive corrompe o repositório.
- Projeto GCP pessoal, BigQuery em modo **sandbox**. **ID do projeto:**
  `portfolio-marketing-digital` (conferido via API em 08/10/2026). O `marketing-digital-510723`
  anotado no `anotacoes.md` **não existe** na conta: era só uma sugestão da tela de criação.
- Fonte: `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
- Windows, VS Code, Python, Node.js, PostgreSQL 17 local, SQL Server Express local
  (`DANTE\SQLEXPRESS`), Power BI Desktop
- Google Cloud SDK 588.0.0 instalado em modo usuário
  (`%LOCALAPPDATA%\Google\Cloud SDK`), já com `bq` e `gsutil`

### Limites do sandbox — respeitar sempre

- 1 TiB de consulta por mês e 10 GiB de armazenamento
- Tabelas, views e partições expiram em 60 dias
- **DML não funciona:** nada de `INSERT`, `UPDATE` ou `DELETE`. Usar
  `CREATE OR REPLACE TABLE ... AS SELECT`
- Sem streaming, sem Data Transfer Service e sem scheduled queries
- A cobrança é por coluna lida, não por linha devolvida: `SELECT *` sai caro e `LIMIT` não
  reduz nada
- **Toda query no dataset GA4 precisa filtrar `_TABLE_SUFFIX`.** Sem isso, o wildcard varre o
  dataset inteiro

## Como trabalhar comigo

- **Respostas curtas e diretas.** Sem preâmbulo, sem repetir a pergunta, sem encher de
  ressalvas.
- **Sempre resumir.** Resposta longa só quando eu perguntar sobre assunto técnico.
- **Um passo por vez.** Dar a próxima ação concreta, esperar eu executar e reportar. Não
  despejar dez etapas de uma vez.
- **Me corrigir.** Query cara, modelagem ruim ou padrão que não escala: dizer na hora. Não
  concordar para ser agradável.
- **Explicar o porquê quando o conceito for novo.** Comando eu copio, mas conceito eu preciso
  entender para repetir sozinho depois. Quando eu disser que não entendi um termo, explicar
  sem jargão.
- **Antes de sugerir uma query**, estimar se ela cabe no sandbox e informar a ordem de
  grandeza esperada.
- **Não inventar estado.** Se não souber se algo já foi feito, perguntar.
- **Ao abrir uma sessão nova:** ler o *Histórico* abaixo e o `docs/roadmap.md`, e perguntar
  onde eu parei antes de sugerir qualquer coisa.

## Rotina — considerar ao estimar esforço

Trabalho de segunda a sexta, das 9h às 18h30, em regime híbrido. Levanto às 4h30 e treino
antes do trabalho. Estudo à noite, 30 a 40 minutos por sessão, que é o meu limite real de
foco. O projeto avança principalmente no fim de semana.

Não propor tarefa que exija quatro horas seguidas de concentração. Quebrar em blocos que
cabem numa noite.

## Convenções

- Código em inglês, conversa e documentação em português
- Commits em [Conventional Commits](https://www.conventionalcommits.org/pt-br/), em
  português: `<tipo>(<escopo>): <descrição no imperativo, minúscula, sem ponto final>`
- **Sem rodapé de atribuição nos commits.** Nada de `Co-Authored-By: Claude`.
- Nada de credencial, chave JSON ou `.env` versionado
- Autenticação via `gcloud auth application-default login`, não service account
- Pedir confirmação antes de `git push` ou de qualquer ação que saia da máquina

## Documentação do projeto

- [docs/roadmap.md](docs/roadmap.md): **to-do do projeto inteiro, por fases.** É a fonte
  do "próximo passo": ao abrir uma sessão, ler o roadmap e o Histórico. Marcar `[x]` ao
  concluir cada item.
- [docs/estudos/setup-bigquery.md](docs/estudos/setup-bigquery.md): passo a passo da
  conexão com o BigQuery (gcloud, ADC, projeto, venv), limites do sandbox e do free tier, o
  que muda em projeto de cliente e a cola de Git. Atualizar sempre que uma configuração nova
  for feita.
- `docs/estudos/` é **pessoal e está no `.gitignore`**: anotações de estudo, `anotacoes.md`.
  O que é documentação técnica do projeto fica em `docs/` e vai para o repositório.

## Templates para clientes

Objetivo: uma pasta `templates/` neste repositório com bases genéricas para reaproveitar em
projetos vendidos (dashboards e pipelines), sem refazer tudo do zero. Aqui entra só a parte
**técnica**. Precificação e estratégia comercial ficam na outra conversa.

**Princípio: extrair, não antecipar.** O template sai do projeto concreto **depois** que ele
funcionar (Fase 10 do roadmap). Template escrito antes do caso real vira abstração errada.
Durante o projeto, escrever o código já pensando em reaproveitamento:

- **Nada fixo no código:** projeto, dataset, datas e moeda viram variáveis (`vars` no
  Dataform, parâmetros no Power BI, constantes no topo do script Python)
- **O schema do export GA4 é o mesmo em qualquer propriedade.** Logo, a staging é 100%
  reaproveitável, e no cliente só muda o caminho `projeto.analytics_XXXXX.events_*`. As marts
  dependem das perguntas de negócio e vão precisar de ajuste
- **Power BI:** salvar como `.pbit` (template) com parâmetros de projeto e dataset. O cliente
  abre, informa os parâmetros e o modelo carrega
- **Docs reaproveitáveis:** README modelo, checklist de setup do cliente (acessos IAM, quem
  paga, conforme a seção 7 do setup), dicionário de dados e perguntas de negócio

Estrutura prevista:

```
templates/
├── dataform-ga4/   # staging + marts parametrizados
├── powerbi/        # .pbit + guia de medidas
├── python/         # teste de conexão e utilitários
└── docs/           # README, checklist do cliente, dicionário
```

Regras: nenhum dado, ID ou nome de cliente real nos templates, e nada da Galeria. No
sandbox, só `table`/`view`. A versão incremental fica documentada como opção para cliente
com faturamento ativo.

## Armadilhas já descobertas

- **O VS Code precisa estar aberto em `C:\Users\dante\Projetos\marketing-digital`.** Se
  estiver na pasta antiga do OneDrive, o Explorer não mostra o `CLAUDE.md` nem o `docs/`, e o
  Claude não carrega este arquivo.

- **A máquina tem dois usuários do Windows: o pessoal e o da Galeria.** Desconsiderar tudo
  que está no usuário da Galeria (`C:\Users\Dante Santos Galeria\...`), inclusive o
  Python 3.11 de lá.
- **O `python` do PATH é o Anaconda 3.9 (sem suporte desde out/2025).** O venv do projeto
  usa o Python 3.14 instalado pelo `uv`: `py -V:Astral/CPython3.14.7 -m venv .venv`.
- **PATH só atualiza depois de reiniciar o VS Code inteiro.** Abrir terminal novo não basta,
  porque ele herda o ambiente do processo do VS Code. Paliativo para a sessão atual:
  `$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')`
- **O instalador do gcloud não pede administrador.** Ele instala em modo usuário. Se a
  solicitação não aparecer, a instalação não está travada.
- **A página "Agora você está autenticado" não garante o login.** Se o escopo
  `cloud-platform` ficar desmarcado na tela de consentimento, o terminal dá erro e não salva
  a credencial. O que vale é o terminal mostrar `Credentials saved to file`.
- **O erro "serviceusage.services.use" no `set-quota-project`** apareceu porque o ID do
  projeto estava errado, não por falta de permissão.

## Histórico

### 08/10/2026 — setup do ambiente

- Pasta criada fora do OneDrive. Um `git init` feito por engano dentro do OneDrive foi
  desfeito antes de qualquer commit.
- `git init -b main` em `C:\Users\dante\Projetos\marketing-digital`. Ainda sem commits.
- `anotacoes.md` movido para cá. **O ID anotado nele (`marketing-digital-510723`) está
  errado**: o ID real é `portfolio-marketing-digital`.
- Google Cloud SDK 588.0.0 instalado via `winget install --id Google.CloudSDK -e`.
- `gcloud auth application-default login` concluído com `dante.cavalcante96@gmail.com`.
  Na primeira tentativa, o escopo `cloud-platform` ficou desmarcado e a credencial não foi
  salva, mesmo com o navegador mostrando "sucesso".
- `gcloud config set project` e `set-quota-project` apontam para
  `portfolio-marketing-digital`. Conferido.

### 09–11/10/2026 — decisão de pasta

- Discutido mover o projeto para o OneDrive (onde estão os outros projetos do Dante).
  **Decisão: fica em `C:\Users\dante\Projetos\marketing-digital`**, no SSD (C:). O HD (D:)
  fica para arquivos grandes e parados.
- A pasta `OneDrive\...\9. Meus Projetos\Marketing Digital` **não é o projeto**. Ela só
  tem um `anotacoes.md` criado pelo Dante e não deve receber código.
- O computador reiniciou: a credencial ADC sobreviveu (conferido em 11/10). Não precisa
  refazer o login após reinício.
- Ainda não foi decidido se este projeto **substitui** o `3.4.2.3 Marketing`
  (`Dashboard_Marketing_Dante`, dado sintético) ou entra como projeto novo no portfólio.

### 11/10/2026 — venv e repositório

- venv `.venv` criado com Python 3.14.7 (uv). Pacotes: google-cloud-bigquery 3.46.1,
  pandas 3.0.6, db-dtypes 1.7.2.
- Repositório criado vazio no GitHub: `DanteCavalcanteSantos/ga4-bigquery-marketing-pipeline`
  (público). Ainda sem remote local e sem commits.
- Decidido: `CLAUDE.md` **entra** no repositório. Licença MIT, `.gitignore` e README serão
  criados localmente e entram no primeiro commit.

- Teste de conexão (`scripts/test_connection.py`, dry run) OK: 0,32 MiB para um dia de
  `event_name`.
- Remote `origin` configurado.

- `.gitignore`, `LICENSE` (MIT), `README.md` e `docs/roadmap.md` criados. Primeiro commit
  e push para o GitHub.
- `docs/estudos/` (inclusive o `setup-bigquery.md`) fica fora do Git **por decisão do Dante**:
  é material de estudo pessoal.

**Próximo passo:** Fase 2 do roadmap (entender os dados).

### (antigo) Próximo passo de 08–11/10: criar o venv e instalar os pacotes. O Dante ainda não rodou nenhum
destes comandos:

```powershell
cd C:\Users\dante\Projetos\marketing-digital
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install google-cloud-bigquery pandas db-dtypes
```

Se o `Activate.ps1` for bloqueado: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.

**Pendente depois disso:** testar a conexão via Python, criar o `.gitignore` (`.venv`,
`.env`, credenciais) e fazer o primeiro commit. Depois: modelagem e dashboard.
