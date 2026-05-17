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

router.put(
  "/:id",
  auth,
  controller.editar
)

module.exports =
  router