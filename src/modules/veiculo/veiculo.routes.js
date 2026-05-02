const express = require("express")
const router = express.Router()

const auth = require("../../shared/middlewares/auth")
const loadLoja = require("../../shared/middlewares/loadLoja")
const lojaAtiva = require("../../shared/middlewares/lojaAtiva")
const temPermissao = require("../../shared/middlewares/permissao")

const controller = require("./veiculo.controller")

/* ===============================
   🌐 ROTAS PÚBLICAS (SEM AUTH)
================================ */
router.get(
  "/public/:id",
  controller.detalhesPublico
)

router.get(
  "/public/veiculos",
  controller.listarPublico
)

/* ===============================
   🔐 MIDDLEWARES GLOBAIS
================================ */
router.use(auth)
router.use(loadLoja)
router.use(lojaAtiva)

/* ===============================
   🚗 MARCAS
================================ */
router.get(
  "/marcas",
  temPermissao("veiculo.visualizar"),
  controller.marcas
)

/* ===============================
   🚗 MODELOS
================================ */
router.get(
  "/modelos",
  temPermissao("veiculo.visualizar"),
  controller.modelos
)

/* ===============================
   🚗 LISTAR VEÍCULOS DA LOJA
================================ */
router.get(
  "/empresa",
  temPermissao("veiculo.visualizar"),
  controller.veiculosEmpresa
)

/* ===============================
   🚗 OPCIONAIS
================================ */
router.get(
  "/opcionais",
  temPermissao("veiculo.visualizar"),
  controller.opcionais
)

/* ===============================
   🚗 SIMILARES
================================ */
router.get(
  "/similares/:id",
  temPermissao("veiculo.visualizar"),
  controller.similares
)

/* ===============================
   📸 FOTOS
================================ */

/* LISTAR FOTOS */
router.get(
  "/:id/fotos",
  temPermissao("veiculo.visualizar"),
  controller.fotos
)

/* UPLOAD FOTOS */
router.post(
  "/:id/fotos",
  temPermissao("veiculo.editar"),
  controller.uploadMiddleware,
  controller.uploadFoto
)

/* REMOVER FOTO */
router.delete(
  "/fotos/:id",
  temPermissao("veiculo.editar"),
  controller.removerFoto
)

/* REMOVER DOCUMENTO */
router.delete(
  "/documentos/:id",
  temPermissao("veiculo.editar"),
  controller.excluirDocumento
)

/* DEFINIR FOTO PRINCIPAL */
router.put(
  "/fotos/:id/principal",
  temPermissao("veiculo.editar"),
  controller.fotoPrincipal
)

/* ===============================
   OPCIONAIS DO VEICULO
================================ */
router.get(
  "/:id/opcionais",
  temPermissao("veiculo.visualizar"),
  controller.opcionaisVeiculo
)

/* ===============================
   CRUD VEICULO
================================ */
router.post(
  "/",
  temPermissao("veiculo.criar"),
  controller.criar
)

router.put(
  "/:id",
  temPermissao("veiculo.editar"),
  controller.atualizar
)

router.delete(
  "/:id",
  temPermissao("veiculo.excluir"),
  controller.excluir
)

/* ===============================
   🔐 DETALHES PRIVADO
================================ */
router.get(
  "/:id",
  temPermissao("veiculo.visualizar"),
  controller.detalhesCompleto
)

module.exports = router