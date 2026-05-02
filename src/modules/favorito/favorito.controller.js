const veiculoService = require("../veiculo/veiculo.service");

/* ===============================
   TOGGLE FAVORITO
================================ */
exports.toggle = async (req, res) => {

  try {

    const usuario_id = req.user.id;
    const veiculo_id = req.params.id;

    const result = await veiculoService.toggleFavorito(
      usuario_id,
      veiculo_id
    );

    res.json(result);

  } catch (e) {

    console.error(e);

    res.status(500).json({
      erro: "Erro ao favoritar"
    });

  }

};

/* ===============================
   LISTAR FAVORITOS
================================ */
exports.listar = async (req, res) => {

  try {

    const usuario_id = req.user.id;

    const data = await veiculoService.listarFavoritos(usuario_id);

    res.json(data);

  } catch (e) {

    console.error(e);

    res.status(500).json({
      erro: "Erro ao listar favoritos"
    });

  }

};