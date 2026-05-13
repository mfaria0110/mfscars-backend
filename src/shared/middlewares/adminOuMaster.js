module.exports = function adminOuMaster(req, res, next) {

  const user = req.user

  if (!user) {
    return res.status(401).json({ erro: "Não autenticado" })
  }

   // 👑 MASTER
  if (user.master === true) {
    return next()
  }

  // 🔥 ADMIN
  if (user.tipo === "admin") {
    return next()
  }

  return res.status(403).json({
    erro: "Acesso permitido apenas para Administradores"
  })
}