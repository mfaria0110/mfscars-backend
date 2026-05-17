const db =
  require(
    "../../shared/database/db"
  )

/* =========================
   RESUMO
========================= */

async function getResumo() {

  const result =
    await db.query(`

      SELECT

        COALESCE(
          SUM(valor)
          FILTER (
            WHERE status = 'pago'
          ),
          0
        ) AS faturamento_total,

        COALESCE(
          SUM(valor)
          FILTER (
            WHERE status = 'pago'
            AND DATE_TRUNC(
              'month',
              criado_em
            ) = DATE_TRUNC(
              'month',
              NOW()
            )
          ),
          0
        ) AS faturamento_mes,

        COUNT(*)
          FILTER (
            WHERE status = 'pago'
            AND DATE(criado_em) = CURRENT_DATE
          ) AS pagamentos_hoje,

        COUNT(*)
          FILTER (
            WHERE status = 'pendente'
          ) AS pix_pendentes

      FROM loja_cobranca

    `)

  return result.rows[0]
}

/* =========================
   COBRANÇAS
========================= */

async function getCobrancas() {

  const result =
    await db.query(`

      SELECT

        c.id,

        l.nome AS loja,

        p.nome AS plano,

        c.valor,

        c.status,

        c.gateway,

        c.criado_em

      FROM loja_cobranca c

      LEFT JOIN loja_plano lp
        ON lp.id = c.loja_plano_id

      LEFT JOIN loja l
        ON l.id = lp.loja_id

      LEFT JOIN plano p
        ON p.id = lp.plano_id

      ORDER BY c.id DESC

      LIMIT 100

    `)

  return result.rows
}

module.exports = {

  getResumo,

  getCobrancas
}