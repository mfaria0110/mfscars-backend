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

/* =========================
   LOJAS
========================= */

router.get(
  "/lojas",
  auth,
  controller.lojas
)

/* =========================
   PLANOS
========================= */

router.get(
  "/planos",
  auth,
  controller.planos
)

module.exports =
  router;