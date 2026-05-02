module.exports = (chave) => {
  return (req, res, next) => {
    try {
 
      /* MASTER LIBERADO */
if (
  req.user?.master === true ||
  req.user?.tipo === "admin"
) {
  return next()
}

      const permissoes =
        req.user?.permissoes || []

      if (
        !permissoes.includes(chave)
      ) {
        return res.status(403).json({
          erro: "Sem permissão"
        })
      }

      next()

    } catch (e) {
      console.error(
        "ERRO PERMISSAO:",
        e
      )

      return res.status(500).json({
        erro:
          "Erro interno no servidor"
      })
    }
  }
}