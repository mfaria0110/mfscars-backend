const db = require("../../shared/database/db");
const cache = new Map();

exports.getDashboard = async (empresaId, lojaId) => {

  const cacheKey = `${empresaId}_${lojaId}`;

  const cached = cache.get(cacheKey);

  if (cached && (Date.now() - cached.timestamp < 30000)) {
    return cached.data;
  }

  const result = await db.query(`
    SELECT
      (SELECT COUNT(*) FROM veiculo WHERE empresa_id = $1 AND loja_id = $2) AS veiculos,
      (SELECT COUNT(*) FROM venda WHERE empresa_id = $1 AND loja_id = $2) AS vendas,
      (SELECT COUNT(*) FROM lead WHERE empresa_id = $1 AND loja_id = $2) AS leads,
      (
        SELECT json_build_object(
          'nome', p.nome,
          'limite', p.limite_veiculos,
          'usados', lp.usados,
          'restante', (p.limite_veiculos - lp.usados),
          'alerta',
            CASE
              WHEN lp.usados >= p.limite_veiculos THEN 'limite'
              WHEN lp.usados >= p.limite_veiculos * 0.8 THEN 'quase'
              ELSE 'ok'
            END
        )
        FROM loja_plano lp
        JOIN plano p ON p.id = lp.plano_id
        WHERE lp.loja_id = $2
        AND lp.status = 'ativo'
        LIMIT 1
      ) AS plano
  `, [empresaId, lojaId]);

  const data = result.rows[0];

  cache.set(cacheKey, {
    data,
    timestamp: Date.now()
  });

  return data;
};