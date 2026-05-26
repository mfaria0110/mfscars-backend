module.exports = (req, res, next) => {
  try {
    const usuario = req.user;

    /*
      👑 MASTER → não precisa loja
    */
    if (usuario?.master === true) {
      return next();
    }

    /*
      🏢 ADMIN → não precisa loja
    */
    if (usuario?.tipo === "admin") {
      return next();
    }

    /*
      👤 USUÁRIO → precisa loja
    */
    if (!req.loja) {
      return res.status(400).json({
        erro: "Loja obrigatória"
      });
    }

    req.loja_id = req.loja.id;

    next();

  } catch (e) {
    console.error("ERRO MIDDLEWARE LOJA:", e);

    return res.status(500).json({
      erro: "Erro ao validar loja"
    });
  }
};