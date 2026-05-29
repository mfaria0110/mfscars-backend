const jwt =
  require("jsonwebtoken")

const db =
  require("../database/db")

module.exports = async (
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

      erro:
        "Token não enviado"

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

    /* =========================
       TOKEN
    ========================= */

    const decoded =
      jwt.verify(

        token,

        process.env.JWT_SECRET

      )

    /* =========================
       EMPRESA DESATIVADA
    ========================= */

    if (

      decoded.empresa_id &&

      !decoded.master

    ) {

      const empresa =
        await db.query(`

          SELECT
            ativo

          FROM empresa

          WHERE id = $1

        `, [

          decoded.empresa_id

        ])

      if (

        empresa.rows.length &&

        !empresa.rows[0].ativo

      ) {

        return res.status(403).json({

          erro:
            "Empresa desativada"

        })
      }
    }

    /* =========================
       DADOS USUÁRIO
    ========================= */

    req.user =
      decoded

    req.usuario =
      decoded

    /* =========================
       LOJA ATIVA
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
    "AUTH ERROR:",
    e
  )

  if (e.name === "TokenExpiredError") {

    return res.status(401).json({
      erro: "jwt expired"
    })

  }

  if (e.name === "JsonWebTokenError") {

    return res.status(401).json({
      erro: "token inválido"
    })

  }

  return res.status(401).json({
    erro: "não autorizado"
  })
}
  
}