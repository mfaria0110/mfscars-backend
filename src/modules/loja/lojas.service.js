const db = require("../../shared/database/db")
const bcrypt = require("bcrypt")
const planoService =
  require("../plano/plano.service")

async function validarSenha(usuarioId, senha, client) {

  const r = await client.query(`
    SELECT senha FROM usuario WHERE id = $1
  `, [usuarioId])

  if (!r.rows.length) {
    throw new Error("Usuário não encontrado")
  }

  const senhaHash = r.rows[0].senha

  const ok = await bcrypt.compare(senha, senhaHash)

  if (!ok) {
    throw new Error("Senha inválida")
  }
}

/* ===============================
   LISTAR (SEM TRANSACTION)
================================ */
exports.listar = async (user, lojaId) => {

  let empresaId = user.empresa_id

  // 🔥 MASTER pode ver qualquer empresa via loja
  if (user.master && lojaId) {
    const lojaRes = await db.query(
      `SELECT empresa_id FROM loja WHERE id = $1`,
      [lojaId]
    )

    if (lojaRes.rows.length) {
      empresaId = lojaRes.rows[0].empresa_id
    }
  }

  // 🔥 ADMIN e USER → usa empresa do usuário
  const res = await db.query(`
    SELECT id, nome, cidade, estado
    FROM loja
    WHERE empresa_id = $1
    ORDER BY nome
  `, [empresaId])

  return res.rows
}


/* ===============================
   DETALHES
================================ */
exports.detalhes = async (id, empresaId) => {

  const r = await db.query(`
    SELECT * FROM loja
    WHERE id = $1 AND empresa_id = $2
  `, [id, empresaId])

  if (!r.rows.length) {
    throw new Error("Loja não encontrada")
  }

  return r.rows[0]
}

/* ===============================
   TODAS (HEADER)
================================ */
exports.todas = async (user) => {

  let query = `
    SELECT id, nome, empresa_id, status
    FROM loja
  `

  let params = []

  if (!user.master) {
    query += `
      WHERE empresa_id = $1
    `
    params.push(user.empresa_id)
  }

  query += `
    ORDER BY nome
  `

  const res = await db.query(
    query,
    params
  )

  return res.rows
}

/* ===============================
   CRIAR (COM TRANSACTION)
================================ */
exports.criar = async (empresaId, dados) => {

  const client = await db.connect()

  try {

    await client.query("BEGIN")

    /* =========================
   VALIDAR LIMITE LOJAS
========================= */

await planoService
  .validarLimiteLojas(

    client,

    empresaId

  )

console.log(
  "DADOS UPDATE RECEBIDOS:",
  dados
)

const nome =
  Array.isArray(dados.nome)
    ? dados.nome[0]
    : dados.nome

const cnpj =
  Array.isArray(dados.cnpj)
    ? dados.cnpj[0]
    : dados.cnpj

if (
  nome === undefined ||
  nome === null ||
  nome === ""
) {
  throw new Error(
    "Informe o nome"
  )
}

if (
  cnpj === undefined ||
  cnpj === null ||
  cnpj === ""
) {
  throw new Error(
    "CNPJ é obrigatório"
  )
}

dados.nome = nome
dados.cnpj = cnpj


    // 🔥 VALIDAR CNPJ DUPLICADO
if (dados.cnpj) {

  const existe = await client.query(`
    SELECT id FROM loja
    WHERE cnpj = $1
  `, [dados.cnpj])

  if (existe.rows.length) {
    throw new Error("CNPJ já cadastrado")
  }
}

const r = await client.query(`
  INSERT INTO loja (
    empresa_id,
    nome,
    cnpj,
    telefone,
    cidade,
    estado,
    endereco,
    numero,
    bairro,
    cep,
    latitude,
    longitude,
    descricao,
    instagram,
    facebook,
    site,
    horario_funcionamento,
    plano_id,
    status,
    logo
  )
  VALUES (
    $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,
    $11,$12,$13,$14,$15,$16,$17,$18,$19,$20
  )
  RETURNING *
`, [
  empresaId,
  dados.nome,
  dados.cnpj || null,
  dados.telefone || null,
  dados.cidade || null,
  dados.estado || null,
  dados.endereco || null,
  dados.numero || null,
  dados.bairro || null,
  dados.cep || null,
  dados.latitude || null,
  dados.longitude || null,
  dados.descricao || null,
  dados.instagram || null,
  dados.facebook || null,
  dados.site || null,
  dados.horario_funcionamento || null,
  dados.plano_id || null,
  dados.status || "ATIVO",
  dados.logo || null
])

const novaLoja =
  r.rows[0]

const template =
  await client.query(
    `
    SELECT
      clausulas,
      garantia,
      transferencia

    FROM loja_clausula

    WHERE padrao = true
    AND ativo = true

    LIMIT 1
    `
  )

const padrao =
  template.rows[0] || {}

await client.query(
console.log(
  "TEMPLATE ENCONTRADO:",
  padrao
)

  `
  INSERT INTO loja_clausula (

    loja_id,
    empresa_id,
    clausulas,
    garantia,
    transferencia

  )

  VALUES ($1,$2,$3,$4,$5)
  `,
  [

    novaLoja.id,

    empresaId,

    padrao.clausulas || "",

    padrao.garantia || "",

    padrao.transferencia || ""
  ]
)

const clausulaCriada =
  await client.query(
    `
    SELECT *
    FROM loja_clausula
    WHERE loja_id = $1
    `,
    [novaLoja.id]
  )

console.log(
  "CLAUSULA CRIADA:",
  clausulaCriada.rows[0]
)

    await client.query("COMMIT")

    return r.rows[0]



  } catch (e) {

    await client.query("ROLLBACK")
    console.error("🔥 ERRO CREATE LOJA:", e)
    throw e

  } finally {

    client.release()
  }
}

/* ===============================
   ATUALIZAR (COM TRANSACTION)
================================ */
exports.atualizar = async (id, empresaId, dados) => {
  const client = await db.connect()

  try {
    await client.query("BEGIN")

console.log(
  "DADOS UPDATE RECEBIDOS:",
  dados
)

const nome =
  Array.isArray(dados.nome)
    ? dados.nome[0]
    : dados.nome

const cnpj =
  Array.isArray(dados.cnpj)
    ? dados.cnpj[0]
    : dados.cnpj

if (
  nome === undefined ||
  nome === null ||
  nome === ""
) {
  throw new Error(
    "Informe o nome"
  )
}

if (
  cnpj === undefined ||
  cnpj === null ||
  cnpj === ""
) {
  throw new Error(
    "CNPJ é obrigatório"
  )
}

dados.nome = nome
dados.cnpj = cnpj

    if (dados.cnpj) {
      const existe = await client.query(`
        SELECT id
        FROM loja
        WHERE cnpj = $1
        AND id <> $2
      `, [dados.cnpj, id])

      if (existe.rows.length) {
        throw new Error("CNPJ já cadastrado")
      }
    }

const r = await client.query(`
  UPDATE loja SET
    nome = $1,
    cnpj = $2,
    telefone = $3,
    cidade = $4,
    estado = $5,
    endereco = $6,
    numero = $7,
    bairro = $8,
    cep = $9,
    latitude = $10,
    longitude = $11,
    descricao = $12,
    instagram = $13,
    facebook = $14,
    site = $15,
    horario_funcionamento = $16,
    status = $17,
    logo = COALESCE($18, logo)
  WHERE id = $19
  AND ($20::int IS NULL OR empresa_id = $20)
  RETURNING *
`, [
  dados.nome,
  dados.cnpj || null,
  dados.telefone || null,
  dados.cidade || null,
  dados.estado || null,
  dados.endereco || null,
  dados.numero || null,
  dados.bairro || null,
  dados.cep || null,
  dados.latitude || null,
  dados.longitude || null,
  dados.descricao || null,
  dados.instagram || null,
  dados.facebook || null,
  dados.site || null,
  dados.horario_funcionamento || null,
  dados.status || "ATIVO",
  dados.logo || null,
  id,
  empresaId
])

    if (!r.rows.length) {
      throw new Error("Loja não encontrada")
    }

    await client.query("COMMIT")

    return r.rows[0]

  } catch (e) {
    await client.query("ROLLBACK")
    console.error("🔥 ERRO UPDATE LOJA:", e)
    throw e

  } finally {
    client.release()
  }
}


/* ===============================
   EXCLUIR (🔥 CORRIGIDO COM CLIENT)
================================ */
exports.excluir = async (id, empresaId, usuario, senha) => {

  const client = await db.connect()

  try {

    if (!usuario.master && usuario.perfil !== "admin") {
      throw new Error("Sem permissão para excluir loja")
    }

    await validarSenha(usuario.id, senha, client)

    await client.query("BEGIN")

    /* 🔥 USUÁRIOS */
    const usuarios = await client.query(`
      SELECT usuario_id FROM usuario_loja WHERE loja_id = $1
    `, [id])

    const idsUsuarios = usuarios.rows.map(u => u.usuario_id)

    let usuariosParaExcluir = []

    if (idsUsuarios.length) {

      const outrosVinculos = await client.query(`
        SELECT usuario_id, COUNT(*) as total
        FROM usuario_loja
        WHERE usuario_id = ANY($1)
        GROUP BY usuario_id
      `, [idsUsuarios])

      usuariosParaExcluir = outrosVinculos.rows
        .filter(u => Number(u.total) === 1)
        .map(u => u.usuario_id)
    }

    /* 🔥 CASCADE */
    await client.query(`DELETE FROM veiculo_documento WHERE loja_id = $1`, [id])
    await client.query(`DELETE FROM veiculo_foto WHERE loja_id = $1`, [id])
    await client.query(`DELETE FROM veiculo_midia WHERE loja_id = $1`, [id])
    await client.query(`DELETE FROM veiculo_opcional WHERE loja_id = $1`, [id])
    await client.query(`DELETE FROM veiculo_proprietario WHERE loja_id = $1`, [id])

await client.query(`
  DELETE FROM loja_clausula
  WHERE loja_id = $1
`, [id])

    await client.query(`DELETE FROM loja_plano WHERE loja_id = $1`, [id])
    await client.query(`DELETE FROM lead WHERE loja_id = $1`, [id])
    await client.query(`DELETE FROM venda WHERE loja_id = $1`, [id])

    await client.query(`DELETE FROM veiculo WHERE loja_id = $1`, [id])

    await client.query(`DELETE FROM usuario_loja WHERE loja_id = $1`, [id])

    if (usuariosParaExcluir.length) {
      await client.query(`
        DELETE FROM usuario WHERE id = ANY($1)
      `, [usuariosParaExcluir])
    }

    const r = await client.query(`
      DELETE FROM loja
      WHERE id=$1
      AND ($2::int IS NULL OR empresa_id = $2)
    `, [id, empresaId])

    if (!r.rowCount) {
      throw new Error("Loja não encontrada")
    }

    await client.query("COMMIT")

    return true

  } catch (e) {

    await client.query("ROLLBACK")
    console.error("🔥 ERRO AO EXCLUIR LOJA:", e)
    throw e

  } finally {

    client.release()
  }
}