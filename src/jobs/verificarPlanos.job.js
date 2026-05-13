const db =
  require("../shared/database/db")

async function verificarPlanos() {

  try {

    console.log(
      "⏰ Verificando planos..."
    )

    const result =
      await db.query(`
        UPDATE loja_plano
        SET status = 'vencido'
        WHERE
          status = 'ativo'
          AND ciclo_fim < NOW()
        RETURNING id, loja_id
      `)

    console.log(
      "📦 Planos vencidos:",
      result.rowCount
    )

  } catch (e) {

    console.error(
      "❌ ERRO JOB PLANOS:",
      e
    )
  }
}

module.exports = {
  verificarPlanos
}