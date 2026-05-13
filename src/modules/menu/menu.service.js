const db = require("../../shared/database/db")

exports.listar = async () => {
  const r = await db.query(`
    SELECT *
    FROM menus
    WHERE ativo = true
    ORDER BY ordem
  `)

  return r.rows
}