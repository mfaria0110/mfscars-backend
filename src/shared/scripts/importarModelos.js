const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args))
const db = require("../database/db")

async function importarModelos(){

// 🔥 pegar algumas marcas (limite pra não travar)
const marcas = await db.query(`
SELECT * FROM marca 
WHERE nome IN (
  'Citroën',
  'Fiat',
  'GM - Chevrolet',
  'Hyundai',
  'Jeep',
  'Kia Motors',
  'Land Rover',
  'Nissan',
  'Peugeot',
  'VW - VolksWagen'
)
`)

for(const marca of marcas.rows){

console.log("Importando modelos da marca:", marca.nome)

// 🔥 buscar código FIPE da marca
const resMarcas = await fetch("https://parallelum.com.br/fipe/api/v1/carros/marcas")
const marcasFipe = await resMarcas.json()

const marcaFipe = marcasFipe.find(m => m.nome === marca.nome)

if(!marcaFipe){
console.log("Marca não encontrada na FIPE:", marca.nome)
continue
}

// 🔥 buscar modelos
const resModelos = await fetch(
`https://parallelum.com.br/fipe/api/v1/carros/marcas/${marcaFipe.codigo}/modelos`
)

const data = await resModelos.json()

for(const m of data.modelos){

await db.query(
`INSERT INTO modelo (nome, marca_id)
 VALUES ($1,$2)
 ON CONFLICT DO NOTHING`,
[m.nome, marca.id]
)

}

}

console.log("Modelos importados")

}

importarModelos()