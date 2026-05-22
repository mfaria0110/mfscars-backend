const db = require("../../config/db")

exports.buscarPorLoja = async (
  lojaId
) => {

  const res = await db.query(
    `
    SELECT *
    FROM loja_clausula
    WHERE loja_id = $1
    LIMIT 1
    `,
    [lojaId]
  )

  return res.rows[0]
}

exports.salvar = async (
  dados
) => {

  const res = await db.query(
    `
    INSERT INTO loja_clausula (

      empresa_id,
      loja_id,

      clausulas,
      garantia,
      transferencia

    )

    VALUES ($1,$2,$3,$4,$5)

    ON CONFLICT (loja_id)

    DO UPDATE SET

      clausulas =
        EXCLUDED.clausulas,

      garantia =
        EXCLUDED.garantia,

      transferencia =
        EXCLUDED.transferencia,

      updated_at = NOW()

    RETURNING *
    `,
    [

      dados.empresa_id,
      dados.loja_id,

      dados.clausulas,
      dados.garantia,
      dados.transferencia
    ]
  )

  return res.rows[0]
}