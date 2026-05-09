const repo = require("./veiculo.repository")

const cloudinary =
  require("../../shared/cloudinary")

/* ===============================
   VEICULOS
================================ */

exports.listar = (filtros) =>
  repo.listar(filtros)

exports.detalhes = (
  id,
  empresaId,
  lojaId
) =>
  repo.detalhes(
    id,
    empresaId,
    lojaId
  )

exports.excluirDocumento = (id) =>
  repo.excluirDocumento(id)

/* ===============================
   CRUD
================================ */

exports.criar = (
  empresaId,
  lojaId,
  dados
) =>
  repo.criar(
    empresaId,
    lojaId,
    dados
  )

exports.atualizar = (
  id,
  empresaId,
  lojaId,
  dados
) =>
  repo.atualizar(
    id,
    empresaId,
    lojaId,
    dados
  )

exports.excluir = (
  id,
  empresaId,
  lojaId
) =>
  repo.excluir(
    id,
    empresaId,
    lojaId
  )

/* ===============================
   RELACIONADOS
================================ */

exports.similares = (id) =>
  repo.similares(id)

/* ===============================
   FAVORITOS
================================ */

exports.toggleFavorito = (
  usuarioId,
  veiculoId
) =>
  repo.toggleFavorito(
    usuarioId,
    veiculoId
  )

exports.listarFavoritos = (
  usuarioId
) =>
  repo.listarFavoritos(
    usuarioId
  )

/* ===============================
   CATÁLOGO
================================ */

exports.marcas = () =>
  repo.marcas()

exports.modelos = async (
  marcaId
) => {

  console.log(
    "🔥 SERVICE modelos:",
    marcaId
  )

  return await repo.modelos(
    marcaId
  )
}

/* ===============================
   OPCIONAIS
================================ */

exports.opcionais = () =>
  repo.opcionais()

exports.opcionaisVeiculo = (
  veiculoId
) =>
  repo.opcionaisVeiculo(
    veiculoId
  )

/* ===============================
   FOTOS
================================ */

exports.fotos = async (
  veiculoId,
  empresaId,
  lojaId
) => {

  return await repo.fotos(
    veiculoId,
    empresaId,
    lojaId
  )
}

/* ===============================
   UPLOAD FOTO CLOUDINARY
================================ */

exports.uploadFoto = async (
  empresaId,
  lojaId,
  veiculoId,
  files
) => {

  const totalFotos =
    await repo.contarFotos(
      veiculoId
    )

  if (
    totalFotos + files.length > 10
  ) {

    throw new Error(
      `Limite máximo de 10 fotos. Já possui ${totalFotos}`
    )
  }

  for (const file of files) {

    console.log(
      "☁️ ENVIANDO CLOUDINARY:",
      file.path
    )

    const result =
      await cloudinary.uploader.upload(
        file.path,
        {
          folder: "mfscars",
          resource_type: "auto"
        }
      )

    console.log(
      "✅ CLOUDINARY URL:",
      result.secure_url
    )

    await repo.salvarFoto(
      empresaId,
      lojaId,
      veiculoId,
      result.secure_url
    )
  }
}

/* ===============================
   REMOVER FOTO
================================ */

exports.removerFoto = async (
  fotoId,
  empresaId,
  lojaId
) => {

  try {

    console.log(
      "🔥 REMOVER FOTO:",
      fotoId
    )

    const foto =
      await repo.buscarFotoPorId(
        fotoId
      )

    console.log(
      "📸 FOTO:",
      foto
    )

    if (!foto) {

      throw new Error(
        "Foto não encontrada"
      )
    }

    if (
      Number(foto.empresa_id) !== Number(empresaId) ||
      Number(foto.loja_id) !== Number(lojaId)
    ) {

      throw new Error(
        "Sem permissão"
      )
    }

    /* 🔥 REMOVER CLOUDINARY */

    if (
      foto.url &&
      foto.url.includes(
        "cloudinary"
      )
    ) {

      try {

        const partes =
          foto.url.split("/")

        const nome =
          partes[
            partes.length - 1
          ]
            .split(".")[0]

        const publicId =
          `mfscars/${nome}`

        console.log(
          "☁️ REMOVENDO CLOUDINARY:",
          publicId
        )

        await cloudinary
          .uploader
          .destroy(
            publicId
          )

      } catch (e) {

        console.error(
          "Erro Cloudinary:",
          e
        )
      }
    }

    console.log(
      "🗑 REMOVENDO BANCO"
    )

    await repo.removerFoto(
      fotoId
    )

    if (foto.principal) {

      console.log(
        "⭐ DEFININDO NOVA PRINCIPAL"
      )

      await repo.definirOutraPrincipal(
        foto.veiculo_id
      )
    }

    console.log(
      "✅ FOTO REMOVIDA"
    )

  } catch (e) {

    console.error(
      "🔥 ERRO REMOVER FOTO:",
      e
    )

    throw e
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

  const foto =
    await repo.buscarFotoPorId(
      fotoId
    )

  if (!foto) {

    throw new Error(
      "Foto não encontrada"
    )
  }

  if (
    Number(foto.empresa_id) !== Number(empresaId) ||
    Number(foto.loja_id) !== Number(lojaId)
  ) {

    throw new Error(
      "Sem permissão"
    )
  }

  await repo.resetarPrincipal(
    foto.veiculo_id
  )

  await repo.setarPrincipal(
    fotoId
  )
}

/* ===============================
   PUBLICO
================================ */

exports.detalhesPublico = async (
  id
) => {

  const veiculo =
    await repo.buscarPublicoPorId(
      id
    )

  if (!veiculo) {

    throw new Error(
      "Veículo não encontrado"
    )
  }

  const fotos =
    await repo.fotosPublicas(id)

  const opcionais =
    await repo.opcionaisPublico(id)

  return {
    veiculo,
    fotos,
    opcionais
  }
}

exports.listarPublico = (
  filtros
) =>
  repo.listarPublico(
    filtros
  )

/* ===============================
   EMPRESA
================================ */

exports.veiculosEmpresa = (
  empresaId,
  lojaId,
  filtros
) =>
  repo.veiculosEmpresa(
    empresaId,
    lojaId,
    filtros
  )