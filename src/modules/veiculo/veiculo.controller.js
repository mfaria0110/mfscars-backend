const multer = require("multer")

const veiculoService = require("./veiculo.service")
const temPermissao = require("../../shared/middlewares/permissao")

/* ===============================
   UPLOAD CONFIG
================================ */
const storage = multer.diskStorage({
  destination: "uploads/",
  filename: (req, file, cb) => {
    cb(null, Date.now() + "-" + file.originalname)
  }
})

const upload = multer({ storage })

exports.uploadMiddleware = upload.array("foto", 6)

/* ===============================
   LISTAR VEÍCULOS
================================ */
exports.veiculosEmpresa = async (req, res) => {
  try {

    const loja_id = req.loja_id
    const empresa_id = req.user.empresa_id

    if (!loja_id) {
      return res.status(400).json({
        erro: "Loja obrigatória"
      })
    }

    const filtros = {
      ...req.query,
      empresa_id,
      loja_id
    }

    const data = await veiculoService.listar(filtros)

    res.json(data.data || data)

  } catch (e) {
    console.error("Erro veiculosEmpresa:", e)

    res.status(500).json({
      erro: "Erro ao listar veículos"
    })
  }
}

/* ===============================
   CRIAR
================================ */
exports.criar = async (req, res) => {
  try {

    const podeCriar = await temPermissao(req.user, "veiculo.criar")

    if (!podeCriar) {
      return res.status(403).json({
        erro: "Sem permissão para criar veículo"
      })
    }

    const loja_id = req.loja_id
    const empresa_id = req.user.empresa_id

    if (!loja_id) {
      return res.status(400).json({
        erro: "Loja obrigatória"
      })
    }

    const data = await veiculoService.criar(
      empresa_id,
      loja_id,
      req.body
    )

    res.json(data)

  } catch (e) {
    console.error("Erro criar veículo:", e)

    res.status(500).json({
      erro: e.message
    })
  }
}

/* ===============================
   ATUALIZAR
================================ */
exports.atualizar = async (req, res) => {
  try {

    const podeEditar = await temPermissao(req.user, "veiculo.editar")

    if (!podeEditar) {
      return res.status(403).json({
        erro: "Sem permissão para editar"
      })
    }

    const id = req.params.id
    const loja_id = req.loja_id
    const empresa_id = req.user.empresa_id

    const data = await veiculoService.atualizar(
      id,
      empresa_id,
      loja_id,
      req.body
    )

    res.json(data)

  } catch (e) {
    console.error(e)

    res.status(500).json({
      erro: "Erro ao atualizar veículo"
    })
  }
}

/* ===============================
   EXCLUIR
================================ */
exports.excluir = async (req, res) => {
  try {

    const podeExcluir = await temPermissao(req.user, "veiculo.excluir")

    if (!podeExcluir) {
      return res.status(403).json({
        erro: "Sem permissão para excluir veículo"
      })
    }

    const id = req.params.id
    const empresa_id = req.user.empresa_id
    const loja_id = req.loja_id

    await veiculoService.excluir(
      id,
      empresa_id,
      loja_id
    )

    res.json({ msg: "Veículo excluído" })

  } catch (e) {
    console.error(e)

    res.status(500).json({
      erro: "Erro ao excluir veículo"
    })
  }
}

/* ===============================
   FOTOS
================================ */
exports.fotos = async (req, res) => {
  try {

    const data = await veiculoService.fotos(
      req.params.id,
      req.user.empresa_id,
      req.loja_id
    )

    res.json(data)

  } catch (e) {
    console.error(e)

    res.status(500).json({
      erro: "Erro ao listar fotos"
    })
  }
}

/* ===============================
   UPLOAD FOTO
================================ */
exports.uploadFoto = async (req, res) => {
  try {

    const veiculo_id = Number(req.params.id)
    const empresa_id = req.user.empresa_id
    const loja_id = req.loja_id

    if (!veiculo_id) {
      return res.status(400).json({
        erro: "Veículo inválido"
      })
    }

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        erro: "Arquivo não enviado"
      })
    }

    await veiculoService.uploadFoto(
      empresa_id,
      loja_id,
      veiculo_id,
      req.files
    )

    res.json({
      msg: "Fotos enviadas com sucesso"
    })

  } catch (e) {
    console.error("ERRO UPLOAD FOTO:", e)

    res.status(500).json({
      erro: e.message
    })
  }
}

/* ===============================
   REMOVER FOTO
================================ */
exports.removerFoto = async (req, res) => {
  try {

    await veiculoService.removerFoto(
      req.params.id,
      req.user.empresa_id,
      req.loja_id
    )

    res.json({
      msg: "Foto removida"
    })

  } catch (e) {
    console.error(e)

    res.status(500).json({
      erro: "Erro ao remover foto"
    })
  }
}

/* ===============================
   FOTO PRINCIPAL
================================ */
exports.fotoPrincipal = async (req, res) => {
  try {

    await veiculoService.definirFotoPrincipal(
      req.params.id,
      req.user.empresa_id,
      req.loja_id
    )

    res.json({
      msg: "Foto principal definida"
    })

  } catch (e) {
    console.error(e)

    res.status(500).json({
      erro: "Erro ao definir principal"
    })
  }
}

/* ===============================
   OPCIONAIS
================================ */
exports.opcionais = async (req, res) => {
  try {

    const data = await veiculoService.opcionais()

    res.json(data)

  } catch (e) {
    console.error(e)

    res.status(500).json({
      erro: "Erro ao listar opcionais"
    })
  }
}

exports.opcionaisVeiculo = async (req, res) => {
  try {

    const data = await veiculoService.opcionaisVeiculo(req.params.id)

    res.json(data)

  } catch (e) {
    console.error(e)

    res.status(500).json({
      erro: "Erro ao listar opcionais do veículo"
    })
  }
}

/* ===============================
   DETALHES
================================ */
exports.detalhesCompleto = async (req, res) => {
  try {

    const data = await veiculoService.detalhes(
      req.params.id,
      req.user.empresa_id,
      req.loja_id
    )

    if (!data || !data.veiculo) {
      return res.status(404).json({
        erro: "Veículo não encontrado"
      })
    }

    res.json(data)

  } catch (e) {
    console.error(e)

    res.status(500).json({
      erro: "Erro ao buscar detalhes"
    })
  }
}

/* ===============================
   SIMILARES
================================ */
exports.similares = async (req, res) => {
  try {

    const data = await veiculoService.similares(req.params.id)

    res.json(data)

  } catch (e) {
    console.error(e)

    res.status(500).json({
      erro: "Erro ao buscar similares"
    })
  }
}

/* ===============================
   PUBLICO
================================ */
exports.detalhesPublico = async (req, res) => {
  try {

    const data = await veiculoService.detalhesPublico(req.params.id)

    res.json(data)

  } catch (e) {
    console.error(e)

    res.status(500).json({
      erro: "Erro ao buscar veículo"
    })
  }
}

exports.listarPublico = async (req, res) => {
  try {

    const data = await veiculoService.listarPublico(req.query)

    res.json(data)

  } catch (e) {
    console.error(e)

    res.status(500).json({
      erro: "Erro ao listar veículos públicos"
    })
  }
}

/* ===============================
   MARCAS / MODELOS
================================ */
exports.marcas = async (req, res) => {
  try {
    const data = await veiculoService.marcas()
    res.json(data)
  } catch (e) {
    console.error(e)
    res.status(500).json({ erro: e.message })
  }
}

exports.modelos = async (req, res) => {
  try {

    const { marca_id } = req.query

    if (!marca_id) {
      return res.status(400).json({
        erro: "marca_id é obrigatório"
      })
    }

    const data = await veiculoService.modelos(marca_id)

    res.json(data)

  } catch (e) {
    console.error(e)
    res.status(500).json({
      erro: "Erro ao buscar modelos"
    })
  }
}

/* ===============================
   DOCUMENTO
================================ */
exports.excluirDocumento = async (req, res) => {
  try {

    await veiculoService.excluirDocumento(req.params.id)

    res.json({
      msg: "Documento excluído"
    })

  } catch (e) {
    console.error(e)

    res.status(500).json({
      erro: "Erro ao excluir documento"
    })
  }
}