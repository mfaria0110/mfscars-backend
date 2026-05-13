const db =
  require("../../shared/database/db")

/* =========================================
   BUSCAR PLANO ATIVO- v1
========================================= */

async function getPlanoAtivo(
  client,
  lojaId
) {

  const result =
    await client.query(`
      SELECT
        lp.*,
        p.nome,
        p.preco,
        p.limite_veiculos
      FROM loja_plano lp
      JOIN plano p
        ON p.id = lp.plano_id
      WHERE
        lp.loja_id = $1
      ORDER BY lp.id DESC
      LIMIT 1
    `, [lojaId])

  return result.rows[0] || null
}

/* =========================================
   VALIDAR LIMITE VEÍCULOS
========================================= */

async function validarLimiteVeiculos(
  client,
  lojaId
) {

  const plano =
    await getPlanoAtivo(
      client,
      lojaId
    )

  if (!plano) {

    throw new Error(
      "Nenhum plano ativo"
    )
  }

  const usados =
    Number(
      plano.usados || 0
    )

  const limite =
    Number(
      plano.limite_veiculos || 0
    )

  if (
    usados >= limite
  ) {

    throw new Error(
      "Limite de veículos atingido"
    )
  }

  return plano
}

/* =========================================
   CONSUMIR VEÍCULO
========================================= */

async function consumirVeiculo(
  client,
  lojaId
) {

  await validarLimiteVeiculos(
    client,
    lojaId
  )

  const result =
    await client.query(`
      UPDATE loja_plano
      SET usados = usados + 1
      WHERE id = (
        SELECT id
        FROM loja_plano
        WHERE
          loja_id = $1
          AND status = 'ativo'
        ORDER BY id DESC
        LIMIT 1
      )
      RETURNING *
    `, [lojaId])

  return result.rows[0]
}

/* =========================================
   LIBERAR VEÍCULO
========================================= */

async function liberarVeiculo(
  client,
  lojaId
) {

  const result =
    await client.query(`
      UPDATE loja_plano
      SET usados = GREATEST(
        usados - 1,
        0
      )
      WHERE id = (
        SELECT id
        FROM loja_plano
        WHERE
          loja_id = $1
          AND status = 'ativo'
        ORDER BY id DESC
        LIMIT 1
      )
      RETURNING *
    `, [lojaId])

  return result.rows[0]
}

/* =========================================
   VALIDAR STATUS
========================================= */
async function validarPlanoAtivo(
  client,
  lojaId
) {

  const plano =
    await getPlanoAtivo(
      client,
      lojaId
    )

  if (!plano) {

    throw new Error(
      "Nenhum plano ativo"
    )
  }

  /* =========================
     STATUS
  ========================= */

  if (
    plano.status !== "ativo"
  ) {

    throw new Error(
      `Plano ${plano.status}`
    )
  }

  /* =========================
     CICLO VENCIDO
  ========================= */

  const vencido =
    await client.query(`
      SELECT NOW() > $1 AS vencido
    `, [plano.ciclo_fim])

  if (
    vencido.rows[0].vencido
  ) {

    throw new Error(
      "Plano vencido"
    )
  }

  return plano
}


module.exports = {

  getPlanoAtivo,

  validarLimiteVeiculos,

  consumirVeiculo,

  liberarVeiculo,

  validarPlanoAtivo
}