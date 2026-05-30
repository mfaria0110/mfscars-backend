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


console.log("===== PLANO ATUAL =====")
console.log("req.loja_id =", req.loja_id)
console.log("req.lojaId =", req.lojaId)


      const result =
        await db.query(
          `
SELECT
  lp.*,

  p.nome,
  p.preco,

  p.limite_veiculos,
  p.limite_lojas,
  p.limite_vendedores,
  p.desconto_founders,

  (
    SELECT COUNT(*)
    FROM veiculo v
    WHERE
      v.loja_id = lp.loja_id
      AND LOWER(v.status) = 'disponivel'
  ) AS usados_veiculos,

  (
    SELECT COUNT(*)
    FROM usuario_loja ul
    JOIN usuario u
      ON u.id = ul.usuario_id
    WHERE
      ul.loja_id = lp.loja_id
      AND ul.ativo = true
      AND u.master = false
  ) AS usados_vendedores,

  (
    SELECT COUNT(*)
    FROM loja l
    WHERE
      l.empresa_id =
      (
        SELECT empresa_id
        FROM loja
        WHERE id = lp.loja_id
      )
      AND LOWER(l.status) = 'ativo'
  ) AS usados_lojas

FROM loja_plano lp

JOIN plano p
  ON p.id = lp.plano_id

WHERE
  lp.loja_id = $1
  AND lp.status = 'ativo'

ORDER BY lp.data_inicio DESC

LIMIT 1
        `,
          [loja_id]
        )


console.log(
  "RESULTADO:",
  result.rows[0]
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
      ciclo_inicio,
      status,
      valor_pago,
      data_pagamento
    )
    VALUES (
      $1,
      $2,
      NOW(),
      NOW(),
      'ativo',
      (
        SELECT preco
        FROM plano
        WHERE id = $2
      ),
      NOW()
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