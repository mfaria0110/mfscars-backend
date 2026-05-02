const express = require("express");
const router = express.Router();

/* ===============================
   IMPORTS CORRETOS
================================ */
const controller = require("./dashboard.controller");
const auth = require("../../shared/middlewares/auth");
const temPermissao = require("../../shared/middlewares/permissao");
/* ===============================
   ROTAS
================================ */
router.get(
  "/",
  auth,
  temPermissao("dashboard.visualizar"),
  controller.dados
);

module.exports = router;