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

async function getCobrancas(filtros = {}) {

  const {

    page = 1,

    limit = 20,

    status = null,

    loja = null,

    plano = null,

    dataInicio = null,

    dataFim = null

  } = filtros

  const offset =
    (page - 1) * limit

  const params = [

    status,

    loja,

    plano,

    dataInicio,

    dataFim,

    limit,

    offset

  ]

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

      WHERE

        ($1::text IS NULL OR c.status = $1)

      AND

        ($2::int IS NULL OR l.id = $2)

      AND

        ($3::int IS NULL OR p.id = $3)

      AND

        (
          $4::date IS NULL
          OR DATE(c.criado_em) >= $4
        )

      AND

        (
          $5::date IS NULL
          OR DATE(c.criado_em) <= $5
        )

      ORDER BY c.id DESC

      LIMIT $6
      OFFSET $7

    `, params)

  /* =========================
     TOTAL
  ========================= */

  const totalResult =
    await db.query(`

      SELECT COUNT(*)::int AS total

      FROM loja_cobranca c

      LEFT JOIN loja_plano lp
        ON lp.id = c.loja_plano_id

      LEFT JOIN loja l
        ON l.id = lp.loja_id

      LEFT JOIN plano p
        ON p.id = lp.plano_id

      WHERE

        ($1::text IS NULL OR c.status = $1)

      AND

        ($2::int IS NULL OR l.id = $2)

      AND

        ($3::int IS NULL OR p.id = $3)

      AND

        (
          $4::date IS NULL
          OR DATE(c.criado_em) >= $4
        )

      AND

        (
          $5::date IS NULL
          OR DATE(c.criado_em) <= $5
        )

    `, [

      status,

      loja,

      plano,

      dataInicio,

      dataFim

    ])

  const total =
    totalResult.rows[0].total

  return {

    items:
      result.rows,

    total,

    page,

    pages:
      Math.ceil(
        total / limit
      )
  }
}

module.exports = {

  getResumo,

  getCobrancas
}