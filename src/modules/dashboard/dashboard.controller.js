const db = require("../../shared/database/db");

exports.dados = async (req, res) => {

  try {

    /* ===============================
       🏪 LOJA (OBRIGATÓRIO)
    ============================== */
    const lojaIdRaw = req.headers["x-loja-id"];
    const lojaId = Number(lojaIdRaw);

    if (!lojaId || isNaN(lojaId)) {
      return res.status(400).json({
        erro: "Selecione uma loja válida"
      });
    }

    console.log("📊 DASHBOARD loja:", lojaId);

    /* ===============================
       🚗 VEÍCULOS
    ============================== */
    const veiculos = await db.query(`
    SELECT COUNT(*) AS total
    FROM veiculo
    WHERE status = 'disponivel'
    AND loja_id = $1
    `, [lojaId])

    const vendas = await db.query(`
      SELECT COUNT(*) AS total
      FROM venda
      WHERE status = 'FINALIZADA'
      AND loja_id = $1
    `, [lojaId])

    const leads = await db.query(`
      SELECT COUNT(*) AS total
      FROM lead
      WHERE loja_id = $1
    `, [lojaId])

    /* ===============================
       📦 PLANO
    ============================== */
    let plano = null;

    const planoRes = await db.query(`
SELECT 
  p.nome,
  p.limite_veiculos
FROM loja_plano lp
JOIN plano p
  ON p.id = lp.plano_id
WHERE
  lp.loja_id = $1
  AND lp.status = 'ativo'
ORDER BY lp.data_inicio DESC
LIMIT 1
    `, [lojaId]);

    if (planoRes.rows.length) {

      const p = planoRes.rows[0];

      const limite =
        Number(p.limite_veiculos || 0)

const usados_veiculos =
  Number(
    veiculos.rows[0].total || 0
  )

const restante =
  Math.max(
    0,
    limite - usados_veiculos
  )

      let alerta = null;

      if (restante <= 0) alerta = "limite";
      else if (restante <= 3) alerta = "quase";

      plano = {
        nome: p.nome,
        limite,
usados_veiculos,
        restante,
percentual: limite > 0
  ? Math.round(
      (usados_veiculos / limite) * 100
    )
  : 0,
        alerta
      };
    }

    /* ===============================
       📤 RESPONSE
    ============================== */
res.json({
  veiculos: Number(veiculos.rows[0].total),
  leads: Number(leads.rows[0].total),
  vendas: Number(vendas.rows[0].total),
  plano
})

  } catch (e) {

    console.error("❌ ERRO DASHBOARD:", e);

    res.status(500).json({
      erro: "Erro ao carregar dashboard"
    });

  }

};