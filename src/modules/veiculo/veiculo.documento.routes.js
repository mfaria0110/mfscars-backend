const express = require("express")
const multer = require("multer")
const path = require("path")
const db = require("../../shared/database/db")

const router = express.Router()

/* ===============================
   📎 CONFIG UPLOAD
================================ */
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(
      null,
      path.join(
        __dirname,
        "../../../uploads"
      )
    )
  },

  filename: (req, file, cb) => {
    const nome =
      Date.now() +
      "-" +
      file.originalname

    cb(null, nome)
  }
})

const upload = multer({
  storage
})

/* ===============================
   📥 LISTAR DOCUMENTOS
================================ */
router.get(
  "/:veiculoId",
  async (req, res) => {
    const { veiculoId } =
      req.params

    try {
      const result =
        await db.query(
          `
        SELECT *
        FROM veiculo_documento
        WHERE veiculo_id = $1
        ORDER BY id DESC
        `,
          [veiculoId]
        )

      res.json(
        result.rows
      )

    } catch (e) {
      console.error(
        "ERRO LISTAR DOCUMENTOS:",
        e
      )

      res.status(500).json({
        erro:
          "Erro ao listar documentos"
      })
    }
  }
)

/* ===============================
   📤 UPLOAD DOCUMENTO
================================ */
router.post(
  "/",
  upload.single("arquivo"),
  async (req, res) => {
    const {
      veiculo_id,
      proprietario_id,
      empresa_id,
      loja_id,
      tipo
    } = req.body

    try {
      if (!req.file) {
        return res
          .status(400)
          .json({
            erro:
              "Arquivo obrigatório"
          })
      }

const BASE_URL =
  process.env.BASE_URL ||
  "https://api.mfscars.com.br"

const arquivo =
  `${BASE_URL}/uploads/${req.file.filename}`

      const result =
        await db.query(
          `
        INSERT INTO veiculo_documento (
          veiculo_id,
          proprietario_id,
          empresa_id,
          loja_id,
          tipo,
          arquivo
        )
        VALUES (
          $1,$2,$3,$4,$5,$6
        )
        RETURNING *
        `,
           [
            veiculo_id,
            proprietario_id || null,
            empresa_id || null,
            loja_id || null,
            tipo,
            arquivo
          ]
        )

      res.json(
        result.rows[0]
      )

    } catch (e) {
      console.error(
        "ERRO UPLOAD DOCUMENTO:",
        e
      )

      res.status(500).json({
        erro:
          "Erro ao enviar documento"
      })
    }
  }
)

/* ===============================
   🗑 EXCLUIR DOCUMENTO
================================ */
router.delete(
  "/:id",
  async (req, res) => {
    const { id } =
      req.params

    try {
      const result =
        await db.query(
          `
        DELETE FROM veiculo_documento
        WHERE id = $1
        RETURNING *
        `,
          [id]
        )

      if (
        !result.rows.length
      ) {
        return res
          .status(404)
          .json({
            erro:
              "Documento não encontrado"
          })
      }

      res.json({
        msg:
          "Documento excluído com sucesso"
      })

    } catch (e) {
      console.error(
        "ERRO EXCLUIR DOCUMENTO:",
        e
      )

      res.status(500).json({
        erro:
          "Erro ao excluir documento"
      })
    }
  }
)

module.exports = router