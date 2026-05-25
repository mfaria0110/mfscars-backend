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

  /* =========================
     ILIMITADO
  ========================= */

  if (
    plano.limite_veiculos === null
  ) {

    return plano
  }

  /* =========================
     VEÍCULOS ATIVOS
  ========================= */

  const ativos =
    await client.query(`

      SELECT
        COUNT(*)::INTEGER AS total

      FROM veiculo

      WHERE
        loja_id = $1
        AND LOWER(status) IN (
          'disponivel',
          'reservado'
        )

    `, [lojaId])

  const ativosTotal =
    Number(
      ativos.rows[0].total || 0
    )

  /* =========================
     VENDIDOS CICLO
  ========================= */

  const vendidosCiclo =
    Number(
      plano.vendidos_ciclo || 0
    )

  /* =========================
     TOTAL CONSUMIDO
  ========================= */

  const consumidos =
    ativosTotal +
    vendidosCiclo

  const limite =
    Number(
      plano.limite_veiculos || 0
    )


  console.log({
    ativosTotal,
    vendidosCiclo,
    consumidos,
    limite
  })

  if (
    consumidos >= limite
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
     SOMA LIMITES DOS PLANOS
  ========================= */

  const limites =
    await client.query(`

      SELECT

        COALESCE(
          SUM(p.limite_lojas),
          0
        )::INTEGER AS limite_total

      FROM loja_plano lp

      JOIN plano p
        ON p.id = lp.plano_id

      JOIN loja l
        ON l.id = lp.loja_id

      WHERE
        l.empresa_id = $1
        AND lp.status = 'ativo'

    `, [empresaId])


    const limiteBruto =
      limites.rows[0]
        ?.limite_total

    if (limiteBruto === null) {

      return true
    }

    const limite =
      Number(limiteBruto || 0)


  /* =========================
     TOTAL LOJAS EMPRESA
  ========================= */

  const total =
    await client.query(`

      SELECT
        COUNT(*)::INTEGER AS total

      FROM loja

      WHERE empresa_id = $1

    `, [empresaId])

  const usados =
    Number(
      total.rows[0]
        ?.total || 0
    )

  /* =========================
     VALIDAÇÃO
  ========================= */

  if (
    usados >= limite
  ) {

    throw new Error(
      "Limite de lojas atingido"
    )
  }

  return true
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

  return await validarLimiteVeiculos(
    client,
    lojaId
  )
}

/* =========================================
   LIBERAR VEÍCULO
========================================= */

async function liberarVeiculo() {

  return true
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