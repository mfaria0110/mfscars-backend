const express = require("express")
const router = express.Router()

const controller = require("./lead.controller")
const auth = require("../../shared/middlewares/auth")

/* criar lead (público) */
router.post("/", controller.criar)

/* listar leads da empresa */
router.get("/empresa", auth, controller.listarEmpresa)

module.exports = router