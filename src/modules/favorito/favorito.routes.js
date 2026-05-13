const express = require("express");
const router = express.Router();

/* ===============================
   IMPORTS CORRETOS
================================ */
const auth = require("../../shared/middlewares/auth");
const controller = require("./favorito.controller");

/* ===============================
   ROTAS
================================ */
router.post("/:id", auth, controller.toggle);
router.get("/", auth, controller.listar);

module.exports = router;