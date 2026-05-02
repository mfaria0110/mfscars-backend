const express = require("express")
const router = express.Router()

const auth = require("../../shared/middlewares/auth")
const controller = require("./menu.controller")

router.get("/", auth, controller.listar)

module.exports = router