const db =
  require(
    "../../shared/database/db"
  )

/* =========================
   LISTAR
========================= */

exports.listar =
  async () => {

    const result =
      await db.query(`

        SELECT

          id,
          nome,
          email,
          telefone,
          cidade,
          estado,
          cnpj,
          ativo,
          data_cadastro

        FROM empresa

        ORDER BY id DESC

      `)

    return result.rows
  }

/* =========================
   BUSCAR
========================= */

exports.buscar =
  async (id) => {

    const result =
      await db.query(`

        SELECT *

        FROM empresa

        WHERE id = $1

      `, [id])

    return result.rows[0]
  }

/* =========================
   EDITAR
========================= */

exports.editar =
  async (
    id,
    data
  ) => {

    const result =
      await db.query(`

        UPDATE empresa

        SET

          nome = $1,
          email = $2,
          telefone = $3,
          cidade = $4,
          estado = $5,
          cnpj = $6

        WHERE id = $7

        RETURNING *

      `, [

        data.nome,
        data.email,
        data.telefone,
        data.cidade,
        data.estado,
        data.cnpj,
        id

      ])

    return result.rows[0]
  }

/* =========================
   BUSCAR USUÁRIO
========================= */

exports.buscarUsuario =
  async (id) => {

    const result =
      await db.query(`

        SELECT *

        FROM usuario

        WHERE id = $1

      `, [id])

    return result.rows[0]
  }

/* =========================
   DESATIVAR
========================= */

exports.desativar =
  async ({
    empresaId,
    motivo,
    observacao,
    usuario,
    ip,
    userAgent
  }) => {

    const empresa =
      await exports.buscar(
        empresaId
      )

    await db.query(`

      UPDATE empresa

      SET ativo = false

      WHERE id = $1

    `, [empresaId])

    await db.query(`

      INSERT INTO
        empresa_exclusao (

          empresa_id,
          empresa_nome,
          empresa_email,
          cnpj,
          motivo,
          observacao,
          desativado_por,
          desativado_por_nome,
          ip,
          user_agent

        )

      VALUES (

        $1,
        $2,
        $3,
        $4,
        $5,
        $6,
        $7,
        $8,
        $9,
        $10

      )

    `, [

      empresa.id,
      empresa.nome,
      empresa.email,
      empresa.cnpj,
      motivo,
      observacao,
      usuario.id,
      usuario.nome,
      ip,
      userAgent

    ])

    return {

      ok: true

    }
  }

/* =========================
   RESTAURAR
========================= */

exports.restaurar =
  async (empresaId) => {

    await db.query(`

      UPDATE empresa

      SET ativo = true

      WHERE id = $1

    `, [empresaId])

    await db.query(`

      UPDATE empresa_exclusao

      SET

        status = 'restaurado',
        restaurado_em = NOW()

      WHERE empresa_id = $1
      AND status = 'pendente'

    `, [empresaId])

    return {

      ok: true

    }
  }