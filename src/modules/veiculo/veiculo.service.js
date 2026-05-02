const repo = require("./veiculo.repository")
const sharp = require("sharp")
const fs = require("fs")
const path = require("path")

/* ===============================
   VEICULOS
================================ */

exports.listar = (filtros) => repo.listar(filtros)

exports.detalhes = (id, empresaId, lojaId) =>
  repo.detalhes(id, empresaId, lojaId)

exports.excluirDocumento = (id) =>
  repo.excluirDocumento(id)

/* ===============================
   CRUD
================================ */

exports.criar = (empresaId, lojaId, dados) =>
  repo.criar(empresaId, lojaId, dados)

exports.atualizar = (id, empresaId, lojaId, dados) =>
  repo.atualizar(id, empresaId, lojaId, dados)

exports.excluir = (id, empresaId, lojaId) =>
  repo.excluir(id, empresaId, lojaId)

/* ===============================
   RELACIONADOS
================================ */

exports.similares = (id) => repo.similares(id)

/* ===============================
   FAVORITOS
================================ */

exports.toggleFavorito = (usuarioId, veiculoId) =>
  repo.toggleFavorito(usuarioId, veiculoId)

exports.listarFavoritos = (usuarioId) =>
  repo.listarFavoritos(usuarioId)

/* ===============================
   CATÁLOGO
================================ */

exports.marcas = () => repo.marcas()

exports.modelos = async (marcaId) => {
  console.log("🔥 SERVICE modelos:", marcaId)
  return await repo.modelos(marcaId)
}

/* ===============================
   OPCIONAIS
================================ */

exports.opcionais = () => repo.opcionais()

exports.opcionaisVeiculo = (veiculoId) =>
  repo.opcionaisVeiculo(veiculoId)

/* ===============================
   FOTOS
================================ */

exports.fotos = async (veiculoId, empresaId, lojaId) => {
  return await repo.fotos(veiculoId, empresaId, lojaId)
}

/* ===============================
   UPLOAD FOTO (🔥 MIGRADO)
================================ */

exports.uploadFoto = async (
  empresaId,
  lojaId,
  veiculoId,
  files
) => {

  const totalFotos = await repo.contarFotos(veiculoId)

  if (totalFotos + files.length > 6) {
    throw new Error(
      `Limite máximo de 6 fotos. Já possui ${totalFotos}`
    )
  }

  for (const file of files) {

    const inputPath = path.resolve(file.path)

    const baseName =
      Date.now() +
      "-" +
      Math.random().toString(36).substring(2, 8)

    const file800 = `${baseName}-800.webp`
    const path800 = `uploads/${file800}`

    await sharp(inputPath)
      .resize(800)
      .webp({ quality: 80 })
      .toFile(path800)

    fs.unlinkSync(inputPath)

    await repo.salvarFoto(
      empresaId,
      lojaId,
      veiculoId,
      file800
    )
  }
}

/* ===============================
   REMOVER FOTO
================================ */

exports.removerFoto = async (fotoId, empresaId, lojaId) => {

  const foto = await repo.buscarFotoPorId(fotoId)

  if (!foto) {
    throw new Error("Foto não encontrada")
  }

  if (
    Number(foto.empresa_id) !== Number(empresaId) ||
    Number(foto.loja_id) !== Number(lojaId)
  ) {
    throw new Error("Sem permissão")
  }

  const caminho = "uploads/" + foto.url

  if (fs.existsSync(caminho)) {
    fs.unlinkSync(caminho)
  }

  await repo.removerFoto(fotoId)

  if (foto.principal) {
    await repo.definirOutraPrincipal(foto.veiculo_id)
  }
}

/* ===============================
   FOTO PRINCIPAL
================================ */

exports.definirFotoPrincipal = async (
  fotoId,
  empresaId,
  lojaId
) => {

  const foto = await repo.buscarFotoPorId(fotoId)

  if (!foto) {
    throw new Error("Foto não encontrada")
  }

  if (
    Number(foto.empresa_id) !== Number(empresaId) ||
    Number(foto.loja_id) !== Number(lojaId)
  ) {
    throw new Error("Sem permissão")
  }

  await repo.resetarPrincipal(foto.veiculo_id)

  await repo.setarPrincipal(fotoId)
}

/* ===============================
   PUBLICO
================================ */

exports.detalhesPublico = async (id) => {

  const veiculo = await repo.buscarPublicoPorId(id)

  if (!veiculo) {
    throw new Error("Veículo não encontrado")
  }

  const fotos = await repo.fotosPublicas(id)
  const opcionais = await repo.opcionaisPublico(id)

  return {
    veiculo,
    fotos,
    opcionais
  }
}

exports.listarPublico = (filtros) =>
  repo.listarPublico(filtros)

/* ===============================
   EMPRESA
================================ */

exports.veiculosEmpresa = (
  empresaId,
  lojaId,
  filtros
) =>
  repo.veiculosEmpresa(empresaId, lojaId, filtros)