const express = require("express")
const router = express.Router()

const usuarioController = require("./usuario.controller")
const auth = require("../../shared/middlewares/auth")
const loadLoja = require("../../shared/middlewares/loadLoja")
const temPermissao = require("../../shared/middlewares/permissao")

// ✅ IMPORT DO DB NO TOPO (PADRÃO)
const db = require("../../shared/database/db")

/* ===============================
   MIDDLEWARES GLOBAIS
============================== */
router.use(auth)

/* ===============================
   ROTA OPERACIONAL (SEM LOJA)
============================== */
router.get("/empresa-simples", async (req, res) => {
  try {
    const { rows } = await db.query(
      `
      SELECT id, nome
      FROM usuario
      WHERE empresa_id = $1
      AND ativo = true
      ORDER BY nome
      `,
      [req.user.empresa_id]
    )

    res.json(rows)

  } catch (e) {
    console.error("🔥 ERRO /usuarios/empresa-simples:", e)

    res.status(500).json({
      erro: "Erro ao buscar usuários"
    })
  }
})

/* ===============================
   MIDDLEWARE LOJA (APÓS ROTA LIVRE)
============================== */
router.use(loadLoja)

/* ===============================
   ROTAS PROTEGIDAS
============================== */

router.get(
  "/",
  temPermissao("usuario.visualizar"),
  usuarioController.listar
)

router.get(
  "/:id",
  temPermissao("usuario.visualizar"),
  usuarioController.detalhes
)

router.post(
  "/",
  temPermissao("usuario.criar"),
  usuarioController.criar
)

router.put(
  "/:id",
  temPermissao("usuario.editar"),
  usuarioController.atualizar
)

router.put(
  "/:id/status",
  temPermissao("usuario.editar"),
  usuarioController.alterarStatus
)

router.delete(
  "/:id",
  temPermissao("usuario.excluir"),
  usuarioController.excluir
)

module.exports = router