const express = require("express");
const router = express.Router();

/* ===============================
   IMPORTS
================================ */
const auth = require("../../shared/middlewares/auth");
const controller = require("./permissao.controller");
const temPermissao = require("../../shared/middlewares/permissao");

/* ===============================
   🔐 LISTAR
================================ */
router.get(
  "/",
  auth,
  temPermissao("permissao.visualizar"),
  controller.listar
);

/* ===============================
   ➕ CRIAR
================================ */
router.post(
  "/",
  auth,
  temPermissao("permissao.criar"),
  controller.salvar
);

/* ===============================
   ✏️ ATUALIZAR
================================ */
router.put(
  "/:id",
  auth,
  temPermissao("permissao.editar"),
  controller.atualizar
);

/* ===============================
   ❌ EXCLUIR
================================ */
router.delete(
  "/:id",
  auth,
  temPermissao("permissao.excluir"),
  controller.excluir
);

module.exports = router;