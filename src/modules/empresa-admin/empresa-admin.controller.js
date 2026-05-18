const service =
  require(
    "./empresa-admin.service"
  )

function validarMaster(
  req,
  res
){

  if(
    !req.usuario?.master
  ){

    res.status(403).json({

      erro:
        "Sem permissão"

    })

    return false
  }

  return true
}

/* =========================
   LISTAR
========================= */

exports.listar =
  async (req, res) => {

    try {

      if(
        !validarMaster(
          req,
          res
        )
      ) return

      const empresas =
        await service.listar()

      res.json(
        empresas
      )

    } catch(e){

      console.error(e)

      res.status(500).json({

        erro:
          "Erro ao listar empresas"

      })
    }
  }

/* =========================
   BUSCAR
========================= */

exports.buscar =
  async (req, res) => {

    try {

      if(
        !validarMaster(
          req,
          res
        )
      ) return

      const empresa =
        await service.buscar(
          req.params.id
        )

      res.json(
        empresa
      )

    } catch(e){

      console.error(e)

      res.status(500).json({

        erro:
          "Erro ao buscar empresa"

      })
    }
  }

/* =========================
   EDITAR
========================= */

exports.editar =
  async (req, res) => {

    try {

      if(
        !validarMaster(
          req,
          res
        )
      ) return

      const empresa =
        await service.editar(

          req.params.id,

          req.body

        )

      res.json(
        empresa
      )

    } catch(e){

      console.error(e)

      res.status(500).json({

        erro:
          "Erro ao editar empresa"

      })
    }
  }

/* =========================
   DESATIVAR
========================= */

exports.desativar =
  async (req, res) => {

    try {

      if(
        !validarMaster(
          req,
          res
        )
      ) return

      const result =
        await service.desativar({

          empresaId:
            req.params.id,

          senha:
            req.body.senha,

          motivo:
            req.body.motivo,

          observacao:
            req.body.observacao,

          usuario:
            req.usuario,

          ip:
            req.ip,

          userAgent:
            req.headers[
              "user-agent"
            ]

        })

      res.json(
        result
      )

    } catch(e){

      console.error(e)

      res.status(500).json({

        erro:
          e.message ||
          "Erro ao desativar empresa"

      })
    }
  }

/* =========================
   RESTAURAR
========================= */

exports.restaurar =
  async (req, res) => {

    try {

      if(
        !validarMaster(
          req,
          res
        )
      ) return

      const result =
        await service.restaurar(

          req.params.id

        )

      res.json(
        result
      )

    } catch(e){

      console.error(e)

      res.status(500).json({

        erro:
          "Erro ao restaurar empresa"

      })
    }
  }