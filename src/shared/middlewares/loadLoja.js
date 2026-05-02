const db = require("../database/db")

module.exports = async function loadLoja(req, res, next) {
  try {

    /* ===============================
       IGNORA ROTAS AUTH
    ============================== */
    if (req.path.startsWith("/auth")) {
      return next()
    }

    /* ===============================
       🔥 PRIORIDADE: HEADER
    ============================== */
    let loja_id = req.headers["x-loja-id"]

    /* ===============================
       FALLBACK: TOKEN (RARO)
    ============================== */
    if (!loja_id) {
      loja_id = req.user?.loja_id
    }

    /* ===============================
       🚨 LOJA É OBRIGATÓRIA
    ============================== */
if (!loja_id) {

  // 🔥 MASTER ou ADMIN → não bloqueia
  if (req.user?.master === true || req.user?.tipo === "admin") {
    return next()
  }

  return res.status(400).json({
    erro: "Loja não informada"
  })
}

    /* ===============================
       🔍 BUSCA LOJA
    ============================== */
    const lojaResult = await db.query(`
      SELECT *
      FROM loja
      WHERE id = $1
    `, [loja_id])

    if (!lojaResult.rows.length) {
      return res.status(404).json({
        erro: "Loja não encontrada"
      })
    }

    const loja = lojaResult.rows[0]

    /* ===============================
       🔐 VALIDA EMPRESA
    ============================== */
    if (
      Number(loja.empresa_id) !==
      Number(req.user?.empresa_id)
    ) {
      return res.status(403).json({
        erro: "Loja não pertence à sua empresa"
      })
    }

    /* ===============================
       ✅ SETA CONTEXTO
    ============================== */
    req.loja = loja
    req.loja_id = loja.id

    next()

  } catch (e) {
    console.error("ERRO LOAD LOJA:", e)

    return res.status(500).json({
      erro: "Erro ao carregar loja"
    })
  }
}