const express = require("express")
const db = require("../../shared/database/db");

const router = express.Router()

/* ===============================
   📥 GET PROPRIETARIO
================================ */
router.get("/:veiculoId", async (req, res) => {

  const { veiculoId } = req.params

  try {
    const result = await db.query(
      "SELECT * FROM veiculo_proprietario WHERE veiculo_id = $1 LIMIT 1",
      [veiculoId]
    )

    res.json(result.rows[0] || null)

  } catch (e) {
    console.error(e)
    res.status(500).json({ erro: "Erro ao buscar proprietário" })
  }
})

/* ===============================
   💾 SALVAR PROPRIETARIO
================================ */
router.post("/", async (req, res) => {

  const {
    veiculo_id,
    nome,
    cpf_cnpj,
    telefone,
    email,
    endereco
  } = req.body

  try {

    const result = await db.query(`
      INSERT INTO veiculo_proprietario
      (veiculo_id, nome, cpf_cnpj, telefone, email, endereco)
      VALUES ($1,$2,$3,$4,$5,$6)
      RETURNING *
    `, [veiculo_id, nome, cpf_cnpj, telefone, email, endereco])

    res.json(result.rows[0])

  } catch (e) {
    console.error(e)
    res.status(500).json({ erro: "Erro ao salvar proprietário" })
  }
})

module.exports = router