const db = require("../../shared/database/db");
const { isMaster } = require("../../shared/utils/permissao");

/* ============================= */
/* CRIAR EMPRESA */
/* ============================= */

exports.criar = async (req,res)=>{

try{

const {
nome,
cidade,
estado,
telefone,
cnpj,
cep,
endereco,
numero,
descricao,
horario_funcionamento,
instagram,
facebook,
site
} = req.body

const slug = nome
.toLowerCase()
.replace(/\s+/g,"-")
.replace(/[^\w-]+/g,"")

const r = await db.query(

`
INSERT INTO empresa
(
nome,
cidade,
estado,
telefone,
cnpj,
cep,
endereco,
numero,
descricao,
horario_funcionamento,
instagram,
facebook,
site,
slug
)
VALUES
($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
RETURNING *
`,
[
nome,
cidade,
estado,
telefone,
cnpj,
cep,
endereco,
numero,
descricao,
horario_funcionamento,
instagram,
facebook,
site,
slug
]
)

res.json(r.rows[0])

}catch(e){

console.error("ERRO CRIAR EMPRESA:",e)

res.status(500).json({
erro:"Erro ao criar empresa"
})

}

}


/* ============================= */
/* EMPRESA LOGADA */
/* ============================= */

exports.me = async (req,res)=>{

try{

const empresaId = isMaster(req.user)
  ? req.query.empresa_id
  : req.user.empresa_id

if(!empresaId){
  return res.status(400).json({ erro:"empresa_id obrigatório" })
}

const r = await db.query(
`
SELECT *
FROM empresa
WHERE id=$1
`,
[empresaId]
)

res.json(r.rows[0])

}catch(e){

console.error(e)

res.status(500).json({
erro:"Erro ao buscar empresa"
})

}

}


/* ============================= */
/* DETALHES EMPRESA */
/* ============================= */

exports.detalhes = async (req,res)=>{

try{

const id = req.params.id

const r = await db.query(
`
SELECT *
FROM empresa
WHERE id=$1
`,
[id]
)

res.json(r.rows[0])

}catch(e){

console.error(e)

res.status(500).json({
erro:"Erro ao buscar empresa"
})

}

}


/* ============================= */
/* VEÍCULOS DA EMPRESA */
/* ============================= */

exports.veiculos = async (req,res)=>{

try{

const id = req.params.id

const r = await db.query(
`
SELECT
v.id,
v.marca,
v.modelo,
v.ano,
v.valor,
(
SELECT url
FROM veiculo_foto
WHERE veiculo_id=v.id
ORDER BY principal DESC
LIMIT 1
) foto
FROM veiculo v
WHERE v.empresa_id=$1
AND v.status='disponivel'
ORDER BY v.data_cadastro DESC
`,
[id]
)

res.json(r.rows)

}catch(e){

console.error(e)

res.status(500).json({
erro:"Erro ao listar veículos"
})

}

}


/* ============================= */
/* LOJA PÚBLICA */
/* ============================= */

exports.lojaPublica = async (req,res)=>{

try{

const id = req.params.id

if(!id){
return res.status(400).json({
erro:"ID da loja não informado"
})
}

const lojaResult = await db.query(`
SELECT
id,
nome,
cidade,
estado,
telefone,
logo,
banner,
endereco,
latitude,
longitude,
descricao,
horario_funcionamento,
instagram,
facebook,
site
FROM loja
WHERE id=$1
`, [id])

if(lojaResult.rows.length === 0){
return res.status(404).json({
erro:"Loja não encontrada"
})
}

const loja = lojaResult.rows[0]

const veiculosResult = await db.query(`
SELECT
v.id,
v.marca,
v.modelo,
v.ano,
v.valor,
(
SELECT url
FROM veiculo_foto
WHERE veiculo_id = v.id
ORDER BY principal DESC
LIMIT 1
) foto
FROM veiculo v
WHERE v.loja_id = $1
AND v.status = 'disponivel'
ORDER BY v.data_cadastro DESC
`, [id])

res.json({
loja,
veiculos: veiculosResult.rows
})

}catch(e){

console.error("ERRO LOJA PUBLICA:", e)

res.status(500).json({
erro:"Erro ao carregar loja"
})

}

}

exports.uploadBanner = async (req, res) => {

  try {

    const id = req.params.id;

    if (!req.file) {
      return res.status(400).json({
        erro: "Arquivo não enviado"
      });
    }

    const filename = req.file.filename;

    const db = require("../../shared/database/db");

    await db.query(`
      UPDATE loja
      SET banner = $1
      WHERE id = $2
    `, [filename, id]);

    res.json({ ok: true });

  } catch (e) {

    console.error(e);

    res.status(500).json({
      erro: "Erro ao enviar banner"
    });

  }

};