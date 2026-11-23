-- Query nativa usada no conector Google BigQuery do Power BI (tabela fct_sessions).
-- Fica aqui para versionar a lógica que está dentro do .pbix.
-- Lê ~60 MB por atualização. Depois os apelidos vão para o Dataform.

SELECT
  session_key,
  user_pseudo_id AS id_usuario,
  session_date AS data,
  is_new_user AS usuario_novo,
  channel AS canal,
  session_source AS origem,
  session_medium AS midia,
  device_category AS dispositivo,
  browser AS navegador,
  country AS pais,
  pageviews,
  is_engaged AS sessao_engajada,
  engagement_time_sec AS tempo_engajado_seg,
  has_view_item AS viu_produto,
  has_add_to_cart AS adicionou_carrinho,
  has_begin_checkout AS iniciou_checkout,
  has_purchase AS comprou,
  transactions AS transacoes,
  revenue AS receita
FROM `portfolio-marketing-digital.marts.fct_sessions`
