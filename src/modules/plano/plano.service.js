const db =
  require("../../shared/database/db")

/* =========================================
   BUSCAR PLANO ATIVO
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

        p.limite_veiculos,
        p.limite_lojas,
        p.limite_vendedores

      FROM loja_plano lp

      JOIN plano p
        ON p.id = lp.plano_id

      WHERE
        lp.loja_id = $1
        AND lp.status = 'ativo'

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
   VALIDAR LIMITE LOJAS
========================================= */

async function validarLimiteLojas(
  client,
  empresaId
) {

  /* =========================
     LOJA PRINCIPAL
  ========================= */

  const lojaPrincipal =
    await client.query(`

      SELECT id

      FROM loja

      WHERE empresa_id = $1

      ORDER BY id ASC

      LIMIT 1

    `, [empresaId])

  if (
    !lojaPrincipal.rows.length
  ) {

    throw new Error(
      "Empresa sem loja"
    )
  }

  const lojaId =
    lojaPrincipal.rows[0].id

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
     ILIMITADO
  ========================= */

  if (
    plano.limite_lojas === null
  ) {

    return plano
  }

  const total =
    await client.query(`

      SELECT
        COUNT(*)::INTEGER AS total

      FROM loja

      WHERE empresa_id = $1

    `, [empresaId])

  const usados =
    Number(
      total.rows[0].total || 0
    )

  const limite =
    Number(
      plano.limite_lojas || 0
    )

  if (
    usados >= limite
  ) {

    throw new Error(
      "Limite de lojas atingido"
    )
  }

  return plano
}

/* =========================================
   VALIDAR LIMITE VENDEDORES
========================================= */

async function validarLimiteVendedores(
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
     ILIMITADO
  ========================= */

  if (
    plano.limite_vendedores === null
  ) {

    return plano
  }

  const total =
    await client.query(`

      SELECT
        COUNT(*)::INTEGER AS total

      FROM usuario

      WHERE
        loja_id = $1
        AND master = false

    `, [lojaId])

  const usados =
    Number(
      total.rows[0].total || 0
    )

  const limite =
    Number(
      plano.limite_vendedores || 0
    )

  if (
    usados >= limite
  ) {

    throw new Error(
      "Limite de vendedores atingido"
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

  validarLimiteLojas,

  validarLimiteVendedores,

  consumirVeiculo,

  liberarVeiculo,

  validarPlanoAtivo
}