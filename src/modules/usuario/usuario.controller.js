const service = require("./usuario.service")
const {
  isMaster
} = require("../../shared/utils/permissao")

/* ===============================
   CRIAR
============================== */
exports.criar = async (req, res) => {
  try {
    const empresaId = req.user.empresa_id

    const {
      nome,
      email,
      senha,
      tipo
    } = req.body

    if (!nome || !email || !senha || !tipo) {
      return res.status(400).json({
        erro: "Nome, email, senha e tipo são obrigatórios"
      })
    }

    const data = await service.criar(
      empresaId,
      req.body
    )

    res.json(data)

  } catch (e) {
    console.error(e)

    if (e.code === "23505") {
      return res.status(400).json({
        erro: "Email já cadastrado"
      })
    }

    res.status(500).json({
      erro: e.message
    })
  }
}

/* ===============================
   LISTAR
============================== */
exports.listar = async (req, res) => {
  try {

    const master = isMaster(req.user)

    const empresaId = master
      ? null
      : req.user.empresa_id

    console.log("🔥 LISTAR → master:", master)
    console.log("🔥 LISTAR → empresaId:", empresaId)

    const data = await service.listar({
      empresaId,
      isMaster: master
    })

    res.json(data)

  } catch (e) {
    console.error(e)

    res.status(500).json({
      erro: "Erro ao listar usuários"
    })
  }
}

/* ===============================
   DETALHES
============================== */
exports.detalhes = async (req, res) => {
  try {

    const empresaId =
      isMaster(req.user)
        ? null
        : req.user.empresa_id

    const lojaId = req.loja_id // 🔥 CORRIGIDO

    const data = await service.detalhes(
      req.params.id,
      empresaId,
      lojaId
    )

    res.json(data)

  } catch (e) {
    console.error(e)

    res.status(500).json({
      erro: "Erro ao buscar usuário"
    })
  }
}

/* ===============================
   ATUALIZAR
============================== */
exports.atualizar = async (req, res) => {
  try {

    const empresaId =
      isMaster(req.user)
        ? null
        : req.user.empresa_id

    const lojaId = req.loja_id // 🔥 CORRIGIDO

    const dados = { ...req.body }

    if (!dados.senha) {
      delete dados.senha
    }

    if (!dados.nome || !dados.email) {
      return res.status(400).json({
        erro: "Nome e email são obrigatórios"
      })
    }

    const data = await service.atualizar(
      req.params.id,
      empresaId,
      lojaId,
      dados
    )

    res.json(data)

  } catch (e) {
    console.error(e)

    res.status(500).json({
      erro: e.message
    })
  }
}

/* ===============================
   ALTERAR STATUS
============================== */
exports.alterarStatus = async (req, res) => {
  try {

    let { ativo } = req.body

    ativo =
      ativo === true ||
      ativo === "true" ||
      ativo === 1

    const empresaId =
      isMaster(req.user)
        ? null
        : req.user.empresa_id

    const data = await service.alterarStatus(
      req.params.id,
      empresaId,
      ativo
    )

    res.json(data)

  } catch (e) {
    console.error("ERRO ALTERAR STATUS:", e)

    res.status(500).json({
      erro: "Erro ao alterar status"
    })
  }
}

/* ===============================
   EXCLUIR
============================== */
exports.excluir = async (req, res) => {
  try {

    const empresaId =
      isMaster(req.user)
        ? null
        : req.user.empresa_id

    const lojaId = req.loja_id // 🔥 CORRIGIDO

    const data = await service.excluir(
      req.params.id,
      empresaId,
      lojaId
    )

    res.json(data)

  } catch (e) {
    console.error(e)

    res.status(500).json({
      erro: e.message
    })
  }
}