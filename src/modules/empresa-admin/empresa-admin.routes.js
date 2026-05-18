const express =
  require("express")

const router =
  express.Router()

const controller =
  require(
    "./empresa-admin.controller"
  )

const auth =
  require(
    "../../shared/middlewares/auth"
  )

router.get(
  "/",
  auth,
  controller.listar
)

router.get(
  "/:id",
  auth,
  controller.buscar
)

router.put(
  "/:id",
  auth,
  controller.editar
)

router.post(
  "/:id/desativar",
  auth,
  controller.desativar
)

router.post(
  "/:id/restaurar",
  auth,
  controller.restaurar
)

module.exports =
  router