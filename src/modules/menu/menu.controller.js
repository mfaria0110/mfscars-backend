const service = require("./menu.service")

exports.listar = async (req, res) => {
  try {
    const menus = await service.listar()
    res.json(menus)
  } catch (e) {
    console.error(e)
    res.status(500).json({
      erro: "Erro ao carregar menus"
    })
  }
}