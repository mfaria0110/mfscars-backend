const db =
  require("../../shared/database/db")

const planoService =
  require("../plano/plano.service")

const {
  withTransaction
} = require("../../shared/database/transaction");

const BASE_URL =
  process.env.BASE_URL ||
  "https://api.mfscars.com.br"

function normalizarFoto(foto) {

  if (
    !foto ||
    foto === "null" ||
    foto === "undefined"
  ) {
    return `${BASE_URL}/uploads/sem-foto.jpg`
  }

  if (foto.startsWith("http")) {
    return foto.replace("http://", "https://")
  }

  return `${BASE_URL}/uploads/${foto}`
}

exports.listar = async (filtros = {}) => {

  if (!filtros.loja_id || Number.isNaN(Number(filtros.loja_id))) {
    return {
      page: 1,
      limit: 12,
      total: 0,
      totalPages: 0,
      data: []
    };
  }

  const page = parseInt(filtros.page) || 1;
  const limit = parseInt(filtros.limit) || 12;
  const offset = (page - 1) * limit;

  const valores = [];

  let where = `WHERE 1=1`;

  if (filtros.empresa_id) {
    valores.push(filtros.empresa_id);
    where += ` AND v.empresa_id = $${valores.length}`;
  }

  if (filtros.loja_id) {
    valores.push(filtros.loja_id);
    where += ` AND v.loja_id = $${valores.length}`;
  }

  const totalQuery = `
    SELECT COUNT(*)
    FROM veiculo v
    ${where}
  `;

  const totalResult = await db.query(totalQuery, valores);
  const total = parseInt(totalResult.rows[0].count);
  const totalPages = Math.ceil(total / limit);

  let query = `
    SELECT 
      v.*,
      l.nome as loja,
      l.cidade,
      l.estado,

      COALESCE((
        SELECT url
        FROM veiculo_foto
        WHERE veiculo_id = v.id
        ORDER BY principal DESC, id ASC
        LIMIT 1
      ), 'sem-foto.jpg') foto

    FROM veiculo v
    JOIN loja l ON l.id = v.loja_id

    ${where}

    ORDER BY v.data_cadastro DESC
  `;

  valores.push(limit);
  valores.push(offset);

  query += ` LIMIT $${valores.length - 1} OFFSET $${valores.length}`;

  const r = await db.query(query, valores);

  const data = r.rows.map(v => ({
    ...v,
    foto: normalizarFoto(v.foto)
  }));

  return {
    page,
    limit,
    total,
    totalPages,
    data
  };
}

exports.marcas = async () => {

  try {

    const r = await db.query(`
      SELECT id, nome
      FROM marca
      ORDER BY nome
    `);

    return r.rows;

  } catch (e) {
    console.error("ERRO SQL marcas:", e);
    throw e;
  }

};

exports.modelos = async (marcaId) => {

  try {

    // 🔒 garantir número
    const id = parseInt(marcaId);

    if (isNaN(id)) {
      throw new Error("marca_id inválido");
    }

    const r = await db.query(`
      SELECT id, nome
      FROM modelo
      WHERE marca_id = $1
      ORDER BY nome
    `, [id]);

    return r.rows;

  } catch (e) {
    console.error("ERRO SQL modelos:", e);
    throw e;
  }

};

exports.opcionais = async ()=>{

  const r = await db.query(`
SELECT id,nome
FROM opcional
ORDER BY nome
  `)

  return r.rows
}

exports.detalhes = async (id, empresaId, lojaId) => {

  let query = `
    SELECT
      v.*,
      v.ano_modelo as ano,
    
      l.nome AS loja,
      l.telefone
    FROM veiculo v
    JOIN loja l ON l.id = v.loja_id
    WHERE v.id = $1
  `

  const valores = [id]

  /* 🔥 EMPRESA (SE NÃO FOR MASTER) */
  if (empresaId !== null && empresaId !== undefined) {
    valores.push(empresaId)
    query += ` AND v.empresa_id = $${valores.length}`
  }

  /* 🔥 LOJA (SE EXISTIR) */
  if (lojaId !== null && lojaId !== undefined) {
    valores.push(lojaId)
    query += ` AND v.loja_id = $${valores.length}`
  }

  const veiculo = await db.query(query, valores)

  /* 🔥 NUNCA RETORNA NULL */
  if (!veiculo.rows.length) {
    return {
      veiculo: null,
      fotos: [],
      opcionais: []
    }
  }

  /* ===============================
     FOTOS (SEM BLOQUEIO)
  ============================== */
  const fotos = await db.query(`
    SELECT 
      id,
      veiculo_id,
      empresa_id,
      loja_id,
      principal,
      url
    FROM veiculo_foto
    WHERE veiculo_id = $1
    ORDER BY principal DESC, id ASC
  `, [id])

  /* ===============================
     OPCIONAIS
  ============================== */

  const opcionais = await db.query(`
    SELECT
      o.id,
      o.nome
    FROM veiculo_opcional vo
    JOIN opcional o ON o.id = vo.opcional_id
    WHERE vo.veiculo_id = $1
  `, [id])

  const proprietario = await db.query(
    `
  SELECT *
  FROM veiculo_proprietario
  WHERE veiculo_id = $1
  LIMIT 1
    `,
    [id]
    )

  return {
    veiculo: veiculo.rows[0],
    fotos: fotos.rows,
    opcionais: opcionais.rows,
    proprietario:
    proprietario.rows[0] || null
  }
  
}

exports.listar = async (filtros = {}) => {

  if (!filtros.loja_id || Number.isNaN(Number(filtros.loja_id))) {
    return {
      page: 1,
      limit: 12,
      total: 0,
      totalPages: 0,
      data: []
    };
  }

  const page = parseInt(filtros.page) || 1;
  const limit = parseInt(filtros.limit) || 12;
  const offset = (page - 1) * limit;

  const valores = [];

  let where = `WHERE 1=1`;

  if (filtros.empresa_id) {
    valores.push(filtros.empresa_id);
    where += ` AND v.empresa_id = $${valores.length}`;
  }

  if (filtros.loja_id) {
    valores.push(filtros.loja_id);
    where += ` AND v.loja_id = $${valores.length}`;
  }

  const totalQuery = `
    SELECT COUNT(*)
    FROM veiculo v
    ${where}
  `;

  const totalResult = await db.query(totalQuery, valores);
  const total = parseInt(totalResult.rows[0].count);
  const totalPages = Math.ceil(total / limit);

  let query = `
    SELECT 
      v.*,
      l.nome as loja,
      l.cidade,
      l.estado,

      COALESCE((
        SELECT url
        FROM veiculo_foto
        WHERE veiculo_id = v.id
        ORDER BY principal DESC, id ASC
        LIMIT 1
      ), 'sem-foto.jpg') foto

    FROM veiculo v
    JOIN loja l ON l.id = v.loja_id

    ${where}

    ORDER BY v.data_cadastro DESC
  `;

  valores.push(limit);
  valores.push(offset);

  query += ` LIMIT $${valores.length - 1} OFFSET $${valores.length}`;

  const r = await db.query(query, valores);

  const data = r.rows.map(v => ({
    ...v,
    foto: normalizarFoto(v.foto)
  }));

  return {
    page,
    limit,
    total,
    totalPages,
    data
  };
}

exports.criar = async (empresaId, lojaId, dados) => {

  const resultado = await withTransaction(async (client) => {

    /* ===============================
       🔒 NORMALIZAÇÃO + VALIDAÇÃO
    ============================== */

    const marca = dados.marca?.trim();
    const modelo = dados.modelo?.trim();
    const versao = dados.versao?.trim() || null;
    const cor = dados.cor?.trim() || null;
    const combustivel = dados.combustivel || null;
    const cambio = dados.cambio || null;
    const carroceria = dados.carroceria || null;

    const placa = dados.placa
    ? dados.placa.replace(/\W/g, '').toUpperCase()
    : null;

    const renavam = dados.renavam || null;
    const descricao = dados.descricao?.trim() || null;

    const ano = dados.ano_modelo;
    const quilometragem = dados.quilometragem;
    const valor = dados.valor;

    const aceita_troca = dados.aceita_troca;
    const licenciado = dados.licenciado;

    const opcionais = Array.isArray(dados.opcionais)
    ? dados.opcionais
    : [];

    /* ===============================
       🔒 VALIDAÇÃO
    ============================== */

    if (!marca) throw new Error("Marca é obrigatória");
    if (!modelo) throw new Error("Modelo é obrigatório");
    if (!valor || isNaN(parseFloat(valor))) throw new Error("Valor inválido");
    if (
      ano &&
      !/^\d{4}(\/\d{4})?$/.test(String(ano))
      ) {
      throw new Error(
        "Ano deve estar no formato 2011 ou 2011/2012"
        )
  }
  if (quilometragem && isNaN(parseInt(quilometragem))) throw new Error("Quilometragem inválida");

    /* ===============================
       🔄 CONVERSÕES
    ============================== */

  const aceita_troca_bool = aceita_troca === true || aceita_troca === "true";
  const licenciado_bool = licenciado === true || licenciado === "true";

  const anoVal = ano ? String(ano).trim() : null;

  const kmVal = quilometragem ? parseInt(quilometragem) : null;
  const valorVal = valor ? parseFloat(valor) : null;

  const placaFinalVal = placa
  ? parseInt(placa.replace(/\D/g, '').slice(-1))
  : null;

    /* ===============================
       🔒 LOCK + VALIDAR PLANO
    ============================== */

    await planoService.validarPlanoAtivo(
      client,
      lojaId
    )

    await planoService.validarLimiteVeiculos(
      client,
      lojaId
    )

    /* ===============================
       🚗 INSERIR VEÍCULO
    ============================== */

  const r = await client.query(`
      INSERT INTO veiculo (
        empresa_id, loja_id, marca, modelo, versao,
        ano_modelo, quilometragem, valor, combustivel, cambio,
        carroceria, cor, placa, renavam, final_placa,
        descricao, aceita_troca, licenciado, status
      )
      VALUES (
        $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,
        $11,$12,$13,$14,$15,$16,$17,$18,'disponivel'
      )
      RETURNING *
    `, [
      empresaId, lojaId, marca, modelo, versao,
      anoVal, kmVal, valorVal, combustivel, cambio,
      carroceria, cor, placa, renavam, placaFinalVal,
      descricao, aceita_troca_bool, licenciado_bool
    ]);

  const veiculoId = r.rows[0].id;

  /* ===============================
   PROPRIETÁRIO
============================== */

  if (
    dados.proprietario_nome ||
    dados.proprietario_cpf ||
    dados.proprietario_telefone
    ) {
    await client.query(
      `
INSERT INTO veiculo_proprietario (
  veiculo_id,
  empresa_id,
  loja_id,
  nome,
  cpf,
  telefone,
  email,
  endereco,
  cidade,
  estado
)
    VALUES (
      $1,$2,$3,$4,$5,$6,$7,$8,$9,$10
    )
      `,
      [
        veiculoId,
        empresaId,
        lojaId,
        dados.proprietario_nome || null,
        dados.proprietario_cpf || null,
        dados.proprietario_telefone || null,
        dados.proprietario_email || null,
        dados.proprietario_endereco || null,
        dados.proprietario_cidade || null,
        dados.proprietario_estado || null
      ]
      )
}

    /* ===============================
       ⚙️ OPCIONAIS (BATCH)
    ============================== */

if (opcionais.length) {
  const valores = [];
  const placeholders = [];

  opcionais.forEach((op, index) => {

    const pos = index * 4

    placeholders.push(`
    (
      $${pos + 1},
      $${pos + 2},
      $${pos + 3},
      $${pos + 4}
    )
    `)

    valores.push(
      veiculoId,
      empresaId,
      lojaId,
      parseInt(op)
    )

  });

  await client.query(`
      INSERT INTO veiculo_opcional (
        veiculo_id,
        empresa_id,
        loja_id,
        opcional_id
      )
      VALUES ${placeholders.join(",")}
        `, valores);
      }


/* ===============================
     ♻️ INVALIDAR CACHE
  ============================== */

const dashboardCache = require("../dashboard/dashboard.repository");

if (dashboardCache.cache) {
  dashboardCache.cache.delete(`${empresaId}_${lojaId}`);
}

return r.rows[0];

  });
};

exports.atualizar = async (id, empresaId, lojaId, dados) => {

  return await withTransaction(async (client) => {

    const marca = dados.marca || null
    const modelo = dados.modelo || null
    const versao = dados.versao || null
    const ano_modelo = dados.ano_modelo || null
    const quilometragem = dados.quilometragem || null
    const valor = dados.valor || null
    const combustivel = dados.combustivel || null
    const cambio = dados.cambio || null
    const carroceria = dados.carroceria || null
    const cor = dados.cor || null
    const placa = dados.placa || null
    const renavam = dados.renavam || null
    const descricao = dados.descricao || null
    const aceita_troca = dados.aceita_troca
    const licenciado = dados.licenciado

const placaFormatada = placa
? placa.replace(/\W/g, '').toUpperCase()
: null

const finalPlaca = placaFormatada
? parseInt(
    placaFormatada
      .replace(/\D/g, '')
      .slice(-1)
  )
: null

    const aceita_troca_bool =
    aceita_troca === true || aceita_troca === "true"

    const licenciado_bool =
    licenciado === true || licenciado === "true"

    const anoVal = ano_modelo
    ? String(ano_modelo).trim()
    : null
    
    const kmVal = parseInt(quilometragem) || null
    const valorVal = Number(valor) || 0

let valores = [
  marca,
  modelo,
  versao,
  anoVal,
  kmVal,
  valorVal,
  combustivel,
  cambio,
  carroceria,
  cor,
  placaFormatada,
  finalPlaca,
  renavam,
  descricao,
  aceita_troca_bool,
  licenciado_bool,
  id
]

    let query = `
      UPDATE veiculo SET
        marca=$1,
        modelo=$2,
        versao=$3,
        ano_modelo=$4,
        quilometragem=$5,
        valor=$6,
        combustivel=$7,
        cambio=$8,
        carroceria=$9,
        cor=$10,
        placa=$11,
        final_placa=$12,
        renavam=$13,
        descricao=$14,
        aceita_troca=$15,
        licenciado=$16
        WHERE id=$17
        `

    if (empresaId !== null && empresaId !== undefined) {
      valores.push(empresaId)
      query += ` AND empresa_id=$${valores.length}`
    }

    if (lojaId !== null && lojaId !== undefined){
      valores.push(lojaId)
      query += ` AND loja_id=$${valores.length}`
    }

    query += ` RETURNING *`

    const r = await client.query(query, valores)

    if (!r.rows.length) {
      throw new Error("Veículo não encontrado ou sem permissão")
    }

    /* ===============================
   ATUALIZA PROPRIETÁRIO
============================== */

/* remove antigo */
    await client.query(
      `
  DELETE FROM veiculo_proprietario
  WHERE veiculo_id = $1
      `,
      [id]
      )

/* insere novo */
    if (
      dados.proprietario_nome ||
      dados.proprietario_cpf ||
      dados.proprietario_telefone
      ) {
      await client.query(
        `
    INSERT INTO veiculo_proprietario (
      veiculo_id,
      empresa_Id,
      loja_Id,
      nome,
      cpf,
      telefone,
      email,
      endereco,
      cidade,
      estado
    )
    VALUES (
      $1,$2,$3,$4,$5,$6,$7,$8,$9,$10
    )
        `,

        [
          id,
          empresaId,
          lojaId,
          dados.proprietario_nome || null,
          dados.proprietario_cpf || null,
          dados.proprietario_telefone || null,
          dados.proprietario_email || null,
          dados.proprietario_endereco || null,
          dados.proprietario_cidade || null,
          dados.proprietario_estado || null
        ]

        )
  }

    /* 🔥 OPCIONAIS */
  if (dados.opcionais) {

    await client.query(
  `DELETE FROM veiculo_opcional WHERE veiculo_id=$1`,
  [id]
  )

    if (dados.opcionais.length) {

      const valores = []
      const placeholders = []

      dados.opcionais.forEach((op, index) => {

      const pos = index * 4

      placeholders.push(`
      (
        $${pos + 1},
        $${pos + 2},
        $${pos + 3},
        $${pos + 4}
      )
      `)

      valores.push(
        id,
        empresaId,
        lojaId,
        parseInt(op)
      )

      })

      await client.query(`
          INSERT INTO veiculo_opcional (
  veiculo_id,
  empresa_id,
  loja_id,
  opcional_id
)
          VALUES ${placeholders.join(",")}
      `, valores)
    }
  }

  return r.rows[0]
})
}

exports.excluir = async (id, empresaId, lojaId) => {

  return await withTransaction(async (client) => {

    /* ==========================
       VALIDAR VEÍCULO
    ========================== */
    const veiculo = await client.query(
      `
      SELECT id
      FROM veiculo
      WHERE id = $1
      AND empresa_id = $2
      AND loja_id = $3
      `,
      [id, empresaId, lojaId]
      )

    if (!veiculo.rows.length) {
      throw new Error("Veículo não encontrado")
    }

    /* ==========================
       BUSCAR FOTOS
    ========================== */
    const midias = await client.query(
      `
      SELECT url
      FROM veiculo_foto
      WHERE veiculo_id = $1
      `,
      [id]
      )


    /* ==========================
       DELETE TABELAS FILHAS
    ========================== */

    await client.query(
  `DELETE FROM veiculo_foto WHERE veiculo_id = $1`,
  [id]
  )

    await client.query(
  `DELETE FROM veiculo_opcional WHERE veiculo_id = $1`,
  [id]
  )

    await client.query(
  `DELETE FROM veiculo_documento WHERE veiculo_id = $1`,
  [id]
  )

    await client.query(
  `DELETE FROM veiculo_proprietario WHERE veiculo_id = $1`,
  [id]
  )

    /* ==========================
       DELETE VEÍCULO
    ========================== */
    await client.query(
      `
      DELETE FROM veiculo
      WHERE id = $1
      AND empresa_id = $2
      AND loja_id = $3
      `,
      [id, empresaId, lojaId]
      )

    /* ==========================
       RETORNO
    ========================== */
    return {
      sucesso: true,
      mensagem: "Veículo excluído com sucesso"
    }

  })
}

exports.verificarDono = async (veiculoId)=>{

  const r = await db.query(
    `SELECT empresa_id, loja_id
FROM veiculo
    WHERE id=$1`,
    [veiculoId]
    )

  return r.rows[0]

}

exports.salvarFoto = async (
  empresaId,
  lojaId,
  veiculoId,
  url
  ) => {
  return await withTransaction(async (client) => {

    const veiculo = await client.query(
      `
      SELECT id, empresa_id, loja_id
      FROM veiculo
      WHERE id = $1
      AND empresa_id = $2
      AND loja_id = $3
      `,
      [
        veiculoId,
        empresaId,
        lojaId
      ]
      )

    if (!veiculo.rows.length) {
      throw new Error(
        "Veículo não encontrado"
        )
    }

    const totalFotos =
    await client.query(
      `
        SELECT COUNT(*)
        FROM veiculo_foto
        WHERE veiculo_id = $1
      `,
      [veiculoId]
      )

    const isPrimeira =
    Number(
      totalFotos.rows[0].count
      ) === 0

    const r =
    await client.query(
      `
        INSERT INTO veiculo_foto (
          veiculo_id,
          empresa_id,
          loja_id,
          url,
          principal
        )
        VALUES ($1,$2,$3,$4,$5)
        RETURNING *
      `,
      [
        veiculoId,
        empresaId,
        lojaId,
        url,
        isPrimeira
      ]
      )

    return r.rows[0]
  })
}


exports.removerFoto = async (id) => {

  return await withTransaction(async (client) => {

    const foto = await client.query(
      `
      SELECT
        id,
        veiculo_id,
        principal,
        url
      FROM veiculo_foto
      WHERE id = $1
      `,
      [id]
      )

    if (!foto.rows.length) {
      throw new Error("Foto não encontrada")
    }

    const {
      veiculo_id,
      principal,
      url
    } = foto.rows[0]


    /* =========================
       REMOVE BANCO
    ========================= */

  await client.query(
    `
      DELETE FROM veiculo_foto
      WHERE id = $1
    `,
    [id]
    )

    /* =========================
       REDEFINE PRINCIPAL
    ========================= */

  if (principal) {

    const outra =
    await client.query(
      `
          SELECT id
          FROM veiculo_foto
          WHERE veiculo_id = $1
          LIMIT 1
      `,
      [veiculo_id]
      )

    if (outra.rows.length) {

      await client.query(
        `
          UPDATE veiculo_foto
          SET principal = true
          WHERE id = $1
        `,
        [outra.rows[0].id]
        )
    }
  }

  return true
})
}

exports.definirPrincipal = async (id) => {

  return await withTransaction(async (client) => {

    const foto = await client.query(
  `SELECT veiculo_id FROM veiculo_foto WHERE id=$1`,
  [id]
  )

    if (!foto.rows.length) {
      throw new Error("Foto não encontrada")
    }

    const veiculoId = foto.rows[0].veiculo_id

    await client.query(
  `UPDATE veiculo_foto SET principal=false WHERE veiculo_id=$1`,
  [veiculoId]
  )

    await client.query(
  `UPDATE veiculo_foto SET principal=true WHERE id=$1`,
  [id]
  )
  })
}

/* ============================= */
/*      MARKETPLACE PUBLICO      */
/* ============================= */
exports.buscarPublico = async (filtros = {}) => {

  const page = parseInt(filtros.page) || 1;
  const limit = 12;
  const offset = (page - 1) * limit;

  let where = `WHERE v.status='disponivel'`;
  const valores = [];

  let query = `
    SELECT
      v.id,
      v.loja_id,
      v.marca,
      v.modelo,
      v.ano_modelo,
      v.valor,

      COALESCE((
        SELECT url
        FROM veiculo_foto
        WHERE veiculo_id=v.id
        ORDER BY principal DESC
        LIMIT 1
      ), 'sem-foto.jpg') foto,

      l.nome AS loja,
      l.cidade,
      l.estado

    FROM veiculo v
    JOIN loja l ON l.id = v.loja_id

    ${where}

    ORDER BY v.data_cadastro DESC
    LIMIT $${valores.length + 1}
    OFFSET $${valores.length + 2}
  `;

  valores.push(limit, offset);

  const r = await db.query(query, valores);

  const data = r.rows.map(v => ({
    ...v,
    foto: normalizarFoto(v.foto)
  }));

  return {
    page,
    data
  };
}

exports.buscarPublicoPorId = async (id) => {

  const r = await db.query(`
    SELECT
      v.*,
      v.ano_modelo as ano,

      l.nome as loja,
      l.cidade,
      l.estado,

      COALESCE((
        SELECT url
        FROM veiculo_foto
        WHERE veiculo_id = v.id
        ORDER BY principal DESC
        LIMIT 1
      ), 'sem-foto.jpg') foto

    FROM veiculo v

    JOIN loja l
    ON l.id = v.loja_id

    WHERE v.id = $1
  `, [id]);

  const v = r.rows[0];

  if (!v) return null;

  return {
    ...v,
    foto: normalizarFoto(v.foto)
  };
}


////FIM ////
exports.filtros = async ()=>{

/* marcas */

    const marcas = await db.query(`
SELECT marca, COUNT(*) as total
FROM veiculo
WHERE status='disponivel'
GROUP BY marca
ORDER BY marca
    `)


/* combustivel */

    const combustiveis = await db.query(`
SELECT combustivel, COUNT(*) as total
FROM veiculo
WHERE status='disponivel'
GROUP BY combustivel
ORDER BY combustivel
    `)


/* anos */

    const anos = await db.query(`
SELECT ano_modelo, COUNT(*) as total
FROM veiculo
WHERE status='disponivel'
GROUP BY ano_modelo
ORDER BY ano_modelo DESC
    `)


    return {

      marcas: marcas.rows,
      combustiveis: combustiveis.rows,
      anos: anos.rows

    }

  }

  exports.similares = async (id) => {

    const base = await db.query(
      `SELECT marca, modelo, valor
     FROM veiculo
      WHERE id = $1`,
      [id]
      )

    if (!base.rows.length) return []

      const { marca, modelo, valor } = base.rows[0]

    const r = await db.query(
      `
    SELECT
      v.id,
      v.marca,
      v.modelo,
      v.valor,
      (
        SELECT url
        FROM veiculo_foto
        WHERE veiculo_id = v.id
        ORDER BY principal DESC
        LIMIT 1
      ) foto
    FROM veiculo v
    WHERE v.id != $1
      AND v.marca = $2
      AND v.valor BETWEEN $3 * 0.7 AND $3 * 1.3
    ORDER BY v.data_cadastro DESC
    LIMIT 8
      `,
      [id, marca, valor]
      )

    return r.rows
  }

  exports.toggleFavorito = async (usuarioId, veiculoId) => {

    const existe = await db.query(
      `SELECT id FROM favorito
      WHERE usuario_id=$1 AND veiculo_id=$2`,
      [usuarioId, veiculoId]
      )

    if (existe.rows.length > 0) {

      await db.query(
        `DELETE FROM favorito
        WHERE usuario_id=$1 AND veiculo_id=$2`,
        [usuarioId, veiculoId]
        )

      return { favoritado: false }

    } else {

      await db.query(
        `INSERT INTO favorito (usuario_id, veiculo_id)
        VALUES ($1,$2)`,
        [usuarioId, veiculoId]
        )

      return { favoritado: true }

    }

  }

exports.listarPublico = async (filtros = {}) => {

  const page = Number(filtros.page || 1);

  const limit = 12;

  const offset = (page - 1) * limit;

  const params = [];

  let where = `
    WHERE v.status = 'disponivel'
  `;

  if (filtros.marca) {

    params.push(`%${filtros.marca}%`);

    where += `
      AND v.marca ILIKE $${params.length}
    `;
  }

  if (filtros.modelo) {

    params.push(`%${filtros.modelo}%`);

    where += `
      AND v.modelo ILIKE $${params.length}
    `;
  }

  if (filtros.cidade) {

    params.push(`%${filtros.cidade}%`);

    where += `
      AND l.cidade ILIKE $${params.length}
    `;
  }

  if (filtros.preco) {

    params.push(Number(filtros.preco));

    where += `
      AND v.valor <= $${params.length}
    `;
  }

  let query = `
    SELECT
      v.id,
      v.loja_id,
      v.marca,
      v.modelo,
      v.ano_modelo,
      v.valor,

      COALESCE((
        SELECT url
        FROM veiculo_foto
        WHERE veiculo_id = v.id
        ORDER BY principal DESC
        LIMIT 1
      ), 'sem-foto.jpg') foto,

      l.nome AS loja,
      l.cidade,
      l.estado

    FROM veiculo v

    JOIN loja l
    ON l.id = v.loja_id

    ${where}

    ORDER BY v.data_cadastro DESC

    LIMIT $${params.length + 1}
    OFFSET $${params.length + 2}
  `;

  params.push(limit);
  params.push(offset);

  const r = await db.query(query, params);

  const data = r.rows.map(v => ({
    ...v,
    foto: normalizarFoto(v.foto)
  }));

  return {
    page,
    data
  };
}

exports.excluirDocumento = async (id) => {
    try {
      const r = await db.query(
        `
      DELETE FROM veiculo_documento
      WHERE id = $1
      RETURNING *
        `,
        [id]
        )

      if (!r.rows.length) {
        throw new Error(
          "Documento não encontrado"
          )
      }

      return true

    } catch (e) {
      console.error(
        "ERRO REPOSITORY excluirDocumento:",
        e
        )
      throw e
    }
  }

exports.fotos = async (
  veiculoId,
  empresaId,
  lojaId
) => {

  let query = `
    SELECT 
      id,
      veiculo_id,
      empresa_id,
      loja_id,
      url,
      principal

    FROM veiculo_foto

    WHERE veiculo_id = $1
  `;

  const params = [veiculoId];

  if (empresaId !== null && empresaId !== undefined) {
    params.push(empresaId);
    query += ` AND empresa_id = $${params.length}`;
  }

  if (lojaId !== null && lojaId !== undefined) {
    params.push(lojaId);
    query += ` AND loja_id = $${params.length}`;
  }

  query += ` ORDER BY principal DESC, id ASC`;

  const r = await db.query(query, params);

  return r.rows.map(f => ({
    ...f,
    url: normalizarFoto(f.url)
  }));
}
 

exports.contarFotos = async (veiculoId) => {
    const result = await db.query(
  `SELECT COUNT(*) FROM veiculo_foto WHERE veiculo_id = $1`,
  [veiculoId]
  )

    return Number(result.rows[0].count)
  } 

exports.buscarFotoPorId = async (id) => {

    const result = await db.query(

      `
    SELECT *
    FROM veiculo_foto
    WHERE id = $1
      `,

      [id]
      )

    return result.rows[0]
  }

exports.definirOutraPrincipal = async (
    veiculoId
    ) => {

    const result = await db.query(

      `
    SELECT id
    FROM veiculo_foto
    WHERE veiculo_id = $1
    LIMIT 1
      `,

      [veiculoId]
      )

    if (!result.rows.length) return

      await db.query(

        `
    UPDATE veiculo_foto
    SET principal = true
    WHERE id = $1
        `,

        [result.rows[0].id]
        )
  }