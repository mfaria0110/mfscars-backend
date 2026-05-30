const db = require('../../shared/database/db');
const bcrypt = require("bcrypt")

const planoService =
  require("../plano/plano.service")

/* ===============================
   CRIAR
================================ */
exports.criar = async (empresaId, dados) => {
  const client = await db.connect()

  try {
    await client.query("BEGIN")

    console.log("🔥 LOJAS NO CREATE:", dados.lojas)

    const {
      nome,
      email,
      senha,
      tipo,
      lojas = []
    } = dados

    const hash = await bcrypt.hash(senha, 10)

    /* =========================
   VALIDA LIMITE VENDEDORES
========================= */

    for (const l of lojas) {

      const lojaId = Number(
        typeof l === "object"
          ? l.loja_id
          : l
      )

      if (!lojaId) continue

      await planoService
        .validarLimiteVendedores(
          client,
          lojaId
        )
    }

    /* 🔥 INSERE USUÁRIO */
    const r = await client.query(`
      INSERT INTO usuario
      (empresa_id, nome, email, senha, tipo, ativo, master)
      VALUES ($1,$2,$3,$4,$5,true,false)
      RETURNING *
    `, [
      empresaId,
      nome,
      email,
      hash,
      tipo || "usuario"
    ])

    const usuarioId = r.rows[0].id

    /* 🔥 INSERE LOJAS + ROLE */
    for (const l of lojas) {
      const lojaId = Number(
        typeof l === "object"
          ? l.loja_id
          : l
      )

      if (!lojaId || isNaN(lojaId)) continue

      const perfil =
        typeof l === "object"
          ? l.perfil || "vendedor"
          : "vendedor"

      const lojaCheck = await client.query(`
        SELECT empresa_id
        FROM loja
        WHERE id = $1
      `, [lojaId])

      if (!lojaCheck.rows.length) continue

      if (
        empresaId !== null &&
        lojaCheck.rows[0].empresa_id !== empresaId
      ) {
        console.log(
          "❌ loja de outra empresa:",
          lojaId
        )
        continue
      }

      /* usuario_loja */
      await client.query(`
        INSERT INTO usuario_loja
        (usuario_id, loja_id, perfil, ativo)
        VALUES ($1,$2,$3,true)
        ON CONFLICT (usuario_id, loja_id)
        DO UPDATE SET perfil = EXCLUDED.perfil
      `, [
        usuarioId,
        lojaId,
        perfil
      ])

      /* usuario_role */
      const roleResult = await client.query(`
        SELECT id
        FROM roles
        WHERE LOWER(nome) = LOWER($1)
        LIMIT 1
      `, [perfil])

      if (roleResult.rows.length) {
        const roleId =
          roleResult.rows[0].id

        await client.query(`
          INSERT INTO usuario_role
          (usuario_id, loja_id, role_id)
          VALUES ($1,$2,$3)
          ON CONFLICT
          (usuario_id, loja_id, role_id)
          DO NOTHING
        `, [
          usuarioId,
          lojaId,
          roleId
        ])
      }
    }

    await client.query("COMMIT")

    return r.rows[0]

  } catch (error) {
    await client.query("ROLLBACK")

    console.error(
      "🔥 ERRO TRANSACTION CREATE:",
      error
    )

    throw error

  } finally {
    client.release()
  }
}

/* ===============================
   LISTAR
================================ */
exports.listar = async ({
  empresaId,
  lojaId,
  isMaster
}) => {

  try {

    let query = `
      SELECT DISTINCT
        u.id,
        u.nome,
        u.email,
        u.tipo,
        u.ativo,
        u.empresa_id
      FROM usuario u
      INNER JOIN usuario_loja ul
        ON ul.usuario_id = u.id
    `

    const params = []

    if (!isMaster) {

      params.push(lojaId)

      query += `
        WHERE ul.loja_id = $${params.length}
      `
    }

    query += `
      ORDER BY u.nome
    `
    console.log("🔥 SQL:", query)
    console.log("🔥 PARAMS:", params)

    const result =
      await db.query(
        query,
        params
      )

    console.log(
      "🔥 RESULTADO:",
      result.rows.length
    )

    return result.rows

  } catch (error) {

    console.error(
      "🔥 ERRO LISTAR:",
      error
    )

    throw error
  }
}

/* ===============================
   ATUALIZAR
================================ */
exports.atualizar = async (
  id,
  empresaId,
  lojaId,
  dados
) => {
  const client = await db.connect()

  try {
    await client.query("BEGIN")

    let {
      nome,
      email,
      senha,
      tipo,
      ativo,
      lojas = []
    } = dados

    ativo =
      ativo === true ||
      ativo === "true"

    lojas = Array.isArray(lojas)
      ? lojas
      : []

    let senhaHash = null

    if (senha) {
      senhaHash = await bcrypt.hash(
        senha,
        10
      )
    }

    /* UPDATE USUÁRIO */
    const result = await client.query(`
      UPDATE usuario SET
        nome = $1,
        email = $2,
        tipo = $3,
        ativo = $4,
        senha = COALESCE($5, senha)
      WHERE id = $6
      AND (
        $7::int IS NULL
        OR empresa_id = $7
      )
    `, [
      nome,
      email,
      tipo,
      ativo,
      senhaHash,
      id,
      empresaId
    ])

    console.log(
      "✅ UPDATE USUARIO:",
      result.rowCount
    )

    /* LOJAS ATUAIS */
    const atuais =
      await client.query(`
        SELECT loja_id
        FROM usuario_loja
        WHERE usuario_id = $1
      `, [id])

    const lojasAtuais =
      atuais.rows.map(r =>
        Number(r.loja_id)
      )

    const lojasNovas =
      lojas.map(l =>
        Number(
          typeof l === "object"
            ? l.loja_id
            : l
        )
      )

    /* REMOVE LOJAS DESMARCADAS */
    for (const lojaIdAtual of lojasAtuais) {
      if (
        !lojasNovas.includes(
          lojaIdAtual
        )
      ) {
        await client.query(`
          DELETE FROM usuario_loja
          WHERE usuario_id = $1
          AND loja_id = $2
        `, [
          id,
          lojaIdAtual
        ])

        await client.query(`
          DELETE FROM usuario_role
          WHERE usuario_id = $1
          AND loja_id = $2
        `, [
          id,
          lojaIdAtual
        ])
      }
    }

    /* INSERE / ATUALIZA NOVAS */
    for (const l of lojas) {
      const lojaIdNovo = Number(
        typeof l === "object"
          ? l.loja_id
          : l
      )

      if (
        !lojaIdNovo ||
        isNaN(lojaIdNovo)
      ) continue

      const perfil =
        typeof l === "object"
          ? l.perfil || "vendedor"
          : "vendedor"

      const lojaCheck =
        await client.query(`
          SELECT empresa_id
          FROM loja
          WHERE id = $1
        `, [lojaIdNovo])

      if (
        !lojaCheck.rows.length
      ) continue

      if (
        empresaId !== null &&
        lojaCheck.rows[0]
          .empresa_id !== empresaId
      ) {
        console.log(
          "❌ loja inválida:",
          lojaIdNovo
        )
        continue
      }

      /* usuario_loja */
      await client.query(`
        INSERT INTO usuario_loja
        (usuario_id, loja_id, perfil, ativo)
        VALUES ($1,$2,$3,true)
        ON CONFLICT
        (usuario_id, loja_id)
        DO UPDATE SET
        perfil = EXCLUDED.perfil
      `, [
        id,
        lojaIdNovo,
        perfil
      ])

      /* limpa role antiga */
      await client.query(`
        DELETE FROM usuario_role
        WHERE usuario_id = $1
        AND loja_id = $2
      `, [
        id,
        lojaIdNovo
      ])

      /* insere nova role */
      const roleResult =
        await client.query(`
          SELECT id
          FROM roles
          WHERE LOWER(nome) = LOWER($1)
          LIMIT 1
        `, [perfil])

      if (
        roleResult.rows.length
      ) {
        const roleId =
          roleResult.rows[0].id

        await client.query(`
          INSERT INTO usuario_role
          (usuario_id, loja_id, role_id)
          VALUES ($1,$2,$3)
        `, [
          id,
          lojaIdNovo,
          roleId
        ])
      }
    }

    await client.query("COMMIT")

    return {
      msg: "Usuário atualizado"
    }

  } catch (error) {
    await client.query("ROLLBACK")

    console.error(
      "🔥 ERRO TRANSACTION:",
      error
    )

    throw error

  } finally {
    client.release()
  }
}

/* ===============================
   EXCLUIR
================================ */
exports.excluir = async (
  id,
  empresaId,
  lojaId
) => {
  const client = await db.connect()

  try {
    await client.query("BEGIN")

    /* ===============================
       VALIDA VÍNCULO COM LOJA
    ============================== */
    if (lojaId) {
      const acesso =
        await client.query(`
          SELECT 1
          FROM usuario_loja
          WHERE usuario_id = $1
          AND loja_id = $2
        `, [id, lojaId])

      if (!acesso.rows.length) {
        throw new Error(
          "Usuário não pertence à sua loja"
        )
      }
    }

    /* REMOVE LOJAS */
    await client.query(`
      DELETE FROM usuario_loja
      WHERE usuario_id = $1
    `, [id])

    /* REMOVE ROLES */
    await client.query(`
      DELETE FROM usuario_role
      WHERE usuario_id = $1
    `, [id])

    /* REMOVE USUÁRIO */
    const result =
      await client.query(`
        DELETE FROM usuario
        WHERE id = $1
        ${
          empresaId
            ? "AND empresa_id = $2"
            : ""
        }
      `,
      empresaId
        ? [id, empresaId]
        : [id]
    )

    if (
      result.rowCount === 0
    ) {
      throw new Error(
        "Usuário não encontrado ou sem permissão"
      )
    }

    await client.query("COMMIT")

    return {
      ok: true
    }

  } catch (error) {
    await client.query("ROLLBACK")

    console.error(
      "ERRO EXCLUIR USUARIO:",
      error
    )

    throw error

  } finally {
    client.release()
  }
}

exports.detalhes = async (
  id,
  empresaId,
  lojaId
) => {
  const params = [id]

  let where = `WHERE u.id = $1`

  if (empresaId) {
    params.push(empresaId)
    where += ` AND u.empresa_id = $${params.length}`
  }

  const query = `
    SELECT 
      u.*,
      COALESCE(
        json_agg(
          json_build_object(
            'loja_id', ul.loja_id,
            'perfil', ul.perfil
          )
        ) FILTER (WHERE ul.loja_id IS NOT NULL),
        '[]'
      ) AS lojas
    FROM usuario u
    LEFT JOIN usuario_loja ul
      ON ul.usuario_id = u.id
    ${where}
    GROUP BY u.id
  `

  const result = await db.query(query, params)

  if (!result.rows.length) {
    throw new Error("Usuário não encontrado")
  }

  return result.rows[0]
}