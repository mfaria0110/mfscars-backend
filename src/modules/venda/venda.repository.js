const db = require("../../shared/database/db");

/* ===============================
   TRANSACTION - CRIAR VENDA
================================ */
async function criarVendaComTransacao(
  empresaId,
  lojaId,
  dados
) {
  const client = await db.connect()

  try {
    await client.query("BEGIN")

    const veiculoRes =
      await client.query(
        `
        SELECT id, empresa_id, loja_id, status
        FROM veiculo
        WHERE id = $1
        FOR UPDATE
        `,
        [dados.veiculo_id]
      )

    if (!veiculoRes.rows.length) {
      throw new Error(
        "Veículo não encontrado"
      )
    }

    const v =
      veiculoRes.rows[0]

    /* valida empresa */
    if (
      empresaId &&
      Number(v.empresa_id) !==
        Number(empresaId)
    ) {
      throw new Error(
        "Veículo não pertence à sua empresa"
      )
    }

    /* valida loja */
    if (
      lojaId &&
      Number(v.loja_id) !==
        Number(lojaId)
    ) {
      throw new Error(
        "Veículo não pertence à sua loja"
      )
    }

    if (
      v.status === "vendido"
    ) {
      throw new Error(
        "Este veículo já foi vendido"
      )
    }

    const valorVenda =
      Number(dados.valor_venda) || 0
    const valorEntrada =
      Number(dados.valor_entrada) || 0
    const valorParcela =
      Number(dados.valor_parcela) || 0

    const vendaRes =
      await client.query(
        `
        INSERT INTO venda (
          empresa_id,
          loja_id,
          veiculo_id,
          data_venda,
          nome_comprador,
          cpf_comprador,
          telefone_comprador,
          condicao_pagamento,
          parcelas,
          banco_financiamento,
          valor_venda,
          valor_entrada,
          valor_parcela,
          observacoes,
          status,
          vendedor,
          rg_comprador,
          estado,
          cidade,
          bairro,
          endereco,
          numero,
          complemento,
          cep,
          email,
          profissao,
          data_nasc,
          renda
        )
          VALUES (
            $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,
            $11,$12,$13,$14,$15,$16,$17,$18,
            $19,$20,$21,$22,$23,$24,$25,$26,$27,$28
          )
        RETURNING *
        `,
    [
  v.empresa_id,
  v.loja_id,
  dados.veiculo_id,
  dados.data_venda || new Date(),
  dados.nome_comprador,
  dados.cpf_comprador || null,
  dados.telefone_comprador || null,
  dados.condicao_pagamento,
  dados.parcelas || null,
  dados.banco_financiamento || null,
  valorVenda,
  valorEntrada,
  valorParcela,
  dados.observacoes || null,
  "FINALIZADA",
  dados.vendedor || null,
  dados.rg_comprador || null,
  dados.estado || null,
  dados.cidade || null,
  dados.bairro || null,
  dados.endereco || null,
  dados.numero || null,
  dados.complemento || null,
  dados.cep || null,
  dados.email || null,
  dados.profissao || null,
  dados.data_nasc || null,
  dados.renda || null
]
      )

const vendaCriada = vendaRes.rows[0]

if (
  dados.veiculos_entrada &&
  dados.veiculos_entrada.length
) {
 for (const entrada of dados.veiculos_entrada) {

  const valorEntrada =
    Number(entrada.valor_entrada) || 0

  if (valorEntrada <= 0) {
    throw new Error(
      "Veículo de entrada precisa ter valor"
    )
  }

  await client.query(
      `
      INSERT INTO venda_entrada (
        venda_id,
        empresa_id,
        loja_id,
        marca,
        modelo,
        tipo,
        ano_modelo,
        renavam,
        chassi,
        placa,
        cor,
        numero_motor,
        combustivel,
        potencia,
        km,
        valor_entrada
      )
      VALUES (
        $1,$2,$3,$4,$5,$6,$7,$8,
        $9,$10,$11,$12,$13,$14,$15,$16
      )
      `,
      [
        vendaCriada.id,
        v.empresa_id,
        v.loja_id,

        entrada.marca,
        entrada.modelo,
        entrada.tipo,
        entrada.ano_modelo,
        entrada.renavam,
        entrada.chassi,
        entrada.placa,
        entrada.cor,
        entrada.numero_motor,
        entrada.combustivel,
        entrada.potencia,
        entrada.km,
        entrada.valor_entrada
      ]
    )
  }
}

    await client.query(`
      UPDATE veiculo
      SET status='vendido'
      WHERE id=$1
    `, [
      dados.veiculo_id
    ])

    await client.query(
      "COMMIT"
    )

    return vendaRes.rows[0]

  } catch (e) {
    await client.query(
      "ROLLBACK"
    )
    throw e

  } finally {
    client.release()
  }
}

/* ===============================
   LISTAR
================================ */
async function listar(
  empresaId,
  lojaId
) {
  const valores = []
  let where = []

  if (empresaId) {
    valores.push(empresaId)

    where.push(
      `v.empresa_id = $${valores.length}`
    )
  }

  // só filtra loja se realmente existir
  if (
    lojaId !== undefined &&
    lojaId !== null &&
    lojaId !== ""
  ) {
    valores.push(Number(lojaId))

    where.push(
      `v.loja_id = $${valores.length}`
    )
  }

  const whereSql =
    where.length > 0
      ? `WHERE ${where.join(" AND ")}`
      : ""

  const r = await db.query(
    `
    SELECT
      v.*,
      ve.id AS veiculo_id,
      ve.marca,
      ve.modelo,
      ve.placa,
      ve.ano_modelo,
      ve.cor,
      ve.chassi,
      ve.renavam

    FROM venda v
    JOIN veiculo ve
      ON ve.id = v.veiculo_id

    ${whereSql}

    ORDER BY v.data_venda DESC
    `,
    valores
  )

  return r.rows
}

/* ===============================
   DETALHES
================================ */
async function detalhes(
  id,
  empresaId,
  lojaId
) {
  let query = `
  SELECT
    v.*,

    ve.marca,
    ve.modelo,
    ve.placa,
    ve.ano_modelo,
    ve.cor

  FROM venda v

  JOIN veiculo ve
    ON ve.id = v.veiculo_id

  WHERE v.id = $1
`

  const params = [id]

  if (empresaId) {
    params.push(empresaId)
    query += `
      AND v.empresa_id = $${params.length}
    `
  }

  if (lojaId) {
    params.push(lojaId)
    query += `
      AND v.loja_id = $${params.length}
    `
  }

  const vendaRes = await db.query(
    query,
    params
  )

  if (!vendaRes.rows.length) {
    return null
  }

  const venda =
    vendaRes.rows[0]

  /* ==========================
     BUSCA VEÍCULOS ENTRADA
  ========================== */
  const entradasRes =
    await db.query(
      `
      SELECT *
      FROM venda_entrada
      WHERE venda_id = $1
      ORDER BY id ASC
      `,
      [id]
    )

  venda.veiculos_entrada =
    entradasRes.rows

  return venda
}

/* ===============================
   CANCELAR VENDA
================================ */
async function cancelarVenda(empresaId, lojaId, veiculoId, motivo) {

  const client = await db.connect();

  try {
    await client.query("BEGIN");

    let query = `
      UPDATE venda v
      SET status='CANCELADA',
          motivo_cancelamento=$1
      WHERE v.veiculo_id=$2
      AND status='FINALIZADA'
    `;

    const valores = [motivo, veiculoId];

    if (empresaId) {
      valores.push(empresaId);
      query += ` AND v.empresa_id=$${valores.length}`;
    }

    if (lojaId) {
      valores.push(lojaId);
      query += ` AND v.loja_id=$${valores.length}`;
    }

    query += ` RETURNING *`;

    const r = await client.query(query, valores);

if (!r.rows.length) {
  await client.query("ROLLBACK");

  return null;
}

    /* 🔥 DEVOLVE VEÍCULO PARA ESTOQUE */
    const vendaCancelada =
      r.rows[0]

    /* ==========================
       DEVOLVE VEÍCULO PRINCIPAL
    ========================== */
    await client.query(
      `
      UPDATE veiculo
      SET status='disponivel'
      WHERE id=$1
      `,
      [veiculoId]
    )

    /* ==========================
       REMOVE VEÍCULOS ENTRADA
    ========================== */
    await client.query(
      `
      DELETE FROM venda_entrada
      WHERE venda_id = $1
      `,
      [vendaCancelada.id]
    )

    await client.query(
      "COMMIT"
    )

    return vendaCancelada

  } catch (e) {
    await client.query("ROLLBACK");
    throw e;
  } finally {
    client.release();
  }
}

/* ===============================
   ATUALIZAR STATUS VEÍCULO
================================ */
async function atualizarStatusVeiculo(id, status) {
  await db.query(
    `UPDATE veiculo
     SET status=$1
     WHERE id=$2`,
    [status, id]
  );
}


/* ===============================
   BUSCAR DADOS CONTRATO
================================ */
async function buscarContrato(
  id,
  empresaId,
  lojaId
) {
  
  const r = await db.query(
    `
    SELECT
      v.*,

      /* VEÍCULO */
      ve.marca,
      ve.modelo,
      ve.placa,
      ve.ano_modelo,
      ve.cor,
      ve.chassi,
      ve.renavam,
      ve.carroceria AS tipo,
      ve.combustivel,
      ve.quilometragem AS km,

      /* LOJA (TODOS OS CAMPOS DO TEMPLATE) */
      COALESCE(l.nome, '') AS loja_nome,
      COALESCE(l.cnpj, '') AS loja_cnpj,
      COALESCE(l.telefone, '') AS loja_telefone,
      COALESCE(l.estado, '') AS loja_estado,
      COALESCE(l.cidade, '') AS loja_cidade,
      COALESCE(l.endereco, '') AS loja_endereco,
      COALESCE(l.numero, '') AS loja_numero,
      COALESCE(l.bairro, '') AS loja_bairro,
      COALESCE(l.cep, '') AS loja_cep,
      COALESCE(l.logo, '') AS loja_logo

    FROM venda v

    JOIN veiculo ve
      ON ve.id = v.veiculo_id

    LEFT JOIN loja l
      ON l.id = v.loja_id

    WHERE v.id = $1
    AND v.empresa_id = $2
    AND v.loja_id = $3
    `,
    [id, empresaId, lojaId]
  )

  if (!r.rows.length) {
    return null
  }

  const venda = r.rows[0]

  /* ENTRADAS */
  const entradasRes = await db.query(
    `
    SELECT
      marca,
      modelo,
      tipo,
      ano_modelo,
      renavam,
      chassi,
      placa,
      cor,
      numero_motor,
      combustivel,
      potencia,
      km,
      valor_entrada
    FROM venda_entrada
    WHERE venda_id = $1
    ORDER BY id ASC
    `,
    [id]
  )

  venda.entradas = entradasRes.rows

  return venda
}

/*===============================
ATUALIZAR
=================================*/
async function atualizarVenda(
  id,
  empresaId,
  lojaId,
  dados
) {
  const client =
    await db.connect()

  try {
    await client.query("BEGIN")

    /* ==========================
       VALIDA STATUS DA VENDA
    ========================== */
    const vendaAtual =
      await client.query(
        `
        SELECT status
        FROM venda
        WHERE id = $1
        AND empresa_id = $2
        AND loja_id = $3
        FOR UPDATE
        `,
        [id, empresaId, lojaId]
      )

    if (
      !vendaAtual.rows.length
    ) {
      throw new Error(
        "Venda não encontrada"
      )
    }

    if (
      vendaAtual.rows[0]
        .status ===
      "CANCELADA"
    ) {
      throw new Error(
        "Venda cancelada não pode ser alterada"
      )
    }

    /* ==========================
       ATUALIZA VENDA
    ========================== */
const valorEntrada =
  Number(dados.valor_entrada) || 0
const valorParcela =
  Number(dados.valor_parcela) || 0    
    await client.query(
      `
      UPDATE venda
      SET
        nome_comprador = $1,
        cpf_comprador = $2,
        telefone_comprador = $3,
        rg_comprador = $4,
        estado = $5,
        cidade = $6,
        bairro = $7,
        endereco = $8,
        numero = $9,
        complemento = $10,
        cep = $11,
        email = $12,
        profissao = $13,
        data_nasc = $14,
        renda = $15,
        vendedor = $16,
        data_venda = $17,
        valor_venda = $18,
        valor_entrada = $19,
        valor_parcela = $20,
        condicao_pagamento = $21,
        parcelas = $22,
        banco_financiamento = $23,
        observacoes = $24
      WHERE id = $25
      AND empresa_id = $26
      AND loja_id = $27
      `,
      [
        dados.nome_comprador,
        dados.cpf_comprador,
        dados.telefone_comprador,
        dados.rg_comprador,
        dados.estado,
        dados.cidade,
        dados.bairro,
        dados.endereco,
        dados.numero,
        dados.complemento,
        dados.cep,
        dados.email,
        dados.profissao,
        dados.data_nasc,
        dados.renda,
        dados.vendedor,
        dados.data_venda,
        dados.valor_venda,
        valorEntrada,
        valorParcela,
        dados.condicao_pagamento,
        dados.parcelas,
        dados.banco_financiamento,
        dados.observacoes,
        id,
        empresaId,
        lojaId
      ]
    )

    /* ==========================
       REMOVE ENTRADAS ANTIGAS
    ========================== */
    await client.query(
      `
      DELETE FROM venda_entrada
      WHERE venda_id = $1
      `,
      [id]
    )

    /* ==========================
       REINSERE ENTRADAS NOVAS
    ========================== */
const vendaInfo = await client.query(
  `
  SELECT empresa_id, loja_id
  FROM venda
  WHERE id = $1
  `,
  [id]
)

const empresaVenda = vendaInfo.rows[0].empresa_id
const lojaVenda = vendaInfo.rows[0].loja_id
    
    if (
      dados.veiculos_entrada?.length
    ) {
      for (const entrada of dados.veiculos_entrada) {

      const valorEntrada =
        Number(entrada.valor_entrada) || 0

      if (valorEntrada <= 0) {
        throw new Error(
          "Veículo de entrada precisa ter valor"
        )
      }
              
        await client.query(
          `
          INSERT INTO venda_entrada (
            venda_id,
            empresa_id,
            loja_id,
            marca,
            modelo,
            tipo,
            ano_modelo,
            renavam,
            chassi,
            placa,
            cor,
            numero_motor,
            combustivel,
            potencia,
            km,
            valor_entrada
          )
          VALUES (
            $1,$2,$3,$4,$5,$6,$7,$8,
            $9,$10,$11,$12,$13,$14,$15,$16
          )
          `,
          [
            id,
            empresaVenda,
            lojaVenda,
            entrada.marca,
            entrada.modelo,
            entrada.tipo,
            entrada.ano_modelo,
            entrada.renavam,
            entrada.chassi,
            entrada.placa,
            entrada.cor,
            entrada.numero_motor,
            entrada.combustivel,
            entrada.potencia,
            entrada.km,
            valorEntrada
          ]
        )
      }
    }

    await client.query("COMMIT")

    return true

  } catch (e) {
    await client.query("ROLLBACK")
    throw e

  } finally {
    client.release()
  }
}


/* ===============================
   EXPORTS
================================ */
module.exports = {
  criarVendaComTransacao,
  listar,
  detalhes,
  cancelarVenda,
  atualizarVenda,
  atualizarStatusVeiculo,
  buscarContrato
}