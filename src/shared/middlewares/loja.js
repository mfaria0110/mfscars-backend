module.exports = (req, res, next) => {

  try {

    const usuario = req.user;

    /*
      👑 MASTER → ignora loja
    */

    if (usuario?.master === true) {
      return next();
    }

    /*
      TODOS OS DEMAIS
    */

    if (!req.loja) {

      return res.status(400).json({
        erro: "Loja obrigatória"
      });
    }

    req.loja_id = req.loja.id;

    next();

  } catch (e) {

    console.error(
      "ERRO MIDDLEWARE LOJA:",
      e
    );

    return res.status(500).json({
      erro: "Erro ao validar loja"
    });
  }
};