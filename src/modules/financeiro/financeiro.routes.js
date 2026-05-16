const express =
  require("express")

const controller =
  require("./financeiro.controller")

const auth =
  require(
    "../../shared/middlewares/auth"
  )

const router =
  express.Router()

/* =========================
   RESUMO
========================= */

router.get(
  "/resumo",
  auth,
  controller.resumo
)

/* =========================
   COBRANÇAS
========================= */

router.get(
  "/cobrancas",
  auth,
  controller.cobrancas
)

module.exports =
  router