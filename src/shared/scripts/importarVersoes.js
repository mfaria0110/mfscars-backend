const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args))
const db = require("../database/db")

async function importarVersoes(){

// 🔥 limitar para não travar
const modelos = await db.query(`
SELECT m.id, m.nome, m.marca_id, ma.nome as marca_nome
FROM modelo m
JOIN marca ma ON ma.id = m.marca_id
LIMIT 1000
`)

for(const modelo of modelos.rows){

console.log(`Importando versões: ${modelo.nome}`)

// 🔥 buscar marcas FIPE
const resMarcas = await fetch("https://parallelum.com.br/fipe/api/v1/carros/marcas")
const marcasFipe = await resMarcas.json()

const marcaFipe = marcasFipe.find(m => m.nome === modelo.marca_nome)

if(!marcaFipe){
console.log("Marca não encontrada:", modelo.marca_nome)
continue
}

// 🔥 buscar modelos FIPE
const resModelos = await fetch(
`https://parallelum.com.br/fipe/api/v1/carros/marcas/${marcaFipe.codigo}/modelos`
)

const dataModelos = await resModelos.json()

const modeloFipe = dataModelos.modelos.find(m => m.nome === modelo.nome)

if(!modeloFipe){
console.log("Modelo não encontrado:", modelo.nome)
continue
}

// 🔥 buscar versões (anos FIPE)
const resVersoes = await fetch(
`https://parallelum.com.br/fipe/api/v1/carros/marcas/${marcaFipe.codigo}/modelos/${modeloFipe.codigo}/anos`
)

const versoes = await resVersoes.json()

for(const v of versoes){

await db.query(
`INSERT INTO versao (nome, modelo_id, codigo_fipe)
 VALUES ($1,$2,$3)
 ON CONFLICT (codigo_fipe, modelo_id) DO NOTHING`,
[v.nome, modelo.id, v.codigo]
)

}

}

console.log("Versões importadas")

}

importarVersoes()