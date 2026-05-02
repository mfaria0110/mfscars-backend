const express = require("express")
const router = express.Router()

const db = require("../../shared/database/db")
const auth = require("../../shared/middlewares/auth")
const temPermissao = require("../../shared/middlewares/permissao")

router.get(
  "/marcas",
  auth,
  temPermissao("veiculo.visualizar"),
  async (req, res) => {
    try {
      const r = await db.query(`
        SELECT id, nome
        FROM marca
        ORDER BY nome
      `)

      res.json(r.rows)

    } catch (e) {
      console.error(e)

      res.status(500).json({
        erro: "Erro ao buscar marcas"
      })
    }
  }
)

router.get(
  "/modelos",
  auth,
  temPermissao("veiculo.visualizar"),
  async (req, res) => {
    try {
      const { marca_id } = req.query

      if (!marca_id) {
        return res.status(400).json({
          erro: "marca_id obrigatório"
        })
      }

      const r = await db.query(`
        SELECT id, nome
        FROM modelo
        WHERE marca_id = $1
        ORDER BY nome
      `, [marca_id])

      res.json(r.rows)

    } catch (e) {
      console.error(e)

      res.status(500).json({
        erro: "Erro ao buscar modelos"
      })
    }
  }
)

module.exports = router