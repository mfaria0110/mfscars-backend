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

  exports.buscar =
  async (req, res) => {

    try {

      const tipo =
        req.query.tipo

      const result =
        await db.query(`

          SELECT *

          FROM termo_sistema

          WHERE tipo = $1
          AND ativo = true

          ORDER BY id DESC

          LIMIT 1

        `, [tipo])

      if (!result.rows.length) {

        return res.status(404).json({

          erro:
            "Termo não encontrado"

        })
      }

      res.json(
        result.rows[0]
      )

    } catch (e) {

      console.error(e)

      res.status(500).json({

        erro:
          "Erro ao buscar termo"

      })
    }
  }

  /* =========================
   NOVA VERSÃO
========================= */

exports.novaVersao =
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

      const atual =
        await db.query(`

          SELECT *

          FROM termo_sistema

          WHERE id = $1

        `, [id])

      if(
        !atual.rows.length
      ){

        return res.status(404).json({

          erro:
            "Termo não encontrado"

        })
      }

      const termo =
        atual.rows[0]

      const novaVersao =
        String(

          Number(
            termo.versao
          ) + 0.1

        )

      const result =
        await db.query(`

          INSERT INTO
            termo_sistema (

              tipo,
              versao,
              titulo,
              conteudo,
              ativo

            )

          VALUES (

            $1,
            $2,
            $3,
            $4,
            false

          )

          RETURNING *

        `, [

          termo.tipo,

          novaVersao,

          termo.titulo,

          termo.conteudo

        ])

      res.json(
        result.rows[0]
      )

    } catch(e){

      console.error(e)

      res.status(500).json({

        erro:
          "Erro ao criar versão"

      })
    }
  }

/* =========================
   VERIFICAR REACEITE
========================= */

exports.verificarAceite =
  async (req, res) => {

    try {

      const usuario =
        req.usuario

      let lojas = []

      /* =========================
         MASTER
      ========================= */

      if (usuario.master) {

        const result =
          await db.query(`

            SELECT id
            FROM loja

          `)

        lojas =
          result.rows.map(
            l => l.id
          )

      /* =========================
         ADMIN
      ========================= */

      } else if (
        usuario.tipo === "admin"
      ) {

        const result =
          await db.query(`

            SELECT id
            FROM loja
            WHERE empresa_id = $1

          `, [

            usuario.empresa_id

          ])

        lojas =
          result.rows.map(
            l => l.id
          )

      /* =========================
         USUÁRIO NORMAL
      ========================= */

      } else {

        const result =
          await db.query(`

            SELECT loja_id
            FROM usuario_loja
            WHERE usuario_id = $1
            AND ativo = true

          `, [

            usuario.id

          ])

        lojas =
          result.rows.map(
            l => l.loja_id
          )
      }

      /* =========================
         SEM LOJAS
      ========================= */

      if (!lojas.length) {

        return res.json({

          precisaAceite: false,

          podeAceitar: false,

          pendentes: []

        })
      }

      /* =========================
         TERMOS ATIVOS
      ========================= */

      const termosAtivos =
        await db.query(`

          SELECT
            tipo,
            versao
          FROM termo_sistema
          WHERE ativo = true

        `)

      /* =========================
         ACEITES DAS LOJAS
      ========================= */

      const aceites =
        await db.query(`

          SELECT DISTINCT
            versao

          FROM usuario_aceite_termo

          WHERE loja_id = ANY($1)

        `, [

          lojas

        ])

      const versoesAceitas =
        aceites.rows.map(
          a => a.versao
        )

      /* =========================
         PENDÊNCIAS
      ========================= */

      const pendentes =
        termosAtivos.rows.filter(

          t =>

            !versoesAceitas.includes(
              t.versao
            )

        )

      /* =========================
         PODE ACEITAR
      ========================= */

      const podeAceitar =

        usuario?.ativo &&
        usuario?.tipo === "admin"

      /* =========================
         RESPONSE
      ========================= */

      res.json({

        precisaAceite:
          pendentes.length > 0,

        podeAceitar,

        pendentes

      })

    } catch(e){

      console.error(e)

      res.status(500).json({

        erro:
          "Erro ao verificar aceite"

      })
    }
  }



/* =========================
   ACEITAR TERMOS
========================= */
exports.aceitar =
  async (req, res) => {

    try {

      const usuarioId =
        req.usuario.id

      const lojaId =
        req.usuario.loja_id

      const {
        versao
      } = req.body

      /* =========================
         BUSCA NOME DA LOJA
      ========================= */

      let lojaNome = null

      if (lojaId) {

        const lojaRes =
          await db.query(`

            SELECT nome

            FROM loja

            WHERE id = $1

            LIMIT 1

          `, [lojaId])

        lojaNome =
          lojaRes.rows[0]?.nome || null
      }

      /* =========================
         SALVA ACEITE
      ========================= */

      await db.query(`

        INSERT INTO
          usuario_aceite_termo (

            usuario_id,
            versao,
            ip,
            loja_id,
            loja_nome

          )

        VALUES (

          $1,
          $2,
          $3,
          $4,
          $5

        )

      `, [

        usuarioId,

        versao,

        req.ip,

        lojaId,

        lojaNome

      ])

      res.json({

        ok: true

      })

    } catch(e){

      console.error(e)

      res.status(500).json({

        erro:
          "Erro ao aceitar termo"

      })
    }
  }
