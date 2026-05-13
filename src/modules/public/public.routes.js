const express = require("express");
const router = express.Router();
const publicAuth = require("./public.auth.controller");

/* ===============================
   IMPORTS CORRETOS
================================ */
const publicController = require("./public.controller");
const db = require("../../shared/database/db");

/* ===============================
   🔐 AUTH PUBLICO
================================ */
router.post("/auth/cadastro", publicAuth.cadastro);

/* ===============================
   🚗 VEÍCULOS
================================ */

// listagem
router.get("/veiculos", publicController.buscarVeiculos);

// detalhe
router.get("/veiculos/:id", publicController.buscarVeiculo);

/* ===============================
   🏪 LOJAS
================================ */
router.get("/lojas", publicController.lojas);

/* ===============================
   📊 CATÁLOGO
================================ */

router.get("/catalogo/marcas", async (req, res) => {
  const r = await db.query(`
    SELECT id, nome 
    FROM marca 
    ORDER BY nome
  `);

  res.json(r.rows);
});

router.get("/catalogo/modelos", async (req, res) => {
  const { marca_id } = req.query;

  const r = await db.query(`
    SELECT id, nome 
    FROM modelo
    WHERE marca_id = $1
    ORDER BY nome
  `, [marca_id]);

  res.json(r.rows);
});

router.get("/catalogo/versoes", async (req, res) => {
  const { modelo_id } = req.query;

  const r = await db.query(`
    SELECT id, nome 
    FROM versao
    WHERE modelo_id = $1
    ORDER BY nome
  `, [modelo_id]);

  res.json(r.rows);
});

/* ===============================
   🏪 LOJA DETALHE
================================ */

router.get("/loja/:id", async (req, res) => {

  try {

    const id = req.params.id;

    const lojaRes = await db.query(`
      SELECT 
        id,
        nome,
        cidade,
        estado,
        telefone,
        logo,
        banner,
        descricao
      FROM loja
      WHERE id=$1
    `, [id]);

    const loja = lojaRes.rows[0];

    if (!loja) {
      return res.status(404).json({ erro: "Loja não encontrada" });
    }

    const veiculosRes = await db.query(`
      SELECT 
        v.*,
        f.url as foto
      FROM veiculo v
      LEFT JOIN LATERAL (
        SELECT url
        FROM veiculo_foto f
        WHERE f.veiculo_id = v.id
        ORDER BY f.principal DESC, f.id ASC
        LIMIT 1
      ) f ON true
      WHERE v.loja_id=$1
      AND v.status = 'disponivel'
      ORDER BY v.valor DESC
    `, [id]);


const veiculos = veiculosRes.rows.map(v => ({
  ...v,
  foto:
    v.foto &&
    v.foto.startsWith("http")
      ? v.foto
      : v.foto
        ? `https://api.mfscars.com.br/uploads/${v.foto}`
        : `https://api.mfscars.com.br/uploads/sem-foto.jpg`
}));


    res.json({ loja, veiculos });

  } catch (e) {

    console.error(e);
    res.status(500).json({ erro: "Erro ao buscar loja" });

  }

});

/* ===============================
   💰 PLANOS (PUBLICO)
================================ */
router.get("/planos", async (req, res) => {

  try {

    const r = await db.query(`
      SELECT id, nome, preco, limite_veiculos, destaque
      FROM plano
      ORDER BY preco
    `);

    res.json(r.rows);

  } catch (e) {

    console.error(e);
    res.status(500).json({ erro: "Erro ao buscar planos" });

  }

});

/* ===============================
   📩 LEADS
================================ */
router.get("/leads", async (req, res) => {

  try {

    const { empresa_id } = req.query;

    if (!empresa_id) {
      return res.status(400).json({ erro: "empresa_id obrigatório" });
    }

    const r = await db.query(`
      SELECT
        l.*,
        v.marca,
        v.modelo
      FROM lead l
      LEFT JOIN veiculo v ON v.id = l.veiculo_id
      WHERE l.empresa_id=$1
      ORDER BY l.data DESC
    `, [empresa_id]);

    res.json(r.rows);

  } catch (e) {

    console.error(e);
    res.status(500).json({ erro: "Erro ao buscar leads" });

  }

});

router.get("/veiculos/similares/:id", async (req, res) => {
  try {
    const { id } = req.params;

    const r = await db.query(`
      SELECT 
        v.id,
        v.marca,
        v.modelo,
        v.valor,
        f.url as foto
      FROM veiculo v
      LEFT JOIN LATERAL (
        SELECT url
        FROM veiculo_foto f
        WHERE f.veiculo_id = v.id
        ORDER BY f.principal DESC, f.id ASC
        LIMIT 1
      ) f ON true
      WHERE v.id != $1
      AND v.status = 'disponivel'
      ORDER BY v.valor DESC
      LIMIT 6
    `, [id]);

const data = r.rows.map(v => ({
  ...v,
  foto:
    v.foto &&
    v.foto.startsWith("http")
      ? v.foto
      : v.foto
        ? `https://api.mfscars.com.br/uploads/${v.foto}`
        : `https://api.mfscars.com.br/uploads/sem-foto.jpg`
}));

    res.json(data);

  } catch (e) {
    console.error(e);
    res.status(500).json({ erro: "Erro ao buscar similares" });
  }
});

router.post("/lead", async (req, res) => {
  try {

    console.log("BODY:", req.body);

    const {
      nome,
      telefone,
      mensagem,
      empresa_id,
      loja_id,
      veiculo_id
    } = req.body;

    if (!nome || !telefone || !empresa_id || !loja_id) {
      return res.status(400).json({ erro: "Dados obrigatórios" });
    }

    await db.query(`
      INSERT INTO lead (
        nome,
        telefone,
        mensagem,
        empresa_id,
        loja_id,
        veiculo_id,
        origem,
        status,
        data
      )
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,NOW())
    `, [
      nome,
      telefone,
      mensagem || null,
      empresa_id,
      loja_id,
      veiculo_id || null,
      'site',       // 👈 origem padrão
      'novo'        // 👈 status padrão
    ]);

    res.json({ ok: true });

  } catch (e) {
    console.error("ERRO LEAD:", e);
    res.status(500).json({ erro: "Erro ao salvar lead" });
  }
});

module.exports = router;