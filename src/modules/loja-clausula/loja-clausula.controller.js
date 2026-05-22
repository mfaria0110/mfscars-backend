const service =
  require("./loja-clausula.service")

exports.buscar = async (
  req,
  res
) => {

  try {

    const lojaId =
      req.params.lojaId

    const dados =
      await service.buscarPorLoja(
        lojaId
      )

    res.json(dados || {})

  } catch (e) {

    console.error(e)

    res.status(500).json({
      erro:
        "Erro ao buscar cláusulas"
    })
  }
}

exports.salvar = async (
  req,
  res
) => {

  try {

    const dados =
      await service.salvar(
        req.body
      )

    res.json(dados)

  } catch (e) {

    console.error(e)

    res.status(500).json({
      erro:
        "Erro ao salvar cláusulas"
    })
  }
}