const db = require("../database/db")

async function seed(){

const marcas = [
"Toyota",
"Honda",
"Ford",
"Chevrolet",
"Volkswagen",
"Hyundai"
]

const modelos = [
"Corolla",
"Civic",
"Focus",
"Onix",
"Golf",
"HB20"
]

for(let i=1;i<=30;i++){

const marca =
marcas[Math.floor(Math.random()*marcas.length)]

const modelo =
modelos[Math.floor(Math.random()*modelos.length)]

const ano =
2015 + Math.floor(Math.random()*10)

const valor =
30000 + Math.floor(Math.random()*50000)

await db.query(

`INSERT INTO veiculo
(marca,modelo,ano,valor,status)
VALUES ($1,$2,$3,$4,'ativo')`,

[marca,modelo,ano,valor]

)

}

console.log("30 veículos inseridos")

process.exit()

}

seed()