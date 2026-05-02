const express = require("express")
const router = express.Router()

const controller = require("./venda.controller")
const auth = require("../../shared/middlewares/auth")
const loadLoja = require("../../shared/middlewares/loadLoja")
const lojaAtiva = require("../../shared/middlewares/lojaAtiva")
const temPermissao = require("../../shared/middlewares/permissao")

/* ===============================
   MIDDLEWARES GLOBAIS
================================ */
router.use(auth)
router.use(loadLoja)
router.use(lojaAtiva)

/* ===============================
   REGISTRAR VENDA
================================ */
router.post(
  "/",
  temPermissao("venda.criar"),
  controller.criar
)

/* ===============================
   GERAR CONTRATO PDF
================================ */
router.get(
  "/:id/contrato-pdf",
  temPermissao("venda.visualizar"),
  controller.contratoPDF
)

/* ===============================
   EXPORTAR VENDAS (🔥 NOVO COMPLETO)
================================ */
router.get("/exportar", async (req, res) => {
  try {
    const db = require("../../shared/database/db")
    const user = req.user

    // 🔒 PERMISSÃO
    if (
      !user.master &&
      user.tipo !== "admin" &&
      user.tipo !== "financeiro"
    ) {
      return res.status(403).json({
        erro: "Sem permissão para exportar"
      })
    }

    const { rows } = await db.query(`
SELECT
  v.id,
  v.data_venda,
  v.nome_comprador,

  -- empresa e loja
  e.nome AS empresa,
  l.nome AS loja,

  -- veículo
  ve.marca,
  ve.modelo,
  ve.placa,

  -- valores
  v.valor_venda,
  COALESCE(v.valor_entrada, 0) AS valor_entrada,

  -- 🔥 financiado
  (v.valor_venda - COALESCE(v.valor_entrada, 0)) AS valor_financiado,

  COALESCE(v.valor_parcela, 0) AS valor_parcela,
  COALESCE(v.parcelas, 0) AS parcelas,

  v.condicao_pagamento,
  v.banco_financiamento,

  -- vendedor (texto)
  v.vendedor,

  v.status

FROM venda v
JOIN veiculo ve ON ve.id = v.veiculo_id
JOIN loja l ON l.id = v.loja_id
JOIN empresa e ON e.id = v.empresa_id

WHERE v.empresa_id = $1

ORDER BY v.data_venda DESC
    `, [user.empresa_id])

    res.json(rows)

  } catch (e) {
    console.error("ERRO EXPORT:", e)

    res.status(500).json({
      erro: "Erro ao exportar vendas"
    })
  }
})

/* ===============================
   CANCELAR VENDA
================================ */
router.put(
  "/cancelar/:id",
  temPermissao("venda.cancelar"),
  controller.cancelar
)

/* ===============================
   LISTAR VENDAS
================================ */
router.get(
  "/",
  temPermissao("venda.visualizar"),
  controller.listar
)

/* ===============================
   EDITAR VENDA
================================ */
router.put(
  "/:id",
  temPermissao("venda.editar"),
  controller.atualizar
)

/* ===============================
   DETALHES DA VENDA
================================ */
router.get(
  "/:id",
  temPermissao("venda.visualizar"),
  controller.detalhes
)

module.exports = router