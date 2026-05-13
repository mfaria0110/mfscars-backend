module.exports = function buildQueryComLoja({
  baseQuery,
  lojaId,
  params = [],
  alias = null // opcional: alias da tabela (ex: "u", "v")
}) {

  if (!lojaId) {
    throw new Error("Loja é obrigatória")
  }

  const campo = alias
    ? `${alias}.loja_id`
    : `loja_id`

  const index = params.length + 1

  const query = `
    ${baseQuery}
    WHERE ${campo} = $${index}
  `

  return {
    query,
    params: [...params, lojaId]
  }
}