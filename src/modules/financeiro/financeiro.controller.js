const service =
  require("./financeiro.service")

/* =========================
   VALIDA ADMIN
========================= */

function validarAdmin(
  req,
  res
) {

  const usuario =
    req.usuario

  if (

    !usuario?.master &&

    usuario?.tipo !==
      "admin"

  ) {

    res.status(403).json({

      error:
        "Sem permissão"
    })

    return false
  }

  return true
}

/* =========================
   RESUMO
========================= */

exports.resumo =
  async (req, res) => {

    try {

      if (
        !validarAdmin(
          req,
          res
        )
      ) return

      const data =
        await service.getResumo()

      res.json(data)

    } catch (e) {

      console.error(e)

      res.status(500).json({

        error:
          "Erro ao carregar resumo financeiro"
      })
    }
  }

/* =========================
   COBRANÇAS
========================= */

exports.cobrancas =
  async (req, res) => {

    try {

      if (
        !validarAdmin(
          req,
          res
        )
      ) return

      const data =
        await service.getCobrancas({

          page:
            Number(req.query.page) || 1,

          limit:
            Number(req.query.limit) || 20,

          status:
            req.query.status || null,

          loja:
            req.query.loja || null,

          plano:
            req.query.plano || null,

          dataInicio:
            req.query.dataInicio || null,

          dataFim:
            req.query.dataFim || null
        })

      res.json(data)

    } catch (e) {

      console.error(e)

      res.status(500).json({

        error:
          "Erro ao carregar cobranças"
      })
    }
  }