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

module.exports = router