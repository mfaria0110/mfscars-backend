const bcrypt =
  require("bcrypt")

const repository =
  require(
    "./empresa-admin.repository"
  )

/* =========================
   LISTAR
========================= */

exports.listar =
  async () => {

    return await repository.listar()
  }

/* =========================
   BUSCAR
========================= */

exports.buscar =
  async (id) => {

    return await repository.buscar(
      id
    )
  }

/* =========================
   EDITAR
========================= */

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

/* =========================
   DESATIVAR
========================= */

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
       VALIDAÇÕES
    ========================= */

    if (!senha) {

      throw new Error(
        "Senha obrigatória"
      )
    }

    if (!motivo) {

      throw new Error(
        "Motivo obrigatório"
      )
    }

    if (
      motivo.trim().length < 10
    ) {

      throw new Error(

        "Motivo deve possuir pelo menos 10 caracteres"

      )
    }

    /* =========================
       VALIDA MASTER
    ========================= */

    const master =
      await repository.buscarUsuario(
        usuario.id
      )

    if (!master) {

      throw new Error(
        "Usuário não encontrado"
      )
    }

    /* =========================
       VALIDA SENHA
    ========================= */

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

    /* =========================
       NÃO PODE DESATIVAR
       A PRÓPRIA EMPRESA
    ========================= */

    if (

      Number(empresaId) ===
      Number(usuario.empresa_id)

    ) {

      throw new Error(

        "Não é permitido desativar sua própria empresa"

      )
    }

    /* =========================
       DESATIVA
    ========================= */

    return await repository.desativar({

      empresaId,
      motivo,
      observacao,
      usuario,
      ip,
      userAgent

    })
  }

/* =========================
   RESTAURAR
========================= */

exports.restaurar =
  async (id) => {

    return await repository.restaurar(
      id
    )
  }