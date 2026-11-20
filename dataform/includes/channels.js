// Agrupamento de canais a partir do medium da sessão.
// Reaproveitável em qualquer propriedade GA4: ajuste os CASE ao padrão de UTM do cliente.
function channelGroup(mediumColumn) {
  return `
    CASE
      WHEN ${mediumColumn} = 'organic' THEN 'Busca orgânica'
      WHEN ${mediumColumn} = 'cpc' THEN 'Busca paga'
      WHEN ${mediumColumn} = 'referral' THEN 'Referência'
      WHEN ${mediumColumn} = '(none)' THEN 'Direto'
      WHEN ${mediumColumn} = 'affiliate' THEN 'Afiliados'
      WHEN ${mediumColumn} = 'email' THEN 'E-mail'
      ELSE 'Não identificado'
    END`;
}

module.exports = { channelGroup };
