const veiculoService = require("../veiculo/veiculo.service");
const empresaService = require("../empresa/empresa.service");

/* ===============================
   VEÍCULOS PÚBLICOS
================================ */
exports.buscarVeiculos = async (req, res) => {
  try {

    const filtros = req.query;

    const veiculos = await veiculoService.listarPublico(filtros);

    res.json(veiculos);

  } catch (error) {

    console.error(error);

    res.status(500).json({
      erro: error.message
    });
  }
};


exports.buscarVeiculo = async (req, res) => {
  try {
    const id = req.params.id;

    const veiculo = await veiculoService.detalhes(id);

    res.json(veiculo);

  } catch (error) {
    console.error(error);
    res.status(500).json({ erro: error.message });
  }
};

/* ===============================
   LOJAS PÚBLICAS
================================ */

exports.lojas = async (req, res) => {
  try {
    const lojas = await empresaService.listarLojas();

    res.json(lojas);

  } catch (e) {
    console.error(e);
    res.status(500).json({ erro: "Erro ao listar lojas" });
  }
};