const fetch = require("node-fetch")
const db = require("../database/db")

async function importar(){

// MARCAS
const marcas = await fetch("https://parallelum.com.br/fipe/api/v1/carros/marcas")
.then(r => r.json())

for(const m of marcas){

const marcaRes = await db.query(
"INSERT INTO marca (nome) VALUES ($1) RETURNING id",
[m.nome]
)

const marca_id = marcaRes.rows[0].id

// MODELOS
const modelos = await fetch(
`https://parallelum.com.br/fipe/api/v1/carros/marcas/${m.codigo}/modelos`
).then(r => r.json())

for(const mod of modelos.modelos){

const modeloRes = await db.query(
"INSERT INTO modelo (nome, marca_id) VALUES ($1,$2) RETURNING id",
[mod.nome, marca_id]
)

const modelo_id = modeloRes.rows[0].id

// VERSÃO (usando anos como base)
const anos = await fetch(
`https://parallelum.com.br/fipe/api/v1/carros/marcas/${m.codigo}/modelos/${mod.codigo}/anos`
).then(r => r.json())

for(const a of anos){

await db.query(
"INSERT INTO versao (nome, modelo_id) VALUES ($1,$2)",
[a.nome, modelo_id]
)

}

}

}

console.log("Importação finalizada")

}

importar()