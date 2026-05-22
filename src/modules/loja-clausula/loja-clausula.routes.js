const router =
  require("express").Router()

const controller =
  require("./loja-clausula.controller")

router.get(
  "/:lojaId",
  controller.buscar
)

router.post(
  "/",
  controller.salvar
)

module.exports = router