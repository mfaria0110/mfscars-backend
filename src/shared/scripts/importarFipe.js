const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args))
const db = require("../database/db")

async function importarMarcas(){

const res = await fetch("https://parallelum.com.br/fipe/api/v1/carros/marcas")
const marcas = await res.json()

for(const m of marcas){

await db.query(
"INSERT INTO marca (nome) VALUES ($1) ON CONFLICT DO NOTHING",
[m.nome]
)

}

console.log("Marcas importadas")

}

importarMarcas()