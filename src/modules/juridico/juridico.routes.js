const express = require("express")

const controller = require("./juridico.controller")

const auth = require("../../shared/middlewares/auth")

const router =
  express.Router()

router.get(
  "/",
  auth,
  controller.listar
)

router.post(
  "/",
  auth,
  controller.criar
)

router.post(
  "/nova-versao/:id",
  auth,
  controller.novaVersao
)

router.get(
  "/verificar-aceite",
  auth,
  controller.verificarAceite
)

router.post(
  "/aceitar",
  auth,
  controller.aceitar
)

router.put(
  "/:id",
  auth,
  controller.editar
)

module.exports =
  router