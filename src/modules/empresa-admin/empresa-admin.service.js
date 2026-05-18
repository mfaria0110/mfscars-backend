const bcrypt =
  require("bcryptjs")

const repository =
  require(
    "./empresa-admin.repository"
  )

exports.listar =
  async () => {

    return await repository.listar()
  }

exports.buscar =
  async (id) => {

    return await repository.buscar(
      id
    )
  }

exports.editar =
  async (
    id,
    data
  ) => {

    return await repository.editar(
      id,
      data
    )
  }

exports.desativar =
  async ({
    empresaId,
    senha,
    motivo,
    observacao,
    usuario,
    ip,
    userAgent
  }) => {

    /* =========================
       VALIDA SENHA MASTER
    ========================= */

    const master =
      await repository.buscarUsuario(
        usuario.id
      )

    const senhaOk =
      await bcrypt.compare(
        senha,
        master.senha
      )

    if (!senhaOk) {

      throw new Error(
        "Senha inválida"
      )
    }

    return await repository.desativar({

      empresaId,
      motivo,
      observacao,
      usuario,
      ip,
      userAgent

    })
  }

exports.restaurar =
  async (id) => {

    return await repository.restaurar(
      id
    )
  }