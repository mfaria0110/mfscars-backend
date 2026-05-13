const express = require("express")
const router = express.Router()

const authController = require("./auth.controller")
const auth = require("../../shared/middlewares/auth")

router.post("/cadastro", authController.cadastro)

router.post("/login", authController.login)
router.post("/selecionar-loja", auth, authController.selecionarLoja)

/* 🔐 NOVA ROTA DE VALIDAÇÃO */
router.get("/me", auth, authController.me)

router.post("/refresh", authController.refresh)

module.exports = router