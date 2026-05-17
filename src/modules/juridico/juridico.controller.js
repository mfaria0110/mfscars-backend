const db =
  require(
    "../../shared/database/db"
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

      const result =
        await db.query(`

          SELECT *

          FROM termo_sistema

          ORDER BY id DESC

        `)

      res.json(
        result.rows
      )

    } catch(e){

      console.error(e)

      res.status(500).json({

        erro:
          "Erro ao listar termos"

      })
    }
  }

/* =========================
   CRIAR
========================= */

exports.criar =
  async (req, res) => {

    try {

      if(
        !validarMaster(
          req,
          res
        )
      ) return

      const {
        tipo,
        versao,
        titulo,
        conteudo
      } = req.body

      const result =
        await db.query(`
          INSERT INTO
            termo_sistema (

              tipo,
              versao,
              titulo,
              conteudo
            )
          VALUES (
            $1,
            $2,
            $3,
            $4

          )

          RETURNING *

        `, [

          tipo,
          versao,
          titulo,
          conteudo

        ])

      res.json(
        result.rows[0]
      )

    } catch(e){

      console.error(e)

      res.status(500).json({

        erro:
          "Erro ao criar termo"

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

      const id =
        req.params.id

      const {

        titulo,
        conteudo,
        ativo

      } = req.body

      const result =
        await db.query(`

          UPDATE termo_sistema

          SET

            titulo = $1,
            conteudo = $2,
            ativo = $3

          WHERE id = $4

          RETURNING *

        `, [

          titulo,
          conteudo,
          ativo,
          id

        ])

      res.json(
        result.rows[0]
      )

    } catch(e){

      console.error(e)

      res.status(500).json({

        erro:
          "Erro ao editar termo"

      })
    }
  }