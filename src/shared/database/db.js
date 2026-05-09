const { Pool } = require("pg")

const pool = new Pool({

  connectionString:
    process.env.DATABASE_URL,

  ssl: {
    rejectUnauthorized: false
  },

  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000
})

pool.query(
  "SELECT NOW()",
  (err, res) => {

    if (err) {

      console.error(
        "❌ ERRO CONEXÃO BANCO:",
        err
      )

    } else {

      console.log(
        "✅ BANCO CONECTADO:",
        res.rows[0]
      )
    }
  }
)

pool.on("connect", () => {
  console.log(
    "🔌 Nova conexão com o banco"
  )
})

pool.on("error", (err) => {
  console.error(
    "💥 ERRO NO POOL:",
    err
  )
})

module.exports = pool