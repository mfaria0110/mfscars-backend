const express = require("express")
const router = express.Router()

const db =
  require("../../shared/database/db")

const auth =
  require("../../shared/middlewares/auth")

const loadLoja =
  require("../../shared/middlewares/loadLoja")

const loja =
  require("../../shared/middlewares/loja")

const lojaAtiva =
  require("../../shared/middlewares/lojaAtiva")

const temPermissao =
  require("../../shared/middlewares/permissao")

/* ===============================
   LISTAR PLANOS
=============================== */
router.get(
  "/",
  auth,
  async (req, res) => {
    try {
      const result =
        await db.query(`
          SELECT
            id,
            nome,
            preco,
            limite_veiculos,
            limite_lojas,
            limite_vendedores,
            desconto_founders,
            destaque
          FROM plano
          WHERE ativo = true
          ORDER BY id ASC
        `)

      res.json(
        result.rows
      )

    } catch (err) {
      console.error(
        "ERRO PLANOS:",
        err
      )

      res.status(500).json({
        erro:
          "Erro ao buscar planos"
      })
    }
  }
)

/* ===============================
   PLANO ATUAL
=============================== */
router.get(
  "/atual",

  auth,

  /*
    ORDEM CORRETA
  */
  loadLoja,
  loja,
  lojaAtiva,

  temPermissao(
    "plano.visualizar"
  ),

  async (req, res) => {
    try {
      const loja_id =
        Number(
          req.loja_id
        )

      if (
        !loja_id ||
        isNaN(loja_id)
      ) {
        return res
          .status(400)
          .json({
            erro:
              "Selecione uma loja válida"
          })
      }

      const result =
        await db.query(
          `
SELECT
  lp.id,
  lp.loja_id,
  lp.plano_id,
  lp.status,
  lp.gateway,
  lp.forma_pagamento,
  lp.data_inicio,
  lp.data_fim,
  lp.ciclo_inicio,
  lp.ciclo_fim,
  lp.valor_pago,
  lp.founders,

  p.nome,
  p.preco,

  p.limite_veiculos,
  p.limite_lojas,
  p.limite_vendedores,
  p.desconto_founders,

  (
    SELECT COUNT(*)
    FROM veiculo v
    WHERE v.loja_id = lp.loja_id
    AND v.status = 'disponivel'
  ) AS usados_veiculos,

  (
    SELECT COUNT(*)
    FROM loja l
    WHERE l.empresa_id = (
      SELECT empresa_id
      FROM loja
      WHERE id = lp.loja_id
    )
  ) AS usados_lojas,

  (
    SELECT COUNT(*)
    FROM usuario_loja ul
    WHERE ul.loja_id = lp.loja_id
    AND ul.ativo = true
    AND ul.perfil = 'vendedor'
  ) AS usados_vendedores

        `,
          [loja_id]
        )

      res.json(
        result.rows[0] ||
          null
      )

    } catch (err) {
      console.error(
        "ERRO PLANO ATUAL:",
        err
      )

      res.status(500).json({
        erro:
          "Erro ao buscar plano atual"
      })
    }
  }
)

/* ===============================
   UPGRADE PLANO
=============================== */
router.post(
  "/upgrade",

  auth,

  loadLoja,
  loja,

  temPermissao(
    "plano.editar"
  ),

  async (req, res) => {
    const client =
      await db.connect()

    try {
      const {
        plano_id
      } = req.body

      const loja_id =
        req.loja_id

      if (
        !plano_id ||
        !loja_id
      ) {
        return res
          .status(400)
          .json({
            erro:
              "Dados obrigatórios"
          })
      }

      await client.query(
        "BEGIN"
      )

      await client.query(
        `
        UPDATE loja_plano
        SET status = 'inativo'
        WHERE loja_id = $1
        AND status = 'ativo'
      `,
        [loja_id]
      )

      const result =
        await client.query(
          `
          INSERT INTO loja_plano (
            loja_id,
            plano_id,
            data_inicio,
            status,
            valor_pago,
            data_pagamento,
            usados
          )
          VALUES (
            $1,
            $2,
            NOW(),
            'ativo',
            (
              SELECT preco
              FROM plano
              WHERE id = $2
            ),
            NOW(),
            0
          )
          RETURNING *
        `,
          [
            loja_id,
            plano_id
          ]
        )

      await client.query(
        "COMMIT"
      )

      res.json({
        sucesso: true,
        plano:
          result.rows[0]
      })

    } catch (err) {
      await client.query(
        "ROLLBACK"
      )

      console.error(
        "ERRO UPGRADE:",
        err
      )

      res.status(500).json({
        erro:
          "Erro ao alterar plano"
      })

    } finally {
      client.release()
    }
  }
)

module.exports =
  router