const jwt = require("jsonwebtoken")

module.exports = (
  req,
  res,
  next
) => {
  const header =
    req.headers.authorization

  /* =========================
     TOKEN NÃO ENVIADO
  ========================= */
  if (!header) {
    return res.status(401).json({
      erro: "Token não enviado"
    })
  }

  const parts =
    header.split(" ")

  /* =========================
     TOKEN MAL FORMATADO
  ========================= */
  if (
    parts.length !== 2 ||
    parts[0] !== "Bearer"
  ) {
    return res.status(401).json({
      erro:
        "Token mal formatado"
    })
  }

  const token =
    parts[1]

  try {
    const decoded =
      jwt.verify(
        token,
        process.env.JWT_SECRET
      )


    /* =========================
       DADOS DO USUÁRIO
    ========================= */
    req.user = decoded

    /* =========================
       LOJA ATIVA
       prioridade:
       1 - header enviado pelo frontend
       2 - loja do token
    ========================= */
    const lojaHeader =
      req.headers["x-loja-id"]


    req.lojaId =
      lojaHeader
        ? Number(lojaHeader)
        : decoded.loja_id

    next()

  } catch (e) {
    console.error(
      "JWT ERROR:",
      e
    )

    return res.status(401).json({
      erro:
        "Token inválido ou expirado"
    })
  }
}