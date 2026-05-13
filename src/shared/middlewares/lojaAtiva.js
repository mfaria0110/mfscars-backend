module.exports = function lojaAtiva(req, res, next) {

  if (!req.loja) {
    return res.status(400).json({
      erro: "Loja não carregada"
    })
  }

  if (req.loja.status !== "ATIVO") {

    // 🔥 somente master passa
    if (req.user?.master === true) {
      return next()
    }

    return res.status(403).json({
      erro: "Esta loja está INATIVA. Entre em contato com o responsável pelo sistema."
    })
  }

  next()
}