const db = require("../../shared/database/db");

/* =============================== */
/* 📄 LISTAR */
/* =============================== */
exports.listar = async (req, res) => {

  try {

    const permissoes = await db.query(`
      SELECT * FROM permissoes ORDER BY chave
    `);

    const roles = await db.query(`
      SELECT * FROM roles ORDER BY nome
    `);

    const rel = await db.query(`
      SELECT * FROM role_permissao
    `);

    res.json({
      permissoes: permissoes.rows,
      roles: roles.rows,
      relacoes: rel.rows
    });

  } catch (e) {

    console.error("ERRO LISTAR PERMISSÕES:", e);

    res.status(500).json({
      erro: "Erro ao listar permissões"
    });

  }

};

/* =============================== */
/* ➕ CRIAR ROLE */
/* =============================== */
exports.salvar = async (req, res) => {

  const client = await db.connect();

  try {

    const { nome, permissoes } = req.body;

    /* 🔥 VALIDAÇÃO */
    if (!nome) {
      return res.status(400).json({ erro: "Nome obrigatório" });
    }

    if (!Array.isArray(permissoes) || permissoes.length === 0) {
      return res.status(400).json({
        erro: "Permissões obrigatórias"
      });
    }

    await client.query("BEGIN");

    const roleRes = await client.query(`
      INSERT INTO roles (nome)
      VALUES ($1)
      RETURNING id
    `, [nome]);

    const role_id = roleRes.rows[0].id;

    for (const p of permissoes) {
      await client.query(`
        INSERT INTO role_permissao (role_id, permissao_id)
        VALUES ($1, $2)
        ON CONFLICT DO NOTHING
      `, [role_id, p]);
    }

    await client.query("COMMIT");

    res.json({ msg: "Role criada com sucesso" });

  } catch (e) {

    await client.query("ROLLBACK");

    console.error("ERRO CRIAR ROLE:", e);

    res.status(500).json({
      erro: "Erro ao salvar role"
    });

  } finally {
    client.release();
  }

};

/* =============================== */
/* ✏️ ATUALIZAR ROLE */
/* =============================== */
exports.atualizar = async (req, res) => {

  const client = await db.connect();

  try {

    const id = req.params.id;
    const { nome, permissoes } = req.body;

    /* 🔥 VALIDAÇÃO */
    if (!nome) {
      return res.status(400).json({ erro: "Nome obrigatório" });
    }

    if (!Array.isArray(permissoes) || permissoes.length === 0) {
      return res.status(400).json({
        erro: "Permissões obrigatórias"
      });
    }

    await client.query("BEGIN");

    await client.query(`
      UPDATE roles
      SET nome = $1
      WHERE id = $2
    `, [nome, id]);

    await client.query(`
      DELETE FROM role_permissao
      WHERE role_id = $1
    `, [id]);

    for (const p of permissoes) {
      await client.query(`
        INSERT INTO role_permissao (role_id, permissao_id)
        VALUES ($1, $2)
        ON CONFLICT DO NOTHING
      `, [id, p]);
    }

    await client.query("COMMIT");

    res.json({ ok: true });

  } catch (e) {

    await client.query("ROLLBACK");

    console.error("ERRO ATUALIZAR ROLE:", e);

    res.status(500).json({
      erro: "Erro ao atualizar role"
    });

  } finally {
    client.release();
  }

};

/* =============================== */
/* ❌ EXCLUIR ROLE */
/* =============================== */
exports.excluir = async (req, res) => {

  const client = await db.connect();

  try {

    const id = req.params.id;

    /* 🔥 PROTEÇÃO ROLE ADMIN */
    const role = await client.query(`
      SELECT nome FROM roles WHERE id = $1
    `, [id]);

    if (role.rows[0]?.nome === "ADMIN") {
      return res.status(400).json({
        erro: "Não é permitido excluir role ADMIN"
      });
    }

    await client.query("BEGIN");

    await client.query(`
      DELETE FROM role_permissao
      WHERE role_id = $1
    `, [id]);

    await client.query(`
      DELETE FROM roles
      WHERE id = $1
    `, [id]);

    await client.query("COMMIT");

    res.json({ ok: true });

  } catch (e) {

    await client.query("ROLLBACK");

    console.error("ERRO EXCLUIR ROLE:", e);

    res.status(500).json({
      erro: "Erro ao excluir role"
    });

  } finally {
    client.release();
  }

};