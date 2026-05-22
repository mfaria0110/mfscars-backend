const repository =
  require("./loja-clausula.repository")

exports.buscarPorLoja =
  async (lojaId) => {

    return repository.buscarPorLoja(
      lojaId
    )
}

exports.salvar =
  async (dados) => {

    return repository.salvar(
      dados
    )
}