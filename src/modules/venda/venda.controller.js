const service = require("./venda.service");
const { isMaster } = require("../../shared/utils/permissao");
const gerarHtmlContrato = require("./contrato.template")

/* ===============================
   REGISTRAR VENDA
================================ */
exports.criar = async (req,res)=>{
  try{

    const empresaId = isMaster(req.user)
      ? req.body.empresa_id
      : req.user.empresa_id

    const lojaId = isMaster(req.user)
      ? req.body.loja_id
      : req.loja_id

    const dados = req.body

    const venda = await service.criar(
      empresaId,
      lojaId,
      dados
    )

    res.json(venda)

  }catch(e){

    console.error("ERRO CRIAR VENDA:", e)
    console.error("STACK:", e.stack)

    res.status(500).json({
      erro: e.message
    })

  }
}

/* ===============================
   LISTAR VENDAS
================================ */
exports.listar = async (req, res) => {
  try {
    const vendas =
      await service.listar(
        req.user.empresa_id,
        req.loja_id
      )

    res.json(vendas)

  } catch (e) {
    console.error(e)

    res.status(500).json({
      erro: e.message
    })
  }
}

/* ===============================
   DETALHES DA VENDA
================================ */
exports.detalhes = async (req,res)=>{
  try{

    const id = req.params.id

    const venda = await service.detalhes(
      id,
      req.user.empresa_id,
      req.loja_id
    )

    res.json(venda)

  }catch(e){

    console.error("ERRO DETALHES VENDA:", e)

    res.status(500).json({
      erro: e.message
    })

  }
}

/* ===============================
   CANCELAR VENDA (CORRIGIDO)
================================ */
exports.cancelar = async (req,res)=>{
  try{

    const empresaId = isMaster(req.user)
      ? null
      : req.user.empresa_id

    const lojaId = isMaster(req.user)
      ? null
      : req.loja_id

    /* 🔥 PEGA ID DA URL */
    const veiculoId = req.params.id

    const { motivo } = req.body

    if(!motivo){
      return res.status(400).json({
        erro:"Motivo do cancelamento é obrigatório"
      })
    }

    const venda = await service.cancelar(
      empresaId,
      lojaId,
      veiculoId,
      motivo
    )

    if (!venda) {
      return res.status(400).json({
        erro: "Venda não encontrada ou já cancelada"
      })
    }

    res.json(venda)

  }catch(e){

    console.error("ERRO CANCELAR VENDA:", e)

    res.status(500).json({
      erro: e.message
    })

  }
}

/* ===============================
   ATUALIZAR VENDA
================================ */
exports.atualizar = async (
  req,
  res
) => {
  try {
    const id =
      req.params.id

    const dados =
      req.body

    await service.atualizar(
      id,
      req.user.empresa_id,
      req.loja_id,
      dados
    )

    res.json({
      sucesso: true
    })

  } catch (e) {
    console.error(
      "ERRO ATUALIZAR VENDA:",
      e
    )

    res.status(500).json({
      erro: e.message
    })
  }
}

exports.contratoPDF = async (req, res) => {
  try {
    const pdf = await service.gerarContratoPDF(
      req.params.id,
      req.user.empresa_id,
      req.loja_id
    )

    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", "inline; filename=contrato.pdf");

    res.send(pdf);

  } 

catch (e) {

  console.error(
    "ERRO GERAR PDF:",
    e
  )

  res.status(500).json({
    erro:
      e.message ||
      String(e)
  })
}

};