const express = require("express")
const db = require("../../shared/database/db")

const router = express.Router()

/* ===============================
   📥 GET PROPRIETARIO
================================ */
router.get("/:veiculoId", async (req, res) => {

  const { veiculoId } = req.params

  try {

    const result = await db.query(
      `
      SELECT *
      FROM veiculo_proprietario
      WHERE veiculo_id = $1
      LIMIT 1
      `,
      [veiculoId]
    )

    res.json(result.rows[0] || null)

  } catch (e) {

    console.error(e)

    res.status(500).json({
      erro: "Erro ao buscar proprietário"
    })
  }
})

/* ===============================
   💾 SALVAR PROPRIETARIO
================================ */
router.post("/", async (req, res) => {

  const {
    veiculo_id,
    empresa_id,
    loja_id,
    nome,
    cpf_cnpj,
    telefone,
    email,
    endereco
  } = req.body

  try {

    /* 🔥 VERIFICA SE JÁ EXISTE */
    const existe = await db.query(
      `
      SELECT id
      FROM veiculo_proprietario
      WHERE veiculo_id = $1
      LIMIT 1
      `,
      [veiculo_id]
    )

    /* ======================================
       🔥 UPDATE
    ====================================== */
    if (existe.rows.length > 0) {

      const result = await db.query(
        `
        UPDATE veiculo_proprietario
        SET
          empresa_id = $1,
          loja_id = $2,
          nome = $3,
          cpf_cnpj = $4,
          telefone = $5,
          email = $6,
          endereco = $7
        WHERE veiculo_id = $8
        RETURNING *
        `,
        [
          empresa_id || null,
          loja_id || null,
          nome,
          cpf_cnpj,
          telefone,
          email,
          endereco,
          veiculo_id
        ]
      )

      return res.json(result.rows[0])
    }

    /* ======================================
       🔥 INSERT
    ====================================== */
    const result = await db.query(
      `
      INSERT INTO veiculo_proprietario (
        veiculo_id,
        empresa_id,
        loja_id,
        nome,
        cpf_cnpj,
        telefone,
        email,
        endereco
      )
      VALUES (
        $1,$2,$3,$4,$5,$6,$7,$8
      )
      RETURNING *
      `,
      [
        veiculo_id,
        empresa_id || null,
        loja_id || null,
        nome,
        cpf_cnpj,
        telefone,
        email,
        endereco
      ]
    )

    res.json(result.rows[0])

  } catch (e) {

    console.error(e)

    res.status(500).json({
      erro: "Erro ao salvar proprietário"
    })
  }
})

/* ===============================
   🗑 EXCLUIR PROPRIETARIO
================================ */
router.delete("/:veiculoId", async (req, res) => {

  const { veiculoId } = req.params

  try {

    await db.query(`
      DELETE FROM veiculo_proprietario
      WHERE veiculo_id = $1
    `, [veiculoId])

    res.json({
      sucesso: true
    })

  } catch (e) {
    console.error(e)

    res.status(500).json({
      erro: "Erro ao excluir proprietário"
    })
  }
})

module.exports = router