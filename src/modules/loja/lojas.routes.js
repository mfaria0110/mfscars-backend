const express = require("express")
const router = express.Router()
const multer = require("multer")
const path = require("path")
const fs = require("fs")

const controller =
  require("./lojas.controller")

const auth =
  require("../../shared/middlewares/auth")

const temPermissao =
  require("../../shared/middlewares/permissao")

/* =========================
   GARANTIR PASTA LOGOS
========================= */
const logosPath = path.join(
  __dirname,
  "../../../uploads/logos"
)

if (!fs.existsSync(logosPath)) {
  fs.mkdirSync(logosPath, {
    recursive: true
  })
}

/* =========================
   CONFIG MULTER
========================= */
const storage =
  multer.diskStorage({
    destination: (
      req,
      file,
      cb
    ) => {
      cb(
        null,
        logosPath
      )
    },

    filename: (
      req,
      file,
      cb
    ) => {
      const nomeArquivo =
        Date.now() +
        path.extname(
          file.originalname
        )

      cb(
        null,
        nomeArquivo
      )
    }
  })

const uploadLogo =
  multer({
    storage
  })

router.use(auth)

/* TODAS */
router.get(
  "/todas",
  controller.todas
)

/* LISTAR */
router.get(
  "/",
  temPermissao(
    "loja.visualizar"
  ),
  controller.listar
)

/* DETALHES */
router.get(
  "/:id",
  temPermissao(
    "loja.visualizar"
  ),
  controller.detalhes
)

/* CRIAR */
router.post(
  "/",
  temPermissao(
    "loja.criar"
  ),
  uploadLogo.single(
    "logo"
  ),
  controller.criar
)

/* ATUALIZAR */
router.put(
  "/:id",
  temPermissao(
    "loja.editar"
  ),
  uploadLogo.single(
    "logo"
  ),
  controller.atualizar
)

/* EXCLUIR */
router.delete(
  "/:id",
  temPermissao(
    "loja.excluir"
  ),
  controller.excluir
)

module.exports = router