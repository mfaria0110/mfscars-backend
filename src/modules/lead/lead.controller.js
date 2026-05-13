const db = require("../../shared/database/db")
const { isMaster } = require("../../shared/utils/permissao")

/* ===============================
   CRIAR LEAD
================================ */
exports.criar = async (req,res)=>{

  try{

    const dados = req.body

    const veiculo = await db.query(
      `SELECT empresa_id
       FROM veiculo
       WHERE id=$1`,
      [dados.veiculo_id]
    )

    if(veiculo.rows.length === 0){
      return res.status(404).json({
        erro:"Veículo não encontrado"
      })
    }

    const empresaId = veiculo.rows[0].empresa_id

    const r = await db.query(
      `INSERT INTO lead(
        empresa_id,
        veiculo_id,
        nome,
        telefone,
        mensagem,
        origem
      )
      VALUES($1,$2,$3,$4,$5,$6)
      RETURNING *`,
      [
        empresaId,
        dados.veiculo_id,
        dados.nome,
        dados.telefone,
        dados.mensagem,
        dados.origem || "site"
      ]
    )

    res.json(r.rows[0])

  }catch(e){

    console.error(e)

    res.status(500).json({
      erro:"Erro ao registrar lead"
    })

  }

}

/* ===============================
   LISTAR LEADS
================================ */
exports.listarEmpresa = async (req,res)=>{

  try{

    const empresaId = isMaster(req.user)
      ? null
      : req.user.empresa_id

    const r = await db.query(
      `SELECT
        l.*,
        v.marca,
        v.modelo
      FROM lead l
      JOIN veiculo v ON v.id = l.veiculo_id
      ${empresaId ? "WHERE l.empresa_id=$1" : ""}
      ORDER BY l.data DESC`,
      empresaId ? [empresaId] : []
    )

    res.json(r.rows)

  }catch(e){

    console.error(e)

    res.status(500).json({
      erro:"Erro ao listar leads"
    })

  }

}