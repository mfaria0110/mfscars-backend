const express = require("express")

const controller =
  require("./billing.controller")

const router = express.Router()

router.get(
  "/teste",
  controller.testar
)

router.post(
  "/assinar",
  controller.assinar
)

router.post(
  "/webhook",
  controller.webhook
)

router.post(
  "/pix",
  controller.gerarPix
)

router.get(
  "/status/:payment_id",
  controller.statusPix
)

module.exports = router