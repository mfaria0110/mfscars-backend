const db = require("../../shared/database/db");

/* ============================= */
/* CRIAR EMPRESA */
/* ============================= */
async function criar(dados) {

  const {
    nome,
    cidade,
    estado,
    telefone,
    cnpj,
    cep,
    endereco,
    numero,
    descricao,
    horario_funcionamento,
    instagram,
    facebook,
    site,
    slug
  } = dados;

  const r = await db.query(
    `
    INSERT INTO empresa
    (
      nome,
      cidade,
      estado,
      telefone,
      cnpj,
      cep,
      endereco,
      numero,
      descricao,
      horario_funcionamento,
      instagram,
      facebook,
      site,
      slug
    )
    VALUES
    ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
    RETURNING *
    `,
    [
      nome,
      cidade,
      estado,
      telefone,
      cnpj,
      cep,
      endereco,
      numero,
      descricao,
      horario_funcionamento,
      instagram,
      facebook,
      site,
      slug
    ]
  );

  return r.rows[0];
}

/* ============================= */
/* BUSCAR POR ID */
/* ============================= */
async function buscarPorId(id) {
  const r = await db.query(
    `
    SELECT *
    FROM empresa
    WHERE id=$1
    `,
    [id]
  );

  return r.rows[0];
}

/* ============================= */
/* VEÍCULOS DA EMPRESA */
/* ============================= */
async function listarVeiculos(empresaId) {
  const r = await db.query(
    `
    SELECT
      v.id,
      v.marca,
      v.modelo,
      v.ano,
      v.valor,
      (
        SELECT url
        FROM veiculo_foto
        WHERE veiculo_id=v.id
        ORDER BY principal DESC
        LIMIT 1
      ) foto
    FROM veiculo v
    WHERE v.empresa_id=$1
    AND v.status='disponivel'
    ORDER BY v.data_cadastro DESC
    `,
    [empresaId]
  );

  return r.rows;
}

/* ============================= */
/* LOJA POR ID */
/* ============================= */
async function buscarLojaPorId(id) {
  const r = await db.query(
    `
    SELECT
      id,
      nome,
      cidade,
      estado,
      telefone,
      logo,
      banner,
      endereco,
      latitude,
      longitude,
      descricao,
      horario_funcionamento,
      instagram,
      facebook,
      site
    FROM loja
    WHERE id=$1
    `,
    [id]
  );

  return r.rows[0];
}

/* ============================= */
/* VEÍCULOS DA LOJA */
/* ============================= */
async function listarVeiculosPorLoja(lojaId) {
  const r = await db.query(
    `
    SELECT
      v.id,
      v.marca,
      v.modelo,
      v.ano,
      v.valor,
      (
        SELECT url
        FROM veiculo_foto
        WHERE veiculo_id = v.id
        ORDER BY principal DESC
        LIMIT 1
      ) foto
    FROM veiculo v
    WHERE v.loja_id = $1
    AND v.status = 'disponivel'
    ORDER BY v.data_cadastro DESC
    `,
    [lojaId]
  );

  return r.rows;
}

/* ============================= */
/* ATUALIZAR BANNER */
/* ============================= */
async function atualizarBanner(lojaId, filename) {
  await db.query(
    `UPDATE loja SET banner=$1 WHERE id=$2`,
    [filename, lojaId]
  );
}

async function listarLojas() {
  const r = await db.query(`
    SELECT id, nome, cidade, estado, logo
    FROM loja
    ORDER BY nome
  `);

  return r.rows;
}

module.exports = {
  criar,
  buscarPorId,
  listarVeiculos,
  buscarLojaPorId,
  listarVeiculosPorLoja,
  atualizarBanner,
  listarLojas
};